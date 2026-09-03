# The plan-critique panel

Source of truth: the lenses, protocol, and fold discipline of the plan-critique panel for
`agent-orchestration-workflows`. The skill body holds only a pointer; edit here.

Run the panel before building, on any non-trivial plan, design, or foundation. It is
adversarial verification where lens diversity, not redundancy, is the point. One generalist
`skeptic` with one brief leaves the goal and architecture lenses self-graded, which
`system-self-inquiry` forbids.

## Lenses

One blind critic each:

1. Goal-alignment (`goal-critic`): does the plan serve the goal at the right priority and
   scope, or is it drift, a means mistaken for the end, or gold-plating? Rubric: the goal
   contract and `goal-definition`.
2. Architecture-coherence (`architecture-critic`): the right module boundary, or accreted
   cruft, conflated axes, a category error? Rubric: `system-self-inquiry`.
3. Mechanism (`mechanism-critic`): trace the real data path (source, transform, output).
   Where does it leak or pass vacuously?
4. Product or market (`skeptic` with a per-lens brief): who is the customer and what job do
   they hire the output for? Stress-test the goal itself, not just the plan against it.

## Protocol

- Blind: each critic gets only the artifact, the goal, and its lens. Never your reasoning or
  conclusion. Divergence is the signal.
- Verify against artifacts: each critic checks claims on disk. This catches a stale premise.
- Parallel: one barrier; fold all findings; reconcile divergences before committing.
- Scale to task: mechanical edits skip the panel. A foundation artifact gets the three named
  lenses together. Goal-shaping or axis work adds the product or market lens as a fourth. A
  single small claim gets a lone `skeptic`. The soundness pass is the mechanism lens; do not
  double it.
- Sharpen each lens: brief in the premortem grammar ("assume the plan has already failed;
  why?"). Require a forced verdict plus a 0 to 100 confidence. When folding, cluster
  findings by root cause, then name the single highest-leverage fix.

## Folding

Confirm, not rescue. The panel is a seatbelt, not the steering wheel.

- Trace first. Before spawning, trace the real data path, boundary, and consumer yourself
  and draft against that. If the panel's central catch is something a literal trace would
  have surfaced, the miss was yours: fix the first-pass habit.
- Verify every load-bearing claim against disk before folding. A blind critic is told to
  find fault, so it returns findings regardless, some wrong or overstated. Read the cited
  `file:line`; fold only what holds. Neither auto-accept the critic nor defend the draft.
- Show what you rejected, not only what you accepted. Every fold reports the findings you
  threw out and why. Rejecting nothing is the yes-man alarm.
- Delegate the check; keep the verify-and-fold.

## Hit-rate

Track the hit-rate across folds: true and load-bearing, false or overstated, cosmetic. All
true every time means a weak first draft; reject nothing means yes-man. The ratio tells you
which imbalance you have.
