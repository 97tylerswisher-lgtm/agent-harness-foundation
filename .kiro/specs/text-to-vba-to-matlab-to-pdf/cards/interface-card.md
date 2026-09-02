# Interface card: existing entry points

Signatures only. Bodies never enter the IDE. The `stubs/` folder carries stand-ins with the
same signatures so the flow can be dry-run.

## Excel macro

| Field | Value |
| --- | --- |
| Workbook | `reshape.xlsm` (not shipped) |
| Macro | `ReshapeData` |
| Signature | `Public Sub ReshapeData()` |
| Input | The active sheet holds the parsed table, header in row 1, data from row 2 |
| Output | The active sheet holds the reshaped table in place |
| Failure | The macro halts with a runtime error; the caller sees a COM exception |
| Invocation | `Application.Run "ReshapeData"` after `Workbooks.Open` on `reshape.xlsm` |

## MATLAB function

| Field | Value |
| --- | --- |
| File | `make_report.m` (real version not shipped; stub in `stubs/`) |
| Signature | `make_report(inputCsv, outputPdf)` |
| `inputCsv` | Path to a comma-separated file with a header row of the schema-card columns |
| `outputPdf` | Path to write; overwritten if present |
| Return | None. Errors raise; `matlab -batch` turns an error into a non-zero exit code |
| Invocation | `matlab.exe -batch "addpath('<folder>'); make_report('<in>','<out>')"` |
