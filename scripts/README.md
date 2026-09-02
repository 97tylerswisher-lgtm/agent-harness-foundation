# scripts

Four Windows PowerShell 5.1 scripts. No modules, no Node, no extensions. Each prints plain
lines and returns an exit code. Run any of them as
`powershell -NoProfile -ExecutionPolicy Bypass -File scripts\<name>.ps1`.

The scripts are optional. The steering, skills, agents, and handoff files are plain markdown
and work without them: a clone with a committed `.kiro/` folder is complete as is. The
scripts remove manual copying, manual grepping, and manual fixture writing; they add no
behavior the markdown depends on.

## install-kiro.ps1

Mirrors the harness-neutral source folders into the folders the Kiro IDE reads:
`steering/*.md` to `.kiro/steering/`, `skills/**` to `.kiro/skills/`, and `agents/*.md` to
`.kiro/agents/`. A file removed from a source folder is removed from its mirror. The script
never touches `.kiro/specs/` or `.kiro/settings/`. Running it twice copies nothing the
second time. `-Check` compares instead of copying and prints each path that differs, is
missing, or is extra. `-Root <path>` targets another repo.

Usage: `scripts\install-kiro.ps1 [-Check] [-Root <repo path>]`

Exit codes: 0 mirror up to date or no differences; 1 `-Check` found a difference; 2 the
repo root could not be resolved.

## check-redaction.ps1

Scans every file under the repo for the literal, case-sensitive terms listed in
`banned-terms.txt` at the repo root and prints each hit as `path:line: term`. Blank lines and
`#` comment lines in the list are ignored. The scan skips `.git/`, `banned-terms.txt` itself,
and files with the extensions png, jpg, pdf, xlsx, xlsm, zip. Run it before every commit. The
work repo replaces the public list with its own.

Usage: `scripts\check-redaction.ps1 [-Root <repo path>]`

Exit codes: 0 no hits; 1 at least one hit; 2 `banned-terms.txt` missing or empty.

## distill-fixture.ps1

Runs outside the IDE on a real delimited text file and writes two public-safe outputs:
`<name>.schema-card.md` (delimiter, encoding, header line count, row count, and per column
the inferred type, an example shape such as `-9.9999` or `XX_99`, numeric min and max, and
decimal places) and `<name>.fixture.<ext>` (the header structure plus `-Rows` synthetic rows:
numerics drawn inside the observed range, text tokens re-lettered in the same shape, dates
shifted in the same format). No real value is copied verbatim. Only the two outputs enter the
repo, under the spec's `cards/` and `fixtures/` folders. See the `data-distillation` skill for
when to run it and what to do with the outputs.

Usage: `scripts\distill-fixture.ps1 -InputFile <real file> -OutDir <folder> [-Rows 20] [-Seed 1]`

Exit codes: 0 both outputs written and their paths printed; 1 input missing, empty, binary, or
without data rows; 2 output folder or write failed.

## check-spec.ps1

Checks one spec folder before the model shows it to the operator. Prints one line per check
as `OK`, `FAIL`, or `PENDING` with the check number, the file, and a one-line reason. The
checks: (1) `goal-contract.md` has the six field headings from `goal-definition`
(`## 1. The judge` through `## 6. Verification`); (2) `requirements.md` has an Introduction,
`### Requirement N` blocks each with a User Story and Acceptance Criteria, and every criterion
is numbered in sequence and contains `THE SYSTEM SHALL` or `THE SESSION SHALL`; (3) `design.md`
has the seven skeleton sections in order; (4) every `_Requirements:_` citation in `tasks.md`
resolves, every criterion is cited by a task (orphans are listed), every task has a citation
line, and one task is the human gate; (5) the three cards and at least one fixture exist, or
the spec is phase 1 only (the line `Phase: requirements` in the first ten lines of
`goal-contract.md`), in which case missing cards print `PENDING`; (6) no line in the folder
contains a term from `banned-terms.txt`. The script edits nothing.

Usage: `scripts\check-spec.ps1 -Spec .kiro\specs\<name>`

Exit codes: 0 no `FAIL`; 1 at least one `FAIL`; 2 the spec folder does not exist.
