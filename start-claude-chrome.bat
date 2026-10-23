@echo off
rem Double-click to start Claude Code in this repo with the Chrome browser tools attached. Add -c to resume the last session.
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-claude-chrome.ps1" %*
