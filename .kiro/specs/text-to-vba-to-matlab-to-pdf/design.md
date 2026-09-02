# Design: text-to-vba-to-matlab-to-pdf

## Overview

Input: delimited text exports (`run_<NNN>.txt`, tab or comma delimited, ASCII, CRLF, with
`#` comment lines) in one folder. Output: one `<name>.pdf` per export in the output folder,
next to `<name>.xlsx`, `<name>.csv`, and the MATLAB output files. Judge: the operator, who
opens each PDF and compares it with the hand-built report; the script's exit code and PDF
check only annotate.

## Mechanism

One script, `run-report.ps1` (Windows PowerShell 5.1, no module), runs the hops in order and
stops at the human gate. Exit codes: 0 ok, 1 input or parse error, 2 Excel failure, 3 MATLAB
failure, 4 PDF check failure.

1. Source: `run_<NNN>.txt` (tab-delimited, or comma-delimited per catalog row 3; ASCII;
   CRLF; leading `#` comment lines; optional `# summary` block at the end)
2. Transform: parse in `run-report.ps1` (`Read-ExportFile`), producing an in-memory table
   (header array plus one `double[]` per row; every field parsed with the invariant culture)
3. Transform: load the table into a new Excel workbook through COM, run the macro when
   `-MacroName` is given, read the sheet back after the macro, in `run-report.ps1` step 1,
   producing `<name>.xlsx` (Excel workbook, format 51, saved by Excel) and `<name>.csv`
   (comma-delimited, ASCII, no BOM, CRLF, written by the script; Excel's CSV export is not used
   because it follows the machine's list separator, catalog row 6). With `-SkipExcel` only the
   CSV is written.
4. Transform: `matlab.exe -batch` calls `make_report('<csv>','<pdf>')` in `run-report.ps1`
   step 2, producing `<name>.pdf` (PDF, written by MATLAB), `<name>.matlab.log` (MATLAB's own
   output via `-logfile`), `<name>.matlab.stdout.txt` and `<name>.matlab.stderr.txt` (the
   process streams; empty ones are deleted after the run)
5. Transform: PDF check in `run-report.ps1` step 3 (`Get-PdfPageCount`): exists, size > 0,
   page count from `/Type /Page` objects; producing one log line per PDF and the gate line
6. Output: `<name>.pdf` (PDF), delivered to the operator at the human gate

## Invocations

Every external command in its exact form. A command not listed here is not run. The lines
below are copied from `run-report.ps1`.

Invocation 1: Excel via COM (step 1). One `Excel.Application` serves every table.

```powershell
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$macroWb = $excel.Workbooks.Open($MacroWorkbook)          # only when -MacroName is given
$wb = $excel.Workbooks.Add()
$ws = $wb.Worksheets.Item(1)
$ws.Range($ws.Cells.Item(1, 1), $ws.Cells.Item($nRows, $nCols)).Value2 = $arr
$ws.Activate()
$excel.Run($MacroName)                                    # only when -MacroName is given
$t = Read-SheetTable $ws                                  # only when -MacroName is given
$wb.SaveAs($xlsx, 51)                                     # Excel saves only the .xlsx
Write-CsvTable $t $csv                                    # comma CSV from this script
$wb.Close($false)
$macroWb.Close($false)                                    # only when -MacroName is given
$excel.Quit()
```

Each object is then passed to `Release-Com`, which calls
`[System.Runtime.InteropServices.Marshal]::ReleaseComObject`. `Quit` and the releases run in
a `finally` block. Working directory: any; the script resolves `-OutputFolder` to an absolute
path before step 1. Expected result: no COM exception; a COM exception from any line (a halted
macro surfaces from `Application.Run`) is logged and becomes script exit 2. Produces:
`<name>.xlsx`, `<name>.csv`.

Invocation 2: MATLAB (step 2), once per CSV.

```powershell
$cmd = "addpath('{0}'); make_report('{1}','{2}')" -f $FunctionFolder, $csv, $pdf
$proc = Start-Process -FilePath $matlab -ArgumentList @('-batch', ('"' + $cmd + '"'), '-logfile', ('"' + $log + '"')) `
    -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdout -RedirectStandardError $stderr
$code = $proc.ExitCode
```

The command line this builds:

```powershell
matlab.exe -batch "addpath('<FunctionFolder>'); make_report('<out>\<name>.csv','<out>\<name>.pdf')" -logfile "<out>\<name>.matlab.log"
```

Working directory: the caller's current directory; the script sets none, and every path in
the command is absolute. Expected exit code: `0`. A non-zero code is logged and becomes script
exit 3. Produces: `<out>\<name>.pdf`, `<out>\<name>.matlab.log` (MATLAB's own output, kept
because `matlab.exe` on Windows does not attach to the parent console),
`<out>\<name>.matlab.stdout.txt` and `<out>\<name>.matlab.stderr.txt` (the redirected process
streams; a file that is still empty after the run is deleted). Wall-clock time is logged.

Invocation 3: PDF check (step 3), in-process, once per PDF.

```powershell
$latin1 = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
$text = $latin1.GetString([System.IO.File]::ReadAllBytes($Path))
return ([regex]::Matches($text, '/Type\s*/Page\b')).Count
```

Working directory: any. Expected result: the file exists, size > 0, count >= 1; otherwise
script exit 4. The `\b` excludes the `/Type /Pages` tree node. Produces: one log line with
path, size, and page count, then the gate line.

## Data boundary

- Enters the IDE: `cards/schema-card.md`, `cards/edge-case-catalog.md`,
  `cards/interface-card.md`, the synthetic files under `fixtures/`, and the stand-ins under
  `stubs/` (real signatures, synthetic bodies).
- Never enters the IDE: the real exports from the rig, the real macro workbook, the real
  MATLAB function, and any rig, program, or part identifier. The runner reads them only when
  the operator runs it outside the IDE.
- Missing card: none.

## Human gate

- Reviewer: the operator (the person who builds the report by hand today).
- Reviews: each `<name>.pdf` from step 3 next to the hand-built report for the same export.
- Form: the PDF opened in a viewer; the step-3 log line gives its path, size, and page count.
- Automation stops at: the gate line printed after step 3. Filing, mailing, sign-off, and any
  later step are not automated and are not part of this spec.
- Approval is recorded in: a line in `handoffs/LOOP_LOG.md` under "Operator questions and
  answers" (the question names the run and the PDFs; the answer is the operator's verdict).
  The Human gate row of the status ledger below is then set to `done` with that line as its
  evidence.

## Verification

- Command: `.\run-report.ps1 -InputFolder .\fixtures -OutputFolder <out>`, run from the spec
  folder; `<out>` is any folder outside the repo.
- Artifact: `<out>\<name>.pdf` for each fixture, plus the console log.
- Gating check: none; the human gate is the only gate.
- Annotate-only check: script exit 0 and one step-3 line per PDF (size > 0, page count >= 1).
- Pass condition: the script prints three step-3 lines and the gate line and exits 0.

Two runs are recorded. Neither is a complete pass: the MATLAB step has never run on the
authoring machine because its MATLAB license had expired (`matlab -batch "disp(1+1)"` fails
the same way), so task 10 in `tasks.md` stays open.

Run 1: real Excel, real MATLAB launch, earlier script revision. Edits to the raw output: the
`HH:mm:ss` timestamp prefix removed from every line; the spec folder, output folder, and
MATLAB path replaced by `<spec>`, `<out>`, `<matlab.exe>`. Only `run_001` reached step 2; the
failure stopped the run there. This revision of the script still saved the CSV through Excel,
which is why its step-1 lines read "saved ... and ...".

```text
[input] 3 file(s) in <spec>\fixtures
[input] run_001.txt: 6 columns, 20 rows
[input] run_002.txt: 6 columns, 20 rows
[input] run_003.txt: 6 columns, 20 rows
[step 1/3 excel] Excel 16.0 started via COM
[step 1/3 excel] run_001: saved <out>\run_001.xlsx and <out>\run_001.csv
[step 1/3 excel] run_002: saved <out>\run_002.xlsx and <out>\run_002.csv
[step 1/3 excel] run_003: saved <out>\run_003.xlsx and <out>\run_003.csv
[step 1/3 excel] Excel quit and COM objects released
[step 2/3 matlab] using <matlab.exe>
[step 2/3 matlab] run_001: -batch "addpath('<spec>\stubs'); make_report('<out>\run_001.csv','<out>\run_001.pdf')"
    matlab> ERROR: MATLAB error Exit Status: 0x00000001
[step 2/3 matlab] run_001: exit 1 after 124.0 s
[step 2/3 matlab] FAIL: make_report failed on run_001 with exit code 1; see <out>\run_001.matlab.log
```

Script exit code: 3.

Run 2: real Excel, current script, `-MatlabExe` pointed at a mock launcher. The mock is a
`.cmd` file that copies a hand-written two-page PDF (295 bytes) to the PDF path derived from
its `-logfile` argument, writes one line to the log file and one line to stdout, writes
nothing to stderr, and exits 0. Edits to the raw output: the timestamp prefix removed from
every line; the spec folder, output folder, and mock path replaced by `<spec>`, `<out>`,
`<mock>`; a trailing space the mock left on its log line removed. All three fixtures were
processed. Nothing else was changed or omitted.

```text
[input] 3 file(s) in <spec>\fixtures
[input] run_001.txt: 6 columns, 20 rows
[input] run_002.txt: 6 columns, 20 rows
[input] run_003.txt: 6 columns, 20 rows
[step 1/3 excel] Excel 16.0 started via COM
[step 1/3 excel] run_001: saved <out>\run_001.xlsx; wrote <out>\run_001.csv
[step 1/3 excel] run_002: saved <out>\run_002.xlsx; wrote <out>\run_002.csv
[step 1/3 excel] run_003: saved <out>\run_003.xlsx; wrote <out>\run_003.csv
[step 1/3 excel] Excel quit and COM objects released
[step 2/3 matlab] using <mock>\matlab.cmd
[step 2/3 matlab] run_001: -batch "addpath('<spec>\stubs'); make_report('<out>\run_001.csv','<out>\run_001.pdf')"
    matlab> mock matlab: wrote <out>\run_001.pdf
    matlab> mock matlab stdout line
[step 2/3 matlab] run_001: exit 0 after 1.0 s
[step 2/3 matlab] run_002: -batch "addpath('<spec>\stubs'); make_report('<out>\run_002.csv','<out>\run_002.pdf')"
    matlab> mock matlab: wrote <out>\run_002.pdf
    matlab> mock matlab stdout line
[step 2/3 matlab] run_002: exit 0 after 1.0 s
[step 2/3 matlab] run_003: -batch "addpath('<spec>\stubs'); make_report('<out>\run_003.csv','<out>\run_003.pdf')"
    matlab> mock matlab: wrote <out>\run_003.pdf
    matlab> mock matlab stdout line
[step 2/3 matlab] run_003: exit 0 after 1.0 s
[step 3/3 pdf] <out>\run_001.pdf: 295 bytes, 2 page(s)
[step 3/3 pdf] <out>\run_002.pdf: 295 bytes, 2 page(s)
[step 3/3 pdf] <out>\run_003.pdf: 295 bytes, 2 page(s)
[gate] Human gate: open each PDF above and review it. Nothing after this point is automated.
```

Script exit code: 0. Files in `<out>` after the run: three `.xlsx` (about 9.8 KB each), three
`.csv` (693 bytes each), three `.pdf` (295 bytes), three `.matlab.log`, three
`.matlab.stdout.txt` (25 bytes); the three `.matlab.stderr.txt` were empty and were deleted.
The CSV bytes were inspected: the file starts with `time_s,load_kN,` (no BOM), fields are
separated by `,`, lines end in CRLF, and whole-number doubles print without a decimal point
(`0,0,0,2,0,-1`), which MATLAB `readtable` reads as doubles. The page counter was also checked
directly on the mock PDF: 2 with the `\b` regex, 3 without it. The macro path (`-MacroName`)
was not run because no macro workbook is shipped; `Read-SheetTable` was checked in isolation
on a 3 x 2 sheet and returned the header and both rows.

## Status ledger

| Step | Status | Evidence |
| --- | --- | --- |
| Parse `run_<NNN>.txt` (hop 2) | done | run 2: 3 x "6 columns, 20 rows" |
| Excel COM: workbook, `Value2`, `.xlsx`, script CSV, Quit, release (hop 3, invocation 1) | done | run 2: three `.xlsx` and three comma CSVs; step 2 reached |
| Excel COM with `-MacroName` (hop 3, macro path) | blocked | no macro workbook is shipped; `Read-SheetTable` checked on a 3 x 2 sheet only |
| MATLAB launch, exit code and time logged (hop 4, invocation 2) | done | run 1: exit 1 became script exit 3 after 124 s; run 2: mock exit 0 propagated |
| MATLAB success path with `stubs/make_report.m` (hop 4) | blocked | MATLAB license on the authoring machine expired; task 10 in `tasks.md` |
| PDF check and gate line (hop 5, invocation 3) | done | run 2: 3 x "295 bytes, 2 page(s)", exit 0 |
| `stubs/make_report.m` runs in MATLAB | blocked | read only; task 10 in `tasks.md` |
| Human gate | not started | awaits task 10; approval line goes to `handoffs/LOOP_LOG.md` |
| Verification run | in progress | run 2 passed on the mock launcher; the real MATLAB run (task 10) is open |
