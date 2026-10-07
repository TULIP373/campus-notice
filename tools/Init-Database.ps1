param(
    [Parameter(Mandatory = $true)]
    [string]$SqlFile
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$databaseRoot = [IO.Path]::GetFullPath((Join-Path $projectRoot 'database'))
$candidatePath = if ([IO.Path]::IsPathRooted($SqlFile)) { $SqlFile } else { Join-Path $projectRoot $SqlFile }
$sqlPath = [IO.Path]::GetFullPath($candidatePath)
if (-not $sqlPath.StartsWith($databaseRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
    [IO.Path]::GetExtension($sqlPath) -ne '.sql' -or -not (Test-Path -LiteralPath $sqlPath -PathType Leaf)) {
    throw 'Choose an existing SQL file inside this project database directory.'
}
$runtimeRoot = Join-Path $projectRoot '.runtime'
$runtimeAlias = Join-Path $env:USERPROFILE '.local\campus-notice-runtime'
if (-not (Test-Path -LiteralPath $runtimeAlias)) { throw 'Run Start-Database.ps1 first.' }
$aliasInfo = Get-Item -LiteralPath $runtimeAlias -Force
if ($aliasInfo.LinkType -ne 'Junction' -or $aliasInfo.Target -ne $runtimeRoot) {
    throw 'The runtime alias belongs to another directory.'
}
$clientPath = Join-Path $runtimeAlias 'mysql-8.4.8\bin\mysql.exe'
$credentialPath = Join-Path $runtimeAlias 'mysql-app.cnf'
if (-not (Test-Path -LiteralPath $clientPath) -or -not (Test-Path -LiteralPath $credentialPath)) {
    throw 'Local MySQL runtime or private account configuration is missing.'
}
$startInfo = New-Object Diagnostics.ProcessStartInfo
$startInfo.FileName = $clientPath
$startInfo.Arguments = '--defaults-extra-file=mysql-app.cnf --default-character-set=utf8mb4 --batch campus_notice'
$startInfo.WorkingDirectory = $runtimeAlias
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardInput = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$clientProcess = New-Object Diagnostics.Process
$clientProcess.StartInfo = $startInfo
[void]$clientProcess.Start()
$sqlText = [IO.File]::ReadAllText($sqlPath, [Text.Encoding]::UTF8)
# Direct UTF-8 bytes prevent Windows PowerShell console encoding from damaging Chinese SQL.
$sqlBytes = [Text.UTF8Encoding]::new($false).GetBytes($sqlText)
$clientProcess.StandardInput.BaseStream.Write($sqlBytes, 0, $sqlBytes.Length)
$clientProcess.StandardInput.Close()
$outputTask = $clientProcess.StandardOutput.ReadToEndAsync()
$errorTask = $clientProcess.StandardError.ReadToEndAsync()
$clientProcess.WaitForExit()
$clientOutput = $outputTask.Result
$clientError = $errorTask.Result
if ($clientProcess.ExitCode -ne 0) { throw ('SQL execution failed: ' + $clientError.Trim()) }
if ($clientOutput) { Write-Output $clientOutput.Trim() }
Write-Host ('SQL completed: database/' + [IO.Path]::GetFileName($sqlPath))
$clientProcess.Dispose()
