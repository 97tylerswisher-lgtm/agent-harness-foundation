# Workflow patterns

Source of truth: the seven-pattern table and its routing rule for `agent-orchestration-workflows`.
The skill body holds only a pointer; edit here.

Route by the question the spawn must answer. Chart: `spawn-strategy-router.flowchart.md` in
this folder. Numbers are the names briefs use.

| You need | Pattern | Why it wins | Cost, and when it hurts |
| --- | --- | --- | --- |
| "What is this?" (task type unclear) | 1. Classify-and-act: a cheap router sends the task to a specialist | One router beats N wrong specialists; tiering cuts cost | Only when the classification is reliable; a misroute poisons everything after it |
| "What exists?" (facts from many places) | 2. Fan-out readers (mapper-class); synthesizer only per rule 6 of the delegate-or-inline decision | Each reader's context is disposable; you absorb digests | N returns land in your window: cap each; the synthesizer is a failure surface; useless when items interact |
| "Do this N times" (3+ similar items) | 2. Fan-out workers (rule 5 shape) | Parallel wall-clock; items cannot cross-contaminate | Parallel edits collide (isolate or serialize); code has fewer parallel-safe tasks than research |
| "Is this real?" (confidence before acting) | 3. Adversarial verification: a separate verifier per producer against a rubric; a skeptic over the verifiers kills false positives | A maker grades itself kindly; refuters have no stake | A verifier that misses launders the claim; keep an "unverified" state and verify before folding |
| "Give me options" (an open space) | 4. Generate-and-filter: overproduce, cull by rubric, dedupe, return survivors | Selection beats perfection | Rubric before generating or the filter is taste; best-of-N is the baseline any fancier shape must beat |
| "Which is best?" (comparable candidates) | 5. Tournament: pairwise brackets | Pairwise holds where absolute scores are unstable across judges | N-1 pairs to pick one, about N log N to rank; try absolute 0-1 scoring first; incomparable candidates make every pair noise |
| "Find them all" (unknown volume) | 6. Loop-until-done: passes until a stop condition holds | A fixed pass count always under- or over-shoots | Fails both ways (repetition, or a premature stop): stop on two no-progress rounds and a pass cap |
| "Make this better" (one artifact, clear rubric) | 7. Evaluator-optimizer: maker, critic, revise, 1 to 3 rounds | Converges when the critic's feedback is usable | Loops forever without a closed rubric; maker is not checker; cap the rounds |

## Routing rule

Pick by the failure you fear, then pay that pattern's cost. False positives: adversarial
verification behind any producer (fan-out plus refute-per-finding is the default). Missed
items: wrap the run in loop-until-done. Picking wrong: a tournament after generate-and-filter.
Unclear task type: classify-and-act in front. Two patterns is the normal pair; beyond two,
write the sequence as an ordered task list before spawning. Prompt chaining (steps with a gate
between) is the shape of one worker's contract, not a fan-out pattern. When nothing fits: one
worker with a capped return, then reassess.

The blind modifier in the skill body applies to every row.
