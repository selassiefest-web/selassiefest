@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Outlook Calendar Assistant
set "CALENDAR_SCRIPT=%~dp0Outlook-Calendar-Assistant.ps1"
if not exist "%CALENDAR_SCRIPT%" (
    echo Outlook-Calendar-Assistant.ps1 is missing.
    echo Extract both files into the same folder and run this launcher again.
    goto failed
)

set "CALENDAR_MODE=-Apply -Watch -OpenCalendar"
if "%~1"=="" goto find
if /I "%~1"=="preview" (
    set "CALENDAR_MODE="
    goto find
)
if /I "%~1"=="selftest" (
    set "CALENDAR_MODE=-SelfTest"
    goto find
)
if /I "%~1"=="calendar" (
    set "CALENDAR_MODE=-CalendarOnly"
    goto find
)
if /I "%~1"=="backfill" (
    set "CALENDAR_MODE=-Apply -Watch -OpenCalendar -Rescan -LookbackDays 14"
    goto find
)
echo Usage: Outlook-Calendar-Assistant.bat [preview^|selftest^|calendar^|backfill]
goto failed

:find
call :findPowerShell
if defined CALENDAR_PWSH goto run
echo PowerShell 7.4 or later is required. Installing it from Microsoft with WinGet.
where winget.exe >nul 2>&1
if errorlevel 1 (
    echo Windows App Installer ^(WinGet^) is unavailable.
    echo Install PowerShell 7 from Microsoft, then open this launcher again.
    goto failed
)
winget.exe install --id Microsoft.PowerShell --exact --source winget --accept-package-agreements --accept-source-agreements
call :findPowerShell
if not defined CALENDAR_PWSH (
    echo PowerShell 7.4 or later could not be found after setup.
    echo If the installer asked you to restart Windows, restart and run this launcher again.
    goto failed
)

:run
"%CALENDAR_PWSH%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%CALENDAR_SCRIPT%" -AutoSetup %CALENDAR_MODE%
set "CALENDAR_EXIT=%ERRORLEVEL%"
if not "%CALENDAR_EXIT%"=="0" (
    echo.
    echo Outlook Calendar Assistant stopped with exit code %CALENDAR_EXIT%.
)
pause
exit /b %CALENDAR_EXIT%

:findPowerShell
set "CALENDAR_PWSH="
if defined ProgramW6432 call :checkPowerShell "%ProgramW6432%\PowerShell\7\pwsh.exe"
if not defined CALENDAR_PWSH call :checkPowerShell "%ProgramFiles%\PowerShell\7\pwsh.exe"
if not defined CALENDAR_PWSH if defined LOCALAPPDATA call :checkPowerShell "%LOCALAPPDATA%\Microsoft\WindowsApps\pwsh.exe"
if not defined CALENDAR_PWSH for /f "delims=" %%P in ('where pwsh.exe 2^>nul') do if not defined CALENDAR_PWSH call :checkPowerShell "%%P"
exit /b 0

:checkPowerShell
if not exist "%~1" exit /b 0
"%~1" -NoLogo -NoProfile -NonInteractive -Command "if ($PSVersionTable.PSVersion -lt [version]'7.4') { exit 1 }" >nul 2>&1
if not errorlevel 1 set "CALENDAR_PWSH=%~1"
exit /b 0

:failed
echo.
pause
exit /b 1
