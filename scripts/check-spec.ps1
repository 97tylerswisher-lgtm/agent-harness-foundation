<#
check-spec.ps1

Purpose
  Mechanical check of one spec folder under .kiro/specs/<name>/ before the spec is shown to
  the operator. Each check prints one line: OK, FAIL, or PENDING, followed by the check number,
  the file, and a one-line reason. The script never edits the spec.

  Checks
  1  goal-contract.md exists and has the six field headings from the goal-definition skill:
     "## 1. The judge", "## 2. Done-when", "## 3. Minimum inputs", "## 4. Roles and tiers",
     "## 5. Do-not-touch", "## 6. Verification".
  2  requirements.md exists, has an Introduction heading and "### Requirement N" blocks, each
     block has a User Story line and an Acceptance Criteria line, every criterion is numbered
     in sequence (N.M, or M inside block N), and every criterion contains THE SYSTEM SHALL or
     THE SESSION SHALL.
  3  design.md exists with the seven section headings of the design skeleton, in order:
     Overview, Mechanism, Invocations, Data boundary, Human gate, Verification, Status ledger.
  4  tasks.md exists, every task has a _Requirements: n.n_ line, every cited number is a
     criterion in requirements.md, every criterion is cited by at least one task (orphans are
     listed), and at least one task is the human gate.
  5  cards/schema-card.md, cards/edge-case-catalog.md, cards/interface-card.md, and at least
     one file under fixtures/ exist.
  6  No line in any file under the spec folder contains a term from scripts/banned-terms.txt
     (literal, case-sensitive; same rules as check-redaction.ps1).

  Phase
  A "Phase: <value>" line in the first ten lines of goal-contract.md says how far the spec has
  progressed. A file that a later phase produces prints PENDING instead of FAIL while it is
  absent:
    Phase: intake        checks 2, 3, 4, and 5 print PENDING when their files are absent.
    Phase: requirements  checks 3, 4, and 5 print PENDING when their files are absent.
    no Phase line        every file is required; an absent file prints FAIL.
Usage
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-spec.ps1 -Spec .kiro\specs\<name>
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-spec.ps1 -All

  -Spec checks one folder. -All checks every folder under .kiro\specs\, prints one block per
  spec, and ends with one summary line.

Exit codes
  0  no FAIL line in any checked spec (PENDING lines are allowed).
  1  at least one FAIL line in any checked spec.
  2  the spec folder does not exist, .kiro\specs\ has no folders, or neither switch was given.
