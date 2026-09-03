---
name: goal-definition
description: Intake gate that turns the operator's fuzzy, multi-part, or dictated ask into a six-field Goal Contract (the judge, done-when criteria, minimum inputs, roles and model tiers, do-not-touch scope, verification artifacts) before any spec is written or any large multi-agent run starts. Use it when the real objective must be derived rather than guessed, when "what does done look like" is not answerable in one sentence, or when a long autonomous run is about to begin and scope drift must be pre-empted. Output is .kiro/specs/<name>/goal-contract.md, the input to spec-authoring. Keywords - goal definition, goal contract, success criteria, define the judge, proxy judge, do-not-touch, scope fence, intake, derive the goal, before the spec.
---

# Goal definition

A long run optimizes whatever goal it was given. A fuzzy goal makes agents climb a hill with
no definition of up. Writing the goal down is the cheapest calibration lever available. This
skill reuses `backwards-design`, `agent-orchestration-workflows`, and `self-learning-research`;
it does not replace them.

## When to use

- After the operator hands over a fuzzy, multi-topic, or dictated ask and the real objective must
  be derived, not guessed.
- Before `spec-authoring` writes `requirements.md`, `design.md`, and `tasks.md`.
- Before a large dynamic workflow or a loop-until-done run starts.
- Any time "what does done look like here" cannot be answered in one sentence.

## The output: a Goal Contract

Write one short markdown file at `.kiro/specs/<name>/goal-contract.md`, starting from
`references/goal-contract-skeleton.md` (its six headings are what `scripts/check-spec.ps1`
verifies). It is the input to the
`spec-authoring` skill. Do not write the spec or launch the work until all six fields are
non-empty. Each field maps to a real failure it prevents.

| # | Field | What it pins down | Prevents | Source method |
| --- | --- | --- | --- | --- |
| 1 | The judge | The real outcome, the proxy that stands in for it, whether the proxy is calibrated or annotate-only, and coverage of both fit (on target) and craft (well made) | Self-grading; hill-climbing with no "up" | `backwards-design`, `eval-design` |
| 2 | Done-when | Numbered declarative success criteria, each verified against an artifact, not a report | Partial work declared finished | `spec-authoring` (EARS requirements) |
| 3 | Minimum inputs | Each input and its cheapest source: a file, a line of code, an LLM call, or a sub-agent, in that order | Bloated context; dumping whole upstream outputs | `backwards-design` |
| 4 | Roles and tiers | The sub-agents or roles, the model tier for each, and the delegation checklist each worker echoes back | Wrong-tier workers; ad-hoc orchestration | `agent-orchestration-workflows` |
| 5 | Do-not-touch | The scope fence: the data boundary in `.kiro/steering/40-data-boundary.md`, the spec's human gate, and anything the operator listed | Goal drift into forbidden surfaces or past the human gate | Steering plus the operator |
| 6 | Verification | The artifacts that prove success, and where run state lands at the closing checkpoint | An unverifiable "done"; a lost handoff | `context-checkpoint` |

Field-to-failure check, said while filling the contract: no judge means the run grades its own
work kindly; no done-when means the run stops early and calls it finished; no do-not-touch means
drift wanders into forbidden surfaces. Fields 1, 2, and 5 exist because of those three failures.

## The interrogation

Run the three steps in order, mostly silently. Derive; do not interview. The aim is to
reconstruct the operator's underlying objective from the raw context, then show it is ready.

### Step 1. Autopsy the ask (derive the real goal)

Use the goal reverse-engineering sequence from `self-learning-research`: human goal, then target
spec, then gap analysis.

1. Read the raw ask. Separate the objective from the musings, examples, and constraints.
2. State the underlying goal in one sentence: "The real goal is to ___, judged by ___."
3. List what is stated, what is implied, and what is missing.

### Step 2. Pull from the end (define the judge)

Anchor at the final output and answer the `backwards-design` questions:

1. Who or what consumes the final output?
2. What exact output does that consumer need?
3. What is the minimum input?
4. What is the cheapest source for each input?
5. Is a new agent needed, or does a file or a line of code do the job?
6. What is the judge?

For generative goals, define the evaluator, not the artifact. Name the real judge and the proxy
judge, and state whether the proxy covers fit and craft.

### Step 3. Downstream-readiness pass (pre-empt the three failure modes)

From `agent-orchestration-workflows`:

- Laziness: write the numbered done-when checklist that workers must echo back.
- Self-grading: name the generator and a different judge now; write the rubric before generating.
- Goal drift: paste the do-not-touch list and the restated criteria into every delegation.

## Hard rules (exit conditions)

1. All six fields are non-empty before the spec is written or a large run launches. A field that
   cannot be filled means the goal is not ready: fill it or surface it under rule 4.
2. Real-versus-proxy honesty. If the proxy judge is not calibrated against a real outcome, the
   work may run only in observe or annotate mode. It never gates. See `eval-design` for how a
   proxy gets calibrated.
3. Spend and irreversible actions are gated, not pre-approved. Paid calls, large irreversible
   actions, and anything that crosses the data boundary go to the operator before they happen.
   Independently, gate the launch on completeness and safety.
4. Ambiguity becomes one decision block, never a stream of questions. Batch genuine intent forks
   into a single "Open decisions" section at the end of the contract and ask the operator in a
   prose block, following `ask-operator-gate`. Research technical gaps silently. The gate exits
   when the contract is complete and no human fork is left open.

Limit: this gate runs on the honor system. Nothing enforces it mid-run. The discipline is to
write the contract file first, then start.

## Worked sketch

Dictated ask: "I want the weekly instrument export to turn into the summary report on its own,
like the one I build by hand in Excel, and I don't want to click through five steps. Also maybe
we could add the trend chart the team keeps asking for."

Step 1. Real goal: "Produce the weekly summary report from the instrument export with one
command, judged by a reviewer who confirms it matches the hand-built report." The trend chart is
a musing; park it in Open decisions.

Step 2. Consumer: the team lead who reads the PDF. Output: one PDF per weekly export. Minimum
inputs: the export schema card, the edge-case catalog, one 20-row synthetic fixture. Cheapest
sources: the cards from `data-distillation`, a script for the transform, no LLM in the path.
Judge: the operator's side-by-side review of the PDF against a hand-built report (proxy: a
script that checks page count and the presence of every required section).

Step 3. Done-when: (1) `run-report.ps1` produces a PDF from the synthetic fixture; (2) the
section check passes; (3) the operator signs off one review. Roles: one code-worker at the
default tier; one fresh-eye critic to blind-check the PDF. Do-not-touch: real export files never
enter the IDE (`.kiro/steering/40-data-boundary.md`); the human PDF review in the spec's design is
never automated; the trend chart is out of scope until the operator decides.

Gate: the proxy check is uncalibrated, so it annotates and the human review gates. One open
decision remains (the trend chart), so the contract stops and asks before `spec-authoring` runs.

## Related skills

- `backwards-design` supplies the judge derivation and the cost ladder (fields 1 and 3).
- `eval-design` supplies the calibration path for a proxy judge (rule 2).
- `agent-orchestration-workflows` supplies the failure modes, tiers, and delegation checklist
  (field 4), and runs the work this skill gates.
- `ask-operator-gate` supplies the shape of the Open decisions block (rule 4).
