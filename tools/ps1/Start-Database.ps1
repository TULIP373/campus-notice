$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeRoot = Join-Path $projectRoot '.runtime'
$runtimeAlias = Join-Path $env:USERPROFILE '.local\campus-notice-runtime'
if (-not (Test-Path -LiteralPath $runtimeAlias)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $runtimeAlias) -Force | Out-Null
    New-Item -ItemType Junction -Path $runtimeAlias -Target $runtimeRoot | Out-Null
}
$aliasInfo = Get-Item -LiteralPath $runtimeAlias -Force
if ($aliasInfo.LinkType -ne 'Junction' -or $aliasInfo.Target -ne $runtimeRoot) {
    throw 'The runtime alias belongs to another directory. Do not overwrite it.'
}
$serverExecutable = Join-Path $runtimeAlias 'mysql-8.4.8\bin\mysqld.exe'
$existingListener = Get-NetTCPConnection -State Listen -LocalPort 3307 -ErrorAction SilentlyContinue
if ($existingListener) {
    $existingProcess = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $existingListener[0].OwningProcess)
    if ($existingProcess.ExecutablePath -eq $serverExecutable) {
        Write-Host 'MySQL is already running: 127.0.0.1:3307'
        return
    }
    throw 'Port 3307 is occupied by another service.'
}
$baseValue = (Join-Path $runtimeAlias 'mysql-8.4.8').Replace('\', '/')
$dataValue = (Join-Path $runtimeAlias 'mysql-data').Replace('\', '/')
$serverConfig = "[mysqld]`nbasedir=$baseValue`ndatadir=$dataValue`nbind-address=127.0.0.1`nport=3307`nmysqlx=0"
[System.IO.File]::WriteAllText((Join-Path $runtimeRoot 'mysql-server.cnf'), $serverConfig, [System.Text.UTF8Encoding]::new($false))
$serverProcess = Start-Process -FilePath $serverExecutable -ArgumentList @('--defaults-file=mysql-server.cnf', '--console') -WorkingDirectory $runtimeAlias -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtimeRoot 'mysql.log') -RedirectStandardError (Join-Path $runtimeRoot 'mysql-error.log')
@{mysql=$serverProcess.Id;mysqlExecutable=$serverExecutable;mysqlPort=3307;runtimeAlias=$runtimeAlias} |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $runtimeRoot 'mysql-process.json') -Encoding UTF8
for ($attempt = 0; $attempt -lt 20; $attempt++) {
    if (Get-NetTCPConnection -State Listen -LocalPort 3307 -ErrorAction SilentlyContinue) {
        Write-Host 'MySQL ready: 127.0.0.1:3307 / campus_notice'
        return
    }
    if ($serverProcess.HasExited) { break }
    Start-Sleep -Seconds 1
}
throw 'MySQL failed to start. Inspect .runtime/mysql-error.log.'
