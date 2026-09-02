---
title: Data boundary
inclusion: always
---

# Data boundary

Real project data never enters this IDE. This rule has no exceptions and no override.

## What may enter

- Synthetic fixtures under `.kiro/specs/<name>/fixtures/`: the real file shape with invented
  values.
- The three cards under `.kiro/specs/<name>/cards/`: schema card, edge-case catalog, and
  interface card. They describe shape, structure, and entry points, never content. The
  fixtures and the three cards together are the four step-zero artifacts.
- Public tool facts: how a language, a library, an application, or a command line works.
- The operator's own words about the job, after the operator has checked them against the
  list below.

## What never enters

- A real data file, or any row, value, or excerpt from one.
- A real path, server name, share name, or filename that identifies a program, part, test,
  or customer.
- A program name, part number, drawing number, test identifier, or project code.
- The body of an existing script or macro. Its signature (name, arguments, what it reads,
  what it writes) may enter through the interface card.
- Anything marked controlled, export-controlled, proprietary, or internal-only.

## What you do

1. Read the operator's message. Before you quote any part of it into a file, or build on a
   value, name, or path in it, run the list above. If an item could be on it, stop and say
   which line, in one sentence. Do not proceed on a guess.
2. When you need to know a data shape, ask for the card or the fixture. Do not ask for "a
   sample". Do not infer the shape from a description and build on the inference.
3. When you write a script that will touch real data at work, it runs outside this IDE and
   its output is reviewed by the operator before any of it comes back in.
   `scripts/distill-fixture.ps1` is the shape-extraction tool for that; see
   `data-distillation`.
4. Before every commit, `scripts/check-redaction.ps1` must pass. At work, replace
   `banned-terms.txt` with the site list. The list is a backstop, not the rule.

## Why this is written for you

You cannot tell controlled data from public data by looking at it. The operator can. Your
job is to notice the boundary and hand the decision to the operator every time it is close.
Asking one extra time costs a sentence. Missing once cannot be undone.
