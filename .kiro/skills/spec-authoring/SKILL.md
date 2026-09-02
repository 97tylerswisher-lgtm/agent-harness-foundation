---
name: spec-authoring
description: Turn a finished goal contract (the output of goal-definition) into a Kiro spec folder at .kiro/specs/<kebab-name>/ with goal-contract.md, requirements.md (user stories with numbered EARS acceptance criteria), design.md (Overview, Mechanism, Invocations, Data boundary, Human gate, Verification, Status ledger), and tasks.md (a checkbox list where every task cites requirements). Use it after goal-definition closes and before any build task starts, or when an existing spec folder must be repaired. Keywords - spec, requirements, EARS, design.md, tasks.md, user story, acceptance criteria, status ledger, human gate.
---

# Spec authoring

A spec is the job contract. It turns a goal contract into three files Kiro can execute and the
operator can approve one phase at a time.

## When to use

- `goal-definition` has produced `.kiro/specs/<name>/goal-contract.md` with all six fields filled
  and no open decision left.
- A job is about to be built and nobody has written what "done" means in checkable form.
- An existing spec folder is missing a file or its tasks no longer cite requirements.

## The output

One folder per job at `.kiro/specs/<kebab-name>/`. The name is lowercase words joined by
hyphens and names the job, not the tool (`weekly-report-from-export`, not `matlab-script`).

| File | What it holds | Skeleton |
| --- | --- | --- |
| `goal-contract.md` | The goal contract, copied in unchanged | none; copy the file |
| `requirements.md` | User stories, each with numbered EARS acceptance criteria | `references/requirements-skeleton.md` |
| `design.md` | Seven fixed sections, from mechanism to status ledger | `references/design-skeleton.md` |
| `tasks.md` | A checkbox list; every task cites requirement numbers | `references/tasks-skeleton.md` |
| `cards/`, `fixtures/` | The data-distillation artifacts, if the job touches data | see `data-distillation` |
| `references/` | Optional. Research findings the spec depends on, one `<topic>.md` per finding | see `self-learning-research` |

## Rules

1. One spec per job. A job with two judges is two specs.
2. A spec never contains real data. No real values, real paths, real names, real identifiers.
   Only the cards and fixtures from `data-distillation` describe the data. If a requirement
   needs an example value, invent one and say it is invented.
3. The human gate is named before any task is written. Write the Human gate section of
   `design.md` first, then the tasks. A task that would run past the gate is not written.
4. Tasks are small. Each task changes one file or one behavior, has a check the model can run,
   and ends with the requirement numbers it satisfies.
5. Every requirement number appears in at least one task. Every task cites at least one
   requirement. An orphan on either side means the spec is not finished.
6. Each phase stops for the operator. Write `requirements.md`, show it, wait. Then `design.md`,
   show it, wait. Then `tasks.md`, show it, wait.
7. After each task runs, update its Status ledger row in `design.md` with the evidence path.
   Never mark the human gate task done; the operator marks it.
8. A requirement that changes mid-build goes back to phase 1. Do not patch a task to satisfy a
   requirement that was never written.

## Phase 1. Requirements

Source: fields 1 (judge), 2 (done-when), and 5 (do-not-touch) of the goal contract.

1. Copy `goal-contract.md` into the spec folder.
2. Write one introduction paragraph: what the job produces and who consumes it.
3. Turn each done-when criterion into a user story: "As <role>, I want <capability>, so that
   <outcome>." One story per criterion. Number the stories 1, 2, 3.
4. Under each story, write acceptance criteria in EARS form, numbered by story: 1.1, 1.2, 2.1.
   The form is fixed:

   ```text
   WHEN <condition or event> THE SYSTEM SHALL <observable behavior>
   ```

   Each criterion names one condition and one behavior that a person can observe or a check
   can verify. "THE SYSTEM SHALL work correctly" is not a criterion. "WHEN the input file has
   an extra header line THE SYSTEM SHALL skip it and parse the remaining rows" is.
