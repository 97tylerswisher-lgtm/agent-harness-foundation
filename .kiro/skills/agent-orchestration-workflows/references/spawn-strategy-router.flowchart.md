# Spawn-strategy router: which workflow pattern the spawn gets

Source of truth: `.kiro/skills/agent-orchestration-workflows/SKILL.md` (The seven workflow
patterns). This chart restates it; the source binds.

```mermaid
flowchart TD
  S0(["Spawn verdict from delegate-or-inline"])
  Q7{"What is this:<br/>task type unclear?"}
  P7["1. Classify-and-act: one cheap router<br/>routes to a specialist; tiering cuts cost<br/>Cost: a misroute poisons everything after;<br/>only when the classification is reliable"]
  Q1{"What exists:<br/>facts or state from many places?"}
  P1["2. Fan-out readers (mapper-class),<br/>synthesizer only per rule 6<br/>Cost: N returns land in my window - cap<br/>each; useless when the items interact"]
  Q2{"Do this N times:<br/>the same work on 3+ similar items?"}
  P2["2. Fan-out workers (rule 5 shape):<br/>one worker per item, capped return each<br/>Cost: parallel edits collide - isolate<br/>or serialize; code is less parallel-safe"]
  Q3{"Confidence before acting:<br/>is a claim real?"}
  P3["3. Adversarial verification:<br/>a separate verifier per producer + rubric<br/>Cost: a verifier that misses launders<br/>the claim; keep an unverified state"]
  Q4{"Good candidates:<br/>options from an open space?"}
  P4["4. Generate-and-filter:<br/>overproduce cheap, cull by rubric<br/>Cost: needs the rubric before generating<br/>or the filter is taste; best-of-N baseline"]
  Q5{"Which is best:<br/>one winner among comparable candidates?"}
  P5["5. Tournament: pairwise brackets<br/>Cost: N-1 pairs to pick one, ~N log N<br/>to rank; try 0-1 scoring first;<br/>incomparable pairs = noise"]
  Q6{"Work of unknown volume:<br/>find them all?"}
  P6["6. Loop-until-done: passes until<br/>a stop condition holds<br/>Cost: fails both ways; stop on two<br/>no-progress rounds and a pass cap"]
  Q8{"Make this better:<br/>improve one artifact against a rubric?"}
  P8["7. Evaluator-optimizer: maker, critic,<br/>revise, 1-3 rounds<br/>Cost: loops forever without a closed<br/>rubric; maker is not checker; cap rounds"]
  FB["Nothing fits: one worker, capped return,<br/>then reassess with its result in hand"]
  E["Write the numbered contract, spawn,<br/>verify by artifact, never by report"]
  M1["Pair for false positives: put this behind<br/>any producer; fan-out + refute-per-finding<br/>is the default"]
  M2["Pair for missed items:<br/>wrap the run in loop-until-done"]
  M3["Pair for picking wrong: a tournament<br/>after generate-and-filter (overproduce,<br/>cull, then rank survivors)"]
  M4["Pair for unclear task type:<br/>classify-and-act in front of any pattern"]
  M5["Pair for one artifact that must get<br/>better: evaluator-optimizer"]
  M6["Pairing rule: pick by the failure you fear,<br/>then pay that pattern's cost. Two patterns<br/>is the normal pair; beyond two, write the<br/>sequence as an ordered task list first"]
  M7["Prompt chaining (steps with a gate between)<br/>is the shape of one worker's contract,<br/>not a fan-out pattern"]
  BL["Blind modifier (any row): when my own view<br/>could contaminate the result, the worker<br/>gets only the artifact + the goal;<br/>strongest tier; divergence is the signal"]
  fin(["End"])
  S0 --> Q7
  Q7 -- "yes" --> P7
  Q7 -- "no" --> Q1
  Q1 -- "yes" --> P1
  Q1 -- "no" --> Q2
  Q2 -- "yes" --> P2
  Q2 -- "no" --> Q3
  Q3 -- "yes" --> P3
  Q3 -- "no" --> Q4
  Q4 -- "yes" --> P4
  Q4 -- "no" --> Q5
  Q5 -- "yes" --> P5
  Q5 -- "no" --> Q6
  Q6 -- "yes" --> P6
  Q6 -- "no" --> Q8
  Q8 -- "yes" --> P8
  Q8 -- "no" --> FB
  P1 --> E
  P2 --> E
  P3 --> E
  P4 --> E
  P5 --> E
  P6 --> E
  P7 --> E
  P8 --> E
  FB --> E
  M1 -.-> P3
  M2 -.-> P6
  M3 -.-> P4
  M3 -.-> P5
  M4 -.-> P7
  M5 -.-> P8
  M6 -.-> E
  M7 -.-> FB
  BL -.-> E
  E --> fin
```

## How to read

- Rectangles are actions, diamonds are decisions, stadiums are the start and end, and nodes
  joined by dotted edges are standing modifiers (the pairing rule and the blind modifier).
- The chart covers the router table, the pairing rule, the numbered names, and the blind
  modifier.
- The classify question is asked first because the pairing rule puts classify-and-act in
  front of any other pattern; the router table lists it near the end.
- The start node is the spawn verdict from the delegate-or-inline chart; rule 5's fan-out
  and rule 6's synthesizer are the two fan-out rows here, both pattern 2.
- Each pattern node shortens its row's "Cost, and when it hurts" cell; the cell in the skill
  binds when they differ.
- The chain follows table order and does not rank rows; when two questions are both true,
  the pairing rule is how you add the second pattern.
