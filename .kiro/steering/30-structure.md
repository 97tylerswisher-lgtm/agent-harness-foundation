---
title: Structure
inclusion: always
---

# Structure

What lives where, and the rules that keep it that way.

## Harness objects

| Object | Where | What it is |
| --- | --- | --- |
| Steering | `.kiro/steering/` | always-on rules; one domain per file |
| Skill | `.kiro/skills/<name>/SKILL.md` | one reusable procedure, loaded on demand by its description |
| Agent | `.kiro/agents/<name>.md` | a spawnable role: system prompt, tools, resources |
| Spec | `.kiro/specs/<name>/` | one job's contract: goal contract, requirements, design, tasks, cards, fixtures |
| Handoff | `handoffs/` | the rolling state between sessions: handoff, loop log, retro register |
| Script | `scripts/*.ps1` | optional helpers; the markdown works without them |
| Hook | `.kiro/hooks/*.json` | a Kiro trigger that runs a script and returns its output to the agent |

Edit every object under `.kiro/` directly. Nothing there is generated. The skills routing
table is `docs/skills-routing.md`; the agents roster is `docs/agents-roster.md`.

## When to make one

- A procedure you have followed by hand twice and will follow again: a skill. Extend an
  existing skill before creating one. Procedure: `skill-authoring`.
- A worker brief you have written two or three times: an agent. Procedure: `agent-authoring`.
- A transform whose inputs and outputs are known in advance: a script, not an agent.

## Folder hygiene

- A folder shows a small set of job-named subfolders, not loose files. The names alone must
  explain the structure.
- A new file goes into the subfolder whose name states its job. A new job class gets a new
  subfolder.
- At about ten files in one folder, split it by job.
- Generated output, run evidence, and anything with real data stay out of this repo.

## Documents

- Write like developer documentation: plain declarative sentences, one idea per sentence,
  no flourishes, no emoji.
- Markdown: blank lines around headings, lists, and fenced blocks; fenced blocks carry a
  language; no duplicate headings in a file; wrap prose near 100 columns.
- Cross-reference skills and agents by name in backticks. Cite paths only inside this repo.
- Update the nearest README when structure changes.

## Budgets

- Always-on steering (this folder) stays under 32 KB in total. Add a rule by removing one.
- A skill stays under 12 KB. Move depth into its `references/` folder.
- A sub-agent's return is capped in its brief: the verdict plus the top findings, each with a
  file and line. Long reasoning goes in a file the agent writes; it returns the path.

## Context assembly

What is in the window at each phase of the flow in `00-session-opener.md`. Each phase adds to
the one before it.

| Phase | In context |
| --- | --- |
| Boot | steering, the handoff, the memory index (`handoffs/memory/INDEX.md`) |
| Intake | plus `goal-definition` and the operator's message |
| Spec | plus `spec-authoring` and the cards |
| Build | plus the one task, the files it touches, and the delegate-or-inline chart |
| Wrap | plus `context-checkpoint` |

- Load the skill for the phase you are in, not the next one.
- Before any run longer than a few turns, write the current state (decisions, the file list,
  the next step) to `handoffs/LOOP_LOG.md`, so an automatic compaction cannot lose it.
- Put the instruction that matters most at the top of a brief and repeat the stop condition
  at its end.

## Code

- Match the project's language. Scripts for this harness are Windows PowerShell 5.1: no
  `&&`, no `??`, no ternary; write files with `-Encoding utf8`.
- No background daemons, no extension installs, no external services unless the design names
  them and the operator approved them.
- Surgical edits. Change only what the task needs. No unrequested features.

## Source control

- The remote at work is GitLab. A public mirror may exist elsewhere. Say "the remote".
- Commit at checkpoints with a message that starts with the session number (`S3:` for
  session 3). The session number is the live block's number in `handoffs/LOOP_LOG.md`; a
  new session takes the next number. Never commit real data or anything that fails
  `scripts/check-redaction.ps1`.
