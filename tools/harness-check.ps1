# harness-check.ps1
# Mechanical gate for the harness workflow. ASCII only on purpose.
#
#   -Stage ready     spec and acceptance criteria are filled in; safe to launch
#   -Stage coverage  ready + every AC id is mentioned in docs/test-cases*.md
#   -Stage final     coverage + report completeness, evidence files, review record
#                    completeness, and (in a git repo) nothing changed since the
#                    verified commit except acceptance artifacts
#
# Passing this script is necessary, not sufficient. It checks that the paperwork
# is complete and consistent. It cannot tell whether a test really asserts
# anything, whether evidence content is right, or whether the review was
# independent.
#
# Exit code 0 = passed, 1 = problems found.

param(
    [ValidateSet('ready', 'coverage', 'final')]
    [string]$Stage = 'ready',
    [string]$Root = ''
)

$ErrorActionPreference = 'Stop'
if ($Root -eq '') { $Root = Split-Path -Parent $PSScriptRoot }
$Root = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\')

$problems = New-Object System.Collections.Generic.List[string]
$notes = New-Object System.Collections.Generic.List[string]
$utf8 = New-Object System.Text.UTF8Encoding($false)
$idPattern = 'AC-[A-Z0-9]+-\d+'
$hashPattern = '[0-9a-fA-F]{7,40}'

# Files that may change after verification without invalidating it.
$artifactFiles = @('docs/acceptance-report.md', 'docs/review-record.md', 'docs/PROGRESS.md')
$artifactDirs = @('reports/')

function Read-Lines([string]$rel) {
    $p = Join-Path $Root $rel
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return $null }
    return , @([System.IO.File]::ReadAllLines($p, $utf8))
}

function Invoke-Git([string]$Arguments) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'git'
    $psi.Arguments = '-c core.quotepath=false -C "' + $Root + '" ' + $Arguments
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = $utf8
    try { $proc = [System.Diagnostics.Process]::Start($psi) } catch { return $null }
    $out = $proc.StandardOutput.ReadToEnd()
    $null = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()
    return @{ Code = $proc.ExitCode; Out = $out }
}

function Test-SameCommit([string]$a, [string]$b) {
    $x = $a.ToLowerInvariant()
    $y = $b.ToLowerInvariant()
    return ($x.StartsWith($y) -or $y.StartsWith($x))
}

# ---- required files ---------------------------------------------------------
$required = @('AGENTS.md', 'spec\main.md', 'docs\acceptance.md', 'docs\workflow.md', 'docs\PROGRESS.md')
foreach ($rel in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $Root $rel) -PathType Leaf)) {
        $problems.Add("missing file: $rel")
    }
}

# ---- unfilled placeholders --------------------------------------------------
$scan = New-Object System.Collections.Generic.List[string]
$scan.Add('AGENTS.md')
$scan.Add('docs\acceptance.md')
$specDir = Join-Path $Root 'spec'
if (Test-Path -LiteralPath $specDir -PathType Container) {
    Get-ChildItem -LiteralPath $specDir -Recurse -File -Filter '*.md' | ForEach-Object {
        $scan.Add($_.FullName.Substring($Root.Length).TrimStart('\'))
    }
}
foreach ($rel in $scan) {
    $lines = Read-Lines $rel
    if ($null -eq $lines) { continue }
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Contains('TODO(harness)')) {
            $problems.Add("unfilled placeholder: ${rel}:$($i + 1)")
        }
    }
}

# ---- open decisions in spec/main.md ----------------------------------------
$mainSpec = Read-Lines 'spec\main.md'
if ($null -ne $mainSpec) {
    for ($i = 0; $i -lt $mainSpec.Count; $i++) {
        if ($mainSpec[$i] -match '^\s*[-*]\s+\[ \]') {
            $problems.Add("open decision (unchecked box): spec\main.md:$($i + 1)")
        }
    }
}

