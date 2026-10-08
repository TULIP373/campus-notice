@echo off
call "%~dp0tools\run.cmd" Frontend %*
exit /b %errorlevel%
