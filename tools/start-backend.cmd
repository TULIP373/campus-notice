@echo off
call "%~dp0run.cmd" Backend %*
exit /b %errorlevel%
