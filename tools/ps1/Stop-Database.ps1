$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeAlias = Join-Path $env:USERPROFILE '.local\campus-notice-runtime'
$aliasInfo = Get-Item -LiteralPath $runtimeAlias -Force
if ($aliasInfo.LinkType -ne 'Junction' -or $aliasInfo.Target -ne (Join-Path $projectRoot '.runtime')) {
    throw 'The runtime alias belongs to another directory.'
}
$listener = Get-NetTCPConnection -State Listen -LocalPort 3307 -ErrorAction SilentlyContinue
if (-not $listener) { Write-Host 'MySQL is already stopped.'; return }
$serverExecutable = Join-Path $runtimeAlias 'mysql-8.4.8\bin\mysqld.exe'
$serverProcess = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $listener[0].OwningProcess)
if ($serverProcess.ExecutablePath -ne $serverExecutable) { throw 'Port 3307 belongs to another service.' }
Push-Location -LiteralPath $runtimeAlias
try {
    & (Join-Path $runtimeAlias 'mysql-8.4.8\bin\mysql.exe') --defaults-extra-file=mysql-root.cnf --execute SHUTDOWN
    if ($LASTEXITCODE -ne 0) { throw 'MySQL shutdown failed.' }
} finally { Pop-Location }
Wait-Process -Id $serverProcess.ProcessId -Timeout 15 -ErrorAction SilentlyContinue
Write-Host 'Project MySQL stopped; data is preserved.'
