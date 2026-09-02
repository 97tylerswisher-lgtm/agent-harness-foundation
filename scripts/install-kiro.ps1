<#
install-kiro.ps1

Purpose
  Mirror the harness-neutral source folders into the folders the Kiro IDE reads:
    steering/*.md  ->  .kiro/steering/
    skills/**      ->  .kiro/skills/
    agents/*.md    ->  .kiro/agents/
  A file removed from a source folder is removed from its mirror. The script never touches
  .kiro/specs/ or .kiro/settings/. Running it twice in a row copies nothing the second time.
  A source folder that does not exist is skipped with a warning and its mirror is left alone.

Usage
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install-kiro.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install-kiro.ps1 -Check
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install-kiro.ps1 -Root <repo path>

  -Check compares instead of copying. It prints one line per path that differs, is missing
  under .kiro/, or exists under .kiro/ without a source, and changes nothing.
  -Root defaults to the repo root (the parent of the scripts folder).

Exit codes
  0  install: the mirror is up to date. -Check: no differences.
  1  -Check: at least one difference.
  2  the repo root could not be resolved.
#>
[CmdletBinding()]
param(
    [switch]$Check,
    [string]$Root = ''
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# Default the root here: PowerShell 5.1 does not populate PSScriptRoot in param defaults.
if ($Root -eq '') { $Root = Split-Path -Parent $PSScriptRoot }

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Output "install-kiro: repo root not found: $Root"
    exit 2
}
$rootPath = (Resolve-Path -LiteralPath $Root).Path

$maps = @(
    @{ Source = 'steering'; Target = '.kiro\steering'; Recurse = $false; Filter = '*.md' },
    @{ Source = 'skills';   Target = '.kiro\skills';   Recurse = $true;  Filter = '*' },
    @{ Source = 'agents';   Target = '.kiro\agents';   Recurse = $false; Filter = '*.md' }
)

# Returns a hashtable: relative path -> full path, for the files a map manages under $base.
function Get-ManagedFiles([string]$base, [bool]$recurse, [string]$filter, [bool]$isSource) {
    $result = @{}
    if (-not (Test-Path -LiteralPath $base -PathType Container)) { return $result }
    $basePath = (Resolve-Path -LiteralPath $base).Path
    if ($recurse) {
        $items = @(Get-ChildItem -LiteralPath $basePath -Recurse -File)
    } else {
        $items = @(Get-ChildItem -LiteralPath $basePath -File -Filter $filter)
    }
    foreach ($item in $items) {
        $rel = $item.FullName.Substring($basePath.Length).TrimStart('\')
        # A README.md at the source root documents the folder. It is not a steering file,
        # a skill, or an agent, so it never mirrors under .kiro/. On the target side it is
        # enumerated so a stray copy is removed as an extra.
        if ($isSource -and ($rel -ieq 'README.md')) { continue }
        $result[$rel] = $item.FullName
    }
    return $result
}

function Test-SameContent([string]$a, [string]$b) {
    if ((Get-Item -LiteralPath $a).Length -ne (Get-Item -LiteralPath $b).Length) { return $false }
    $ha = (Get-FileHash -LiteralPath $a -Algorithm SHA256).Hash
    $hb = (Get-FileHash -LiteralPath $b -Algorithm SHA256).Hash
    return ($ha -eq $hb)
}

$copied = 0
$unchanged = 0
$removed = 0
$differences = 0
$perMap = @()

foreach ($map in $maps) {
    $src = Join-Path $rootPath $map.Source
    $dst = Join-Path $rootPath $map.Target
    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
        Write-Output "warning: source folder absent, mirror left untouched: $($map.Source)"
        $perMap += "$($map.Source) absent"
        continue
    }
    $srcFiles = Get-ManagedFiles $src $map.Recurse $map.Filter $true
    $dstFiles = Get-ManagedFiles $dst $map.Recurse $map.Filter $false
    $perMap += "$($map.Source) $($srcFiles.Count)"

    foreach ($rel in @($srcFiles.Keys | Sort-Object)) {
        $target = Join-Path $dst $rel
        $exists = $dstFiles.ContainsKey($rel)
        if ($exists -and (Test-SameContent $srcFiles[$rel] $target)) {
            $unchanged++
            continue
        }
        if ($Check) {
            if ($exists) { Write-Output "differs: $($map.Target)\$rel" }
            else { Write-Output "missing: $($map.Target)\$rel" }
            $differences++
            continue
        }
        $dir = Split-Path -Parent $target
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
        Copy-Item -LiteralPath $srcFiles[$rel] -Destination $target -Force
        Write-Output "copied: $($map.Target)\$rel"
        $copied++
    }

    foreach ($rel in @($dstFiles.Keys | Sort-Object)) {
        if ($srcFiles.ContainsKey($rel)) { continue }
        if ($Check) {
            Write-Output "extra: $($map.Target)\$rel"
            $differences++
            continue
        }
        Remove-Item -LiteralPath $dstFiles[$rel] -Force
        Write-Output "removed: $($map.Target)\$rel"
        $removed++
    }

    # Drop folders left empty by removals (deepest first).
    if ($map.Recurse -and -not $Check -and (Test-Path -LiteralPath $dst -PathType Container)) {
        $dirs = @(Get-ChildItem -LiteralPath $dst -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending)
        foreach ($d in $dirs) {
            $any = @(Get-ChildItem -LiteralPath $d.FullName -Force)
            if ($any.Count -eq 0) { Remove-Item -LiteralPath $d.FullName -Force }
        }
    }
}

$mode = 'install'
if ($Check) { $mode = 'check' }
Write-Output "install-kiro ($mode): copied $copied, unchanged $unchanged, removed $removed, differences $differences ($($perMap -join ', '))"

if ($Check -and $differences -gt 0) { exit 1 }
exit 0
