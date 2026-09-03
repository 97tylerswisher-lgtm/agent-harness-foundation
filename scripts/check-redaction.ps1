<#
check-redaction.ps1

Purpose
  Scan every file in the repo for the literal terms listed in scripts/banned-terms.txt. Run it before every push. The public copy ships an extraction list; the work repo
  replaces the list with its own (program names, part numbers, project codes).

  Matching is case-sensitive and literal (no wildcards). Blank lines and lines starting with
  '#' in scripts/banned-terms.txt are ignored. The scan skips .git/, the terms file itself, and files
  with the extensions png, jpg, pdf, xlsx, xlsm, zip.

Usage
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-redaction.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-redaction.ps1 -Root <repo path>

  -Root defaults to the repo root (the parent of the scripts folder).
  Each hit prints as  path:line: term  with the path relative to -Root.

Exit codes
  0  no hits.
  1  at least one hit.
  2  scripts/banned-terms.txt is missing or lists no terms.
#>
[CmdletBinding()]
param(
    [string]$Root = ''
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# Default the root here: PowerShell 5.1 does not populate PSScriptRoot in param defaults.
if ($Root -eq '') { $Root = Split-Path -Parent $PSScriptRoot }

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Output "check-redaction: root folder not found: $Root"
    exit 2
}
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$termsFile = Join-Path $rootPath 'scripts\banned-terms.txt'
if (-not (Test-Path -LiteralPath $termsFile -PathType Leaf)) {
    Write-Output "check-redaction: scripts\banned-terms.txt not found under $rootPath"
    exit 2
}

$terms = @()
foreach ($raw in [System.IO.File]::ReadAllLines($termsFile)) {
    $t = $raw.Trim()
    if ($t.Length -eq 0) { continue }
    if ($t.StartsWith('#')) { continue }
    $terms += $t
}
if ($terms.Count -eq 0) {
    Write-Output "check-redaction: scripts\banned-terms.txt lists no terms"
    exit 2
}

$skipExtensions = @('.png', '.jpg', '.pdf', '.xlsx', '.xlsm', '.zip')
$ordinal = [System.StringComparison]::Ordinal

$hits = 0
$filesScanned = 0
$files = @(Get-ChildItem -LiteralPath $rootPath -Recurse -File -Force)
foreach ($file in $files) {
    $rel = $file.FullName.Substring($rootPath.Length).TrimStart('\')
    if ($rel.StartsWith('.git\', $ordinal)) { continue }
    if ($rel -eq 'scripts\banned-terms.txt') { continue }
    if ($skipExtensions -contains $file.Extension.ToLowerInvariant()) { continue }
    $filesScanned++
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        foreach ($term in $terms) {
            if ($lines[$i].IndexOf($term, $ordinal) -ge 0) {
                Write-Output ("{0}:{1}: {2}" -f $rel, ($i + 1), $term)
                $hits++
            }
        }
    }
}

Write-Output "check-redaction: $hits hits in $filesScanned files scanned against $($terms.Count) terms"
if ($hits -gt 0) { exit 1 }
exit 0
