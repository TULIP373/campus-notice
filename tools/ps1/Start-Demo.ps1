param(
    [ValidateSet('All', 'Backend', 'Frontend', 'Model', 'Stop')]
    [string]$Mode = 'All',
    [switch]$NoBrowser,
    [switch]$NoPause
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. "$PSScriptRoot\Service-Process.ps1"

function Test-RunningService([int]$Port, [string]$ProcessName, [string]$Url) {
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return $false }
    foreach ($listener in $listeners) {
        $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener.OwningProcess)
        if (-not (Test-ProjectProcess $process $projectRoot $ProcessName)) {
            throw "Port $Port is used by another program. Close that program or change its port."
        }
    }
    if ($Port -eq 5173) {
        $response = Invoke-WebRequest $Url -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -ne 200) { throw "Frontend on port $Port is not ready." }
    } else {
        $health = Invoke-RestMethod $Url -TimeoutSec 5
        if ($health.status -ne 'UP') { throw "Service on port $Port is not ready." }
    }
    Write-Host "Already running: $Url"
    return $true
}

try {
    if ($Mode -eq 'Stop') {
        & "$PSScriptRoot\Stop-Frontend.ps1"
        & "$PSScriptRoot\Stop-Backend.ps1"
        Write-Host 'Frontend and backend stopped. MySQL remains running.'
        exit 0
    }
    # Check occupied ports before starting another service.
    $backendRunning = $false
    $frontendRunning = $false
    if ($Mode -in @('All', 'Backend')) {
        $backendRunning = Test-RunningService 8080 'java.exe' 'http://127.0.0.1:8080/api/health'
    }
    if ($Mode -in @('All', 'Frontend')) {
        $frontendRunning = Test-RunningService 5173 'node.exe' 'http://127.0.0.1:5173/'
    }
    if ($Mode -in @('All', 'Backend')) {
        & "$PSScriptRoot\Start-Database.ps1"
        if (-not $backendRunning) {
            $hasJar = Test-Path -LiteralPath (Join-Path $projectRoot 'target\campus-notice-0.0.1-SNAPSHOT.jar')
            & "$PSScriptRoot\Start-Backend.ps1" -SkipBuild:$hasJar
        }
    }
    if ($Mode -in @('All', 'Frontend') -and -not $frontendRunning) {
        & "$PSScriptRoot\Start-Frontend.ps1"
    }
    if ($Mode -eq 'Model' -and -not (Test-RunningService 8787 'python.exe' 'http://127.0.0.1:8787/health')) {
        & "$PSScriptRoot\Start-ModelBridge.ps1"
    }
    if ($Mode -in @('All', 'Frontend') -and -not $NoBrowser) {
        Start-Process 'http://127.0.0.1:5173/'
    }
    exit 0
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host 'See .runtime logs for startup errors.'
    exit 1
}
