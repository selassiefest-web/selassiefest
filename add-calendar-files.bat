@echo off
REM ============================================================
REM add-calendar-files.bat
REM
REM Double-click this file to add the SelassieFest 2027 Calendar
REM (festivals, special-events, weekly folders) into this repo.
REM
REM IMPORTANT: This .bat file must sit in the SAME FOLDER as
REM add-calendar-files.ps1, and both should be placed directly
REM inside your repo folder, e.g.:
REM   C:\Users\mkepr\Documents\GitHub\selassiefest\
REM ============================================================

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0add-calendar-files.ps1"

echo.
echo Press any key to close this window...
pause >nul
