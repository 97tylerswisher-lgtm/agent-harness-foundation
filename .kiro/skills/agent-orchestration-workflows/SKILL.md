---
name: agent-orchestration-workflows
description: How the orchestrator decides what to do inline, what to delegate to sub-agents, which workflow pattern a delegation gets, and how to verify what comes back. Use when a task would flood the main context, when you need verification you can trust rather than self-assessment, when a plan needs a blind multi-lens critique before you commit it, when a worker claimed done and you must check it, or when choosing the model tier for a delegated job.
---

# Agent orchestration workflows

Load this skill before authoring any fan-out or panel, even if you remember it. A
half-remembered version drops the specifics that change the outcome.

## Vocabulary: what "spawn" means here

Sub-agents are the files in `.kiro/agents/<name>.md`. An orchestrator
agent that lists `subagent` in its `tools` invokes them; "spawn a worker" means invoke one
with a brief. Sub-agents run in parallel in isolated contexts and share steering only
through their `resources`. Only the worker's final message returns.

## Session-constructor authority

The orchestrator decides how the work is executed: focused sub-agents, one bounded
sub-orchestrator layer (a builder that spawns its own workers, one nesting level), or a
fan-out. Do not ask the operator for separate consent to delegate. Worker selection, count,
model tier, sequencing, and verification shape are implementation decisions. A skill
instruction to spawn a mapper, critic, verifier, or panel is sufficient authorization.

This authority does not expand scope. A worker inherits the orchestrator's boundaries: no
new paid spend, destructive action, public or external mutation, business decision, or
human-gate bypass unless separately authorized under its own rule.

## Context is the budget

Every message resends the full conversation to the model. The orchestrator stays concise
to stay smart. Anything bulky (file dumps, transcripts, raw corpora, large media or document
sweeps) belongs in a worker's context, which starts clean, does one job, and ends.

Return economics: the worker's return still lands in your window, and fat returns are a top
context leak. Ask for a verdict, not the reasoning: the call plus the top-N findings, one
line each with a `file:line` cite, under an explicit cap ("150 words, 5 findings"). Long
reasoning goes in an artifact the worker writes; the return carries its path. Blind critics
always get a full-critique file path in the contract: the cap protects the fold, and the
depth must exist on disk. State the return shape in the brief; nothing enforces it.

Delegate inputs, keep synthesis: read-to-map and check-to-verdict return little and deliver
much. But if you delegate the deciding, the authoring of durable documents (handoff, retro,
plan), or the edit itself, the judgment lives in the worker and you stop being the
conductor.

## The delegate-or-inline decision

Apply this to each need (a file to read, a process to run, research, a sweep). Rules 0 and
7 are standing modifiers. Rules 1 to 4 run in order and stop at the first verdict. A spawn
verdict continues through rules 5 and 6, which shape the spawn, then picks its pattern from
the router below. Chart: `references/delegate-or-inline.flowchart.md`.

0. Boundary check. Spend, destructive, public or external, or secret-touching work is never
   resolved here. The escalation rules in `.kiro/steering/` govern first.
1. Judgment, verification, or the fold? Do it yourself. Never delegate the plan, the
   decision, the audit of a worker's claims, or the decision-fold (the synthesis that drives
   a decision you own). Verification at volume is sampled: spot-check two or three raw items
   against the artifact, never the whole payload.
2. Knowable transform? Write or run code. No agent, no inline reasoning.
3. Smaller than the brief? If doing it costs less than writing the spawn prompt (a known
   `file:line` edit, one grep, one read under about 2k tokens), do it yourself.
4. Estimate forced absorption before reading: file bytes divided by 4. Under about 5k:
   inline (a spawn costs about 1k of your window plus latency and a retry risk). About 5k to
   20k: inline only if the decision needs the raw detail; spawn if a conclusion suffices.
   Over about 20k: always spawn. Executing a heavy skill body counts: spawn a worker whose
   brief says "Read `.kiro/skills/<name>/SKILL.md` first and follow it exactly. Inputs: ...
   Return: <capped format>." Judgment-bearing procedures you own (the wrap itself) stay
   inline; delegate their mechanical phases.
5. Spawn shape, who then how many. Roster first: if an `.kiro/agents/<name>.md` description fits,
   spawn it by name. No fit: an inline brief on the closest generic role (`research-worker`
   for reading, `code-worker` for builds). A brief hand-written two or three times gets
   minted (`agent-authoring`). Then fan-out: the same read or process over three or more
   similar items means one worker per item (or a pipeline), each with a capped return.
