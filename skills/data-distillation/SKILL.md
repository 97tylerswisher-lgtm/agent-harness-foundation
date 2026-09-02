---
name: data-distillation
description: Step-zero protocol for any job whose real data must never enter the IDE. Produces the four artifacts the model is allowed to see (schema card, synthetic fixtures, edge-case catalog, interface card) under .kiro/specs/<name>/cards/ and fixtures/, and gives the operator the classification checklist to run before anything enters. Use it when a spec touches files, exports, databases, or existing scripts whose contents are controlled, proprietary, or personal; when the model needs the shape of data it cannot see; when scripts/distill-fixture.ps1 is about to be run; or whenever the model is tempted to guess a file format. Keywords - data boundary, schema card, synthetic fixture, edge cases, interface card, distill-fixture, controlled data, step zero, do not guess the shape.
---

# Data distillation

The model must write code that handles real file formats it never sees. It needs the shape of
the data and never the values. This skill is the checklist that gets the shape into the IDE
with nothing else attached. The operator is the judge of every item that enters.

The rule lives in `steering/40-data-boundary.md`. This skill is the procedure. The script
`scripts/distill-fixture.ps1` is the knowable transform.

## When to use

- A spec's Mechanism section names a file whose real contents cannot be shown to the model.
- An existing script (VBA, MATLAB, PowerShell, SQL) must be called and its real body cannot be
  pasted.
- The model is about to write a parser and does not have a card for the format.
- The operator wants to add a file to the spec folder and is not sure it is safe.

## The four cards

Only these four artifacts describe the data inside the IDE. Nothing else about the data
enters.

| Card | What it contains | Who makes it | Template |
| --- | --- | --- | --- |
| Schema card | Per file type: filename pattern, encoding, delimiter, header rows, columns with type and unit, row count range, trailing blocks. Sensitive column names replaced by generic ones. | `scripts/distill-fixture.ps1` drafts it from a real file; the operator edits and approves. | `references/schema-card.md` |
| Synthetic fixture | A file with the real shape and fake values. Twenty rows. Same delimiter, header, encoding, and column order as the real file. | `scripts/distill-fixture.ps1` generates it; the operator reads every line before it enters. | none; the script writes the file |
| Edge-case catalog | Every variation the existing code already handles: extra header line, missing column, different delimiter, trailing summary block, empty file, duplicate rows. One row per case with how it is detected and what the correct handling is. | The operator, from memory and from reading the existing code outside the IDE. | `references/edge-case-catalog.md` |
| Interface card | Entry points of existing scripts as signatures only: name, arguments with types, return or output, side effects, how it is invoked. Never bodies. | The operator, from the existing code outside the IDE. | `references/interface-card.md` |

Each card lives at `.kiro/specs/<name>/cards/<card-name>.md`. Fixtures live at
`.kiro/specs/<name>/fixtures/<generic-name>.<ext>`. One schema card per spec
(`cards/schema-card.md`) with one section and one Columns table per file type; one fixture per
file type; one edge-case catalog and one interface card per spec.

## The classification checklist

The operator runs this over every file before it enters the IDE, including files the script
produced. One "yes" means stop: the file does not enter until the item is removed.

1. Does it contain a real value from a real record (a measurement, a quantity, a date tied to
   a real event, a serial number)?
2. Does it contain a real path (a drive letter, a share name, a folder that exists at work)?
3. Does it contain a real name (a person, a customer, a vendor, a site)?
4. Does it contain a program, project, part, or contract identifier?
5. Does it contain anything marked controlled, export-restricted, proprietary, or internal by
   the organization's policy?
6. Does it contain a script body, a formula, or a query, rather than a signature?
7. Does it contain a term listed in `banned-terms.txt`? Run `scripts/check-redaction.ps1`.

If unsure on any item, the answer is yes. Ask the person who owns the classification. The
model never runs this checklist on the operator's behalf; it can only remind the operator to
run it.

## Using distill-fixture.ps1

The script runs outside the IDE, on the operator's machine, against a real file. It never runs
from inside a Kiro session and it is never given a path that the IDE can see.

1. Outside the IDE, from the repo root, run:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\distill-fixture.ps1 `
       -InputFile <real file> -OutDir <folder outside the repo> -Rows 20
   ```

2. The script writes two files to the output folder:
   - `<name>.schema-card.md`: a property table (encoding, delimiter, header line count, data
     row count, column count) and a Columns table with Index, Type, Shape, Min, Max,
     Decimals, Empty, and Notes per column. Columns are numbered, not named. The card
     records the observed numeric min and max per column.
   - `<name>.fixture.<ext>`: the input's header lines with letters and digits scrambled,
     followed by 20 synthetic rows in the same delimiter and column order.
3. The operator opens both files and reads every line. Values that the generator failed to
   replace are replaced by hand. A min or max that is sensitive on its own is widened by
   hand.
4. The operator turns the draft into `cards/schema-card.md` using the template at
   `references/schema-card.md`: one section per file type, with a generic name chosen by
   hand for every column index. Sensitive header text in the fixture is replaced with the
   same generic names.
5. The operator runs the classification checklist on both files.
6. Only then does the operator copy the card into `.kiro/specs/<name>/cards/` and the fixture
   into `fixtures/`.

The script handles delimited text. A format it does not handle (binary, spreadsheet, database
export) gets a hand-written schema card from the template and a hand-made fixture. The
checklist applies the same way.

## Rules for the model

1. Ask for a missing card by name. If the Mechanism section names a file with no schema card,
   say "I need the schema card for <file role>" and stop. Do not infer columns from the file
   name, the job description, or a similar format seen elsewhere.
2. Write parsers against the fixture and the edge-case catalog only. A parser that passes on
   the fixture and covers every catalog row is done; the real file is the operator's test,
   run outside the IDE.
3. Call existing scripts through the interface card only. If the card lacks an argument the
   job needs, ask for the card to be extended. Do not guess argument order.
4. Never request a real file, a real path, or a "small sample". The request itself is the
   boundary violation.
5. When the operator pastes something that fails the checklist, say which item it fails and do
   not use it. Do not quote it back.
6. Keep fixtures small and boring. Twenty rows is the default. A fixture that needs more rows
   to show an edge case gets a second fixture named for the case.

## Order of work

Step zero runs before `spec-authoring` phase 2, because the Mechanism section cannot be written
without the schema card.

1. The operator lists the file types and existing scripts the job touches.
2. For each file type: the script drafts the schema card and fixture outside the IDE; the
   operator reviews, classifies, and adds them.
3. The operator fills the edge-case catalog from the existing code's history.
4. The operator fills the interface card from the existing code's entry points.
5. The model reads the four cards and confirms in a prose block that every hop in the planned
   mechanism has a named format and a named entry point. Any gap is a request for a card.
6. `spec-authoring` continues.

## For a weaker model

- The cards are the only source of truth about the data. If it is not on a card, you do not
  know it.
- When you notice you are guessing a column name, a delimiter, or an argument, stop and ask
  for the card.
- Never ask for the real file. Ask for the card.
- The operator decides what enters. You remind; you do not decide.

## Related skills

- `spec-authoring` consumes the cards in its Mechanism, Invocations, and Data boundary
  sections.
- `goal-definition` field 5 (do-not-touch) names the data boundary this skill enforces.
- `ask-operator-gate` gives the shape of the request for a missing card.
