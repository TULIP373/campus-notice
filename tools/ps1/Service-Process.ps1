function Test-ProjectProcess($Process, [string]$ProjectRoot, [string]$ProcessName) {
    if (-not $Process -or $Process.Name -ne $ProcessName -or -not $Process.CommandLine) { return $false }
    if ($Process.CommandLine.IndexOf($ProjectRoot, [StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    if ($ProcessName -ne 'java.exe') { return $false }
    $mainClass = 'com.example.campusnotice.CampusNoticeApplication'
    $classesPath = Join-Path $ProjectRoot 'target\classes'
    # Maven 和 IDEA 可将中文路径写入 Java 参数文件，命令行只留下 @文件名。
    foreach ($match in [regex]::Matches($Process.CommandLine, '@(?:"([^"]+)"|([^\s]+))')) {
        $argumentFile = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[2].Value }
        if (-not (Test-Path -LiteralPath $argumentFile -PathType Leaf)) { continue }
        if ((Get-Item -LiteralPath $argumentFile).Length -gt 1048576) { continue }
        foreach ($encoding in @([Text.Encoding]::UTF8, [Text.Encoding]::GetEncoding(936))) {
            $text = [IO.File]::ReadAllText($argumentFile, $encoding).Replace('\\', '\').Replace('/', '\')
            if (-not ($Process.CommandLine.Contains($mainClass) -or $text.Contains($mainClass))) { continue }
            foreach ($entry in $text.Split(';')) {
                if ($entry.Trim().Trim('"') -ieq $classesPath) { return $true }
            }
        }
    }
    return $false
}
