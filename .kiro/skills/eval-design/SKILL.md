---
name: eval-design
description: How to define and audit an eval so it can fail. Covers the closed question, the answer space, the pass bar set before the run, known-bad calibration, maker is not checker, persisted inputs and outputs, and the decision each outcome triggers. Use before writing any judge, rubric, grader script, gate, review question, or acceptance criterion, before trusting a number a judge produced, and periodically to audit the judges already in use. Prevents the open-ended-question eval ("is this good?") that praises everything and corrects nothing. Keywords - eval, judge, rubric, grader, gate, calibration, known-bad, vacuous pass, decision mapping.
---

# Eval design

An eval that cannot fail is not an eval. This skill defines what an eval must contain before it
runs, how to audit one that already exists, and the failure mode each rule prevents.

## When to use this skill

- Before writing any judge, rubric dimension, grader script, gate, or acceptance bar.
- Before trusting a number a judge produced.
- When a metric keeps saying PASS while the operator or a direct look at the output says NO.
- Periodically: run the audit questions in section 4 over every judge in use.

## 1. What an eval is

An eval is a repeatable measurement. Four parts, all required:

1. A frozen question. The exact words are written down before the run and do not change
   during it.
2. A closed answer space. Forced choice (A/B/C, PASS/FAIL, "which one is ours?") or a bounded
   number (0-10, a count, a percentage). Never free prose as the verdict.
3. A pass bar stated before the run. "At least 95% of rows parse" is a bar. "It should work" is
   not.
4. An instrument that has proven it can say NO. It has been shown a known-bad input and it
   failed that input.

If any of the four is missing, you do not have an eval. You have an opinion with a number
attached. A score no input can lower is a constant, not proof of quality.

## 2. The definition checklist

Every eval states all eight fields, in writing, before it runs. Copy this table into the eval's
doc (the spec's `design.md` Human gate section, or the eval's own README).

| # | Field | The test it must pass |
| --- | --- | --- |
| 1 | Question text | Frozen before the run, quoted verbatim in the artifact |
| 2 | Answer space | Forced choice or bounded scalar, never open prose |
| 3 | Baseline | The chance rate or noise floor the result is compared against |
| 4 | Calibration set | Known-good and known-bad, separated beyond noise, before use |
| 5 | Maker is not checker | The thing judged was not made by the judge or by the judge's context |
| 6 | Persisted inputs and outputs | Prompts, shuffle key, assignments, raw answers, in the repo |
| 7 | Decision mapping | Each outcome names a system correction; no correction means cut the eval |
| 8 | Re-certification | Any change to the instrument or its text triggers a fresh calibration run |

Notes on the fields people skip:

- Baseline (3). A judge that picks the target output out of a five-item lineup 20% of the time
  is at chance. Without the baseline written down, 20% reads like a failure. Noise-floor version:
  run the instrument twice on the same input; whatever moves is noise, and real movement must
  exceed it.
- Calibration set (4). Feed it one input you know is good and one you know is bad. If the
  number does not separate them beyond noise, the instrument is blind. Prose agreement is not
  separation; the scalar has to move.
- Maker is not checker (5). A judge that shares a model, a context window, or a prompt lineage
  with the maker grades its own habits. Spawn the checker as a separate sub-agent with only the
  question and the inputs. See `agent-orchestration-workflows` for blind-critic setup.
- Persisted inputs and outputs (6). The number must be reproducible from committed files, not
  from a chat transcript or a sub-agent result that evaporated.
- Decision mapping (7). Write the sentence "if it says X we do Y" for every outcome. If every
  outcome leads to the same action, the eval is dead weight. Delete it.
- Re-certification (8). Save the exact text or config that earned the calibration stamp as a
  standalone file at certification time. Any edit needs a fresh calibration round before its
  verdicts count.

## 3. Worked examples

### Bad: the open-ended review question

A code review gate asks a sub-agent: "Would you merge this?" Why it fails:

- No anchor. No reference implementation or checklist sits beside the diff.
- Maker and checker are the same model family, so the checker approves its own habits.
- It passes work the operator rejects on sight: an unhandled empty-file case, a swallowed
  exception, a hardcoded path. A gate that passes what a human rejects measures nothing.
- No decision mapping. Nothing changes differently at a 92% merge rate versus 85%.

The fix is a closed checklist: "Does the diff handle an empty input file? YES/NO, cite the
line." Each NO maps to a named fix.

### Bad: the vacuous pass

A closed, reproducible eval is still bad if its inputs never reach the failure. A data-file
parser test reports 52/52 green. In production the parser silently drops rows. All 52 cases
ran one fixture in comma-delimited form; the live files are tab-delimited, and the parser has no
tab branch and no fallback. 52/52 was true for commas and said nothing about tabs, because the
test never tried tabs. Coverage is part of the eval, not a footnote.

### Good: the report correctness count

Question: "How many rows in the generated report have a total that does not equal the sum of
their line items?" Answer space: an integer. Method: a script over the report file and its
source data. Pass bar: 0.

- Closed question, integer answer, anyone can re-run the script and get the same number.
- Decision-mapped: failures all in one section point at that section's aggregation step;
  failures spread across sections point at the input join.
- It still needs a coverage audit. If the script skips the appendix tables, it can report 0
  while the appendix is wrong. Good evals get audited too.

## 4. The audit questions

Run these on every judge and eval in the system, periodically and always before trusting a new
one. Answer them in writing. An eval that cannot answer all seven is annotation-only until it
can. It never acts as a gate.

1. Could this eval ever fail? Name the concrete input that would make it say NO.
2. What known-bad has it actually failed? Cite the case and the date. "It should catch that"
   is not evidence. A witnessed failure is.
3. Is the question closed? Forced choice or bounded number. If the verdict is prose, it is not
   closed.
4. Does the input set cover the classes the verdict will be applied to? If it only ever saw
   comma-delimited files, it says nothing about tab-delimited ones.
5. What decision changes on each outcome? Write "if X then Y" for every outcome. If Y is the
   same for all of them, cut the eval.
6. Who audits the auditor, and when was it last audited? Name the checker (not the maker) and
   the date.
7. Is the number reproducible from committed files? Point at the file. Not a chat, not a
   sub-agent result that is gone.

Where to run them: `system-self-inquiry` fires this list at every session and phase boundary.
`context-checkpoint` is where the answers land in the handoff. Record an eval that fails the
audit as one row in `handoffs/RETRO.md`.

## 5. The failure mode this prevents

The no-improvement loop. An open-ended judge is asked "is this good?" It says yes, with
reasons. You change something. It says yes again, with different reasons. Nothing was
falsifiable, so nothing corrected. The loop burns budget while the defect sits untouched.

A self-correcting system needs something that can say NO, at a specific input, for a stated
reason, mapped to a named fix. Section 2 exists to make that NO reachable.

## Anti-patterns

- Verdict as prose. "Looks solid overall" is not a measurement.
- Bar set after the run. A threshold chosen once the numbers are in fits the numbers.
- Calibration by assertion. "It would catch that" without a witnessed known-bad failure.
- Fixture monoculture. One fixture, one format, one size, then a verdict applied to all.
- Same-outcome mapping. Every result leads to "proceed", so the eval changes nothing.
- Silent instrument edits. The rubric text changed and the old calibration stamp stayed.
- Tuning the bar to pass. Moving the threshold instead of fixing the thing measured.
- Perfect pass streak. A gate that has never failed anything is a rubber stamp. Track its
  fail rate; a 100% pass streak is an alarm.

## Related skills

- `goal-definition` defines the judge at goal level (real versus proxy, calibrated versus
  annotate-only). This skill defines how that judge is built and audited.
- `backwards-design` derives what the judge should measure from the output's downstream
  consumer.
- `agent-orchestration-workflows` supplies maker-is-not-checker, blind critics, and the
  adversarial-verification setup (checklist field 5).
- `system-self-inquiry` fires the section 4 audit list at every session boundary.