5. Add a story for the do-not-touch fence, with criteria of the form "WHEN <forbidden
   condition> THE SYSTEM SHALL stop and report". The data boundary and the human gate each get
   one criterion here.
6. Show the file to the operator. Wait for approval before phase 2.

After hand edits, check the file for conflicting criteria. Use Kiro's "Analyze Requirements"
action if the Kiro version offers it; otherwise re-read the requirements yourself.

## Phase 2. Design

Source: fields 3 (minimum inputs), 4 (roles), and 6 (verification) of the goal contract, plus
the cards from `data-distillation`.

`design.md` has seven sections in a fixed order. Do not add, rename, or reorder them.

| Section | What goes in it |
| --- | --- |
| Overview | Three sentences: input, output, judge. |
| Mechanism | The literal data path: source file, each transform, output file. One line per hop. Name the file format at each hop from the schema card. |
| Invocations | Every external command in its exact form, one fenced block each. Include the working directory and the expected exit code. A command not written here is not run. |
| Data boundary | What enters the IDE: only `cards/` and `fixtures/`. Where the real data lives (by role, not by path) and that the runner reads it only outside the IDE. |
| Human gate | Who reviews what, in which form, and the exact step where automation stops. Write this section before `tasks.md`. |
| Verification | The command the operator runs, the artifact it produces, the check that passes. Say which check gates (calibrated) and which only annotates. |
| Status ledger | A table with columns Step, Status, Evidence. Status is `not started`, `in progress`, `done`, or `blocked`. Evidence is a path or a command result. |

The Mechanism section exposes a missing card. If a hop cannot be named, stop and ask for it.

Show the file to the operator. Wait for approval before phase 3.

## Phase 3. Tasks

Source: the Mechanism and Invocations sections of `design.md`, walked in order.

1. Write one task per hop of the mechanism, in execution order.
2. Each task is a checkbox item with a number, sub-items for the concrete steps, and a trailing
   requirements line:

   ```markdown
   - [ ] 1. Parse the export fixture into a row table
     - Read `fixtures/export-sample.txt` with the delimiter from the schema card
     - Skip the extra header line listed in the edge-case catalog
     - Write a check that the row count equals 20
     - _Requirements: 1.1, 1.2_
   ```

3. Put the human gate as its own task with one sub-item: "stop and show the operator". Tasks
   after the gate take the operator's recorded approval as an input.
4. Run the orphan check from rule 5.

Kiro's exact `tasks.md` syntax for sub-tasks and optional tasks is not published. The shape
above uses the documented pieces (a markdown checklist and `_Requirements: n.n_`
back-references). On first use, let Kiro generate one `tasks.md` in a scratch spec, compare,
and adjust the skeleton once. Record the adjustment in `handoffs/LOOP_LOG.md`.

Show the file to the operator. Wait for approval before executing task 1.

## For a weaker model

- Do the phases in order: goal contract, requirements, design, tasks. Do not start with code.
- Stop at the end of each phase and show the operator the file. Do not continue on your own.
- If a section of `design.md` cannot be filled, say which one and what is missing. Do not
  fill it with a guess.
- If the data shape is unknown, ask for the card by name (`data-distillation`). Do not invent
  columns.
- Copy the skeletons from `references/`. Replace every angle-bracket placeholder. A
  placeholder left in the file means the phase is not finished.

## Related skills

- `goal-definition` produces the goal contract this skill consumes.
- `data-distillation` produces the cards and fixtures the Mechanism and Data boundary sections
  cite.
- `ask-operator-gate` gives the shape of the phase-end stop.
- `agent-orchestration-workflows` runs the tasks once the operator approves `tasks.md`.
- `eval-design` decides whether a verification check may gate or only annotate.
- `context-checkpoint` records the status ledger state in the handoff at wrap.
