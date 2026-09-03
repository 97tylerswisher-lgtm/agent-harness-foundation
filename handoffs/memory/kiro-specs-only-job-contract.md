---
name: kiro-specs-only-job-contract
description: A Kiro spec folder under .kiro/specs/<name>/ is the only job contract; no second plan or contract format exists.
type: project
---

A job's contract is its spec folder at `.kiro/specs/<name>/` (goal contract, requirements,
design, tasks). There is no second contract format.

Why: one contract in one place keeps the tasks, their requirement citations, and the status
ledger checkable by `scripts/check-spec.ps1` and by the operator.

How to apply: when a job needs a plan, a task list, or a definition of done, write it into the
spec with `spec-authoring`. Do not start a parallel plan file, a to-do list in the handoff, or
a contract inside a brief.
