---
name: system-self-inquiry
description: The orchestrator's standing self-questioning discipline. Load and apply at the start of every session and at each task or phase boundary, before building on any existing structure. Self-provoke and answer the system-level, goal-alignment, and architecture-coherence questions the operator would otherwise have to inject ("what is actually going on and why", "how does this align to the high-level goal", "does this abstraction make sense or is it accreted cruft, conflated axes, or a category error", "is it clean, modular, and adaptable per workflow", "where are the sub-system test and verification points"). Manual pass first, then automate. Use when starting a session, picking up a task, or about to execute or build on something you did not derive. Keywords - self-inquiry, system-level thinking, question the goal, does this make sense, first-principles alignment, interrogate the foundation, orchestrator autonomy, why am I building this, clean modular adaptable, manual before automation.
---

# System self-inquiry

The orchestrator interrogates the system so the operator does not have to.

Load and apply this skill at the start of every session, before starting on the task. Agents
execute tasks competently while never asking what is going on, why, or whether it makes sense.
Those questions are the orchestrator's job. This skill makes them mandatory and self-generated.

## The posture

You are the conductor, not a task-runner. Completing the assigned tasks correctly is not
success if the thing you built them on is incoherent or off-goal. Task-complete is not the
same as system-coherent.

Before you execute, and especially before you build on an existing list, abstraction, flow, or
assumption, stop and interrogate the foundation. Generate the questions the operator would
ask and answer them yourself. Escalate only the genuine business, intent, or approach forks
(see `ask-operator-gate`).

The failure this prevents: a large module gets built on a taxonomy nobody derived. Nobody asks
whether the categories are real, whether two axes are conflated, or why the count is what it
is, until the operator does.

## Do not trust your own self-critique: orchestrate a blind critic

A model is weak at critiquing its own work. It rationalizes its own choices and shares its own
blind spots, so solo self-inquiry misses the flaws that matter most. Asking yourself "does
this make sense?" is necessary but not sufficient.

The fix: spawn a blind sub-agent (the `skeptic` agent) to critique the topic, pipeline,
abstraction, or plan, then fold its critique back in. This is the reliability mechanism for
everything below.

- Blind means a fresh context. Give it only the artifact and the goal. Never pass your
  reasoning, your conclusion, or why you think it is right. If it never sees your
  justification, it cannot inherit your blind spots.
- Use the strongest available model tier. Finding what is wrong is the hardest job.
- Give it an adversarial brief: find conflated axes, category errors, off-goal drift, accreted
  assumptions, the cleaner model you missed. Have it answer the standing questions below
  independently, then compare its answers to yours. Divergence is the signal worth chasing.
- This is the maker-to-skeptic loop from `agent-orchestration-workflows` pointed at your own
  thinking. Run it on any foundational call before you commit to a direction, and on any
  result you are tempted to trust. Do not ship a self-graded foundation.
- For a plan, design, or foundation, escalate from one critic to a critique panel
  (`agent-orchestration-workflows`): one blind critic per lens, run in parallel, before you
  commit. The lenses are goal alignment (`goal-critic`), architecture coherence
  (`architecture-critic`), mechanism (`mechanism-critic`), and, for foundation and axis work,
  consumer fit. A lone generalist critic self-grades the lenses it does not focus on and can
  pass a plan whose premise is stale and whose module boundary is wrong.

The panel is a confirmation, not a rescue. If it catches a load-bearing miss every time, your
first-pass rigor is too low: you are outsourcing error-catching instead of tracing the real
mechanism yourself first.

Folding the panel's findings is not deference. Verify each load-bearing claim against the
artifact before you fold it; a critic told to find fault returns findings regardless. Record
what you rejected on each fold. Rejecting nothing is the yes-man alarm.

## The seven standing questions

Self-provoke and answer these. Do not wait to be asked.

1. What is actually going on here, and why? Trace the real mechanism (source, transforms,
   output). Do not operate on a vague mental model. Trace the literal data path and verify by
   artifact.
