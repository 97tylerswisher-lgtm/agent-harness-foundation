<#
distill-fixture.ps1

Purpose
  Turn a real delimited text file into two public-safe artifacts that may enter the IDE:
    <name>.schema-card.md   column index, inferred type, example shape, numeric range,
                            delimiter, header line count, encoding, row count
    <name>.fixture.<ext>    the same header structure plus -Rows synthetic rows
  No real value is copied verbatim. Numerics are drawn uniformly inside the observed range
  with the observed decimal places. Text tokens keep their shape (letters become random
  letters, digits become random digits, punctuation stays). Dates keep their format and are
  shifted by a random number of days. Header lines are copied with letters and digits
  scrambled the same way. The schema card records the observed numeric min and max per
  column, so review it before sharing if a range alone is sensitive.

  RUN THIS OUTSIDE THE IDE, on the real file, in a plain PowerShell window. Only the two
  outputs go into the repo (under .kiro/specs/<name>/fixtures/ and cards/). The real file
  never enters the IDE workspace.

  Detection rules
  - Delimiter: tab, comma, semicolon, pipe, or whitespace; the one with the most consistent
    column count over the first 50 non-blank lines wins. Ties go to the earlier candidate.
  - Header lines: leading lines whose column count differs from the body count. A leading
    line with the body count also counts as a header when every token in it is text and the
    body has at least one numeric or date column.
  - Types: numeric when every non-empty value parses as a number (NaN and Inf allowed, no
    leading zeros); date when every non-empty value parses with one common date format;
    text otherwise. Quoted fields are not handled; a delimiter inside quotes splits.
  - Blank lines are dropped. Body rows whose column count differs from the body count are
    skipped and counted in the card.
  - A whitespace-delimited fixture is joined with single spaces; column alignment is lost.
  - A numeric column with a single observed value, or a few integers, yields draws that can
    equal a real value. A range that narrow carries no identity; review the card anyway.

