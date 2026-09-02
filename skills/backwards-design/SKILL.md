---
name: backwards-design
description: Derive any role, pipeline step, agent, system, or goal by working backwards from its output and its judge. Use when designing or auditing an agent pipeline, deciding sequential versus parallel orchestration, deciding a step's inputs, outputs, and goal, deciding whether a needed input becomes a pre-set file, a new LLM call, or a spawned sub-agent, defining success criteria or an evaluator or a proxy judge, or untangling overlapping role boundaries. Keywords - backwards design, demand-driven, pull from the end, define the judge, role contract, inputs outputs goal, sequential versus parallel, when to add a sub-agent, success criteria, evaluator, proxy judge, calibration, ground truth, decomposition, first principles.
---

# Backwards design

Derive a system from its output and its judge. Use it whenever "what is this step for?" is
fuzzy; that fuzziness causes most downstream bugs.

## The core principle: design backwards

Most systems are built front to back and accrete steps nobody validated. Build back to front
instead:

1. Output first. You cannot define the ideal output until you know who consumes it next, so
   pull the spec from the downstream need. The consumer defines the spec.
2. Inputs second. The minimum needed to produce that output.
3. Process last. The process is the bridge between the two ends. Define the ends first; the
   middle follows.

This applies at every scale: a single field, one agent, or the whole pipeline. For a pipeline,
anchor at the last deliverable, where the consumer is known, and pull backwards step by step
to the first input.

## The interrogation

Run these six questions, in order, on any role, step, or system:

1. Who consumes my output? Name the immediate downstream consumer.
2. What exact output does that consumer need to do its job? This is the spec. It is pulled,
   not invented.
3. What is the minimum input required to produce that output? More input is not better.
4. Where is each input cheapest to source? See the cost ladder. Inputs may come from several
   sources, not one upstream dump.
5. Do I need a new agent here, or just a file or a line of code? This is the stopping rule.
6. What is the judge that says this output is good? This is the hardest and most important
   question.

Anti-dump rule: "each step gets the full output of the step before" bloats the system and the
humans reading it. Give each step the minimum targeted slice, assembled from wherever each
piece lives.

### The ideal-prompt technique and the cog rule

Two complementary moves for deriving a step's inputs:

- Ideal-prompt technique: imagine the perfect system prompt and user prompt that would produce
  this step's output. Then realize it minimally from the available banks: operator inputs,
  prior outputs, knowledge files. Where the ideal needs something no bank has, that is a flag
  for a new extraction-and-store task (a fixed research step), not something to invent at
  runtime.
- The cog rule: each step is a focused cog. Feed it the minimum compiled work order, not the
  raw higher-level "why", which distracts and degrades output. Keep horizontal interface
  context and the examples that show what good looks like for this step. Resolve inputs to leaf granularity: naming a
  parent does not deliver its children. If a step seems to need the raw "why", the upstream
  work order is incomplete. Fix that; do not bloat the cog.

## Sourcing inputs: the cost ladder

An input does not have to come from one place. Pick the cheapest source that is strong enough:

1. Pre-set data (cheapest): facts already known. A file, a lookup table, examples, a routing
   rule. Anything stable and knowable in advance never gets re-derived by an LLM.
2. A prior LLM output (medium): only the slice needed, not the whole dump.
3. A new LLM call or spawned sub-agent (most expensive): only when the input needs fresh
   judgment or scale that nothing cheaper can give.

An LLM supplies judgment; data and code supply facts. If a thing is knowable up front, it is
a file, not a thought.

### Fixed step versus dynamic sub-agent

When an input does not exist yet, you manufacture it. Choose the shape by variability:

- Add a fixed step (a code step or a baked-in LLM call) when the input is needed every run and
  its shape is known. Predictable, cheap, testable. If the needed context does not exist yet,
  run a research step once and bake the result in as data. Most needs are this. Prefer it.
- Spawn a dynamic sub-agent only when the work is conditional and variable, unknown until you
  see the actual input at runtime. Examples: a thin source versus a rich one; a one-item
  input versus a fifty-item input; a loop that fails to converge.

Discipline for production systems: fixed spine, dynamic limbs. The core path needs
predictable cost and quality. Reserve dynamic spawning for genuinely variable edges.

The patterns in `agent-orchestration-workflows` (fan-out, tournament, adversarial-verify,
loop-until-done) are recipes for manufacturing an output that cannot be produced in one clean
shot. The root question is the same: what output do I need, and what is the cheapest way to
manufacture it?

## Defining the judge

