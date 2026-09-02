<#
.SYNOPSIS
    Text exports -> Excel reshape -> MATLAB report -> PDF check, in one command.

.DESCRIPTION
    Step 1 (Excel via COM): for each *.txt in -InputFolder, parse the delimited table (see
    cards/schema-card.md and cards/edge-case-catalog.md), write it into a new workbook, run the
    reshape macro when -MacroName is given, save <name>.xlsx in -OutputFolder, close. The
    <name>.csv that MATLAB reads is written by this script, not by Excel: comma delimiter,
    ASCII encoding, no BOM, CRLF line endings. Excel's own CSV export uses the machine's list
    separator (";" on many regional settings), so it is not used. With -SkipExcel the parsed
    table is written to <name>.csv directly and no workbook is made.
    Step 2 (MATLAB): matlab.exe -batch "addpath('<FunctionFolder>'); make_report('<csv>','<pdf>')"
    for each CSV, started with Start-Process. -batch means no UI and no file dialogs; the exit
    code is propagated. MATLAB output lands in <name>.matlab.log (-logfile),
    <name>.matlab.stdout.txt, and <name>.matlab.stderr.txt; empty files are removed.
    Step 3 (PDF check): the PDF exists, has size > 0, and its page count is printed.
    The human gate follows: the operator opens the PDF. Nothing after that is automated.

    Windows PowerShell 5.1 compatible.

.PARAMETER InputFolder
    Folder holding the rig export files (*.txt).
.PARAMETER OutputFolder
    Folder that receives <name>.xlsx, <name>.csv, <name>.pdf and the MATLAB output files.
    Created if missing.
.PARAMETER MacroName
    Name of the reshape macro. When omitted no macro runs and no macro-enabled workbook is needed.
.PARAMETER MacroWorkbook
    Path to the macro-enabled workbook that holds -MacroName. Default: reshape.xlsm beside this script.
.PARAMETER MatlabExe
    Path to matlab.exe. Default: newest install under Program Files, else "matlab" on PATH.
.PARAMETER FunctionFolder
    Folder added to the MATLAB path that holds make_report.m. Default: stubs beside this script.
.PARAMETER SkipExcel
    Skip step 1; write the parsed table straight to CSV.

.EXAMPLE
    .\run-report.ps1 -InputFolder .\fixtures -OutputFolder .\out

.NOTES
    Exit codes: 0 ok, 1 input or parse error, 2 Excel failure, 3 MATLAB failure, 4 PDF check failure.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $InputFolder,
    [Parameter(Mandatory = $true)] [string] $OutputFolder,
    [string] $MacroName,
    [string] $MacroWorkbook,
    [string] $MatlabExe,
    [string] $FunctionFolder,
    [switch] $SkipExcel
)

Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $MacroWorkbook) { $MacroWorkbook = Join-Path $scriptDir 'reshape.xlsm' }
if (-not $FunctionFolder) { $FunctionFolder = Join-Path $scriptDir 'stubs' }
$inv = [System.Globalization.CultureInfo]::InvariantCulture

