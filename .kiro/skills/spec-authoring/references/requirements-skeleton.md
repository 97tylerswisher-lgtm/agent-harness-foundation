Copy this file to `.kiro/specs/<kebab-name>/requirements.md`. Replace every angle-bracket
placeholder. Delete these two instruction lines when done.

# Requirements: <job name>

## Introduction

<One paragraph. What the job produces, who consumes it, and which goal contract it comes from.
Example: "This job turns a weekly instrument export into a one-page PDF summary that the team
lead reads on Monday. It implements goal-contract.md in this folder.">

## Requirements

### Requirement 1

User Story: As <role>, I want <capability>, so that <outcome>.

Acceptance Criteria:

1. WHEN <condition or event> THE SYSTEM SHALL <observable behavior>
2. WHEN <condition or event> THE SYSTEM SHALL <observable behavior>

### Requirement 2

User Story: As <role>, I want <capability>, so that <outcome>.

Acceptance Criteria:

1. WHEN <condition or event> THE SYSTEM SHALL <observable behavior>
2. WHEN <condition or event> THE SYSTEM SHALL <observable behavior>

### Requirement <n>: scope fence

User Story: As the operator, I want the job to stop at the data boundary and the human gate, so
that <outcome>.

Acceptance Criteria:

1. WHEN <a real data file, path, or identifier would enter the IDE> THE SYSTEM SHALL stop and
   report instead of reading it
2. WHEN <the step before the human gate> completes THE SYSTEM SHALL stop and show the operator
   <the artifact> before any later step runs
3. WHEN <any other do-not-touch condition from the goal contract> THE SYSTEM SHALL <stop and
   report>

## Checks before showing the operator

- Every done-when criterion in `goal-contract.md` maps to one requirement.
- Every criterion has one condition and one observable behavior.
- No criterion contains a real value, path, name, or identifier.
- Criteria are numbered <story>.<item> so `tasks.md` can cite them (1.1, 1.2, 2.1).