For generative systems you usually cannot enumerate the ideal output; there are infinitely
many valid ones. Stop defining the artifact and define the evaluator. The output is "the
thing that passes this test". In a generative system, the goal is the judge. Without a
trustworthy judge there is no reliable improvement, because there is no definition of up.

### Real judge versus proxy judge

- Real judge: the true outcome (the report was correct in production; the user accepted the
  result). Honest, but unmeasurable at build time.
- Proxy judge: a build-time prediction of the real judge (an expert's call, a rubric score, a
  structural check). You optimize the proxy, betting it correlates with the real judge.

Calibration is mandatory. A test rig that drifts from reality gives confident wrong answers.
Periodically validate the proxy against real outcomes (production data, a human spot-check).

### The ground-truth ladder: whose taste is being optimized

When the judge is a matter of taste, or a domain you lack, do not make the builder's gut the
judge, and do not hardcode a "sensible default". Taste is a trained function over real-world
inputs, so source it. Ranked weakest to strongest:

1. A person's unaided gut (weakest). One uncalibrated opinion. Fine as a spot-check, never as
   the evaluator.
2. Extracted real-world corpora (the bootstrap truth). What real experts or real usage
   produced: reference outputs, accepted past deliverables, published standards. Strong enough
   to start. Caveat: most corpora measure exposure, not outcome, so they remain a proxy.
3. Live outcome data (the real truth). The only rung that is the real judge. Build the system
   to climb toward it and recalibrate rungs 1 and 2 against it.

The rule: when you lack the taste, manufacture the judge by extracting ground truth (a fixed
research step), and prefer the highest rung available. "We do not know what good looks like"
is an instruction to go extract it, never to bake in a default.

### Make the proxy deterministic where you can

Prefer perceive-then-match over a black-box "is this good?" opinion. Use one LLM call to read
the artifact into a structured vocabulary, then match by code against the target spec. This
collapses the fuzziness into one calibratable perception step, anchored with scored examples.

### Before versus after, and fit versus craft

- Before-judge: a cheap gate at a seam, on a partial output. It catches obvious losers early.
  It sees an incomplete artifact, so it is a sanity check, never the final verdict.
- After-judge: runs on the full artifact. This is the real test.
- Fit ("does it hit the target?") is not craft ("is it rendered correctly: legible, faithful,
  no defects?"). An on-target artifact with a garbled execution still fails. Judge both.

## Worked examples

### A data file to a report pipeline

The request: "turn the monthly export into the summary report". Built front to back, the
pipeline parses the whole file and passes everything downstream. Backwards design starts at
the end. The consumer is a reviewer who checks three totals against a reference sheet. So the
output spec is three named totals with their source rows, in the reviewer's layout. The
minimum input is the rows that feed those totals, not the whole file. The column mapping is
stable across runs, so it is a pre-set file (rung 1). The only LLM work left is flagging rows
that do not fit the mapping, a fixed step because it runs every month with a known shape. The
judge is deterministic: the totals match the reference sheet within tolerance and every
flagged row is listed. Output and judge came first; the parse step shrank to fit them.

### A review gate whose judge was never defined

A pipeline had a "quality review" step between draft and delivery. It returned "looks good"
or "needs work" with a paragraph of reasoning, and the operator disagreed with it about half
the time. Question 6 exposed the gap: nobody had said what "good" meant. The consumer was the
operator deciding whether to ship, and the operator's real criteria were three checks: every
required section present, every number traceable to its source, no placeholder text left.
Two are code. The third is one perceive-then-match call that lists placeholders, then a code
check that the list is empty. The opinion paragraph was cut. The gate was calibrated against
ten past deliverables the operator had accepted or rejected and agreed with all ten. The step
did not lack intelligence; it lacked a judge.

## Anti-patterns

- Building front to back and adding steps before defining the final output.
- Defining the artifact instead of the judge ("make a good report" with no evaluator).
- Dumping a whole upstream output into the next step instead of the minimum slice.
- Making an LLM re-derive a stable fact that should be a file.
- Spawning a sub-agent for work that is the same every run (should be a fixed step), or
  hardcoding a fixed step for work that is genuinely variable per run (should be dynamic).
- Trusting a before-gate, a partial-artifact judge, as the final verdict.
- Shipping a proxy judge that is never calibrated against the real outcome.
- Using the builder's gut as the judge in a domain the builder lacks.

## Related skills

- `agent-orchestration-workflows`: recipes for manufacturing an output that needs fan-out,
  sub-agents, or tournaments.
- `eval-design`: how to build and calibrate the proxy judge once this skill has named it.
- `goal-definition`: the intake step that records the judge and done-when in the goal contract.
