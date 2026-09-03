# Delegate or inline: the orchestrator's decision tree

Source of truth: `.kiro/skills/agent-orchestration-workflows/SKILL.md` (The delegate-or-inline
decision). This chart restates it; the source binds.

```mermaid
flowchart TD
  A(["A need appears: a file to read,<br/>a process to run, research, a sweep"])
  R0{"Rule 0<br/>spend, destructive, public,<br/>or secret-touching?"}
  E0["Escalate per the steering rules.<br/>Not decided by this tree."]
  R1{"Rule 1<br/>judgment, verification,<br/>or the decision-fold?"}
  I1["Do it myself.<br/>Never delegate the plan, the decision,<br/>the audit of a worker, or the fold.<br/>At volume: spot-check 2-3 raw items."]
  R2{"Rule 2<br/>a knowable transform?"}
  I2["Write or run code.<br/>No agent, no inline reasoning."]
  R3{"Rule 3<br/>one grep, one read under ~2k tokens,<br/>a known file:line edit:<br/>cheaper to do than to write the brief?"}
  I3["Do it inline."]
  R4["Rule 4<br/>estimate forced absorption before reading:<br/>file bytes / 4"]
  R4a{"under ~5k tokens?"}
  I4["Inline.<br/>A spawn costs ~1k of my window<br/>plus latency and a retry risk."]
  R4b{"~5k to ~20k rather than over ~20k?"}
  R4c{"does the decision need<br/>the raw detail?"}
  S["Spawn a worker"]
  R5a{"Rule 5, who: does an<br/>.kiro/agents/ role fit the job?"}
  N5["Spawn it by name"]
  G5["Inline brief on the closest generic role<br/>(code-worker for builds,<br/>research-worker for reading)"]
  MINT["Brief hand-written 2-3x:<br/>mint it (agent-authoring)"]
  R5{"Rule 5, how many: the same read<br/>or process over 3+ similar items?"}
  F["Fan out: one worker per item<br/>or a pipeline, capped return each"]
  W["One worker, capped return,<br/>numbered contract echoed back"]
  R6{"Rule 6<br/>total returns over ~15k tokens,<br/>or only aggregates needed?"}
  SY["Insert a synthesizer worker.<br/>Absorb its digest plus 2-3 raw returns<br/>I spot-check myself."]
  PS[/"Pick the strategy:<br/>see spawn-strategy-router chart"/]
  AB["Absorb the returns.<br/>Verify by artifact, never by report."]
  M7["Rule 7, standing: past ~50% of the window<br/>halve every threshold; past ~75% delegate<br/>everything but rules 1-3 and checkpoint"]
  BL["Blind modifier: when my own view could<br/>contaminate the result (perception, plan<br/>critique, what a draft missed): the worker<br/>gets only artifact + goal, strongest tier"]
  X["Worker fails: respawn once with a tighter<br/>brief, then fall back inline, log the hiccup"]
  fin(["End"])
  A --> R0
  R0 -- "yes" --> E0
  R0 -- "no" --> R1
  R1 -- "yes" --> I1
  R1 -- "no" --> R2
  R2 -- "yes" --> I2
  R2 -- "no" --> R3
  R3 -- "yes" --> I3
  R3 -- "no" --> R4
  R4 --> R4a
  R4a -- "yes" --> I4
  R4a -- "no" --> R4b
  R4b -- "yes" --> R4c
  R4b -- "no" --> S
  R4c -- "yes" --> I4
  R4c -- "no" --> S
  S --> R5a
  R5a -- "yes" --> N5
  R5a -- "no" --> G5
  MINT -.-> G5
  N5 --> R5
  G5 --> R5
  R5 -- "yes" --> F
  R5 -- "no" --> W
  F --> R6
  W --> R6
  R6 -- "yes" --> SY
  R6 -- "no" --> PS
  SY --> PS
  PS --> AB
  M7 -.-> R3
  M7 -.-> R4
  BL -.-> W
  BL -.-> F
  X -.-> AB
  E0 --> fin
  I1 --> fin
  I2 --> fin
  I3 --> fin
  I4 --> fin
  AB --> fin
```

## How to read

- Rectangles are actions, diamonds are decisions, stadiums are the start and end, the
  parallelogram hands off to the spawn-strategy-router chart, and nodes joined by dotted
  edges are standing modifiers that apply throughout.
- The chart covers rules 0 to 7, the worker-failure line, and the blind modifier.
- Rules 1 to 4 run top-down and stop at the first verdict; rules 5 and 6 shape a spawn
  verdict rather than re-decide it.
- Rule 4 also counts executing a heavy skill body toward absorption; judgment-bearing
  procedures you own stay inline and delegate only their mechanical phases.
- The numbers are calibration defaults, not laws; a deviation and its reason go in
  `handoffs/LOOP_LOG.md`.
- The maker-is-not-checker rule for your own edits to `.kiro/steering/`, `.kiro/skills/`, or
  `.kiro/agents/` (spawn `instruction-auditor` first) governs your edits, not a need's routing,
  so it is not drawn.
