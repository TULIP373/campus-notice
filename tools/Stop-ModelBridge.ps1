$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$script = Join-Path $projectRoot 'model-service\bridge.py'
$recordPath = Join-Path $projectRoot '.runtime\model-bridge-process.json'
if (-not (Test-Path -LiteralPath $recordPath)) { Write-Host 'No model bridge process record.'; return }
$record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
if ($record.project -ne $projectRoot) { throw 'Process record belongs to another project.' }
$process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + [int]$record.pid)
if (-not $process) { Remove-Item -LiteralPath $recordPath; Write-Host 'Model bridge is not running.'; return }
$liveProcess = Get-Process -Id $record.pid
# PowerShell 7 may deserialize ISO timestamps as DateTime; compare UTC ticks,
# rather than coercing a DateTime to a culture-specific display string.
$recordStarted = if ($record.started -is [DateTime]) { $record.started.ToUniversalTime() } else {
    [DateTime]::Parse([string]$record.started, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
}
if ($process.Name -ne 'python.exe' -or -not $process.CommandLine.Contains($script) -or $liveProcess.StartTime.ToUniversalTime().Ticks -ne $recordStarted.Ticks) { throw 'Process identity changed; refusing to stop it.' }
# Only this verified service and its own SDK workers are terminated.
& taskkill /PID $record.pid /T /F | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Could not stop model bridge.' }
Remove-Item -LiteralPath $recordPath
Write-Host 'Model bridge stopped.'
