# Spec phases: from goal contract to wrap

Source of truth: `.kiro/skills/spec-authoring/SKILL.md` (Rules; Phase 1 to Phase 3) and
`.kiro/steering/00-session-opener.md` (The flow every project follows, rows Build to Wrap).
This chart restates them; the sources bind.

```mermaid
flowchart TD
  start(["Start: goal-definition has closed"])
  gc[/"goal-contract.md, copied into<br/>.kiro/specs/name/ unchanged"/]
  req["Phase 1. Write requirements.md:<br/>one story per done-when criterion,<br/>numbered EARS criteria"]
  show1["Rule 6. Run scripts/check-spec.ps1,<br/>fix every FAIL, show requirements.md"]
  ok1{"Operator approves?"}
  fix1["Revise requirements.md<br/>per the operator's changes"]
  cards{"Cards and fixtures present<br/>in cards/ and fixtures/?"}
  zero["Step zero. Get the cards<br/>(data-distillation)"]
  des["Phase 2. Write design.md:<br/>seven sections, Human gate first (rule 3)"]
  show2["Rule 6. Run scripts/check-spec.ps1,<br/>fix every FAIL, show design.md"]
  ok2{"Operator approves?"}
  fix2["Revise design.md<br/>per the operator's changes"]
  tasks["Phase 3. Write tasks.md:<br/>one task per hop, gate as its own task,<br/>orphan check (rule 5)"]
  show3["Rule 6. Run scripts/check-spec.ps1,<br/>fix every FAIL, show tasks.md"]
  ok3{"Operator approves?"}
  fix3["Revise tasks.md<br/>per the operator's changes"]
  left{"Unchecked tasks left?"}
  isgate{"Is the next task<br/>the human gate?"}
  gate["Stop and show the operator.<br/>The operator marks the gate task (rule 7)"]
  approval[/"The operator's recorded approval"/]
  run["Run the next task<br/>(agent-orchestration-workflows)"]
  ledger["Rule 7. Update the task's Status ledger<br/>row in design.md with the evidence path"]
  chk["Run scripts/check-spec.ps1,<br/>fix every FAIL"]
  changed{"Rule 8. Did a requirement<br/>change mid-build?"}
  nodata["Rule 2. No real data in any spec file;<br/>only cards and fixtures describe it"]
  wrap["Wrap. Record the ledger state<br/>in the handoff (context-checkpoint)"]
  fin(["End"])
  start --> gc
  gc --> req
  req --> show1
  show1 --> ok1
  ok1 -- "no" --> fix1
  fix1 --> show1
  ok1 -- "yes" --> cards
  cards -- "no" --> zero
  zero --> cards
  cards -- "yes" --> des
  des --> show2
  show2 --> ok2
  ok2 -- "no" --> fix2
  fix2 --> show2
  ok2 -- "yes" --> tasks
  tasks --> show3
  show3 --> ok3
  ok3 -- "no" --> fix3
  fix3 --> show3
  ok3 -- "yes" --> left
  left -- "no" --> wrap
  left -- "yes" --> isgate
  isgate -- "yes" --> gate
  gate --> approval
  approval --> left
  isgate -- "no" --> run
  run --> ledger
  ledger --> chk
  chk --> changed
  changed -- "yes" --> req
  changed -- "no" --> left
  nodata -.-> req
  nodata -.-> des
  wrap --> fin
```

## How to read

- Rectangles are actions, diamonds are decisions, stadiums are the start and end, and
  parallelograms are files or verdicts; the dotted node is a standing rule on the phases it
  touches.
- Each of the three phases ends in the same stop: run the check script, show the file, wait;
  a "no" loops on the operator's changes, never on a guess.
- The cards question sits before design because the Mechanism section cannot be written
  without the schema card; the source says to stop and ask, not to invent columns.
- The build loop runs one task at a time and returns to "Unchecked tasks left?"; the human gate
  is one of those tasks and only the operator marks it done.
- The sources do not say who decides that a task's evidence is sufficient before the ledger
  row is updated; the chart assumes the session does and the operator sees it at the gate.
