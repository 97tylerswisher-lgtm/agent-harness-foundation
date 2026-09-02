# START HERE - handoff

> The rolling state between sessions. The wrap of each session rewrites it. Every state claim
> here is a map to verify against disk, not a fact. Commit state is never recorded here; run
> `git log` and `git status` yourself.

## Zoom-out

No project session has run in this repo yet. The harness was assembled from a prior project
and reduced to what a fresh session needs. The worked example under
`.kiro/specs/text-to-vba-to-matlab-to-pdf/` shows the full flow once, on synthetic data.

## Mandate for the next session

1. Confirm the environment: ask the operator for the Kiro version (Help, About is a menu
   only they can read), check whether `node --version` works,
   whether `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-redaction.ps1`
   runs.
   Record the answers under State below.
2. Read the worked example end to end: `goal-contract.md`, the three cards, `requirements.md`,
   `design.md`, `tasks.md`. Do not run it on real data.
3. Start the operator's first real project at the Intake step of the flow in
   `steering/00-session-opener.md`: ask for the request, write the goal contract with the
   `goal-definition` skill, stop, and show it.

## State

- Environment at work: not yet recorded.
- Active spec: none. The worked example is a reference, not an active job.
- Scripts: `install-kiro.ps1`, `check-redaction.ps1`, `distill-fixture.ps1`, `check-spec.ps1`
  under `scripts/`; tested on the authoring machine, untested at work.

## Operating contract

- The flow in `steering/00-session-opener.md` is the order of work. Intake before spec, spec
  before build, gate before anything public or irreversible.
- Real data never enters the IDE (`steering/40-data-boundary.md`).
- Decide and log; escalate only business, spend, time, and approach forks
  (`ask-operator-gate`).
- Blind critic before relying on a plan or a result (`agent-orchestration-workflows`).
- Edit `steering/`, `skills/`, `agents/` at the root and run `scripts/install-kiro.ps1`;
  edit `.kiro/specs/` directly.

## Pending operator asks

1. The first real project request, in the operator's own words.
2. The site `banned-terms.txt` (program names, part numbers, project codes) before the first
   commit at work.

## Settled

- Kiro specs are the job contract. There is no second contract format.
- Scripts are optional PowerShell. The markdown works without them.
- The worked example stays synthetic and light. It is not a template to copy values from.

## Verification boundary

The worked example's runner was dry-run on the authoring machine: the Excel step and the PDF
check passed with synthetic fixtures; the MATLAB step did not run because that machine's
MATLAB license had expired (retro row R0-4), so `stubs/make_report.m` is unexecuted. Nothing
has been run at work. The first session at work re-verifies before trusting any claim here.

## Latest checkpoint

Session 0 (assembly). Trail: `handoffs/LOOP_LOG.md`.
