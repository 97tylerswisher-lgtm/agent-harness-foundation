Copy this file to `.kiro/specs/<kebab-name>/design.md`. Replace every angle-bracket
placeholder. Keep the seven sections in this order. Delete these instruction lines when done.

# Design: <job name>

## Overview

<Three sentences. Input: what comes in and in what form. Output: what goes out and in what
form. Judge: who or what decides the output is right.>

## Mechanism

The literal data path, one line per hop. Name the format at each hop from the schema card.

1. Source: `<file pattern from the schema card>` (<format, delimiter, encoding>)
2. Transform: <what happens> in `<script or tool>`, producing `<intermediate file>` (<format>)
3. Transform: <what happens> in `<script or tool>`, producing `<intermediate file>` (<format>)
4. Output: `<output file>` (<format>), delivered to <consumer>

## Invocations

Every external command in its exact form. A command not listed here is not run.

Invocation 1: <what it does>

```powershell
<exact command, with arguments>
```

Working directory: `<relative path>`. Expected exit code: `<0>`. Produces: `<file>`.

Invocation 2: <what it does>

```powershell
<exact command, with arguments>
```

Working directory: `<relative path>`. Expected exit code: `<0>`. Produces: `<file>`.

## Data boundary

- Enters the IDE: `cards/schema-card.md` (one table per file type), `cards/edge-case-catalog.md`,
  `cards/interface-card.md`, and the synthetic files under `fixtures/`.
- Never enters the IDE: <the real input files, described by role, for example "the weekly
  export from the instrument">. The runner reads them only when the operator runs it outside
  the IDE.
- Missing card: <name the card that is still missing, or "none">.

## Human gate

- Reviewer: <role>.
- Reviews: <the artifact, for example "the generated PDF next to the hand-built one">.
- Form: <how it is presented, for example "both files open side by side">.
- Automation stops at: <the exact step; nothing after it runs without the reviewer's approval>.
- Approval is recorded in: <where, for example "the status ledger row for the gate">.

## Verification

- Command: `<the one command the operator runs>`.
- Artifact: `<the file it produces>`.
- Gating check: <the calibrated check that must pass, or "none; the human gate is the only
  gate">.
- Annotate-only check: <the check that reports but does not block, or "none">.
- Pass condition: <one sentence a person can confirm>.

## Status ledger

| Step | Status | Evidence |
| --- | --- | --- |
| <hop 1 from Mechanism> | not started | |
| <hop 2 from Mechanism> | not started | |
| <invocation 1> | not started | |
| <invocation 2> | not started | |
| Human gate | not started | |
| Verification run | not started | |

Status values: `not started`, `in progress`, `done`, `blocked`. Evidence is a path or a
command result.
