# Starts Claude Code (clwelding profile) in the CURRENT folder (any folder) with: Chrome tools, access to
# Documents/Desktop/Downloads, auto commit+push+deploy after every edit (GitHub Pages + Supabase functions),
# Docker auto-start, full-URL rules, and token-saving settings.
# Add -c to resume the last session. Add -NoPickup to skip the pickup-note prompt. Other args pass through to claude.
$ConfigDir = Join-Path $HOME ".claude-clwelding"

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir | Out-Null
    Write-Host "First run: sign in with the CLWELDING account in the browser." -ForegroundColor Yellow
}
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code ('claude') not found. Install it first." -ForegroundColor Red
    exit 1
}
. (Join-Path $PSScriptRoot "start-claude-common.ps1")

foreach ($p in @((Join-Path $HOME "scoop\shims"), (Join-Path $HOME "AppData\Local\Python\bin"), "C:\Program Files\Git\cmd")) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) { $env:PATH = "$p;$env:PATH" }
}

$env:CLAUDE_CONFIG_DIR = $ConfigDir
$ProjectDir = (Get-Location).Path
$Host.UI.RawUI.WindowTitle = "Claude Code - clwelding | Chrome + Deploy ($ProjectDir)"

function Warn($m) { Write-Host "  [!] $m" -ForegroundColor Yellow }
function Ok($m)   { Write-Host "  [ok] $m" -ForegroundColor Green }

Write-Host "Profile: clwelding | Folder: $ProjectDir  (type /status to confirm account)" -ForegroundColor Cyan
Write-Host "Preflight:" -ForegroundColor Cyan

Initialize-ClaudeConfig $ConfigDir
Ok "Auto commit/push/deploy hook installed; full-URL + low-token rules installed"
Start-DockerIfNeeded
Set-TokenSavingEnv

if (-not (Get-Process chrome -ErrorAction SilentlyContinue)) {
    Warn "Chrome is not running. Open Chrome (signed in to claude.ai) BEFORE using browser tools, then type /chrome in Claude."
} else { Ok "Chrome is running" }

$inRepo = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    $null = git rev-parse --show-toplevel 2>&1
    $inRepo = ($LASTEXITCODE -eq 0)
    if ($inRepo) {
        $null = git push --dry-run 2>&1
        if ($LASTEXITCODE -eq 0) { Ok "git push works (site deploy)" }
        else { Warn "git push dry-run failed. Sign in to GitHub (run 'git push' once) so deploys work." }
    } else { Write-Host "  (not a git repo here: auto-deploy applies only inside repos)" -ForegroundColor DarkGray }
} else { Warn "git not found: cannot push (deploys the site)." }

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
    Warn "supabase CLI not found on PATH (expected C:\Users\mkepr\scoop\shims\supabase.exe): cannot deploy Edge Functions."
} elseif (Test-Path (Join-Path $ProjectDir "supabase")) {
    if (-not (Test-Path (Join-Path $ProjectDir "supabase\.temp\linked-project.json"))) { Warn "Supabase project is not linked here. Run: supabase link" }
    else {
        $null = supabase projects list 2>&1
        if ($LASTEXITCODE -eq 0) { Ok "Supabase CLI logged in and project linked" } else { Warn "Supabase CLI is not logged in. Run: supabase login" }
    }
}
Write-Host ""

$launch = Get-ClaudeLaunchArgs
$Pickup = Join-Path $ProjectDir "legal\documents-inbox\PICKUP-NEXT-SESSION.md"
$rest = @($args | Where-Object { $_ -ne "-NoPickup" })

if ($args -contains "-NoPickup" -or -not (Test-Path $Pickup)) {
    claude @launch @rest
} else {
    $prompt = "Read $Pickup first, then START-HERE.md in the same folder if needed. Check list_connected_browsers, then continue the task described in the pickup note. Tell me in two lines where we are before you act."
    claude @launch @rest $prompt
}
