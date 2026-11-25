@echo off
setlocal
rem Sort partner mail from the stephen@selassiefest.com Inbox into Partnered and save new ones to BOB.
rem Keep this file beside Sort-Partner-Mail.ps1.
cd /d "%~dp0"
echo ============================================================
echo  SelassieFest: sort partner mail (stephen@selassiefest.com)
echo ============================================================
echo  1. PREVIEW ONLY: list partner mail. MOVES NOTHING.
echo  2. MOVE partner mail to Partnered now and save the new ones to BOB
echo  3. MOVE now and keep doing it automatically every 15 minutes
echo  4. Self-test: check the partner list (no Microsoft sign-in)
echo ============================================================
choice /c 1234 /n /m "Choose 1-4: "
if errorlevel 4 goto opt4
if errorlevel 3 goto opt3
if errorlevel 2 goto opt2
pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0Sort-Partner-Mail.ps1"
goto done
:opt2
pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0Sort-Partner-Mail.ps1" -Apply
goto done
:opt3
pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0Sort-Partner-Mail.ps1" -Apply -InstallSchedule
goto done
:opt4
pwsh -NoLogo -ExecutionPolicy Bypass -File "%~dp0Sort-Partner-Mail.ps1" -SelfTest
:done
echo.
pause
endlocal
