@echo off
rem Double-click (or run from ANY folder) to start Claude Code (clwelding profile) in the current folder with Chrome tools,
rem auto commit/push/deploy (git + Supabase), Docker auto-start and token-saving settings. Add -c to resume the last session.
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-claude-clwelding.ps1" %*
