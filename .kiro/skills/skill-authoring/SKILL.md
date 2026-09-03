---
name: skill-authoring
description: Rules for creating, structuring, and maintaining skills under .kiro/skills/<name>/SKILL.md. Read BEFORE creating a new skill, editing any SKILL.md, writing or revising a front matter description, bundling reference files or helper scripts into a skill folder, or deciding whether to extend an existing skill or mint a new one (merge-over-create). Covers how Kiro loads skills, the naming and front matter limits, progressive disclosure limits, body style, path rules, proactive capture signals, the routing-table update rule, and the pre-publish quality checklist. Keywords - skill, SKILL.md, front matter, description, routing table, merge-over-create, references folder, scripts folder, progressive disclosure, capture a pattern.
---

# Skill authoring

## How skills work

Kiro loads each skill's `name` and `description` at startup. It loads the body only when the
description matches the current task or the operator types `/<name>`. The description decides
whether the skill is ever used at all.

Each skill lives at `.kiro/skills/<name>/SKILL.md`, where Kiro reads it.

## Folder structure

```text
.kiro/skills/
  <skill-name>/
    SKILL.md          required, the procedure, under 500 lines
    scripts/          optional, bundled helper scripts
    references/       optional, bundled reference material
    assets/           optional, templates and static files
```

Naming rules:

- The folder name is lowercase letters, digits, and hyphens, at most 64 characters.
- The front matter `name` equals the folder name exactly.
- The `description` is at most 1024 characters.

## The description carries all the triggers

Write every triggering context into the front matter description: the situations, task types,
and keywords that should route an agent here. Long and direct is correct, because it is the
only text the agent sees before deciding to load the body. A short polite description on a
critical skill means the skill silently never fires.

- State WHAT the skill contains and WHEN to reach for it ("Read BEFORE...", "Use when...").
- Include the domain nouns and synonyms an agent would search for.
- Name what is NOT included when misrouting is likely.
- Do not put use-when triggers only in the body; the description must stand alone as the
  router.

Bad example: `description: Helpful information about reports.` No trigger, no keyword. Good
example: this file's own front matter.

## Body rules: progressive disclosure

- Keep SKILL.md under 500 lines. The body holds the procedure and the decisions; it is not an
  archive.
- Move big reference material to `references/` in the skill folder. The body keeps a one-line
  pointer in the form "read `references/X.md` when Y". The agent then loads detail only when
  the task needs it.
- Give a reference file over about 300 lines a table of contents at the top, so an agent can
  jump instead of reading linearly.
- Turn repeated helper code into a script in the skill's `scripts/` folder, referenced from the
  body, not a code block the agent re-types each use.
- Remove sections that do not change an agent's actions. Ask on every update; if the answer
  is nothing, delete the section.

## Body rules: style

- Imperative voice. Write instructions as commands ("Run the gate", not "the gate should be
  run").
- Explain the why. A rule with its reason survives contact with edge cases; a bare rule gets
  misapplied. One clause of reasoning is usually enough.
- Label examples. Mark them good or bad and say what property makes them so.
- No all-caps directives without reasoning, because an agent applies a justified rule more
  reliably than a loud one.
- Markdown lint clean; the rules live in `common-pitfalls`.

## Path and reference rules

- Relative paths only, from the repo root or from the skill folder for bundled files. Absolute
  paths break the moment a repo is cloned or moved.
- Every cited path must resolve on disk at authoring time, because no gate reads skill prose
  and a dead pointer fails nothing until an agent acts on it.
- Cross-references use the skill name in backticks and point only at skills in `.kiro/skills/`.
- Verify API-reference skills against live official docs at authoring time, because a skill
  written from model memory can ship a fabricated API surface. For any external API detail
  (model IDs, endpoints, parameters, prices): check each load-bearing claim, stamp each section
  with the source URL and access date, and mark unverified items LOW-CONFIDENCE.

## SKILL.md template

```markdown
---
name: <skill-name>
description: <what it contains, when to load it, domain keywords; under 1024 characters>
---

# <Title>

## <Procedure sections>

(Imperative voice; reasons attached; examples labeled; pointers as "read X when Y".)

(Last section: Related skills, one line per linked skill, name in backticks.)
```

## When to create a new skill: merge-over-create first

Create a skill when a topic recurs across sessions, a pattern must stay consistent, or
documentation would prevent a recurring mistake. Do not create one for one-off information or
a topic an existing skill already covers.

Before creating, run the merge check:

1. Skim `docs/skills-routing.md` (the routing table) for overlap.
2. Check the Related skills sections of the nearest candidates.
3. Extend the existing skill unless the topic is genuinely new. A roster of few, deep skills
   routes better than many shallow ones.

When updating an existing skill: keep its scope, update its Related skills, and route
recurring errors to `common-pitfalls`.

## Proactive skill capture

Proposing skills is the agent's job, not the operator's. Watch for these signals during and at
the end of every session:

- You re-derived something a past session already figured out. Write it down.
- You searched more than 3 times or read many files to reconstruct how a subsystem works. The
  conclusion is a skill or a README row.
- A pattern or decision recurred twice or more. Encode it.
- You produced hard-won external research a future session will need.
- The operator had to ask for a skill. That is a miss; log in `handoffs/LOOP_LOG.md` why the
  signal did not fire.

When a signal fires, draft the skill or the update yourself and show the operator the text. Do
not stop at "should I make a skill?". Run the merge check first, then add the routing-table
row. The wrap step in `context-checkpoint` sweeps for anything missed mid-flight.

## Context maintenance

When you create or modify a skill, update `docs/skills-routing.md` (add or revise the routing
row). That file is the single roster; do not keep a skill list inside any skill, because duplicate rosters drift. When a task
reveals an undocumented subsystem, fix it inline: update the nearest README and prefer pointer
comments over full rewrites.

## Quality checklist

Before publishing a skill:

- [ ] `name` equals the folder name and meets the naming limits
- [ ] `description` is under 1024 characters and carries all use-when triggers and domain
      keywords (the router test: would an agent that only reads descriptions load this at
      the right moment?)
- [ ] SKILL.md under 500 lines; big reference material moved to bundled files with
      "read X when Y" pointers; reference files over 300 lines have a TOC
- [ ] Imperative voice; rules carry their why; examples labeled
- [ ] Paths are relative and every cited path resolves on disk
- [ ] Markdown lint clean (full rules in `common-pitfalls`)
- [ ] Related skills rows point at skills that exist in `.kiro/skills/`
- [ ] Routing-table row added or updated in `docs/skills-routing.md`

## Related skills

- `agent-authoring`: the agent-file HOW; reuses the description and body craft from here.
- `common-pitfalls`: markdown lint rules and recurring errors.
- `context-checkpoint`: the wrap step that sweeps for missed capture signals.
