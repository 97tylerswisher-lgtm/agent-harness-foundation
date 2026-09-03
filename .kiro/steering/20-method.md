---
title: Method
inclusion: always
---

# Method

How to think before building anything. The full procedures live in skills; this file is the
short form that is always on.

## Design backwards

1. Name who or what consumes the output. The consumer defines the spec.
2. Name the judge: the test that says the output is good. If you cannot name it, you are not
   ready to build. Full procedure: `backwards-design`, `eval-design`.
3. List the minimum inputs and the cheapest source for each. A knowable fact is a file or a
   line of code, not a model call. A model call is for judgment.
4. Only then design the process, which is the bridge between the two ends.

## Ask the standing questions yourself

Answer these at every phase boundary and before building on anything you did not derive:

- What is actually going on here, and why? Trace the real data path: source, transform, output.
- Does this serve the goal, and is the goal well defined? If it is fuzzy, sharpen it first.
- Does this abstraction make sense, or is it accreted history?
- Where is the weak point I am glossing over? Name the hole a reviewer would find.
- Where are the test and verification points, and can each one actually fail?

Full procedure: `system-self-inquiry`.

## Do not grade your own work

A model rationalizes its own choices. For any plan, design, or result you are about to rely
on, hand a blind critic only the artifact and the goal, never your reasoning, and compare its
view to yours. Divergence is the signal. Fold only what you verify against the artifact, and
say what you rejected. Roles: `skeptic`, `goal-critic`, `architecture-critic`,
`mechanism-critic`.

Two rules that are easy to miss:

- A foundation artifact (a goal contract, a requirements file, a design) gets the three-lens
  panel, `goal-critic`, `architecture-critic`, and `mechanism-critic`, run together. A lone
  `skeptic` is for a single small claim. One critic self-grades the lenses it does not hold.
- Load `agent-orchestration-workflows` before you spawn anything. It holds the brief shape,
  the return caps, and the fold discipline. Spawning from memory drops them.
- How spawning works here: the roles under `.kiro/agents/` are Kiro custom agents. A chat
  session delegates to one as a sub-agent (isolated context, parallel); the agent's front
  matter names its tools and its `resources` (`skill://<name>` for a skill, `file://<path>`
  for a file), described in `agent-authoring`. If your Kiro build offers no sub-agents, run
  each lens yourself in a fresh chat with only the artifact and the lens brief, and say so
  in the loop log.

## Manual pass first

Prove an approach with one hand-run pass before you write the script, the skill, or the
automation that repeats it. Scaling an unproven approach scales its flaws.

## Evals must be able to fail

A judge is a closed question with a pass bar set before the run, checked against a known-bad
case. "Does this look good?" is not a judge. A judgment that is not calibrated against real
outcomes annotates; it does not gate. Full procedure: `eval-design`.

## Spawn less than you want to

Before spawning a sub-agent, ask whether one grep, one file read, or one script run answers
the question. Spawn for scale (many similar items), for isolation (a large read you only need
a digest of), or for a blind check. A model on this tier tends to over-delegate; a spawn costs
context, latency, and a verification pass.

## Decide, log, proceed

If you hold a defensible default, take it and log it. Stop for the operator only at a
genuine business, spend, time, or approach fork. Full procedure: `ask-operator-gate`.
