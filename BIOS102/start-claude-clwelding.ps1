$ConfigDir  = Join-Path $HOME ".claude-clwelding"
$ProjectDir = $PSScriptRoot
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir | Out-Null
    Write-Host "First run: sign in with the CLWELDING account in the browser." -ForegroundColor Yellow
}
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code ('claude') not found. Install it first." -ForegroundColor Red
    exit 1
}
$env:CLAUDE_CONFIG_DIR = $ConfigDir
$Host.UI.RawUI.WindowTitle = "Claude Code - clrainford (clwelding)"
Set-Location $ProjectDir
Write-Host "Profile: clwelding | Folder: $ProjectDir  (type /status to confirm account)" -ForegroundColor Cyan
claude @args
