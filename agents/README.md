# Agents

Each file in this folder is one spawnable role: front matter (`name`, `description`, `tools`,
`resources`) plus a system prompt body. The description states when to use the role. The
orchestrator picks a role from the roster below and hands it a numbered task contract. Blind
roles receive only the artifact and the goal, never the orchestrator's reasoning.

## Roster

| Name | Use when | Tools | Blind? |
| --- | --- | --- | --- |
| `skeptic` | Judge a plan, spec, or claim before committing; single generalist pass | read, shell | yes |
| `mapper` | Inventory named files or folders, citation-backed, no opinions | read, shell | no |
| `research-worker` | Distill external knowledge; falsify a claim against web sources | read, shell, web | no |
| `code-worker` | Build a bounded, named-path change in the project language | read, write, shell | no |
| `fresh-eye` | First impression of one image, document, or page; glance then detail | read, shell | yes |
| `goal-critic` | Panel lens: does the plan serve the goal at the right scope | read, shell | yes |
| `architecture-critic` | Panel lens: are module boundaries clean or conflated | read, shell | yes |
| `mechanism-critic` | Panel lens: trace the data path; can its checks fail | read, shell | yes |
| `handoff-verifier` | At wrap or on a stale smell: FRESH or STALE with heal rows | read, shell | no |
| `instruction-auditor` | Audit one skill, agent, or steering file: format, pointers, bloat | read, shell | yes |

Panel size follows the artifact. A foundation artifact (a plan, a design, a spec) gets the
three named lenses together, spawned in parallel on the same artifact. Goal-shaping or axis
work adds a product or market lens as a fourth (`skeptic` with a per-lens brief). A single
small claim gets a lone `skeptic`.

## Standing worker contract

Every spawned worker honors these six rules in addition to its spawn prompt's numbered task
contract. The spawn prompt cannot relax them.

1. Echo the contract. End your work by repeating the spawn prompt's numbered contract with each
   item marked done or not done, plus one line of evidence each (a path, a hash, a witnessed
   command result). Unfinished items are stated plainly.
2. Lean return. The final message is data for the orchestrator, not prose for a human: the
   result in the requested shape, within its caps. Long reasoning goes in an artifact file only
   when the contract names one; return its path, not its body.
3. No git writes. No stash, checkout, reset, commit, branch, or push. Read-only git (`status`,
   `log`, `diff`) is allowed. Git mutations belong to the orchestrator.
4. No paid or external calls. No metered API, no external service, no network call outside the
   harness web tool where the role has it. Spend and external actions are the orchestrator's to
   escalate.
5. Never edit files the contract did not name. New outputs go only to named paths or their
   obvious children. Anything the active spec's do-not-touch list or the data-boundary steering
   protects is off limits. When a contract seems to require such an edit, stop and report.
6. Honest hiccups. Report what actually happened: a failed step, a mismatched hash, a default
   you chose, a check you could not run. A disclosed limitation is a contribution; a quiet
   workaround is a defect.

## Writing a new agent

Read `agent-authoring` first. Mint an agent only after the same worker brief has been written
by hand two or three times. Add the roster row here in the same change.
