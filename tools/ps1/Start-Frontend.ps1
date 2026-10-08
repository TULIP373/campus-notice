$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$frontendRoot = Join-Path $projectRoot 'frontend'
$runtimeRoot = Join-Path $projectRoot '.runtime'
New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
$taskNode = (Get-Command node.exe -ErrorAction Stop).Source
$taskNpm = Join-Path (Split-Path -Parent $taskNode) 'npm.cmd'
if (-not (Test-Path -LiteralPath $taskNpm)) { $taskNpm = (Get-Command npm.cmd -ErrorAction Stop).Source }
if (Get-NetTCPConnection -State Listen -LocalPort 5173 -ErrorAction SilentlyContinue) { throw 'Port 5173 is in use. Stop the previous frontend first.' }
Push-Location $frontendRoot
try {
    if (-not (Test-Path -LiteralPath 'node_modules\vite\bin\vite.js')) {
        & $taskNpm ci
        if ($LASTEXITCODE -ne 0) { throw 'npm ci failed.' }
    }
    $vite = Join-Path $frontendRoot 'node_modules\vite\bin\vite.js'
    $process = Start-Process -FilePath $taskNode -ArgumentList @(('"' + $vite + '"'), '--host', '127.0.0.1', '--port', '5173', '--strictPort') -WorkingDirectory $frontendRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtimeRoot 'frontend.log') -RedirectStandardError (Join-Path $runtimeRoot 'frontend-error.log')
    [IO.File]::WriteAllText((Join-Path $runtimeRoot 'frontend-process.json'), (@{pid=$process.Id;project=$projectRoot} | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        try {
            $response = Invoke-WebRequest 'http://127.0.0.1:5173/' -UseBasicParsing
            if ($response.StatusCode -eq 200) { Write-Host 'Frontend ready: http://127.0.0.1:5173'; return }
        } catch {}
        if ($process.HasExited) { break }
        Start-Sleep -Seconds 1
    }
    throw 'Frontend startup failed. Read .runtime/frontend-error.log.'
} finally { Pop-Location }
