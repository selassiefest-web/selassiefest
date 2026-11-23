@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Partnered Mail Export
set "PARTNERED_SCRIPT=%~dp0Export-Partnered-Mail.ps1"
if not exist "%PARTNERED_SCRIPT%" (
    echo Export-Partnered-Mail.ps1 is missing.
    echo Extract both files into the same folder and run this launcher again.
    goto failed
)

:find
call :findPowerShell
if defined PARTNERED_PWSH goto run
echo PowerShell 7.4 or later is required. Installing it from Microsoft with WinGet.
where winget.exe >nul 2>&1
if errorlevel 1 (
    echo Windows App Installer ^(WinGet^) is unavailable.
    echo Install PowerShell 7 from Microsoft, then open this launcher again.
    goto failed
)
winget.exe install --id Microsoft.PowerShell --exact --source winget --accept-package-agreements --accept-source-agreements
call :findPowerShell
if not defined PARTNERED_PWSH (
    echo PowerShell 7.4 or later could not be found after setup.
    echo If the installer asked you to restart Windows, restart and run this launcher again.
    goto failed
)

:run
"%PARTNERED_PWSH%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PARTNERED_SCRIPT%" -InstallSchedule
set "PARTNERED_EXIT=%ERRORLEVEL%"
if not "%PARTNERED_EXIT%"=="0" (
    echo.
    echo Partnered Mail Export stopped with exit code %PARTNERED_EXIT%.
)
pause
exit /b %PARTNERED_EXIT%

:findPowerShell
set "PARTNERED_PWSH="
if defined ProgramW6432 call :checkPowerShell "%ProgramW6432%\PowerShell\7\pwsh.exe"
if not defined PARTNERED_PWSH call :checkPowerShell "%ProgramFiles%\PowerShell\7\pwsh.exe"
if not defined PARTNERED_PWSH if defined LOCALAPPDATA call :checkPowerShell "%LOCALAPPDATA%\Microsoft\WindowsApps\pwsh.exe"
if not defined PARTNERED_PWSH for /f "delims=" %%P in ('where pwsh.exe 2^>nul') do if not defined PARTNERED_PWSH call :checkPowerShell "%%P"
exit /b 0

:checkPowerShell
if not exist "%~1" exit /b 0
"%~1" -NoLogo -NoProfile -NonInteractive -Command "if ($PSVersionTable.PSVersion -lt [version]'7.4') { exit 1 }" >nul 2>&1
if not errorlevel 1 set "PARTNERED_PWSH=%~1"
exit /b 0

:failed
echo.
pause
exit /b 1
