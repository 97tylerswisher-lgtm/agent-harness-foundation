Copy this file to `.kiro/specs/<name>/goal-contract.md` and replace every angle-bracket
placeholder. Keep the six headings exactly as written; `scripts/check-spec.ps1` checks them.
Keep the `Phase:` line while only the requirements exist; remove it once the cards and the
design are in.

# Goal contract: <job name>

Phase: requirements

## 1. The judge

<The real outcome, who or what judges it, and the proxy that stands in at build time. State
whether the proxy is calibrated (gates) or not (annotates only). Cover fit and craft.>

## 2. Done-when

1. <A declarative criterion verified against an artifact, not a report.>
2. <...>

## 3. Minimum inputs

| Input | Cheapest source |
| --- | --- |
| <input> | <a file, a card, a fixture, an operator answer, a sub-agent> |

## 4. Roles and tiers

<Which agents do what, and on which model tier. "This session, inline" is a valid entry.>

## 5. Do-not-touch

- Real project data never enters the IDE (`steering/40-data-boundary.md`).
- <The human gate this job stops at.>
- <Anything the operator listed.>

## 6. Verification

- <The artifacts that prove success, by path.>
- <Where run state lands: the spec's status ledger, the loop log.>
