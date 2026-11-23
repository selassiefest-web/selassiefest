@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not exist "%~dp0Outlook-Calendar-Assistant.bat" (
    echo Extract the complete ZIP and keep these files together.
    pause
    exit /b 1
)
call "%~dp0Outlook-Calendar-Assistant.bat" backfill
exit /b %ERRORLEVEL%
