# Schema card: rig export file

Synthetic. The shape of the real export, with generic names and fake values. Filled by the
operator outside the IDE per `data-distillation`.

## File

| Field | Value |
| --- | --- |
| Filename pattern | `run_<NNN>.txt` |
| Encoding | ASCII (UTF-8 without BOM is also accepted) |
| Line ending | CRLF |
| Header lines | 2 comment lines, each starting with `#` |
| Delimiter | Tab (see the edge-case catalog for the comma variant) |
| Column header | One line, column names as below, same delimiter as the data |
| Row count | Tens to a few thousand; fixtures carry 20 |

## Columns

| Column | Type | Unit | Notes |
| --- | --- | --- | --- |
| `time_s` | numeric | seconds | Monotonic, starts at 0 |
| `load_kN` | numeric | kilonewtons | Applied load |
| `ch01_ue` | numeric | microstrain | Strain channel 1 |
| `ch02_ue` | numeric | microstrain | Strain channel 2 |
| `ch03_ue` | numeric | microstrain | Strain channel 3 |
| `ch04_ue` | numeric | microstrain | Strain channel 4, may be absent |

## Not in this card

Real rig names, specimen identifiers, program names, and measured values never enter the IDE.
The comment lines in the fixtures carry placeholder text only.
