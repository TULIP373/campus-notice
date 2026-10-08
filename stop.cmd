@echo off
setlocal
pushd "%~dp0"
if errorlevel 1 exit /b 1
if /i "%~1"=="-NoPause" (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\ps1\Start-Demo.ps1" -Mode "Stop" -NoBrowser -NoPause
) else (
    powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\ps1\Start-Demo.ps1" -Mode "Stop"
)
set "result=%errorlevel%"
popd
if /i not "%~1"=="-NoPause" pause
exit /b %result%
