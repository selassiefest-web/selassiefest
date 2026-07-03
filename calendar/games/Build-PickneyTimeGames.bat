@echo off
setlocal

echo ============================================================
echo  Pickney Time Games Archive - Site Builder
echo ============================================================
echo.
echo This will (re)build the "games" folder next to this file.
echo If a "games" folder already exists, it will be renamed to
echo a games_backup_TIMESTAMP folder first - nothing is deleted.
echo.
pause

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-PickneyTimeGames.ps1"

echo.
echo ============================================================
echo  Build finished. Check the "games" folder next to this file.
echo ============================================================
pause
