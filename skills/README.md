# Skills routing table

Each skill lives at `skills/<name>/SKILL.md` (source of truth). `scripts/install-kiro.ps1`
copies the tree to `.kiro/skills/`. Kiro loads every `name` and `description` at startup and
loads a body only when the description matches the task or the operator types `/<name>`.

This table is the single roster. When you add or change a skill, update its row here and
nowhere else. Authoring rules: `skill-authoring`.

| name | use when | loads |
| --- | --- | --- |
| `system-self-inquiry` | Starting a session, picking up a task, or about to build on a structure you did not derive; asks and answers the goal-alignment and architecture-coherence questions before work starts | `SKILL.md` |
| `backwards-design` | Deriving any role, step, agent, or goal by working backwards from its output and its judge; deciding file vs LLM call vs sub-agent, sequential vs parallel, and success criteria | `SKILL.md` |
| `goal-definition` | Turning the operator's fuzzy request into a goal contract (judge, done-when, minimum inputs, roles, do-not-touch scope, verification artifacts) before any large build starts | `SKILL.md` |
| `ask-operator-gate` | Feeling the urge to ask the operator a question; exhausts files, research, defaults, and self-inquiry first, then batches only genuine intent, spend, time, or approach forks into one prose block | `SKILL.md` |
| `eval-design` | Writing or auditing any judge, rubric, grader, gate, or acceptance criterion; makes the eval a closed question with a pass bar set before the run and a known-bad calibration | `SKILL.md` |
| `agent-orchestration-workflows` | A task needs parallel workers, blind verification, or loop-until-done execution, or risks bloating the orchestrator's context; decides delegate vs inline and routes the spawn | `SKILL.md`, `references/` (delegate-or-inline and spawn-router charts) |
| `skill-authoring` | Creating or editing any SKILL.md, writing a description, bundling references or scripts, or deciding extend vs mint (merge-over-create) | `SKILL.md` |
| `agent-authoring` | Creating or editing an agent file: front matter fields, tools grant, resources, the body as system prompt, and the landing checklist | `SKILL.md` |
| `common-pitfalls` | Creating or editing markdown, hitting an error that feels familiar, or working around PowerShell and Windows quirks; the markdown lint rules live here | `SKILL.md` |
| `self-learning-research` | A request is high-level or dictated, a technical detail is missing or may have drifted, or research findings need a permanent home on disk | `SKILL.md` |
| `new-knowledge-triage` | Absorbing external agent-engineering content (a thread, a video, an article, a found repo) and deciding adopt, pilot, defer, archive, or discard with a closed verdict | `SKILL.md` |
| `flowchart` | Charting a decision tree, a procedure, a data path, or a gate sequence as a standard flow chart in mermaid with a permanent `.flowchart.md` file | `SKILL.md` |
| `context-checkpoint` | Wrapping a session or checkpointing mid-task: the retro questions, folding the loop log into the handoff, and the wrap order | `SKILL.md` |
| `spec-authoring` | Turning a goal contract into `.kiro/specs/<name>/requirements.md` (EARS), `design.md`, and `tasks.md`, including the status ledger and the named human gate | `SKILL.md`, `references/` (spec skeletons) |
| `data-distillation` | Step zero before any build over real data: getting the schema card, synthetic fixtures, edge-case catalog, and interface card from the operator or `scripts/distill-fixture.ps1` | `SKILL.md`, `references/` (card templates) |
