@echo off
setlocal

rem Open a new Windows PowerShell window.
rem The PS1 file is loaded from the same folder as this BAT file.
start "Claude Code" powershell.exe -NoLogo -NoExit -ExecutionPolicy Bypass -File "%~dp0Open-Claude-Here.ps1"

endlocal
exit /b
