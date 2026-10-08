$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. "$PSScriptRoot\Service-Process.ps1"
$listeners = Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue
if (-not $listeners) { Write-Host 'Backend is not running.'; return }
foreach ($listener in $listeners) {
    $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener.OwningProcess)
    if (-not (Test-ProjectProcess $process $projectRoot 'java.exe')) { throw 'Port 8080 belongs to another project. Refusing to stop it.' }
    Stop-Process -Id $process.ProcessId
}
Write-Host 'Backend stopped. Database data is preserved.'
