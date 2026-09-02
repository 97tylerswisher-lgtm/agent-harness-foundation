# Edge-case catalog: rig export file

Synthetic. Every variation the existing macro already handles, stated so new code handles the
same set. Each row names a fixture when one exists. Row 6 is a machine variation, not a file
variation; it is listed here because it changes what the runner writes.

| # | Variation | Expected handling | Fixture |
| --- | --- | --- | --- |
| 1 | A third comment line before the column header | Skip every leading line that starts with `#`; do not count them | `fixtures/run_002.txt` |
| 2 | `ch04_ue` column missing | Parse the columns present; plot only the channels found; do not fail | none (describe only) |
| 3 | Comma delimiter instead of tab | Detect the delimiter from the column header line: tab if present, else comma | `fixtures/run_003.txt` |
| 4 | Trailing summary block starting with `# summary` | Stop reading at that line; nothing after it is data | none (describe only) |
| 5 | Blank lines anywhere | Skip | none |
| 6 | The machine's list separator is `;` (regional setting), so Excel's own CSV export is not comma-delimited | Never use Excel's CSV export. The runner writes the CSV itself: comma delimiter, ASCII, no BOM, CRLF | none (environment, not a file) |

## Out of scope

Rows with a different field count from the header are an error. The script stops with a
message that names the file and the line number.