# ---- acceptance criteria ids ------------------------------------------------
$ids = New-Object System.Collections.Generic.List[string]
$acc = Read-Lines 'docs\acceptance.md'
if ($null -ne $acc) {
    $strict = '^\s*[-*]\s+\*\*(' + $idPattern + ')\*\*'
    $loose = '^\s*(?:[-*+]\s+)?(?:\*\*|__)?AC-'
    for ($i = 0; $i -lt $acc.Count; $i++) {
        $line = $acc[$i]
        if ($line -cmatch $strict) {
            $id = $Matches[1]
            if ($ids.Contains($id)) { $problems.Add("duplicate criterion id: $id") }
            else { $ids.Add($id) }
        }
        elseif ($line -cmatch $loose) {
            # Looks like a criterion but would be silently ignored. Refuse instead.
            $problems.Add("malformed criterion line (expected '- **AC-XXX-01** ...'): docs\acceptance.md:$($i + 1)")
        }
    }
    if ($ids.Count -eq 0) {
        $problems.Add('docs\acceptance.md defines no criteria (expected lines like "- **AC-RUN-01** ...")')
    }
}

# ---- coverage ---------------------------------------------------------------
if ($Stage -eq 'coverage' -or $Stage -eq 'final') {
    $docsDir = Join-Path $Root 'docs'
    $testFiles = @()
    if (Test-Path -LiteralPath $docsDir -PathType Container) {
        $testFiles = @(Get-ChildItem -LiteralPath $docsDir -File -Filter 'test-cases*.md')
    }
    if ($testFiles.Count -eq 0) {
        $problems.Add('missing file: docs\test-cases.md (written by test-author in workflow step 2)')
    }
    else {
        $mentioned = New-Object System.Collections.Generic.HashSet[string]
        foreach ($f in $testFiles) {
            $text = [System.IO.File]::ReadAllText($f.FullName, $utf8)
            foreach ($m in [regex]::Matches($text, $idPattern)) { [void]$mentioned.Add($m.Value) }
        }
        foreach ($id in $ids) {
            if (-not $mentioned.Contains($id)) { $problems.Add("no test case mentions: $id") }
        }
    }
}

