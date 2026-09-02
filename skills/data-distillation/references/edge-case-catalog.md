Copy this file to `.kiro/specs/<kebab-name>/cards/edge-case-catalog.md`, one per spec. The
operator fills it from the existing code and its fix history, outside the IDE. Every variation
the existing code already handles gets one row. Delete these instruction lines when done.

# Edge-case catalog: <job name>

## How to fill it

- One row per variation. Say how it is detected and what the correct handling is.
- Describe the case by shape, never by the real record that caused it.
- Add a fixture named for the case when the default fixture cannot show it.
- Every row here becomes at least one acceptance criterion in `requirements.md`.

## Cases

| # | Case | Applies to | How it is detected | Correct handling | Fixture |
| --- | --- | --- | --- | --- | --- |
| 1 | <Extra header line> | <file role> | <line 1 does not match the column header pattern> | <skip lines until the header row matches> | <fixtures/<name>-extra-header.txt> |
| 2 | <Missing column> | <file role> | <header row has fewer names than the schema card> | <stop and report the missing name> | <fixtures/<name>-missing-column.txt> |
| 3 | <Different delimiter> | <file role> | <first data row splits into one field on the expected delimiter> | <try the alternate delimiter from the schema card, then stop> | <> |
| 4 | <Trailing summary block> | <file role> | <a line starting with <marker> after the last data row> | <stop reading at the marker> | <> |
| 5 | <Empty file> | <file role> | <zero bytes or header only> | <produce an empty output and report> | <> |
| 6 | <Duplicate rows> | <file role> | <two rows with the same key columns> | <keep the last; report the count> | <> |
| 7 | <Out-of-range value> | <column> | <value outside <min> to <max>> | <flag the row; do not drop it> | <> |
| 8 | <Encoding mismatch> | <file role> | <byte order mark present or absent> | <read with the encoding from the schema card> | <> |

## Cases the existing code does not handle

<List variations the operator knows about that currently break the existing code. These are
candidates for new requirements, not silent fixes.>

- <case>
- <case>

## Review

- Filled by: <the operator, on <date>>
- Source: <the existing script names by role, read outside the IDE>
