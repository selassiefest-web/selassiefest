# Open-Claude-Here.ps1
# Launches Claude Code in this folder with:
#   1) Chrome integration (--chrome)
#   2) Auto commit / push / deploy after Claude finishes each response (Stop hook -> Auto-Sync.ps1)
#   3) A handoff note written on exit, which the next session reads on startup:
#        a) review the last set of work
#        b) repo health check
#        c) suggested next task

# Native-command stderr (git, claude) must not abort this script.
$ErrorActionPreference = 'Continue'

# Always work from the folder containing this script.
Set-Location -LiteralPath $PSScriptRoot
$RepoPath   = $PSScriptRoot
$folderName = Split-Path -Leaf $RepoPath
$Host.UI.RawUI.WindowTitle = "Claude Code - $folderName"

$NotesDir   = Join-Path $RepoPath '.claude-notes'
$NoteFile   = Join-Path $NotesDir 'next-session.md'
$SyncScript = Join-Path $PSScriptRoot 'Auto-Sync.ps1'
$Utf8NoBom  = New-Object System.Text.UTF8Encoding($false)

# ---- Verify Claude Code is available ----
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "Claude Code was not found." -ForegroundColor Red
    Write-Host "Make sure Claude Code is installed and that the 'claude' command works in PowerShell."
    Write-Host ""
    return
}

# ---- Git repo detection ----
$isRepo = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    $null = & git -C $RepoPath rev-parse --is-inside-work-tree 2>$null
    $isRepo = ($LASTEXITCODE -eq 0)
}
if (-not $isRepo) {
    Write-Host "Warning: this folder is not a git repository. Auto-sync and repo checks are disabled." -ForegroundColor Yellow
}

