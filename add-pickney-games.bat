@echo off
REM ============================================================
REM add-pickney-games.bat
REM
REM Double-click this file to add the Pickney Time Games Archive
REM (/pickney-time/games/ — 33 game pages + hub) into this repo.
REM
REM IMPORTANT: This .bat file must sit in the SAME FOLDER as
REM add-pickney-games.ps1, and both should be placed directly
REM inside your repo folder, e.g.:
REM   C:\Users\mkepr\Documents\GitHub\selassiefest\
REM ============================================================

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0add-pickney-games.ps1"

echo.
echo Press any key to close this window...
pause >nul
