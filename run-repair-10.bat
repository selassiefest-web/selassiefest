@echo off
REM run-repair-10.bat
REM Double-click this file (or run it) from inside the selassiefest repo folder,
REM or drop it directly in that folder next to repair-10.ps1.
REM It runs repair-10.ps1 with the execution-policy restriction bypassed for
REM just this one run -- nothing changes system-wide.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-10.ps1"

echo.
echo Done. Check link-audit-log.txt for anything flagged for manual review.
pause
