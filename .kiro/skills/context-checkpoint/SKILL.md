---
name: context-checkpoint
description: Session tracking and wrap procedure. Phase 0 (every session) logs decisions, hiccups, lessons, operator answers, and open self-questions in handoffs/LOOP_LOG.md as they happen. The wrap folds that log into handoffs/NEXT_AGENT_HANDOFF.md, adds open improvements to handoffs/RETRO.md, archives the session block, runs the redaction check, commits and pushes, spawns handoff-verifier, and ends the reply with a Zooming out block. Use when the operator says "checkpoint", "wrap up", "review", or "handoff", at every phase boundary, and before the context window gets long. Load this file before running a checkpoint; do not run it from memory.
---

# Context checkpoint

A checkpoint has two parts. Phase 0 runs all session long and keeps the loop log current. The
wrap runs at the end and turns that log into a handoff a fresh session can act on.

Run a checkpoint at every phase boundary and before the context window gets long, not only at
the end of a chat.

## Phase 0: decide, track, loop (every session)

Two standing rules:

1. Drive to the goal. When a fork is a step toward a known end goal, decide it, record it, and
   keep going. Stop for the operator only on business, legal, spend, or intent ambiguity, and
   ask in one prose block (`ask-operator-gate`). A defensible default is not a reason to stop.
2. Never loop blind. Every decision, surprise, and lesson goes into `handoffs/LOOP_LOG.md` as it
   happens, not reconstructed at the wrap.

The loop log holds the current session under one heading with five sections:

- Decisions: what was settled, why, and which precedent applied.
- Hiccups: symptom, root cause, fix.
- Lessons: generalizable rules, each naming where it should be enforced.
- Operator questions and answers: every ask and its answer, verbatim where it matters.
- Open self-questions: unknowns the session could not close.

The log is curated, not a transcript. Before reopening any decision, check the handoff's
Settled section and the loop-log archive. If the decision is there, it is closed.

## The wrap

Run the steps in this order. Do not skip a step because the session was short.

1. Fold the loop log into `handoffs/NEXT_AGENT_HANDOFF.md`. Overwrite the file using this fixed
   section skeleton; never stack a dated block on top of the old text:
   - Zoom-out: two sentences on what is now true of the system that was not before.
   - Mandate for the next session: the goal, the first task, and the skills to load first
     (three to five, each with a one-line why).
   - State: what exists on disk, verified by reading the artifact in this pass, never by
     copying another document. Do not record commit state; point to `git log`.
   - Operating contract: the standing rules the next session must keep (do-not-touch paths,
     gates, spend limits).
   - Pending operator asks: one numbered item per fork, with a one-line ask, short context,
     and closed options with the recommendation first.
   - Settled: decisions the next session must not reopen. Keep it to about twelve lines.
   - Verification boundary: what was checked and how, and what was not checked.
   - Latest checkpoint: session number, date, and the archive heading of the loop-log block.
   Carry unresolved threads forward as known unknowns. Tag every "next" as a hypothesis, not
   an order. Keep the file near 150 lines.
2. Add one row to `handoffs/RETRO.md` for each open improvement the retrospective surfaced.
   The columns are ID, text, session seen, disposition:
   `| R<session>-<n> | <text> | S<session> | OPEN |`. Disposition is `OPEN` or `CLOSED`; a
   closed row adds a one-line evidence pointer to its text. A learning that lives only
   in a retro row is logged, not implemented; wire it into a steering rule, a skill, or a
   script in the same wrap when the fix is cheap.
3. Move the finished session block in `handoffs/LOOP_LOG.md` under the archive heading at the
   bottom of the file. This is a plain cut and paste; there is no script. The live area at
   the top then holds only the next session's empty skeleton.
4. Run `scripts/check-redaction.ps1` and fix every hit. Zero hits before every commit.
5. Commit and push to the remote (GitLab at work; the operator may also mirror to a public
   copy). The message starts with the session number, then one headline and two to four
   bullets. Never force-push. On a rejected push, pull with rebase and push again; on a real
   conflict, stop and report to the operator.
6. Spawn the `handoff-verifier` agent to check the handoff against disk. Fix every stale row
   it reports, then re-read the handoff as if you were the next session holding only that
   file: does it route to the goal, does it avoid re-asking the operator, and is every state
   claim true on disk now.
7. End the chat reply with the Zooming out block (below).

## Retrospective

Before step 1, answer these questions in the loop log. Each answer that names a change becomes
a RETRO row in step 2.

- Skill use: which skills matched this session's work? Mark each loaded, skipped, or acted on
  from memory. For each skip, would loading it have changed the plan or the output?
- Missing skill or agent: did the session re-derive a procedure, search more than three times
  for the same thing, or hand-write the same worker brief twice? Propose the mint to the
  operator (`skill-authoring`, `agent-authoring`).
- Decomposition: did the split into sub-agents fit the work? What would be shaped differently?
- Sub-agent leverage: was a mechanical loop kept inline, or was an agent used where a file or
  a command would do?
- Loading: was the right context loaded up front, or were there wasted loads and missed
  triggers?
- Second-brain friction: did the handoff, the loop log, and the gates serve the session, or
  lose context?
- Hiccups: for each one, the rule that prevents it next time.

For a session with real work, spawn a `skeptic` agent with only the session's artifacts and
goal, not your answers, and ask it to critique how the session was run. Where it disagrees
with you, verify against the artifact and record the result.

## The Zooming out block

Every wrap reply ends with a block titled "Zooming out", three to five plain sentences:

1. The project goal, one line.
2. What this session permanently moved.
3. Where that leaves the project, stated honestly.
4. Drift check: name any work that did not serve the goal.
5. Is the queued next step still the highest-leverage step, or polish on a step that has
   already had three sessions?

Mirror sentences 2 and 3 as the Zoom-out section of the handoff.

## Anti-patterns

- Reconstructing the loop log at the wrap from memory.
- Appending a dated block to the handoff instead of overwriting the sections.
- Writing "flagged" or "noted" in a RETRO row. Every row has a disposition.
- Snapshotting commit state in the handoff.

## Related skills

- `ask-operator-gate`: the format for pending operator asks.
- `skill-authoring` and `agent-authoring`: minting what the retrospective surfaced.
- `agent-orchestration-workflows`: the blind critic spawn.