function Write-Log([string] $Step, [string] $Message) {
    Write-Host ('[{0}] [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Step, $Message)
}

function Fail([int] $Code, [string] $Step, [string] $Message) {
    Write-Log $Step ('FAIL: ' + $Message)
    exit $Code
}

# Parse one export file into a header array and a list of double[] rows.
function Read-ExportFile([string] $Path) {
    $header = $null
    $delim = $null
    $rows = New-Object System.Collections.Generic.List[object]
    $lineNo = 0
    foreach ($line in [System.IO.File]::ReadLines($Path)) {
        $lineNo++
        $trim = $line.Trim()
        if ($trim.Length -eq 0) { continue }
        if ($trim.StartsWith('#')) {
            if ($trim -match '^#\s*summary') { break }   # catalog row 4: trailing summary block
            continue                                       # catalog row 1: any number of comment lines
        }
        if ($null -eq $header) {
            if ($line.Contains("`t")) { $delim = "`t" }    # catalog row 3: delimiter from the header
            elseif ($line.Contains(',')) { $delim = ',' }
            else { throw ('{0}:{1}: header line has neither tab nor comma' -f $Path, $lineNo) }
            $header = @($line.Split($delim) | ForEach-Object { $_.Trim() })
            continue
        }
        $fields = $line.Split($delim)
        if ($fields.Count -ne $header.Count) {
            throw ('{0}:{1}: expected {2} fields, found {3}' -f $Path, $lineNo, $header.Count, $fields.Count)
        }
        $vals = New-Object double[] $fields.Count
        for ($i = 0; $i -lt $fields.Count; $i++) {
            $vals[$i] = [double]::Parse($fields[$i].Trim(), $inv)
        }
        $rows.Add($vals)
    }
    if ($null -eq $header) { throw ('{0}: no column header found' -f $Path) }
    if ($rows.Count -eq 0) { throw ('{0}: no data rows found' -f $Path) }
    return @{ Header = $header; Rows = $rows }
}

# One CSV field: doubles in round-trip invariant form, anything else as text.
function Format-CsvValue([object] $Value) {
    if ($null -eq $Value) { return '' }
    if ($Value -is [double]) { return $Value.ToString('R', $inv) }
    return [string]$Value
}

# Write a table as CSV: comma delimiter, ASCII, no BOM, CRLF. Independent of the machine's
# list separator (catalog row 6).
function Write-CsvTable([hashtable] $Table, [string] $Path) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add(($Table.Header -join ','))
    foreach ($r in $Table.Rows) {
        $lines.Add((@($r | ForEach-Object { Format-CsvValue $_ }) -join ','))
    }
    [System.IO.File]::WriteAllLines($Path, $lines, [System.Text.Encoding]::ASCII)
}

# Read the used range of a worksheet back into a header array and a list of object[] rows.
# Used after the macro so the CSV carries the reshaped table.
function Read-SheetTable([object] $Sheet) {
    $data = $Sheet.UsedRange.Value2
    $r0 = $data.GetLowerBound(0)
    $c0 = $data.GetLowerBound(1)
    $nRows = $data.GetLength(0)
    $nCols = $data.GetLength(1)
    $header = New-Object string[] $nCols
    for ($c = 0; $c -lt $nCols; $c++) { $header[$c] = Format-CsvValue $data.GetValue($r0, $c0 + $c) }
    $rows = New-Object System.Collections.Generic.List[object]
    for ($r = 1; $r -lt $nRows; $r++) {
        $vals = New-Object object[] $nCols
        for ($c = 0; $c -lt $nCols; $c++) { $vals[$c] = $data.GetValue($r0 + $r, $c0 + $c) }
        $rows.Add($vals)
    }
    return @{ Header = $header; Rows = $rows }
}

function Release-Com([object] $Obj) {
    if ($null -ne $Obj) {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($Obj)
    }
}

function Find-Matlab() {
    if ($MatlabExe) { return $MatlabExe }
    $candidates = @(Get-ChildItem -Path (Join-Path $env:ProgramFiles 'MATLAB') -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName 'bin\matlab.exe' } |
        Where-Object { Test-Path $_ })
    if ($candidates.Count -gt 0) { return $candidates[0] }
    $cmd = Get-Command matlab -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Get-PdfPageCount([string] $Path) {
    $latin1 = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
    $text = $latin1.GetString([System.IO.File]::ReadAllBytes($Path))
    # /Type /Page objects are pages; /Type /Pages is the tree node and is excluded by \b.
    return ([regex]::Matches($text, '/Type\s*/Page\b')).Count
}

