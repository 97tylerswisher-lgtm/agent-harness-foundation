# Fixtures

Every file here is synthetic. The values are generated from simple formulas and mean nothing.
The shape matches `cards/schema-card.md`.

| File | Variation |
| --- | --- |
| `run_001.txt` | Clean: 2 comment lines, tab-delimited, all six columns |
| `run_002.txt` | Extra comment line (catalog row 1) |
| `run_003.txt` | Comma-delimited (catalog row 3) |

Each file carries 20 data rows. To make fixtures from a real file at work, use
`scripts/distill-fixture.ps1` outside the IDE and review the output before it enters.
