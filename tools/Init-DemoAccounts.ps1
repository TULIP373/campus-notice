param([switch]$SkipRun)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeRoot = Join-Path $projectRoot '.runtime'
New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
function New-PrivateValue {
    $buffer = New-Object byte[] 36
    $generator = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $generator.GetBytes($buffer) } finally { $generator.Dispose() }
    [Convert]::ToBase64String($buffer)
}
$securityFile = Join-Path $runtimeRoot 'security.properties'
if (-not (Test-Path -LiteralPath $securityFile)) {
    [IO.File]::WriteAllText($securityFile, ('app.jwt.secret=' + (New-PrivateValue)), [Text.UTF8Encoding]::new($false))
}
$accountFile = Join-Path $runtimeRoot 'demo-accounts.json'
if (-not (Test-Path -LiteralPath $accountFile)) {
    $accounts = @{teacher=@{username='demo_teacher';password=(New-PrivateValue)};student=@{username='demo_student';password=(New-PrivateValue)}}
    [IO.File]::WriteAllText($accountFile, ($accounts | ConvertTo-Json -Depth 3), [Text.UTF8Encoding]::new($false))
}
Write-Host 'Private demo accounts are in .runtime/demo-accounts.json. Passwords are not printed.'
if ($SkipRun) { return }
$javaHome = $env:JAVA_HOME
if (-not $javaHome) { $javaHome = Join-Path $env:USERPROFILE '.jdks/ms-17.0.20.1' }
$java = Join-Path $javaHome 'bin/java.exe'
if (-not (Test-Path -LiteralPath $java)) { throw 'Set JAVA_HOME to JDK17.' }
$jar = Join-Path $projectRoot 'target/campus-notice-0.0.1-SNAPSHOT.jar'
if (-not (Test-Path -LiteralPath $jar)) { throw 'Build the backend first.' }
Push-Location $projectRoot
try {
    & $java '-Dfile.encoding=UTF-8' '-jar' $jar '--server.port=0' '--app.demo.initialize=true' *> (Join-Path $runtimeRoot 'demo-init.log')
    if ($LASTEXITCODE -ne 0) { throw 'Initialization failed. Check .runtime/demo-init.log locally.' }
    Write-Host 'Demo accounts initialized with BCrypt; existing accounts were kept.'
} finally { Pop-Location }
