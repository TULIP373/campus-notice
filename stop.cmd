@echo off
call "%~dp0tools\run.cmd" Stop %*
exit /b %errorlevel%
