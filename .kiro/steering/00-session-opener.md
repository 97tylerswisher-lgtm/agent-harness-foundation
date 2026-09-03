---
title: Session opener
inclusion: always
---

# Session opener

This file is the first thing every session follows. Read it top to bottom, then do what it
says, in order. Do not skip a step because it looks obvious.

## Read order

1. This file, then the other steering files (they are all loaded with it).
2. The live handoff, pulled in below. It says where the last session stopped and what the
   next session does first.
3. The memory index, pulled in below. Open a memory file (`handoffs/memory/<name>.md`) only
   when its hook matches the current work. Never load them all.
4. The active spec named in the handoff, under `.kiro/specs/<name>/`. Read its
   `goal-contract.md`, then `tasks.md`, then whichever of `requirements.md` and `design.md`
   the current task needs.
5. Skills load on demand. Each skill has a description that says when to use it. Load a
   skill before the work it governs, not from memory. The routing table is
   `docs/skills-routing.md`. The agent roster and the standing worker contract are
   `docs/agents-roster.md`.

Live handoff:

#[[file:handoffs/NEXT_AGENT_HANDOFF.md]]

Memory index:

#[[file:handoffs/memory/INDEX.md]]

## The flow every project follows

| Step | You do | Where it is told |
| --- | --- | --- |
| Boot | read the handoff and the active spec | this file |
| Intake | turn the operator's request into a goal contract | `goal-definition` skill |
| Boundary | decide what may enter this IDE; stop and ask if unsure | `40-data-boundary.md` |
| Step zero | get the cards and fixtures that describe the data's shape | `data-distillation` skill |
| Spec | write requirements, design, tasks under `.kiro/specs/<name>/`; run `scripts/check-spec.ps1` before showing any phase | `spec-authoring` skill |
| Build | run tasks; delegate per the decision chart; check with a blind critic | `agent-orchestration-workflows` skill |
| Gate | stop at the human review the design names; never automate past it | the spec's `design.md` |
| Wrap | fold decisions into the loop log and the handoff | `context-checkpoint` skill |

A new project starts at Intake. A continuing project starts where the handoff says.

## Rules that hold every turn

- Treat the handoff as a map to verify, not a task list. Check a claimed state against the
  file or the command output before acting on it.
- Log as you go in `handoffs/LOOP_LOG.md`: decisions with a one-line why, hiccups, lessons,
  the operator's questions and your answers, open self-questions. Do not wait for the wrap.
- When an input is missing (a card, a fixture, a decision only the operator can make), stop
  and ask for it in one prose block. Do not invent a shape, a path, or a value.
- Never cite a repo file, skill, agent, or helper script that does not exist in this repo as
  if it existed. A file a later step will create (a card, a design) may be named as planned
  work, marked as such. If you need a skill or script that does not exist, say so and propose
  it. Standard tools such as `git` and `powershell` are fine.
- Verify against artifacts, not reports. A sub-agent's "done" is checked by opening what it
  wrote.
- Checkpoint at phase boundaries and before the conversation gets long, not only at the end.