# ---- final ------------------------------------------------------------------
if ($Stage -eq 'final') {
    $verified = ''

    # -- acceptance report: one row per criterion, PASS, real evidence files --
    $report = Read-Lines 'docs\acceptance-report.md'
    if ($null -eq $report) {
        $problems.Add('missing file: docs\acceptance-report.md (written by the main agent in workflow step 9)')
    }
    else {
        $rows = @{}
        $dupes = New-Object System.Collections.Generic.HashSet[string]
        foreach ($line in $report) {
            if ($line -cmatch ('^\s*Verified-Commit:\s*`?(' + $hashPattern + ')`?\s*$')) { $verified = $Matches[1] }
            if ($line -cmatch ('^\s*\|\s*(' + $idPattern + ')\s*\|\s*([A-Za-z]*)\s*\|([^|]*)\|')) {
                $rid = $Matches[1]
                if ($rows.ContainsKey($rid)) { [void]$dupes.Add($rid) }
                else { $rows[$rid] = @{ Result = $Matches[2].ToUpperInvariant(); Evidence = $Matches[3].Trim() } }
            }
        }
        foreach ($d in $dupes) { $problems.Add("report has more than one row for: $d (keep exactly one)") }
        foreach ($id in $ids) {
            if ($dupes.Contains($id)) { continue }
            if (-not $rows.ContainsKey($id)) { $problems.Add("report has no row for: $id"); continue }
            $row = $rows[$id]
            if ($row.Result -ne 'PASS') {
                $shown = $row.Result
                if ($shown -eq '') { $shown = '(empty)' }
                $problems.Add("not passed: $id is $shown")
                continue
            }
            $paths = @([regex]::Matches($row.Evidence, '`([^`]+)`') | ForEach-Object { $_.Groups[1].Value })
            if ($paths.Count -eq 0) {
                $problems.Add("no evidence file cited for: $id (put a repo path in backticks)")
                continue
            }
            foreach ($p in $paths) {
                $full = ''
                try { $full = [System.IO.Path]::GetFullPath((Join-Path $Root $p)) } catch { $full = '' }
                if ($full -eq '' -or -not $full.StartsWith($Root + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
                    $problems.Add("evidence path is not inside the project: $id -> $p")
                }
                elseif (Test-Path -LiteralPath $full -PathType Container) {
                    $problems.Add("evidence is a folder, cite a file: $id -> $p")
                }
                elseif (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
                    $problems.Add("evidence file does not exist: $id -> $p")
                }
                elseif ((Get-Item -LiteralPath $full).Length -eq 0) {
                    $problems.Add("evidence file is empty: $id -> $p")
                }
            }
        }
    }

    # -- is this a git work tree? --------------------------------------------
    $isGit = $false
    $probe = Invoke-Git 'rev-parse --is-inside-work-tree'
    if ($null -eq $probe) {
        $notes.Add('version binding NOT checked: git is not available')
    }
    elseif ($probe.Code -ne 0 -or $probe.Out.Trim() -ne 'true') {
        $notes.Add('version binding NOT checked: this folder is not a git repository')
    }
    else { $isGit = $true }

    # -- review record completeness (not proof that the review was independent)
    $review = Read-Lines 'docs\review-record.md'
    $reviewed = ''
    if ($null -eq $review) {
        $problems.Add('missing file: docs\review-record.md (reviewer verdict saved verbatim in workflow step 8)')
    }
    else {
        $verdicts = New-Object System.Collections.Generic.List[string]
        foreach ($line in $review) {
            if ($line -cmatch '^\s*Verdict:\s*([A-Za-z]+)') { $verdicts.Add($Matches[1].ToUpperInvariant()) }
            if ($line -cmatch ('^\s*Reviewed-Commit:\s*`?(' + $hashPattern + ')`?\s*$')) { $reviewed = $Matches[1] }
        }
        if ($verdicts.Count -eq 0) { $problems.Add('review record has no "Verdict: PASS" line') }
        elseif ($verdicts.Count -gt 1) { $problems.Add('review record has more than one Verdict line (keep only the latest review; move older ones to reports/)') }
        elseif ($verdicts[0] -ne 'PASS') { $problems.Add("review record verdict is $($verdicts[0])") }
    }

    # -- version binding ------------------------------------------------------
    if ($isGit) {
        if ($null -ne $report -and $verified -eq '') {
            $problems.Add('report has no "Verified-Commit: <hash>" line')
        }
        if ($null -ne $review -and $reviewed -eq '') {
            $problems.Add('review record has no "Reviewed-Commit: <hash>" line')
        }
        if ($verified -ne '' -and $reviewed -ne '' -and -not (Test-SameCommit $verified $reviewed)) {
            $problems.Add("review record covers commit $reviewed but the report verifies $verified")
        }
        if ($verified -ne '') {
            $exists = Invoke-Git ('cat-file -e ' + $verified + '^{commit}')
            if ($exists.Code -ne 0) {
                $problems.Add("Verified-Commit $verified is not a commit in this repository")
            }
            else {
                $changed = New-Object System.Collections.Generic.List[string]
                $tracked = Invoke-Git ('diff --name-only --relative ' + $verified + ' -- .')
                $untracked = Invoke-Git 'ls-files --others --exclude-standard'
                foreach ($res in @($tracked, $untracked)) {
                    if ($res.Code -ne 0) { $problems.Add('git could not list changes since the verified commit'); continue }
                    foreach ($raw in ($res.Out -split "`n")) {
                        $f = $raw.Trim().Replace('\', '/')
                        if ($f -eq '') { continue }
                        $isArtifact = $artifactFiles -contains $f
                        foreach ($d in $artifactDirs) { if ($f.StartsWith($d)) { $isArtifact = $true } }
                        if (-not $isArtifact -and -not $changed.Contains($f)) { $changed.Add($f) }
                    }
                }
                if ($changed.Count -gt 0) {
                    $shown = @($changed | Select-Object -First 10) -join ', '
                    $more = ''
                    if ($changed.Count -gt 10) { $more = " (+$($changed.Count - 10) more)" }
                    $problems.Add("changed since verified commit ${verified}: $shown$more - commit, re-verify and update the report")
                }
            }
        }
    }
}

# ---- result -----------------------------------------------------------------
foreach ($n in $notes) { Write-Output "harness-check: NOTE $n" }
if ($problems.Count -gt 0) {
    Write-Output "harness-check: stage '$Stage' FAILED with $($problems.Count) problem(s):"
    foreach ($p in $problems) { Write-Output "  - $p" }
    exit 1
}
Write-Output "harness-check: stage '$Stage' passed ($($ids.Count) criteria). Paperwork is complete; this does not replace running the tests or the independent review."
exit 0
