@echo off
setlocal

rem Move into the folder this .bat file lives in.
cd /d "%~dp0"

echo.
echo Running push-new-files from:
echo   %cd%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0push-new-files.ps1"

echo.
echo Press any key to close this window.
pause >nul
