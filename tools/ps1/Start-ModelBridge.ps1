param([string]$Python = '', [string]$CodexBin = '')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeRoot = Join-Path $projectRoot '.runtime'
$script = Join-Path $projectRoot 'model-service\bridge.py'
if (-not $Python) { $Python = Join-Path $runtimeRoot 'sdk-research\Scripts\python.exe' }
if (-not (Test-Path -LiteralPath $Python)) { throw 'Install the Python SDK venv first; see model-service/README.md.' }
if ($CodexBin -and -not (Test-Path -LiteralPath $CodexBin)) { throw 'Codex executable does not exist.' }
if (Get-NetTCPConnection -State Listen -LocalPort 8787 -ErrorAction SilentlyContinue) { throw 'Port 8787 is already in use.' }
New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
$previousBin = $env:CAMPUS_CODEX_BIN
try {
    if ($CodexBin) { $env:CAMPUS_CODEX_BIN = $CodexBin }
    $process = Start-Process -FilePath $Python -ArgumentList @('-I', '-X', 'utf8', ('"' + $script + '"')) -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtimeRoot 'model-bridge.log') -RedirectStandardError (Join-Path $runtimeRoot 'model-bridge-error.log')
    $record = @{pid=$process.Id;project=$projectRoot;started=$process.StartTime.ToUniversalTime().ToString('o')}
    [IO.File]::WriteAllText((Join-Path $runtimeRoot 'model-bridge-process.json'), ($record | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        try {
            $health = Invoke-RestMethod 'http://127.0.0.1:8787/health'
            if ($health.status -eq 'UP') { Write-Host 'Model bridge ready: http://127.0.0.1:8787 (model not checked).'; return }
        } catch {}
        if ($process.HasExited) { break }
        Start-Sleep -Seconds 1
    }
    if (-not $process.HasExited) { Stop-Process -Id $process.Id }
    throw 'Model bridge startup failed. See .runtime/model-bridge-error.log.'
} finally { $env:CAMPUS_CODEX_BIN = $previousBin }
