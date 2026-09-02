---
name: self-learning-research
description: >-
  Reverse-engineer a vague goal or raw dictation into a target spec, run the
  Context Threshold Test before touching code, pick a research channel
  (in-IDE web search or fetch, a research-worker sub-agent, or documents the
  operator supplies), and write findings to disk so they are never researched
  twice. Use when a request is high-level or dictated, when a technical
  detail, library parameter, or API signature is missing or may have drifted,
  or when fresh research needs a permanent home in the repo.
---

# Self-learning research

## When to use this skill

- The operator gives a high-level goal, a vague request, or raw microphone dictation.
- A technical specification, module contract, or API detail is missing or may be out of date.
- Before any code change or shell command, to run the Context Threshold Test.
- To choose a research channel when the test fails.
- To store newly learned facts so the next session does not pay for them again.

## 1. Goal reverse-engineering

Do not guess from a high-level prompt. Work backwards from the goal before writing code.

```text
Operator goal -> Target spec -> Gap analysis -> Knowledge requirements
```

1. Deconstruct the prompt. State the primary objective and list every implied component (a
   pipeline step, an external API, a script, an output file).
2. Write the target specification. Describe what success looks like in technical terms:
   inputs, outputs, and the judge that decides pass or fail. The `goal-definition` skill
   holds the full contract shape.
3. Run a gap analysis. Scan the repo for files, modules, and configuration that already
   cover part of the target. Read the handoff file and the active spec under
   `.kiro/specs/<name>/` first.
4. Draft the knowledge requirements. Write a checklist of the technical details the build
   needs: schemas, parameter shapes, version capabilities, format limits.

## 2. The Context Threshold Test

Run this test before every code edit or shell command that depends on external facts.

| Result | Condition | Action |
| --- | --- | --- |
| PASS | You know the exact file paths, parameter structures, type signatures, and project rules the change needs. | Proceed to planning and execution. |
| FAIL | You are missing a technical specific, guessing at an API shape, facing a naming conflict, or unsure whether a version supports a feature. | Stop. Do not make a silent assumption. Go to section 3. |

## 3. Research protocol

When the test fails, check local sources first, then pick the cheapest external channel that
can answer the question. Never call a paid research API; the operator owns spend.

### Local first

1. Search `skills/*/SKILL.md` and any `references/` folder beside a skill or spec.
2. Search `handoffs/RETRO.md` and `handoffs/LOOP_LOG.md` for a prior answer.
3. Read the active spec's `design.md` and its `cards/` folder if present.

If a local file answers the question, use it and stop.

### External channels

| Channel | Use for | Notes |
| --- | --- | --- |
| In-IDE web search or fetch | A syntax lookup, a package version, a standard error message, one documentation page. | Fetch the page only if the site allows it. Prefer the vendor's own docs over a summary site. |
| `research-worker` sub-agent | Multi-page reading, comparing several sources, or a question whose answer needs synthesis. | Give it the knowledge-requirements checklist from section 1 and a bounded return shape (max rows, word cap, source URLs). It returns text only and writes no files; you write its findings to disk per section 4. |
| Operator-supplied documents | Any question when the network is blocked or the source is behind a login. | Ask in a prose block. Name the exact document or page you need and why. |

When the source is a version-sensitive fact (a model name, a library release, a CLI flag),
record the date and the source URL or document name next to the finding.

## 4. Write-back protocol

Research that stays in the chat window is lost at the next session. Write every finding to
disk before you use it.

1. Route the finding. The `new-knowledge-triage` skill decides whether it belongs in the repo
   at all and which class it is.
2. Process lessons go to `handoffs/RETRO.md` as one row: what happened, what to change.
3. Technical facts, schemas, and API shapes go to a `references/<topic>.md` file beside the
   skill or spec that needs them. Give the file a descriptive name and a one-line header that
   states the source and date.
4. If the research yields a reusable procedure, write a new skill under
   `skills/<name>/SKILL.md` per the `skill-authoring` skill.
5. List the written files in the wrap summary so the next session finds them.

Never re-research a fact that already has a file. If the file looks stale, update it and note
the date; do not create a second copy.

## 5. Decoding dictated intent

Voice-dictated prompts carry pacing, repetition, and conversational structure. Decode before
acting.

1. Filter the pacing. Drop filler phrases and verbal style.
2. Isolate the intent. Capture the core objectives and the technical elements named. Example:
   "convert the monthly export to a summary report and check the totals against last month"
   yields two objectives and one comparison rule.
3. Draft the specification. Translate the intent into a structured list of sub-problems and
   the parameters each one needs.

## 6. Ask or research

The full gate lives in the `ask-operator-gate` skill. The short form:

| Gap type | Action |
| --- | --- |
| Operator intent, business rule, product behavior, spend, or a public action | Ask the operator in a prose block. |
| Technical syntax, library parameter, API signature, tool capability | Research per section 3. Do not ask. |

## Related skills

- `goal-definition`: the goal contract that section 1 produces.
- `ask-operator-gate`: the full ask-or-proceed gate that section 6 summarizes.
- `new-knowledge-triage`: whether and where a finding enters the repo.
- `skill-authoring`: structure and description rules for a new skill.