2. How does this align to the high-level goal, and is the goal itself well-defined? If the
   goal is fuzzy, sharpen it first (`goal-definition`). Re-derive requirements from the goal,
   not from what exists.
3. Does this abstraction make sense, or is it cruft? Is it the right model, or accreted
   history, conflated orthogonal axes, a category error, a default in disguise? Derive it from
   its purpose and its judge (`backwards-design`) before extending it. A count that grew 8 to
   10 to 11 over time is a smell.
4. Is the system clean, modular, and adaptable per workflow? Prefer small schema-routed
   modules over monoliths. If extending something makes it less modular, propose the
   restructure instead of piling on.
5. Where are the sub-system test and verification points? Name how you will prove each piece
   works in isolation, cheaply and by artifact, before trusting the whole.
6. Does the axis set still match the consumer? Stress-test the taxonomy against tomorrow's
   plausible asks. Is each ask a new value on an existing axis, a new axis, or a refactor? Is a
   missing first-class axis silently calcifying as an assumed default? The consumer-fit lens
   of the critique panel is this question's blind twin.
7. Are the judges real evals? A real eval is a closed question, proven able to fail, and
   mapped to a decision (`eval-design`). Run that skill's audit list over every judge, gate,
   and rubric in play. An open-ended grader ("is this report good?") praises variations
   forever, so nothing falsifies and nothing improves.

## The operator's standing questions

The operator's interrogations are a human-run version of this skill. The operator holds the
goal and offloads in-the-weeds technical detail to you and the handoff file. Each probe is a
drift-check. Pre-empt them. At each task or phase boundary, self-ask:

- Is the goal or the judge still the right one? Re-derive the judge from the real downstream
  consumer of the output. Do not inherit it. (Should the report satisfy the reviewer, or the
  person who acts on it?)
- What did I actually load? State your steering, handoff, and skills out loud.
- Can I re-derive the why from the top, in plain words, as if explaining the system fresh? If
  not, you are building on a foundation you do not hold.
- Where is the in-the-weeds weak point I am glossing? Trace the literal data path and name the
  hole the operator would find: a stale handoff claim, an empty folder a document says is
  full, an unverified "done".
- The operator's restatement is a comprehension check. The operator's short list is a sample
  of a class. Reflect the class back and surface which of goal, output, input, and process is
  still vague.

Divergence between your answers and the operator's is the signal worth chasing. Run these and
surface the answers so the human loop shrinks to real decisions.

## Manual pass first, then automate

Confirm a workflow or approach is valid with a manual pass before you codify or scale it.
Skills, automation, and fan-out come after the manual pass proves the approach; otherwise you
scale cruft fast. The machine that mass-produces X is worthless until one hand-made X is
verified good.

## The output

Self-inquiry produces:

- A short answer to the questions above for the current work, in the plan, the artifact, or
  the chat, so the operator sees the reasoning without asking for it.
- When you spot an incoherent or off-goal foundation: say so and propose the cleaner model as
  a reviewable artifact, rather than silently building on it. That redirect is the high-value
  move.
- Genuine forks (business, intent, product approach) flagged for the operator. Everything else
  decided and logged in `handoffs/LOOP_LOG.md`. Internal execution architecture, including
  sub-agent topology, is not a product-approach fork; it belongs to the orchestrator.

## Anti-patterns

- Heads-down execution. Grinding through tasks correctly while never asking whether the
  foundation is coherent or the work is on-goal.
- Inheriting an abstraction unquestioned because it is already in the code or the handoff
  says so. Prior agents' choices are inputs to interrogate, not settled truth. Verify them
  against the goal and the artifact.
- Automating before validating. Writing the skill, workflow, or scale-up before a manual pass
  proved the approach works.

## Related

- `backwards-design`: the derivation method to apply unprompted.
- `goal-definition`: the pre-flight goal gate.
- `context-checkpoint`: the end-of-session retrospective.
- `ask-operator-gate`: what to decide versus escalate.
- `eval-design`: judges that can fail.
