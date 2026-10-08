@echo off
call "%~dp0run.cmd" Frontend %*
exit /b %errorlevel%
