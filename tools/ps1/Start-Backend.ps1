param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runtimeRoot = Join-Path $projectRoot '.runtime'
New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
$javaHomeCandidates = @($env:JAVA_HOME, (Join-Path $env:USERPROFILE '.jdks\ms-17.0.20.1'))
foreach ($candidate in $javaHomeCandidates) {
    if (-not $candidate) { continue }
    $java = Join-Path $candidate 'bin\java.exe'
    if (-not (Test-Path -LiteralPath $java)) { continue }
    $version = & $java --version | Out-String
    if ($version -match '(?m)^(openjdk|java) 17\.') { $env:JAVA_HOME = $candidate; break }
}
if (-not $env:JAVA_HOME -or -not ($version -match '(?m)^(openjdk|java) 17\.')) { throw 'Set JAVA_HOME to an installed JDK 17.' }
$java = Join-Path $env:JAVA_HOME 'bin\java.exe'
$env:PATH = (Join-Path $env:JAVA_HOME 'bin') + ';' + $env:PATH
$listener = Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue
if ($listener) { throw 'Port 8080 is in use. Stop the previous backend first with Stop-Backend.ps1.' }
Push-Location $projectRoot
try {
    if (-not $SkipBuild) {
        & .\mvnw.cmd -B -ntp package
        if ($LASTEXITCODE -ne 0) { throw 'Maven build failed.' }
    }
    $jar = Join-Path $projectRoot 'target\campus-notice-0.0.1-SNAPSHOT.jar'
    if (-not (Test-Path -LiteralPath $jar)) { throw 'Build the JAR before starting.' }
    $process = Start-Process -FilePath $java -ArgumentList @('-Dfile.encoding=UTF-8', '-jar', ('"' + $jar + '"'), '--server.address=127.0.0.1') -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtimeRoot 'backend.log') -RedirectStandardError (Join-Path $runtimeRoot 'backend-error.log')
    [System.IO.File]::WriteAllText((Join-Path $runtimeRoot 'backend-process.json'), (@{pid=$process.Id;project=$projectRoot} | ConvertTo-Json), [System.Text.UTF8Encoding]::new($false))
    for ($attempt = 0; $attempt -lt 40; $attempt++) {
        try {
            $health = Invoke-RestMethod 'http://127.0.0.1:8080/api/health'
            if ($health.status -eq 'UP') { Write-Host 'Backend ready: http://127.0.0.1:8080'; return }
        } catch {}
        if ($process.HasExited) { break }
        Start-Sleep -Seconds 1
    }
    throw 'Backend startup failed. Read .runtime/backend.log and backend-error.log.'
} finally { Pop-Location }
