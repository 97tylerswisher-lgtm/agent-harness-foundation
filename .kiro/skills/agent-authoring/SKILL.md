---
name: agent-authoring
description: How to create or edit a Kiro custom agent file (.kiro/agents/<name>.md). Covers the front matter field by field (name, description as the routing trigger, model, tools tags, excludedTools, allowedTools, permissions, resources, mcpServers), the body as system prompt (role line, operating rules, return spec), the blind-spawn protocol for critics, the minimal resources rule (skills it uses plus the method and data-boundary steering only), and the landing checklist (roster row, blind audit by instruction-auditor). Read before writing or editing any agent definition, choosing an agent's tools or model, or wiring a skill or steering file into an agent. The when-to-mint gate lives in agent-orchestration-workflows; shared description and body craft lives in skill-authoring. Keywords - agent file, custom agent, sub-agent, persona, front matter, system prompt, tools, resources, blind agent, roster.
---

# Agent Authoring Guide

An agent file is `.kiro/agents/<name>.md`, where Kiro reads it. The file is YAML front matter
plus a body. The body becomes the agent's system prompt when it runs. A skill is instructions
any reader loads on demand; an agent is a role with its own tool grants and a clean context.

A sub-agent is the same file. An orchestrator whose `tools` include `subagent` invokes it.
Sub-agents run in parallel with isolated context. They see steering only through their
`resources` list. Write every agent as if it wakes up knowing nothing about the project.

## When to mint

Mint an agent when the same worker brief has been hand-written two or three times with a stable
contract. Before that, spawn a general worker with the brief in the prompt. A knowable transform
is a script, not an agent. The full gate and the delegate-or-inline chart live in
`agent-orchestration-workflows`. At every wrap, name candidates at or near the gate in the
handoff instead of deferring them silently (`context-checkpoint`).

## Front matter, field by field

- `name` (required): lowercase letters, digits, hyphens. Matches the filename exactly.
- `description` (required): the routing trigger. Same craft as a skill description
  (`skill-authoring`): what the agent does, when to call it, domain keywords. Keep it under
  1024 characters. Agent-specific additions: the per-spawn unit ("one artifact per spawn"),
  any spawn protocol the orchestrator must honor ("spawn blind: hand it the artifact and the
  goal only"), and the negative boundary ("not for critique; that is `skeptic`"). The protocol
  lives here because the spawner reads only the description when choosing.
- `model` (optional): omit for builders and workers so they inherit the session model. Pin a
  model only for blind critics and judges that need the strongest tier, and repeat the reason
  in the body. An unknown model name falls back with a warning, so check the exact identifier
  in the Kiro docs before pinning. Never pin as a silent default.
- `tools` (optional; omit = all): tags from `read`, `write`, `shell`, `web`, `subagent`, or
  `*`. Grant only what the role needs. Coherence check in both directions: every ability the
  body's rules mention must exist in the grant, and no grant may contradict the body's claims.
  A "read-only reviewer" with `write` is a defect. A "writes its report to disk" rule with no
  `write` is a defect.
- `excludedTools` (optional): tools removed from the grant. Use it to carve one tag out of a
  broad grant instead of listing everything else.
- `allowedTools` (optional): glob patterns for tools that run without a prompt. Keep it narrow;
  a wide glob turns a bounded role into an unattended one.
- `permissions.rules` (optional): a list of `{capability, match, effect}` entries. Use it to
  fence `shell` or `write` to specific paths, for example allow `write` matching
  `handoffs/**` and deny everything else for a wrap agent.
- `resources` (optional): what the agent can load. Entries are `skill://<name>` for a skill and
  `file://<path>` for a file. See the minimal resources rule below.
- `mcpServers`, `includeMcpJson` (optional): leave unset unless the role cannot work without a
  server confirmed available on the target machine.

## The body is a system prompt

Write to the agent in second person, imperative. It reads the body as its identity.

1. Role line: one sentence. "You are a bounded builder that implements one task from a spec."
2. Operating rules: a short list of bounded behaviors, each with a one-clause why. Include the
   standing rules the role must keep: no source-control writes, no paid calls, no edits outside
   the named paths, honest reporting of anything that failed.
3. Return spec: "Your final message is the return. No preamble, no sign-off." State the cap
   (a word count or a fixed shape) and the required fields: what was written with paths, what
   was verified with the witnessed command, what did not get done.

Do not restate steering in the body. Steering the agent needs goes in `resources`; the body
points to it in one line ("Follow `.kiro/steering/20-method.md`.").

## The blind-spawn protocol

A critic that sees the builder's reasoning inherits the builder's blind spots. For `skeptic`,
`fresh-eye`, `goal-critic`, `architecture-critic`, `mechanism-critic`, and `handoff-verifier`,
bake the blindness into the file so it survives a rushed spawn:

- In the description: "Spawn blind. Give it only the artifact and the goal statement."
- In the operating rules: what the agent must not read (the handoff, the loop log, the spec's
  design notes, any prior review) and what it must do if the spawn prompt includes them
  (state that the protocol was broken, then proceed on the artifact alone).
- In `resources`: no `file://handoffs/...` entries. The critic's `resources` hold only the
  skill it executes plus the two steering files named below.

Divergence between a blind critic and the builder is the signal. Do not resolve it by handing
the critic more context; resolve it by fixing the artifact or the goal statement.

## The minimal resources rule

An agent receives no steering unless `resources` lists it. List exactly:

- `skill://<name>` for each skill the body tells the agent to execute.
- `file://.kiro/steering/20-method.md` (backwards design, judge first).
- `file://.kiro/steering/40-data-boundary.md` (what may enter the IDE).

Never list the whole steering folder. The opener and operator-profile files are for the primary
session; they cost context on every spawn and change nothing the sub-agent does. Add another
`file://` entry only when the body names that file as an input.

A `skill://` entry makes the skill available; the spawn prompt makes it mandatory: "Read the
`<name>` skill first and follow it exactly. Inputs: ... Return: <capped>." Use both.

Example front matter for a builder:

```yaml
---
name: code-worker
description: Bounded builder. Implements ONE task from an active spec and returns paths plus
  witnessed check results. Not for design or critique.
tools: [read, write, shell]
resources:
  - skill://backwards-design
  - file://.kiro/steering/20-method.md
  - file://.kiro/steering/40-data-boundary.md
---
```

## Landing checklist

- [ ] Roster row added to `docs/agents-roster.md`. Capability facts (tools, model, spawn protocol)
      match the file exactly. A divergence between row and file is drift.
- [ ] Blind audit before commit: spawn `instruction-auditor` over the new or edited file with
      the file and the goal only. The author does not audit their own agent.
- [ ] Coherence check passed: body rules against `tools`, body inputs against `resources`.
- [ ] `resources` holds the skills used plus the two steering files, nothing else.
- [ ] Every cited path resolves on disk. Markdown lint clean (`common-pitfalls`).
- [ ] Invocation confirmed once from the Kiro agent picker and from an orchestrator with
      `subagent`.

## Related skills

- `skill-authoring`: description as router, body style, merge-over-create.
- `agent-orchestration-workflows`: when to mint, the delegation prompt checklist, the blind
  modifier, the delegate-or-inline chart.
- `common-pitfalls`: markdown lint rules for the file you are writing.
