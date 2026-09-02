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

## Manual pass first

Prove an approach with one hand-run pass before you write the script, the skill, or the
automation that repeats it. Scaling an unproven approach scales its flaws.

## Evals must be able to fail

A judge is a closed question with a pass bar set before the run, checked against a known-bad
case. "Does this look good?" is not a judge. A judgment that is not calibrated against real
outcomes annotates; it does not gate. Full procedure: `eval-design`.

## Decide, log, proceed

If you hold a defensible default, take it and log it. Stop for the operator only at a
genuine business, spend, time, or approach fork. Full procedure: `ask-operator-gate`.
