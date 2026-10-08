@echo off
call "%~dp0run.cmd" Stop %*
exit /b %errorlevel%
