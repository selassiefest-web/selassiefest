@echo off
setlocal

rem Opens a new PowerShell window and runs Open-Claude-Here.ps1.
rem Open-Claude-Here.ps1 calls Auto-Sync.ps1 itself, so this one command starts everything.
rem Both .ps1 files must be in the same folder as this .bat file.

if not exist "%~dp0Open-Claude-Here.ps1" (
    echo ERROR: Open-Claude-Here.ps1 was not found in "%~dp0"
    pause
    exit /b 1
)

if not exist "%~dp0Auto-Sync.ps1" (
    echo WARNING: Auto-Sync.ps1 was not found in "%~dp0"
    echo Claude will start, but auto commit/push/deploy will be disabled.
    pause
)

start "Claude Code" powershell.exe -NoLogo -NoExit -ExecutionPolicy Bypass -File "%~dp0Open-Claude-Here.ps1"

endlocal
exit /b 0
