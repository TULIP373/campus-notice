param([switch]$SkipRun)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
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
$accounts = @{}
if (Test-Path -LiteralPath $accountFile) {
    (Get-Content -LiteralPath $accountFile -Raw -Encoding UTF8 | ConvertFrom-Json).PSObject.Properties | ForEach-Object {
        $accounts[$_.Name] = @{username=$_.Value.username;password=$_.Value.password}
    }
}
$definitions = @(
    @{key='student';username='demo_student';name='余同学';courses=@()},
    @{key='teacher';username='demo_teacher';name='陈老师';courses=@('软件项目实训（二）')},
    @{key='teacher_database';username='teacher_database';name='林老师';courses=@('数据库原理')},
    @{key='teacher_testing';username='teacher_testing';name='周老师';courses=@('软件测试')},
    @{key='teacher_java';username='teacher_java';name='王老师';courses=@('Java程序设计')},
    @{key='teacher_structure';username='teacher_structure';name='赵老师';courses=@('数据结构')},
    @{key='teacher_network';username='teacher_network';name='孙老师';courses=@('计算机网络')},
    @{key='teacher_os';username='teacher_os';name='刘老师';courses=@('操作系统')},
    @{key='teacher_web';username='teacher_web';name='许老师';courses=@('Web前端开发')}
)
foreach ($definition in $definitions) {
    if (-not $accounts.ContainsKey($definition.key)) {
        $accounts[$definition.key] = @{username=$definition.username;password=(New-PrivateValue)}
    }
    $accounts[$definition.key].name = $definition.name
    $accounts[$definition.key].courses = $definition.courses
}
[IO.File]::WriteAllText($accountFile, ($accounts | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
$accountLines = [Collections.Generic.List[string]]::new()
$accountLines.Add('演示账号')
$accountLines.Add('登录地址：http://127.0.0.1:5173/')
$accountLines.Add('双击 start.cmd 启动前后端，双击 stop.cmd 关闭前后端。')
$accountLines.Add('教师账号只显示和维护自己的任教课程；学生账号可查看全部课程。')
foreach ($definition in $definitions) {
    $account = $accounts[$definition.key]
    $accountLines.Add('')
    $accountLines.Add($definition.name + $(if ($definition.courses.Count) { ' · ' + ($definition.courses -join '、') } else { ' · 学生' }))
    $accountLines.Add('用户名：' + $account.username)
    $accountLines.Add('密码：' + $account.password)
}
[IO.File]::WriteAllLines((Join-Path $projectRoot '演示账号.txt'), $accountLines, [Text.UTF8Encoding]::new($true))
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
