# Retro register

> One row per open improvement or standing flag. Add a row at any wrap. Close a row by
> changing its disposition to CLOSED with a one-line evidence pointer; do not delete rows.

| ID | Improvement or flag | Seen | Disposition |
| --- | --- | --- | --- |
| R0-1 | Scripts are tested on the authoring machine only. Verify `check-redaction.ps1`, `distill-fixture.ps1`, and `check-spec.ps1` at work; log any execution-policy or encoding failure here. | S0 | OPEN |
| R0-2 | `tasks.md` syntax: Kiro's exact checkbox and sub-task format is not published. Compare the example's `tasks.md` with one Kiro generates and adjust the `spec-authoring` skeleton. | S0 | OPEN |
| R0-3 | `.kiro/skills/agent-orchestration-workflows/SKILL.md` is 15 KB against the 12 KB skill rule in `.kiro/steering/30-structure.md`. Trim the pattern table's rationale column or move it to `references/`. | S0 | OPEN |
| R0-4 | The worked example's MATLAB step is unverified: the authoring machine's MATLAB license had expired, so `make_report.m` never ran. First run at work: execute task 10 of the example's `tasks.md` and record the result in the status ledger of its `design.md`. | S0 | OPEN |
