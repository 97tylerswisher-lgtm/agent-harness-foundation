Copy this file to `.kiro/specs/<kebab-name>/tasks.md`. Replace every angle-bracket placeholder.
One task per hop of the Mechanism section in `design.md`, in execution order. Delete these
instruction lines when done.

Kiro's exact syntax for sub-tasks and optional tasks is not published. This shape uses the
documented pieces: a markdown checklist and `_Requirements: n.n_` back-references. On first use,
let Kiro generate one `tasks.md` in a scratch spec, compare, and adjust this skeleton once.

# Tasks: <job name>

- [ ] 1. <Task name: one file or one behavior>
  - <Concrete step>
  - <Concrete step>
  - <The check the model runs to confirm this task, for example "row count equals 20">
  - _Requirements: <1.1, 1.2>_

- [ ] 2. <Task name>
  - <Concrete step>
  - <Concrete step>
  - <The check>
  - _Requirements: <2.1>_

- [ ] 3. <Task name>
  - <Concrete step>
  - <The check>
  - _Requirements: <2.2, 3.1>_

- [ ] <n>. Human gate: stop and show the operator <the artifact>
  - Do not mark this task done. The operator marks it.
  - _Requirements: <the scope-fence criterion for the gate>_

- [ ] <n+1>. <Task that runs only after the operator approves the gate, or delete this item>
  - Input: the operator's recorded approval in the status ledger
  - <Concrete step>
  - _Requirements: <n.n>_

## Orphan check

Fill in before showing the operator.

- Requirement numbers with no task: <list, or "none">
- Tasks with no requirement line: <list, or "none">
