# agent-harness-foundation

A harness for running an AI coding agent on real engineering work in the Kiro IDE: what the
agent reads at boot, how it turns a request into a spec, how it keeps controlled data out of
the IDE, when it stops for a human, and how it hands off to the next session. Plain markdown
plus three optional PowerShell scripts. No extensions, no MCP, no Node required.

It is written for a model that follows explicit structure and does not infer missing steps.
Every step names the file that governs it.

## Clone and go

1. Clone this repo into the project folder, or copy `.kiro/`, `docs/`, `handoffs/`,
   `scripts/`, and `AGENTS.md` into an existing project.
2. Open the folder in Kiro. The files under `.kiro/steering/` load on every turn. Skills and
   agents under `.kiro/` are picked up automatically.
3. Replace `scripts/banned-terms.txt` with the site list (program names, part numbers, project codes).
4. Start a chat. The agent reads `.kiro/steering/00-session-opener.md`, then
   `handoffs/NEXT_AGENT_HANDOFF.md`, and asks for the first project request.

Optional: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-redaction.ps1`
before every commit. `scripts/README.md` describes the three scripts. The markdown works without them.

The Ponytail coding-style ruleset (MIT, see `NOTICE`) is included: `.kiro/steering/ponytail.md`
loads every turn, `.kiro/steering/platform-native.md` on request, and four `ponytail-*` skills. Its
trimmed source, refreshed from upstream, is `https://github.com/97tylerswisher-lgtm/ponytail_kiro`;
copy its `.kiro/steering/` and `.kiro/skills/` entries over these when it updates.

## The flow

```mermaid
flowchart TD
    A([Session starts]) --> B[Read steering, handoff, active spec]
    B --> C{New project?}
    C -- yes --> D[Intake: goal contract<br/>goal-definition]
    C -- no --> M[Resume at the handoff's next step]
    D --> E{Does any input touch<br/>controlled data?}
    E -- yes --> F[Ask for cards and fixtures<br/>data-distillation]
    E -- no --> G
    F --> G[Spec: requirements, design, tasks<br/>spec-authoring]
    G --> H[Operator reviews the spec]
    H --> I[Build tasks; delegate and blind-check<br/>agent-orchestration-workflows]
    I --> J{Human gate reached?}
    J -- yes --> K[Stop. Operator reviews the output.]
    J -- no --> I
    K --> L[Wrap: loop log, handoff, retro row<br/>context-checkpoint]
    M --> I
    L --> Z([Session ends])
```

## Layout

```text
AGENTS.md                 the five-line boot note for tools that read only AGENTS.md
.kiro/
  .kiro/steering/               always-on rules; one domain per file
    00-session-opener.md  read order, the flow, the rules that hold every turn
    10-operator-profile.md  who the operator is and how to talk to them
    20-method.md          design backwards, name the judge, do not self-grade
    30-structure.md       what lives where, hygiene, budgets, source control
    40-data-boundary.md   real data never enters the IDE
    ponytail.md           the Ponytail laziness ladder (always on)
    platform-native.md    native-vs-dependency reference (on request)
  .kiro/skills/<name>/          procedures loaded on demand; includes the four ponytail-* skills
  .kiro/agents/<name>.md        spawnable roles
  hooks/                  harness-checks.json: check-spec -All after each task,
                          check-redaction when the agent stops
  specs/<name>/           one folder per job: goal contract, cards, fixtures,
                          requirements, design, tasks; the example adds
                          run-report.ps1 and stubs/
docs/                     skills-routing.md (the skills routing table),
                          agents-roster.md (the agents roster and worker contract)
handoffs/                 NEXT_AGENT_HANDOFF.md, LOOP_LOG.md, RETRO.md
scripts/                  check-redaction.ps1, distill-fixture.ps1, check-spec.ps1,
                          banned-terms.txt
```

Edit steering, skills, agents, and specs under `.kiro/` directly. Nothing there is generated.
The two hooks in `.kiro/hooks/` make the spec and redaction checks mechanical inside Kiro;
`.kiro/hooks/README.md` says when they run and how to disable one.

## Reuse across projects

Default: clone this repo as the project, or copy `.kiro/`, `handoffs/`, `scripts/`, `AGENTS.md`,
and `NOTICE` into an existing project. Each project keeps its own specs, handoffs, and memory.

Global option: Kiro merges `~/.kiro/steering`, `~/.kiro/skills`, `~/.kiro/agents`, and
`~/.kiro/hooks` into every workspace, so the skills, agents, hooks, and the method, structure,
data-boundary, and Ponytail steering files can live there once. Keep `00-session-opener.md`
and `10-operator-profile.md` in each project's `.kiro/steering/`: the opener pulls
`handoffs/NEXT_AGENT_HANDOFF.md` and `handoffs/memory/INDEX.md` by workspace-relative path, which
is not documented for global steering, and a global agent's `file://` resources resolve against
the agent file's own folder. Specs are workspace-only either way.

## The worked example

`.kiro/specs/text-to-vba-to-matlab-to-pdf/` walks the flow once on a synthetic job: delimited
text files land in a folder, an existing spreadsheet macro reshapes them, an existing MATLAB
function writes a PDF report, a person reviews the PDF. It shows the goal contract, the three
cards, synthetic fixtures, EARS requirements, a design that names every invocation, a task
list, and a one-command runner. Nothing in it is real data. It is a reference, not a template
to copy values from.

## Rules in one place

- Real project data never enters the IDE. Shape enters through cards and synthetic fixtures.
- The agent decides execution; the operator decides intent, spend, time, and approach.
- A plan or result is checked by a blind critic before it is relied on.
- Every human gate the design names is a full stop.
- The handoff is rewritten at every wrap; the next session verifies it against disk.

## License

MIT. See `LICENSE`.
