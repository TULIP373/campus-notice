$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$docPath = Join-Path $taskRoot 'deliverables/202232110113余家祥.docx'
$pdfPath = Join-Path $PSScriptRoot 'report.pdf'
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$document = $null
try {
    $document = $word.Documents.Open($docPath, $false, $true)
    $document.Fields.Update() | Out-Null
    $document.Repaginate()
    $pages = [ordered]@{}
    for ($n = 1; $n -le 5; $n++) {
        $name = 'exp' + $n
        $pages[$name] = $document.Bookmarks.Item($name).Range.Information(3)
    }
    $pages | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'pages.json') -Encoding UTF8
    $document.ExportAsFixedFormat($pdfPath, 17)
    [ordered]@{ pages = $document.ComputeStatistics(2); toc = $pages; method = 'Word COM PDF export read only; no DOCX save' } | ConvertTo-Json -Depth 5
} finally {
    if ($null -ne $document) { $document.Close(0) }
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
