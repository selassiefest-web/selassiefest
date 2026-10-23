$ProjectDir = $PSScriptRoot
# Starts Claude Code in this repo with Claude in Chrome attached (the mcp__claude-in-chrome__* browser tools).
# The extension is already installed and onboarded on this PC; Chrome must be open and signed in to the same claude.ai account.
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code ('claude') not found. Install it first." -ForegroundColor Red
    exit 1
}
$Host.UI.RawUI.WindowTitle = "Claude Code - selassiefest (Chrome attached)"
Set-Location $ProjectDir
Write-Host "Folder: $ProjectDir | Claude in Chrome: ON (type /chrome to check the connection)" -ForegroundColor Cyan
claude --chrome @args
