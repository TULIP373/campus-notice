$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$listeners = Get-NetTCPConnection -State Listen -LocalPort 5173 -ErrorAction SilentlyContinue
if (-not $listeners) { Write-Host 'Frontend is not running.'; return }
foreach ($listener in $listeners) {
    $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener.OwningProcess)
    if ($process.Name -ne 'node.exe' -or -not $process.CommandLine.Contains($projectRoot)) { throw 'Port 5173 belongs to another project. Refusing to stop it.' }
    Stop-Process -Id $process.ProcessId
}
Write-Host 'Frontend stopped.'
