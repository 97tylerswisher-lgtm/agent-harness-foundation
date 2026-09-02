# Stubs

These stand in for the real macro and the real MATLAB function, which are never shipped and
never enter the IDE. Their only job is to let `run-report.ps1` run end to end on the synthetic
fixtures.

| Stub | Stands in for | Notes |
| --- | --- | --- |
| `make_report.m` | The real `make_report(inputCsv, outputPdf)` | Reads the CSV, plots strain channels against time and load against time, prints one PDF |
| (none) | `ReshapeData` in `reshape.xlsm` | No stub. With `-MacroName` omitted, `run-report.ps1` writes the parsed table to a new workbook and saves it, so the dry run needs no macro-enabled workbook and no VBA trust setting |

At work, point `run-report.ps1 -FunctionFolder` at the folder that holds the real function and
pass `-MacroName ReshapeData -MacroWorkbook <path to reshape.xlsm>`.
