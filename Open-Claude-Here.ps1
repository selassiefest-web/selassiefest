$ErrorActionPreference = 'Stop'

# Always switch to the folder containing this script.
Set-Location -LiteralPath $PSScriptRoot

# Give the PowerShell window a useful title.
$folderName = Split-Path -Leaf $PSScriptRoot
$Host.UI.RawUI.WindowTitle = "Claude Code - $folderName"

# Verify that Claude Code is installed and available on PATH.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "Claude Code was not found." -ForegroundColor Red
    Write-Host "Make sure Claude Code is installed and that the 'claude' command works in PowerShell."
    Write-Host ""
    return
}

# Start Claude Code in this folder.
& claude