6. Spawn shape, return volume. Expected total returns equal N workers times the cap. Over
   about 15k tokens, or when the decision needs only aggregates, insert a synthesizer
   worker; absorb its digest plus two or three raw returns you spot-check yourself. A
   mechanical digest is delegable; the rule-1 fold is not.
7. Window-pressure modifier. Past about 50% of the session window, halve every threshold
   above. Past about 75%, delegate everything except rules 1 to 3 and prepare the checkpoint
   (`context-checkpoint`).

Worker failure: respawn once with a tighter brief, then fall back inline and log the hiccup
in `handoffs/LOOP_LOG.md`. The numbers are calibration defaults; log a deviation and why.

Maker is not checker, and that applies to you. Before committing your own inline edits to
`.kiro/steering/`, `.kiro/skills/`, or `.kiro/agents/`, spawn `instruction-auditor` over the
touched files, unless a blind pass already covered them this session.

## The three failure modes

1. Agentic laziness: the worker declares done after partial progress (20 of 50 items).
   Countermeasure: a numbered task contract the worker echoes back marked done or not done;
   the orchestrator counts items.
2. Self-preferential bias: an agent judging its own output grades it kindly. Countermeasure:
   generator and judge are different agents, stated in the prompt; rubric before generating.
3. Goal drift: fidelity to the objective decays across turns and compactions, and "do not do
   X" constraints get lost. Countermeasure: hard success criteria up front, restated in every
   delegation; verification gates against the original goal, not the current trajectory.

Verification rule: judge a worker by its artifact, not its report. A final message can be
truncated while the file is complete, and a confident "done" can sit over a missing file.

## Workflow patterns

Seven patterns, one per question the spawn must answer, with their costs and the pairing rule.
Read `references/patterns.md` before choosing a pattern.

The blind modifier applies to every pattern. When your own view could contaminate the result
(perceptual judgment of an artifact, critique of a plan, hunting what a draft missed), hand
the worker only the artifact and the goal: never the reasoning, the defect list, or the
expected answer. Divergence is the signal. Blind workers run the strongest tier available.

## The plan-critique panel

Three blind lenses plus an optional fourth, run in parallel on a foundation artifact before
building. Read `references/panel.md` before spawning critics.

## Return caps by role

- Verdict roles (critics, auditors, verifiers): the verdict plus at most five findings, each
  with a file and line, under 150 words. Depth goes in a file the agent writes; it returns
  the path.
- Reading roles (mapper, research-worker): a structured digest of about 1,500 tokens plus the
  path of the full artifact. Never the raw material.

## Model policy

The operator profile (`.kiro/steering/10-operator-profile.md`) names the models allowed at this
site. Nothing below overrides that list.

1. The orchestrator runs on the session model. It is the standing checker: it holds the
   high-level goal and never tunnels on one fix while others regress.
2. Delegated builders inherit the session model. Omit a model pin in briefs and agent files.
3. Blind critics and skeptics run the strongest tier available. Finding what is actually
   wrong is the hardest job; never downgrade it.
4. Mechanical sweeps (structure checks, lints, enumerations) may take the site's approved
   lower tier when one exists; never a model outside the operator profile's list.
5. If the harness offers one model, every rule above resolves to it. Say so and move on. The
   blind and maker-is-not-checker rules still apply: they separate contexts, not models.

## Delegation prompt checklist

The standing worker contract (echo the contract, lean return, no source-control writes, no
paid calls, honest hiccups) lives once in `docs/agents-roster.md`. Reference it in the brief.
Every brief must additionally contain:

1. Role and the minimum context: paths, not pasted content. Workers read files themselves.
2. A numbered task contract.
3. Output artifact paths and their format or lint constraints.
4. The return's shape and cap: "the call plus the top five `file:line`-cited findings, 150
   words".
5. For judged work: the rubric, written before generation, judged by a different agent.

Gap-analysis rule: a "we do not have X" claim, from a worker or from you, must be preceded
by a scan of the full `.kiro/skills/` catalog and `scripts/` for an existing X. A mapper that
inventories only the skills it was handed will miss what already ships. Put "scan the full
catalog for each candidate gap" into any gap-analysis contract, and verify a load-bearing
"missing" claim yourself before it binds a plan.

## Related skills

- `agent-authoring`: how to mint a reusable agent once a brief repeats.
- `context-checkpoint`: the wrap that rule 7 prepares for.
- `common-pitfalls`: markdown lint rules for any files workers write.