# ---- Keep helper files out of commits (local exclude, not .gitignore) ----
if ($isRepo) {
    try {
        $excludePath = (& git -C $RepoPath rev-parse --git-path info/exclude 2>$null | Select-Object -First 1)
        if ($excludePath) {
            if (-not [IO.Path]::IsPathRooted($excludePath)) { $excludePath = Join-Path $RepoPath $excludePath }
            $excludePath = [IO.Path]::GetFullPath($excludePath)
            $excludeDir  = Split-Path -Parent $excludePath
            if (-not (Test-Path -LiteralPath $excludeDir)) { New-Item -ItemType Directory -Path $excludeDir -Force | Out-Null }
            $existing = @()
            if (Test-Path -LiteralPath $excludePath) { $existing = Get-Content -LiteralPath $excludePath }
            foreach ($entry in '.claude-notes/', 'Open-Claude-Here.ps1', 'Open-Claude-Here.bat', 'Auto-Sync.ps1') {
                if ($existing -notcontains $entry) { Add-Content -LiteralPath $excludePath -Value $entry }
            }
        }
    } catch {
        Write-Host "Could not update .git/info/exclude: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ---- Build a per-session settings file with the auto-sync hook ----
$SettingsFile = $null
if ($isRepo -and (Test-Path -LiteralPath $SyncScript)) {
    try {
        $hookCommand = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{0}" -RepoPath "{1}"' -f $SyncScript, $RepoPath
        $settings = [ordered]@{
            hooks = [ordered]@{
                Stop = @(
                    [ordered]@{
                        hooks = @(
                            [ordered]@{ type = 'command'; command = $hookCommand; timeout = 600 }
                        )
                    }
                )
            }
        }
        $SettingsFile = Join-Path $env:TEMP ('claude-autosync-{0}.json' -f ([Math]::Abs($RepoPath.ToLowerInvariant().GetHashCode())))
        [IO.File]::WriteAllText($SettingsFile, ($settings | ConvertTo-Json -Depth 10), $Utf8NoBom)
    } catch {
        Write-Host "Could not create hook settings: $($_.Exception.Message). Auto-sync disabled." -ForegroundColor Yellow
        $SettingsFile = $null
    }
} elseif ($isRepo) {
    Write-Host "Auto-Sync.ps1 not found next to this script. Auto-sync disabled." -ForegroundColor Yellow
}

# ---- Remember where the repo was when the session started ----
$startHead = ''
if ($isRepo) { $startHead = (& git -C $RepoPath rev-parse HEAD 2>$null | Select-Object -First 1) }

# ---- Start Claude Code ----
$claudeArgs = @('--chrome')
if ($SettingsFile) { $claudeArgs += @('--settings', $SettingsFile) }
if (Test-Path -LiteralPath $NoteFile) {
    $claudeArgs += 'Read .claude-notes\next-session.md and follow the instructions in it. Report your findings and ask before changing anything.'
}
& claude @claudeArgs

# ============================ ON EXIT ============================
if (-not $isRepo) { return }

Write-Host ""
Write-Host "Claude Code closed. Running exit tasks..." -ForegroundColor Cyan

# 1) Final sweep: commit / push / deploy anything still pending.
if (Test-Path -LiteralPath $SyncScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $SyncScript -RepoPath $RepoPath
}

# 2) Only write a new note if something actually changed (or no note exists yet).
$endHead   = (& git -C $RepoPath rev-parse HEAD 2>$null | Select-Object -First 1)
$dirty     = (& git -C $RepoPath status --porcelain 2>$null)
$somethingChanged = ($endHead -ne $startHead) -or (-not [string]::IsNullOrWhiteSpace(($dirty -join '')))
if ((-not $somethingChanged) -and (Test-Path -LiteralPath $NoteFile)) {
    Write-Host "No changes this session. Keeping the existing handoff note." -ForegroundColor DarkGray
    return
}

Write-Host "Writing handoff note (this takes a moment)..." -ForegroundColor Cyan

$notePrompt = 'Write a handoff note for the next session as markdown. Output only the markdown, nothing else. Use exactly these sections: ## Last session summary (what was changed and why, files touched, anything unfinished or risky) ; ## Review checklist (specific things to re-check in the last set of work) ; ## Repo health check (concrete checks to run next time, plus any problems you already noticed) ; ## Suggested next task (the single most logical next thing to work on and why, plus two alternatives). Be concise and specific.'
$allowedTools = 'Read,Grep,Glob,Bash(git status:*),Bash(git log:*),Bash(git diff:*),Bash(git branch:*)'

$generated = $null
try {
    $generated = & claude -p $notePrompt --continue --allowedTools $allowedTools 2>$null
    if ($LASTEXITCODE -ne 0) { $generated = $null }
} catch {
    $generated = $null
}
$generatedText = ''
if ($generated) { $generatedText = (($generated | ForEach-Object { "$_" }) -join "`n").Trim() }

if ([string]::IsNullOrWhiteSpace($generatedText)) {
    # Fallback so a note always exists, even if the headless run failed.
    $recent = (& git -C $RepoPath log -5 --stat --format='%h %s (%cr)' 2>$null) -join "`n"
    $state  = (& git -C $RepoPath status --short --branch 2>$null) -join "`n"
    $generatedText = @"
## Last session summary
(Automatic summary was unavailable. Recent history is below.)

$recent

## Working tree
$state
"@
}

$branchName = (& git -C $RepoPath rev-parse --abbrev-ref HEAD 2>$null | Select-Object -First 1)
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'

$noteText = @"
# Handoff note - $stamp (branch: $branchName)

## Instructions for the next session
1. **Review the last set of work.** Check git log and the diffs from the last session for mistakes, unfinished edits, and anything risky that was auto-committed or deployed.
2. **Perform a repo health check.** Run git status, check for unpushed commits and divergence from the remote, run the build / tests / lint if the project has them, look for outdated or vulnerable dependencies, stray or oversized files, and confirm the latest deploy succeeded (see .claude-notes/auto-sync.log).
3. **Suggest the next logical thing to work on**, and wait for approval before starting it.

Report findings first. Do not change files until the user approves.

---

$generatedText
"@

try {
    if (-not (Test-Path -LiteralPath $NotesDir)) { New-Item -ItemType Directory -Path $NotesDir -Force | Out-Null }
    [IO.File]::WriteAllText($NoteFile, $noteText, $Utf8NoBom)
    Write-Host "Handoff note saved: $NoteFile" -ForegroundColor Green
} catch {
    Write-Host "Could not save the handoff note: $($_.Exception.Message)" -ForegroundColor Red
}
