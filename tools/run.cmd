@echo off
setlocal
set "mode=%~1"
set "noninteractive=%~2"
pushd "%~dp0.."
if errorlevel 1 exit /b 1
if /i "%noninteractive%"=="-NoPause" (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\Start-Demo.ps1" -Mode "%mode%" -NoBrowser -NoPause
) else (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\Start-Demo.ps1" -Mode "%mode%"
)
set "result=%errorlevel%"
popd
if /i not "%noninteractive%"=="-NoPause" pause
exit /b %result%