#>
[CmdletBinding()]
param(
    [string]$Spec = '',
    [switch]$All
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:failCount = 0
$script:pendingCount = 0

function Write-Ok([int]$Check, [string]$File, [string]$Reason) {
    Write-Output ("OK      {0} {1}: {2}" -f $Check, $File, $Reason)
}
function Write-Fail([int]$Check, [string]$File, [string]$Reason) {
    $script:failCount++
    Write-Output ("FAIL    {0} {1}: {2}" -f $Check, $File, $Reason)
}
function Write-Pending([int]$Check, [string]$File, [string]$Reason) {
    $script:pendingCount++
    Write-Output ("PENDING {0} {1}: {2}" -f $Check, $File, $Reason)
}
function Read-Lines([string]$Path) {
    return ,[System.IO.File]::ReadAllLines($Path)
}
$repoRoot = Split-Path -Parent $PSScriptRoot

# Runs checks 1 to 6 on one resolved spec folder. Prints the header, the check lines, and the
# per-spec summary line. Counts go to $script:failCount and $script:pendingCount.
function Invoke-SpecChecks([string]$specPath) {
    $script:failCount = 0
    $script:pendingCount = 0
    Write-Output "check-spec: $specPath"

    # ---------------------------------------------------------------------------
    # Check 1: goal-contract.md
    # ---------------------------------------------------------------------------
    $goalFile = Join-Path $specPath 'goal-contract.md'
    $phase = ''   # '', 'intake', or 'requirements'
    if (-not (Test-Path -LiteralPath $goalFile -PathType Leaf)) {
        Write-Fail 1 'goal-contract.md' 'file missing'
    } else {
        $goalLines = Read-Lines $goalFile
        $fieldNames = @('The judge', 'Done-when', 'Minimum inputs', 'Roles and tiers', 'Do-not-touch', 'Verification')
        $missing = @()
        for ($n = 1; $n -le 6; $n++) {
            $pattern = '^##\s+' + $n + '\.\s+' + [regex]::Escape($fieldNames[$n - 1]) + '\s*$'
            $found = $false
            foreach ($line in $goalLines) {
                if ($line -imatch $pattern) { $found = $true; break }
            }
            if (-not $found) { $missing += ('## ' + $n + '. ' + $fieldNames[$n - 1]) }
        }
        if ($missing.Count -eq 0) {
            Write-Ok 1 'goal-contract.md' 'six field headings present'
        } else {
            Write-Fail 1 'goal-contract.md' ('missing headings: ' + ($missing -join '; '))
        }
        $top = $goalLines | Select-Object -First 10
        foreach ($line in $top) {
            if ($line -match '^Phase:\s*(intake|requirements)\s*$') { $phase = $Matches[1].ToLowerInvariant() }
        }
    }
    # Files a later phase produces are PENDING, not FAIL, while absent.
    $pendingRequirements = ($phase -eq 'intake')
    $pendingDesignTasksCards = ($phase -eq 'intake' -or $phase -eq 'requirements')
    $phaseNote = 'not yet written (Phase: ' + $phase + ')'

    # ---------------------------------------------------------------------------
    # Check 2: requirements.md
    # ---------------------------------------------------------------------------
    $reqFile = Join-Path $specPath 'requirements.md'
    $criteria = @{}   # key "N.M" -> line number
    $reqParsed = $false
    if (-not (Test-Path -LiteralPath $reqFile -PathType Leaf)) {
        if ($pendingRequirements) {
            Write-Pending 2 'requirements.md' $phaseNote
        } else {
            Write-Fail 2 'requirements.md' 'file missing'
        }
    } else {
        $reqParsed = $true
        $reqLines = Read-Lines $reqFile
        $hasIntro = $false
        foreach ($line in $reqLines) {
            if ($line -match '^##\s+Introduction\s*$') { $hasIntro = $true; break }
        }
        if ($hasIntro) {
            Write-Ok 2 'requirements.md' 'Introduction heading present'
        } else {
            Write-Fail 2 'requirements.md' 'no "## Introduction" heading'
        }

        # Split into requirement blocks: from "### Requirement N" to the next "##" heading.
        $blocks = @()
        $current = $null
        for ($i = 0; $i -lt $reqLines.Length; $i++) {
            $line = $reqLines[$i]
            if ($line -match '^###\s+Requirement\s+(\d+)\b') {
                $current = @{ Number = [int]$Matches[1]; Start = $i + 1; Lines = @() }
                $blocks += $current
                continue
            }
            if ($line -match '^##\s+') { $current = $null; continue }
            if ($null -ne $current) { $current.Lines += $line }
        }
        if ($blocks.Count -eq 0) {
            Write-Fail 2 'requirements.md' 'no "### Requirement N" block'
        } else {
            Write-Ok 2 'requirements.md' ($blocks.Count.ToString() + ' requirement block(s)')
        }

        $seenNumbers = @{}
        $blockProblems = @()
        $criterionProblems = @()
        foreach ($block in $blocks) {
            $n = $block.Number
            $label = 'Requirement ' + $n
            if ($seenNumbers.ContainsKey($n)) {
                $blockProblems += ($label + ' appears twice')
                continue
            }
            $seenNumbers[$n] = $true

            $hasStory = $false
            $criteriaStart = -1
            for ($j = 0; $j -lt $block.Lines.Count; $j++) {
                $line = $block.Lines[$j]
                if ($line -match '^\*{0,2}User Story\*{0,2}:') { $hasStory = $true }
                if ($line -match '^\*{0,2}Acceptance Criteria\*{0,2}:') { $criteriaStart = $j + 1 }
            }
            if (-not $hasStory) { $blockProblems += ($label + ' has no "User Story:" line') }
            if ($criteriaStart -lt 0) {
                $blockProblems += ($label + ' has no "Acceptance Criteria:" line')
                continue
            }

            # Collect criteria: a numbered line plus its indented continuation lines.
            $items = @()
            $item = $null
            for ($j = $criteriaStart; $j -lt $block.Lines.Count; $j++) {
                $line = $block.Lines[$j]
                if ($line -match '^(\d+)(?:\.(\d+))?\.?\s+(.*)$') {
                    $item = @{ Major = $Matches[1]; Minor = $Matches[2]; Text = $Matches[3]; Line = $block.Start + $j + 1 }
                    $items += $item
                    continue
                }
                if ($line -match '^\s+\S' -and $null -ne $item) {
                    $item.Text = $item.Text + ' ' + $line.Trim()
                    continue
                }
                $item = $null
            }
            if ($items.Count -eq 0) {
                $blockProblems += ($label + ' has no numbered criterion')
                continue
            }
            $expected = 1
            foreach ($it in $items) {
                if ([string]::IsNullOrEmpty($it.Minor)) {
                    $major = $n
                    $minor = [int]$it.Major
                } else {
                    $major = [int]$it.Major
                    $minor = [int]$it.Minor
                }
                $key = '{0}.{1}' -f $major, $minor
                if ($major -ne $n) {
                    $criterionProblems += ('line ' + $it.Line + ': ' + $key + ' sits under ' + $label)
                } elseif ($minor -ne $expected) {
                    $criterionProblems += ('line ' + $it.Line + ': ' + $key + ' expected ' + $n + '.' + $expected)
                }
                if ($it.Text -cnotmatch 'THE (SYSTEM|SESSION) SHALL') {
                    $criterionProblems += ('line ' + $it.Line + ': ' + $key + ' lacks THE SYSTEM SHALL or THE SESSION SHALL')
                }
                if ($criteria.ContainsKey($key)) {
                    $criterionProblems += ('line ' + $it.Line + ': ' + $key + ' duplicates line ' + $criteria[$key])
                } else {
                    $criteria[$key] = $it.Line
                }
                $expected++
            }
        }
        if ($blocks.Count -gt 0) {
            if ($blockProblems.Count -eq 0) {
                Write-Ok 2 'requirements.md' 'every block has User Story and Acceptance Criteria'
            } else {
                Write-Fail 2 'requirements.md' ($blockProblems -join '; ')
            }
            if ($criterionProblems.Count -eq 0) {
                Write-Ok 2 'requirements.md' ($criteria.Count.ToString() + ' criteria, all numbered N.M with THE SYSTEM SHALL or THE SESSION SHALL')
            } else {
                Write-Fail 2 'requirements.md' ($criterionProblems -join '; ')
            }
        }
    }

    # ---------------------------------------------------------------------------
    # Check 3: design.md
    # ---------------------------------------------------------------------------
    $designFile = Join-Path $specPath 'design.md'
    if (-not (Test-Path -LiteralPath $designFile -PathType Leaf)) {
        if ($pendingDesignTasksCards) {
            Write-Pending 3 'design.md' $phaseNote
        } else {
            Write-Fail 3 'design.md' 'file missing'
        }
    } else {
        $designLines = Read-Lines $designFile
        $sections = @('Overview', 'Mechanism', 'Invocations', 'Data boundary', 'Human gate', 'Verification', 'Status ledger')
        $positions = @()
        $missing = @()
        foreach ($s in $sections) {
            $pos = -1
            for ($i = 0; $i -lt $designLines.Length; $i++) {
                if ($designLines[$i] -match ('^##\s+' + [regex]::Escape($s) + '\s*$')) { $pos = $i; break }
            }
            if ($pos -lt 0) { $missing += ('## ' + $s) } else { $positions += $pos }
        }
        if ($missing.Count -gt 0) {
            Write-Fail 3 'design.md' ('missing headings: ' + ($missing -join '; '))
        } else {
            $inOrder = $true
            for ($i = 1; $i -lt $positions.Count; $i++) {
                if ($positions[$i] -lt $positions[$i - 1]) { $inOrder = $false }
            }
            if ($inOrder) {
                Write-Ok 3 'design.md' 'seven section headings present, in order'
            } else {
                Write-Fail 3 'design.md' 'seven section headings present but out of order'
            }
        }
    }

    # ---------------------------------------------------------------------------
    # Check 4: tasks.md
    # ---------------------------------------------------------------------------
    $tasksFile = Join-Path $specPath 'tasks.md'
    if (-not (Test-Path -LiteralPath $tasksFile -PathType Leaf)) {
        if ($pendingDesignTasksCards) {
            Write-Pending 4 'tasks.md' $phaseNote
        } else {
            Write-Fail 4 'tasks.md' 'file missing'
        }
    } else {
        $taskLines = Read-Lines $tasksFile
        $tasks = @()
        $task = $null
        for ($i = 0; $i -lt $taskLines.Length; $i++) {
            $line = $taskLines[$i]
            if ($line -match '^\s*-\s+\[[ xX]\]\s+(\d+)\.\s+(.*)$') {
                $task = @{ Number = $Matches[1]; Title = $Matches[2]; Line = $i + 1; Cites = @(); HasCiteLine = $false }
                $tasks += $task
                continue
            }
            if ($line -match '^\s*-?\s*_Requirements:\s*(.*?)_\s*$') {
                if ($null -eq $task) { continue }
                $task.HasCiteLine = $true
                $raw = $Matches[1]
                foreach ($tok in ($raw -split '[,\s]+')) {
                    if ($tok.Length -gt 0) { $task.Cites += $tok }
                }
                continue
            }
            if ($line -match '^##\s+') { $task = $null }
        }
        if ($tasks.Count -eq 0) {
            Write-Fail 4 'tasks.md' 'no "- [ ] N." task line'
        } else {
            Write-Ok 4 'tasks.md' ($tasks.Count.ToString() + ' task(s)')
            $noCite = @()
            $badCite = @()
            $cited = @{}
            $gateTasks = @()
            foreach ($t in $tasks) {
                if (-not $t.HasCiteLine) { $noCite += ('task ' + $t.Number) }
                foreach ($c in $t.Cites) {
                    if ($c -notmatch '^\d+\.\d+$') {
                        $badCite += ('task ' + $t.Number + ' cites "' + $c + '" (not N.M)')
                    } elseif ($reqParsed -and -not $criteria.ContainsKey($c)) {
                        $badCite += ('task ' + $t.Number + ' cites ' + $c + ' (no such criterion)')
                    }
                    $cited[$c] = $true
                }
                if ($t.Title -imatch 'human gate') { $gateTasks += $t.Number }
            }
            if ($noCite.Count -eq 0) {
                Write-Ok 4 'tasks.md' 'every task has a _Requirements:_ line'
            } else {
                Write-Fail 4 'tasks.md' ('no _Requirements:_ line: ' + ($noCite -join ', '))
            }
            if (-not $reqParsed) {
                Write-Fail 4 'tasks.md' 'requirements.md missing; citations cannot resolve'
            } elseif ($badCite.Count -eq 0) {
                Write-Ok 4 'tasks.md' 'every citation resolves to a criterion'
            } else {
                Write-Fail 4 'tasks.md' ($badCite -join '; ')
            }
            if ($reqParsed) {
                $orphans = @()
                foreach ($key in ($criteria.Keys | Sort-Object { [int]($_.Split('.')[0]) }, { [int]($_.Split('.')[1]) })) {
                    if (-not $cited.ContainsKey($key)) { $orphans += $key }
                }
                if ($orphans.Count -eq 0) {
                    Write-Ok 4 'tasks.md' 'every criterion is cited by a task'
                } else {
                    Write-Fail 4 'tasks.md' ('orphan criteria (no task cites them): ' + ($orphans -join ', '))
                }
            }
            if ($gateTasks.Count -gt 0) {
                Write-Ok 4 'tasks.md' ('human gate is task ' + ($gateTasks -join ', '))
            } else {
                Write-Fail 4 'tasks.md' 'no task titled "Human gate"'
            }
        }
    }

    # ---------------------------------------------------------------------------
    # Check 5: cards and fixtures
    # ---------------------------------------------------------------------------
    $cardNames = @('cards\schema-card.md', 'cards\edge-case-catalog.md', 'cards\interface-card.md')
    $missingCards = @()
    foreach ($c in $cardNames) {
        if (-not (Test-Path -LiteralPath (Join-Path $specPath $c) -PathType Leaf)) { $missingCards += $c }
    }
    $fixturesDir = Join-Path $specPath 'fixtures'
    $fixtureCount = 0
    if (Test-Path -LiteralPath $fixturesDir -PathType Container) {
        $fixtureCount = @(Get-ChildItem -LiteralPath $fixturesDir -File).Count
    }
    if ($fixtureCount -eq 0) { $missingCards += 'fixtures\ (at least one file)' }
    if ($missingCards.Count -eq 0) {
        Write-Ok 5 'cards, fixtures' ('three cards present, ' + $fixtureCount + ' fixture file(s)')
    } elseif ($pendingDesignTasksCards) {
        Write-Pending 5 'cards, fixtures' ($phaseNote + '; missing: ' + ($missingCards -join ', '))
    } else {
        Write-Fail 5 'cards, fixtures' ('missing: ' + ($missingCards -join ', '))
    }

    # ---------------------------------------------------------------------------
    # Check 6: banned terms
    # ---------------------------------------------------------------------------
    $termsFile = Join-Path $repoRoot 'scripts\banned-terms.txt'
    if (-not (Test-Path -LiteralPath $termsFile -PathType Leaf)) {
        Write-Fail 6 'scripts/banned-terms.txt' ('not found at ' + $termsFile)
    } else {
        $terms = @()
        foreach ($raw in (Read-Lines $termsFile)) {
            $t = $raw.Trim()
            if ($t.Length -eq 0) { continue }
            if ($t.StartsWith('#')) { continue }
            $terms += $t
        }
        $skipExtensions = @('.png', '.jpg', '.pdf', '.xlsx', '.xlsm', '.zip')
        $ordinal = [System.StringComparison]::Ordinal
        $hits = @()
        $files = @(Get-ChildItem -LiteralPath $specPath -Recurse -File -Force)
        foreach ($file in $files) {
            if ($skipExtensions -contains $file.Extension.ToLowerInvariant()) { continue }
            $rel = $file.FullName.Substring($specPath.Length).TrimStart('\')
            $lines = Read-Lines $file.FullName
            for ($i = 0; $i -lt $lines.Length; $i++) {
                foreach ($term in $terms) {
                    if ($lines[$i].IndexOf($term, $ordinal) -ge 0) {
                        $hits += ('{0}:{1}: {2}' -f $rel, ($i + 1), $term)
                    }
                }
            }
        }
        if ($terms.Count -eq 0) {
            Write-Fail 6 'scripts/banned-terms.txt' 'lists no terms'
        } elseif ($hits.Count -eq 0) {
            Write-Ok 6 'spec folder' ($files.Count.ToString() + ' file(s) scanned against ' + $terms.Count + ' terms, no hit')
        } else {
            Write-Fail 6 'spec folder' ('banned term hits: ' + ($hits -join '; '))
        }
    }

    # -----------------------------------------------------------------------
    Write-Output ("check-spec: {0} FAIL, {1} PENDING" -f $script:failCount, $script:pendingCount)
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
if ($All) {
    $specsRoot = Join-Path $repoRoot '.kiro\specs'
    $folders = @()
    if (Test-Path -LiteralPath $specsRoot -PathType Container) {
        $folders = @(Get-ChildItem -LiteralPath $specsRoot -Directory | Sort-Object Name)
    }
    if ($folders.Count -eq 0) {
        Write-Output "check-spec: no spec folders under $specsRoot"
        exit 2
    }
    $totalFail = 0
    $totalPending = 0
    $failedSpecs = @()
    foreach ($folder in $folders) {
        Invoke-SpecChecks $folder.FullName
        Write-Output ''
        $totalFail += $script:failCount
        $totalPending += $script:pendingCount
        if ($script:failCount -gt 0) { $failedSpecs += $folder.Name }
    }
    $summary = 'check-spec: {0} spec(s), {1} FAIL, {2} PENDING' -f $folders.Count, $totalFail, $totalPending
    if ($failedSpecs.Count -gt 0) { $summary += '; failing: ' + ($failedSpecs -join ', ') }
    Write-Output $summary
    if ($totalFail -gt 0) { exit 1 }
    exit 0
}

if ($Spec -eq '') {
    Write-Output 'check-spec: give -Spec <folder> or -All'
    exit 2
}
if (-not (Test-Path -LiteralPath $Spec -PathType Container)) {
    Write-Output "check-spec: spec folder not found: $Spec"
    exit 2
}
Invoke-SpecChecks (Resolve-Path -LiteralPath $Spec).Path
if ($script:failCount -gt 0) { exit 1 }
exit 0