# ---------------------------------------------------------------- inputs
$inputArg = $InputFolder
$InputFolder = (Resolve-Path $InputFolder -ErrorAction SilentlyContinue).Path
if (-not $InputFolder) { Fail 1 'input' ('input folder not found: ' + $inputArg) }
if (-not (Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder | Out-Null }
$OutputFolder = (Resolve-Path $OutputFolder).Path
$inputs = @(Get-ChildItem -Path $InputFolder -Filter '*.txt' -File | Sort-Object Name)
if ($inputs.Count -eq 0) { Fail 1 'input' ('no *.txt files in ' + $InputFolder) }
Write-Log 'input' ('{0} file(s) in {1}' -f $inputs.Count, $InputFolder)

$tables = @{}
foreach ($f in $inputs) {
    try {
        $t = Read-ExportFile $f.FullName
    } catch {
        Fail 1 'input' $_.Exception.Message
    }
    $tables[$f.BaseName] = $t
    Write-Log 'input' ('{0}: {1} columns, {2} rows' -f $f.Name, $t.Header.Count, $t.Rows.Count)
}

# ---------------------------------------------------------------- step 1: Excel
$csvPaths = @{}
if ($SkipExcel) {
    foreach ($name in @($tables.Keys | Sort-Object)) {
        $csv = Join-Path $OutputFolder ($name + '.csv')
        Write-CsvTable $tables[$name] $csv
        $csvPaths[$name] = $csv
        Write-Log 'step 1/3 excel' ('skipped; wrote ' + $csv)
    }
} else {
    if ($MacroName -and -not (Test-Path $MacroWorkbook)) {
        Fail 2 'step 1/3 excel' ('macro workbook not found: ' + $MacroWorkbook)
    }
    $excel = $null
    $macroWb = $null
    $excelFailed = $false
    try {
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $false
        $excel.DisplayAlerts = $false
        Write-Log 'step 1/3 excel' ('Excel {0} started via COM' -f $excel.Version)
        if ($MacroName) {
            $macroWb = $excel.Workbooks.Open($MacroWorkbook)
            Write-Log 'step 1/3 excel' ('opened macro workbook ' + $MacroWorkbook)
        }
        foreach ($name in @($tables.Keys | Sort-Object)) {
            $t = $tables[$name]
            $wb = $null
            $ws = $null
            try {
                $wb = $excel.Workbooks.Add()
                $ws = $wb.Worksheets.Item(1)
                $nRows = $t.Rows.Count + 1
                $nCols = $t.Header.Count
                $arr = New-Object 'object[,]' $nRows, $nCols
                for ($c = 0; $c -lt $nCols; $c++) { $arr[0, $c] = $t.Header[$c] }
                for ($r = 0; $r -lt $t.Rows.Count; $r++) {
                    for ($c = 0; $c -lt $nCols; $c++) { $arr[($r + 1), $c] = $t.Rows[$r][$c] }
                }
                $ws.Range($ws.Cells.Item(1, 1), $ws.Cells.Item($nRows, $nCols)).Value2 = $arr
                $ws.Activate()
                if ($MacroName) {
                    try {
                        $excel.Run($MacroName)
                        Write-Log 'step 1/3 excel' ('{0}: ran {1}' -f $name, $MacroName)
                    } catch {
                        # A halted macro (runtime error, End pressed) surfaces as a COM exception.
                        throw ('macro {0} halted on {1}: {2}' -f $MacroName, $name, $_.Exception.Message)
                    }
                    $t = Read-SheetTable $ws    # the CSV must carry the reshaped table
                }
                $xlsx = Join-Path $OutputFolder ($name + '.xlsx')
                $csv = Join-Path $OutputFolder ($name + '.csv')
                foreach ($p in @($xlsx, $csv)) { if (Test-Path $p) { Remove-Item $p -Force } }
                $wb.SaveAs($xlsx, 51)    # xlOpenXMLWorkbook; Excel saves only the .xlsx
                Write-CsvTable $t $csv   # comma CSV from this script, not Excel's list-separator CSV
                $csvPaths[$name] = $csv
                Write-Log 'step 1/3 excel' ('{0}: saved {1}; wrote {2}' -f $name, $xlsx, $csv)
            } finally {
                if ($null -ne $wb) { $wb.Close($false) }
                Release-Com $ws
                Release-Com $wb
            }
        }
    } catch {
        Write-Log 'step 1/3 excel' ('FAIL: ' + $_.Exception.Message)
        $excelFailed = $true
    } finally {
        if ($null -ne $macroWb) { $macroWb.Close($false); Release-Com $macroWb }
        if ($null -ne $excel) { $excel.Quit(); Release-Com $excel }
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
    if ($excelFailed) { exit 2 }
    Write-Log 'step 1/3 excel' 'Excel quit and COM objects released'
}

# ---------------------------------------------------------------- step 2: MATLAB
$matlab = Find-Matlab
if (-not $matlab -or -not (Test-Path $matlab)) { Fail 3 'step 2/3 matlab' 'matlab.exe not found; pass -MatlabExe' }
if (-not (Test-Path (Join-Path $FunctionFolder 'make_report.m'))) {
    Fail 3 'step 2/3 matlab' ('make_report.m not found in ' + $FunctionFolder)
}
$FunctionFolder = (Resolve-Path $FunctionFolder).Path
Write-Log 'step 2/3 matlab' ('using ' + $matlab)
$pdfPaths = @{}
foreach ($name in @($csvPaths.Keys | Sort-Object)) {
    $csv = $csvPaths[$name]
    $pdf = Join-Path $OutputFolder ($name + '.pdf')
    if (Test-Path $pdf) { Remove-Item $pdf -Force }
    $cmd = "addpath('{0}'); make_report('{1}','{2}')" -f $FunctionFolder, $csv, $pdf
    $log = Join-Path $OutputFolder ($name + '.matlab.log')
    $stdout = Join-Path $OutputFolder ($name + '.matlab.stdout.txt')
    $stderr = Join-Path $OutputFolder ($name + '.matlab.stderr.txt')
    foreach ($p in @($log, $stdout, $stderr)) { if (Test-Path $p) { Remove-Item $p -Force } }
    Write-Log 'step 2/3 matlab' ('{0}: -batch "{1}"' -f $name, $cmd)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    # matlab.exe on Windows does not attach to the console; -logfile keeps the MATLAB output.
    $proc = Start-Process -FilePath $matlab -ArgumentList @('-batch', ('"' + $cmd + '"'), '-logfile', ('"' + $log + '"')) `
        -Wait -PassThru -NoNewWindow -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    $code = $proc.ExitCode
    $sw.Stop()
    foreach ($p in @($log, $stdout, $stderr)) {
        if (-not (Test-Path $p)) { continue }
        if ((Get-Item $p).Length -eq 0) { Remove-Item $p -Force; continue }
        Get-Content $p | ForEach-Object { Write-Host ('    matlab> ' + $_) }
    }
    Write-Log 'step 2/3 matlab' ('{0}: exit {1} after {2:N1} s' -f $name, $code, $sw.Elapsed.TotalSeconds)
    if ($code -ne 0) { Fail 3 'step 2/3 matlab' ('make_report failed on {0} with exit code {1}; see {2}' -f $name, $code, $log) }
    $pdfPaths[$name] = $pdf
}

# ---------------------------------------------------------------- step 3: PDF check
foreach ($name in @($pdfPaths.Keys | Sort-Object)) {
    $pdf = $pdfPaths[$name]
    if (-not (Test-Path $pdf)) { Fail 4 'step 3/3 pdf' ('missing: ' + $pdf) }
    $size = (Get-Item $pdf).Length
    if ($size -le 0) { Fail 4 'step 3/3 pdf' ('empty: ' + $pdf) }
    $pages = Get-PdfPageCount $pdf
    if ($pages -lt 1) { Fail 4 'step 3/3 pdf' ('no /Type /Page objects: ' + $pdf) }
    Write-Log 'step 3/3 pdf' ('{0}: {1} bytes, {2} page(s)' -f $pdf, $size, $pages)
}

Write-Log 'gate' 'Human gate: open each PDF above and review it. Nothing after this point is automated.'
exit 0