Usage
  powershell -NoProfile -ExecutionPolicy Bypass -File distill-fixture.ps1 `
    -InputFile <path to the real file> -OutDir <folder for the two outputs> [-Rows 20] [-Seed 1]

  Outputs are written as UTF-8 (PowerShell 5.1 -Encoding utf8 adds a byte order mark).

Exit codes
  0  both outputs written; their paths are printed as the last two lines.
  1  the input is missing, empty, binary, or has no data rows.
  2  the output folder could not be created or a write failed.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputFile,
    [Parameter(Mandatory = $true)][string]$OutDir,
    [int]$Rows = 20,
    [int]$Seed = 1
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$invariant = [System.Globalization.CultureInfo]::InvariantCulture
$script:rng = New-Object System.Random($Seed)

# ---------- input ----------

if (-not (Test-Path -LiteralPath $InputFile -PathType Leaf)) {
    Write-Output "distill-fixture: input file not found: $InputFile"
    exit 1
}
$inputPath = (Resolve-Path -LiteralPath $InputFile).Path
$bytes = [System.IO.File]::ReadAllBytes($inputPath)
if ($bytes.Length -eq 0) {
    Write-Output "distill-fixture: input file is empty"
    exit 1
}

$encodingName = ''
$encoding = $null
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $encodingName = 'UTF-8 with BOM'
    $encoding = New-Object System.Text.UTF8Encoding($true)
} elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    $encodingName = 'UTF-16 LE'
    $encoding = [System.Text.Encoding]::Unicode
} elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
    $encodingName = 'UTF-16 BE'
    $encoding = [System.Text.Encoding]::BigEndianUnicode
} else {
    $probe = [math]::Min($bytes.Length, 65536)
    $hasNull = $false
    $hasHigh = $false
    for ($i = 0; $i -lt $probe; $i++) {
        if ($bytes[$i] -eq 0) { $hasNull = $true; break }
        if ($bytes[$i] -ge 0x80) { $hasHigh = $true }
    }
    if ($hasNull) {
        Write-Output "distill-fixture: input contains null bytes; only delimited text files are supported"
        exit 1
    }
    if (-not $hasHigh) {
        $encodingName = 'ASCII'
        $encoding = New-Object System.Text.UTF8Encoding($false)
    } else {
        $strict = New-Object System.Text.UTF8Encoding($false, $true)
        try {
            [void]$strict.GetString($bytes)
            $encodingName = 'UTF-8 without BOM'
            $encoding = $strict
        } catch {
            $encodingName = 'ANSI (Windows-1252)'
            $encoding = [System.Text.Encoding]::GetEncoding(1252)
        }
    }
}

$text = $encoding.GetString($bytes).TrimStart([char]0xFEFF)
$lines = @()
foreach ($raw in ($text -split "\r\n|\n|\r")) {
    if ($raw.Trim().Length -gt 0) { $lines += $raw }
}
if ($lines.Count -eq 0) {
    Write-Output "distill-fixture: input has no non-blank lines"
    exit 1
}

# ---------- delimiter ----------

$candidates = @(
    @{ Name = 'tab';        Char = "`t"; Join = "`t" },
    @{ Name = 'comma';      Char = ',';  Join = ',' },
    @{ Name = 'semicolon';  Char = ';';  Join = ';' },
    @{ Name = 'pipe';       Char = '|';  Join = '|' },
    @{ Name = 'whitespace'; Char = '';   Join = ' ' }
)

function Split-Row([string]$line, $cand) {
    if ($cand.Char -eq '') { return @($line.Trim() -split '\s+') }
    return @($line.Split([char]$cand.Char))
}

function Get-ModeCount([int[]]$counts) {
    $tally = @{}
    foreach ($n in $counts) {
        if ($tally.ContainsKey($n)) { $tally[$n]++ } else { $tally[$n] = 1 }
    }
    $modeN = 0
    $modeFreq = 0
    foreach ($k in $tally.Keys) {
        if ($tally[$k] -gt $modeFreq -or ($tally[$k] -eq $modeFreq -and $k -gt $modeN)) {
            $modeFreq = $tally[$k]
            $modeN = $k
        }
    }
    return @($modeN, $modeFreq)
}

$sample = @($lines | Select-Object -First 50)
$delimiter = $null
$bestFreq = -1
foreach ($cand in $candidates) {
    $counts = @()
    foreach ($line in $sample) { $counts += @(Split-Row $line $cand).Count }
    $mode = Get-ModeCount ([int[]]$counts)
    if ($mode[0] -lt 2) { continue }
    if ($mode[1] -gt $bestFreq) {
        $delimiter = $cand
        $bestFreq = $mode[1]
    }
}
if ($null -eq $delimiter) { $delimiter = $candidates[4] }

# ---------- header lines and body ----------

$allCounts = @()
foreach ($line in $lines) { $allCounts += @(Split-Row $line $delimiter).Count }
$bodyMode = Get-ModeCount ([int[]]$allCounts)
$columnCount = $bodyMode[0]

$headerCount = 0
while ($headerCount -lt $lines.Count -and $allCounts[$headerCount] -ne $columnCount) { $headerCount++ }

$numericPattern = '^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$'
$specialPattern = '^[+-]?(NaN|Inf|Infinity)$'
$leadingZeroPattern = '^[+-]?0\d'
$dateFormats = @(
    'yyyy-MM-dd', 'yyyy/MM/dd', 'yyyy.MM.dd', 'MM/dd/yyyy', 'M/d/yyyy', 'dd/MM/yyyy', 'd/M/yyyy',
    'dd.MM.yyyy', 'dd-MM-yyyy', 'MM-dd-yyyy', 'dd-MMM-yyyy', 'yyyy-MM-dd HH:mm:ss', 'yyyy-MM-ddTHH:mm:ss',
    'yyyy-MM-ddTHH:mm:ssZ', 'yyyy-MM-dd HH:mm', 'MM/dd/yyyy HH:mm:ss', 'MM/dd/yyyy HH:mm',
    'dd/MM/yyyy HH:mm:ss', 'yyyy-MM-dd HH:mm:ss.fff'
)

function Test-Numeric([string]$v) {
    if ($v -cmatch $specialPattern) { return $true }
    if ($v -notmatch $numericPattern) { return $false }
    return ($v -notmatch $leadingZeroPattern)
}

function Test-DateFormat([string]$v, [string]$fmt) {
    $dt = [datetime]::MinValue
    return [datetime]::TryParseExact($v, $fmt, $invariant, [System.Globalization.DateTimeStyles]::None, [ref]$dt)
}

function Get-DateFormat([string[]]$values) {
    foreach ($fmt in $dateFormats) {
        if (-not (Test-DateFormat $values[0] $fmt)) { continue }
        $all = $true
        foreach ($v in $values) { if (-not (Test-DateFormat $v $fmt)) { $all = $false; break } }
        if ($all) { return $fmt }
    }
    return ''
}

function Get-Shape([string]$token) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $token.ToCharArray()) {
        if ([char]::IsDigit($ch)) { [void]$sb.Append('9') }
        elseif ([char]::IsLetter($ch)) { [void]$sb.Append('X') }
        else { [void]$sb.Append($ch) }
    }
    return $sb.ToString()
}

function Get-Scrambled([string]$token) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $token.ToCharArray()) {
        if ([char]::IsDigit($ch)) { [void]$sb.Append([char]$script:rng.Next(48, 58)) }
        elseif ([char]::IsUpper($ch)) { [void]$sb.Append([char]$script:rng.Next(65, 91)) }
        elseif ([char]::IsLetter($ch)) { [void]$sb.Append([char]$script:rng.Next(97, 123)) }
        else { [void]$sb.Append($ch) }
    }
    $out = $sb.ToString()
    if ($out -ceq $token -and ($token -match '[A-Za-z0-9]')) { return (Get-Scrambled $token) }
    return $out
}

# Column analysis over a set of body rows. Returns one hashtable per column.
function Get-ColumnInfo([object[]]$dataRows, [int]$columnCount) {
    $columns = @()
    for ($c = 0; $c -lt $columnCount; $c++) {
        $values = @()
        $empty = 0
        foreach ($row in $dataRows) {
            $v = ([string]$row[$c]).Trim()
            if ($v.Length -eq 0) { $empty++ } else { $values += $v }
        }
        $info = @{
            Index = $c + 1; Type = 'empty'; Shape = ''; Min = 0.0; Max = 0.0; Decimals = 0
            Exponent = $false; Format = ''; Values = $values; Empty = $empty; Total = $dataRows.Count
        }
        if ($values.Count -gt 0) {
            $info.Shape = Get-Shape $values[0]
            $allNumeric = $true
            foreach ($v in $values) { if (-not (Test-Numeric $v)) { $allNumeric = $false; break } }
            if ($allNumeric) {
                $info.Type = 'numeric'
                $info.Shape = $values[0] -replace '\d', '9'
                $finite = @()
                foreach ($v in $values) {
                    if ($v -cmatch $specialPattern) { continue }
                    $finite += [double]::Parse($v, [System.Globalization.NumberStyles]::Float, $invariant)
                    if ($v -match '[eE]') { $info.Exponent = $true }
                    $mantissa = ($v -split '[eE]')[0]
                    $dot = $mantissa.IndexOf('.')
                    if ($dot -ge 0) {
                        $d = $mantissa.Length - $dot - 1
                        if ($d -gt $info.Decimals) { $info.Decimals = $d }
                    }
                }
                if ($finite.Count -gt 0) {
                    $info.Min = ($finite | Measure-Object -Minimum).Minimum
                    $info.Max = ($finite | Measure-Object -Maximum).Maximum
                } else {
                    $info.Type = 'numeric-special'
                }
            } else {
                $fmt = Get-DateFormat $values
                if ($fmt -ne '') {
                    $info.Type = 'date'
                    $info.Format = $fmt
                } else {
                    $info.Type = 'text'
                }
            }
        }
        $columns += $info
    }
    return $columns
}

function Get-BodyRows([int]$start) {
    $rowList = @()
    $ragged = 0
    for ($i = $start; $i -lt $lines.Count; $i++) {
        $cells = @(Split-Row $lines[$i] $delimiter)
        if ($cells.Count -ne $columnCount) { $ragged++; continue }
        $rowList += , $cells
    }
    return @{ Rows = $rowList; Ragged = $ragged }
}

$body = Get-BodyRows $headerCount
$bodyRows = @($body.Rows)
$raggedCount = $body.Ragged
if ($bodyRows.Count -eq 0) {
    Write-Output "distill-fixture: no data rows found (header lines: $headerCount)"
    exit 1
}

# A column-name row with the body column count: all text, body has a typed column.
if ($bodyRows.Count -gt 1) {
    $first = $bodyRows[0]
    $allText = $true
    foreach ($v in $first) {
        $t = ([string]$v).Trim()
        if ($t.Length -eq 0 -or (Test-Numeric $t) -or ((Get-DateFormat @($t)) -ne '')) { $allText = $false; break }
    }
    if ($allText) {
        $rest = @(Get-ColumnInfo @($bodyRows | Select-Object -Skip 1) $columnCount)
        $typed = $false
        foreach ($col in $rest) { if ($col.Type -ne 'text' -and $col.Type -ne 'empty') { $typed = $true; break } }
        if ($typed) {
            $headerCount++
            $body = Get-BodyRows $headerCount
            $bodyRows = @($body.Rows)
            $raggedCount = $body.Ragged
        }
    }
}

$columns = @(Get-ColumnInfo $bodyRows $columnCount)

# ---------- synthetic rows ----------

function Format-Number([double]$v, $col) {
    if ($col.Exponent) {
        $fmt = '0'
        if ($col.Decimals -gt 0) { $fmt = '0.' + ('0' * $col.Decimals) }
        return $v.ToString($fmt + 'e+00', $invariant)
    }
    return ([math]::Round($v, $col.Decimals)).ToString('F' + $col.Decimals, $invariant)
}

function New-NumericValue($col) {
    $span = $col.Max - $col.Min
    return Format-Number ($col.Min + $script:rng.NextDouble() * $span) $col
}

function New-DateValue($col) {
    $template = $col.Values[$script:rng.Next(0, $col.Values.Count)]
    $dt = [datetime]::ParseExact($template, $col.Format, $invariant)
    $days = $script:rng.Next(-365, 366)
    if ($days -eq 0) { $days = 1 }
    return $dt.AddDays($days).ToString($col.Format, $invariant)
}

function New-CellValue($col) {
    if ($col.Total -gt 0 -and $col.Empty -gt 0) {
        if ($script:rng.NextDouble() -lt ($col.Empty / $col.Total)) { return '' }
    }
    switch ($col.Type) {
        'numeric' { return New-NumericValue $col }
        'numeric-special' { return $col.Values[$script:rng.Next(0, $col.Values.Count)] }
        'date' { return New-DateValue $col }
        'text' { return Get-Scrambled $col.Values[$script:rng.Next(0, $col.Values.Count)] }
        default { return '' }
    }
}

$outputLines = @()
for ($i = 0; $i -lt $headerCount; $i++) { $outputLines += Get-Scrambled $lines[$i] }
for ($r = 0; $r -lt $Rows; $r++) {
    $cells = @()
    foreach ($col in $columns) { $cells += New-CellValue $col }
    $outputLines += ($cells -join $delimiter.Join)
}

# ---------- schema card ----------

$name = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
$ext = [System.IO.Path]::GetExtension($inputPath)
if ($ext -eq '') { $ext = '.txt' }
$sourceName = [System.IO.Path]::GetFileName($inputPath)
$fixtureName = "$name.fixture$ext"

$delimiterLabel = $delimiter.Name
if ($delimiter.Char -ne '' -and $delimiter.Name -ne 'tab') { $delimiterLabel = "$($delimiter.Name) ($($delimiter.Char))" }

$card = @()
$card += "# Schema card: $name"
$card += ''
$card += 'Generated by scripts/distill-fixture.ps1. This card holds shapes and ranges, not real values.'
$card += ''
$card += '| Property | Value |'
$card += '| --- | --- |'
$card += "| Source file | $sourceName |"
$card += "| Encoding | $encodingName |"
$card += "| Delimiter | $delimiterLabel |"
$card += "| Header lines | $headerCount |"
$card += "| Data rows | $($bodyRows.Count) |"
$card += "| Ragged rows skipped | $raggedCount |"
$card += "| Columns | $columnCount |"
$card += "| Fixture | $fixtureName ($Rows rows, seed $Seed) |"
$card += ''
$card += '## Columns'
$card += ''
$card += '| Index | Type | Shape | Min | Max | Decimals | Empty | Notes |'
$card += '| --- | --- | --- | --- | --- | --- | --- | --- |'
foreach ($col in $columns) {
    $min = ''
    $max = ''
    $dec = ''
    $notes = ''
    if ($col.Type -eq 'numeric') {
        $min = Format-Number ([double]$col.Min) $col
        $max = Format-Number ([double]$col.Max) $col
        $dec = [string]$col.Decimals
        if ($col.Exponent) { $notes = 'exponent notation' }
    } elseif ($col.Type -eq 'numeric-special') {
        $notes = 'only NaN or Inf values'
    } elseif ($col.Type -eq 'date') {
        $notes = "format $($col.Format)"
    } elseif ($col.Type -eq 'text') {
        $distinct = @($col.Values | Sort-Object -Unique).Count
        $notes = "$distinct distinct values"
    }
    $card += "| $($col.Index) | $($col.Type) | $($col.Shape) | $min | $max | $dec | $($col.Empty) | $notes |"
}
$card += ''

# ---------- write ----------

try {
    if (-not (Test-Path -LiteralPath $OutDir -PathType Container)) {
        New-Item -ItemType Directory -Path $OutDir | Out-Null
    }
    $outPath = (Resolve-Path -LiteralPath $OutDir).Path
    $cardPath = Join-Path $outPath "$name.schema-card.md"
    $fixturePath = Join-Path $outPath $fixtureName
    Set-Content -LiteralPath $cardPath -Value $card -Encoding utf8
    Set-Content -LiteralPath $fixturePath -Value $outputLines -Encoding utf8
} catch {
    Write-Output "distill-fixture: write failed: $($_.Exception.Message)"
    exit 2
}

Write-Output $cardPath
Write-Output $fixturePath
exit 0
