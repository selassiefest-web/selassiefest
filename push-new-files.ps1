<#
=====================================================================
 Push New Files Only - SelassieFest repo
=====================================================================
 What this does:
   1. Verifies git, the repo, your identity, and the remote are all
      set up correctly - stops with a clear message if not.
   2. Finds ONLY untracked (brand new) files - never touches files
      that already exist on GitHub, even if you have changed them
      locally.
   3. Shows you the exact list and asks for confirmation.
   4. Commits just those new files.
   5. Pushes to origin - does NOT pull or fetch first, and does NOT
      force-push. If GitHub has newer commits than your machine,
      the push will be safely rejected by git itself, and this
      script will explain that rather than trying to force past it.

 Run via push-new-files.bat (handles execution policy for you), not
 by double-clicking this .ps1 file directly.
=====================================================================
#>

$RepoRoot = $PSScriptRoot
Set-Location $RepoRoot

$junkPatterns = @("Thumbs.db", "desktop.ini", ".DS_Store")

function Invoke-Git {
    param([string[]]$GitArgs)
    $output = & git @GitArgs 2>&1
    return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($output -join "`n") }
}

Write-Host "=== Push New Files Only ===" -ForegroundColor Cyan
Write-Host "Working directory: $RepoRoot"
Write-Host ""

# ---------------------------------------------------------------
# 1. Is git even installed?
# ---------------------------------------------------------------
$gitCheck = Invoke-Git @("--version")
if ($gitCheck.ExitCode -ne 0) {
    Write-Host "ERROR: git does not appear to be installed or is not on PATH." -ForegroundColor Red
    Write-Host "Install it from https://git-scm.com/downloads and try again." -ForegroundColor Red
    return
}
Write-Host ("Git found: " + $gitCheck.Output) -ForegroundColor Green

# ---------------------------------------------------------------
# 2. Are we actually inside a git repo?
# ---------------------------------------------------------------
$insideCheck = Invoke-Git @("rev-parse", "--is-inside-work-tree")
if ($insideCheck.ExitCode -ne 0 -or $insideCheck.Output.Trim() -ne "true") {
    Write-Host "ERROR: this folder is not inside a git repository." -ForegroundColor Red
    Write-Host "Make sure push-new-files.ps1 and push-new-files.bat sit inside" -ForegroundColor Red
    Write-Host "your cloned selassiefest repo folder, then try again." -ForegroundColor Red
    return
}

# ---------------------------------------------------------------
# 3. Confirm this looks like the real selassiefest repo, not some
#    other repo the files were accidentally dropped into.
# ---------------------------------------------------------------
$expectedMarkers = @("about", "festival", "assets", ".git")
$foundMarker = $false
foreach ($marker in $expectedMarkers) {
    if (Test-Path (Join-Path $RepoRoot $marker)) { $foundMarker = $true }
}
if (-not $foundMarker) {
    Write-Host "WARNING: none of the expected repo markers (about, festival, assets, .git)" -ForegroundColor Yellow
    Write-Host "were found in $RepoRoot" -ForegroundColor Yellow
    $answer = Read-Host "Continue anyway? (y/n)"
    if ($answer -ne "y") {
        Write-Host "Stopped." -ForegroundColor Red
        return
    }
}

# ---------------------------------------------------------------
# 4. Git identity configured? Commit will fail without this.
# ---------------------------------------------------------------
$userName  = (Invoke-Git @("config", "user.name")).Output.Trim()
$userEmail = (Invoke-Git @("config", "user.email")).Output.Trim()
if ([string]::IsNullOrWhiteSpace($userName) -or [string]::IsNullOrWhiteSpace($userEmail)) {
    Write-Host "ERROR: git user.name / user.email is not configured on this machine." -ForegroundColor Red
    Write-Host "Set it first, for example:" -ForegroundColor Red
    Write-Host '  git config --global user.name "Your Name"' -ForegroundColor Yellow
    Write-Host '  git config --global user.email "you@example.com"' -ForegroundColor Yellow
    return
}
Write-Host ("Git identity: " + $userName + " <" + $userEmail + ">") -ForegroundColor Green

# ---------------------------------------------------------------
# 5. Confirm we are on a real branch, not detached HEAD.
# ---------------------------------------------------------------
$branchResult = Invoke-Git @("rev-parse", "--abbrev-ref", "HEAD")
$branch = $branchResult.Output.Trim()
if ($branchResult.ExitCode -ne 0 -or $branch -eq "HEAD" -or [string]::IsNullOrWhiteSpace($branch)) {
    Write-Host "ERROR: not on a normal branch (detached HEAD or unreadable)." -ForegroundColor Red
    Write-Host "Run 'git checkout main' (or your branch name) and try again." -ForegroundColor Red
    return
}
Write-Host ("Current branch: " + $branch) -ForegroundColor Green

# ---------------------------------------------------------------
# 6. Confirm an 'origin' remote exists.
# ---------------------------------------------------------------
$remoteResult = Invoke-Git @("remote", "get-url", "origin")
if ($remoteResult.ExitCode -ne 0) {
    Write-Host "ERROR: no 'origin' remote is configured for this repo." -ForegroundColor Red
    Write-Host "Set it up first, for example:" -ForegroundColor Red
    Write-Host '  git remote add origin https://github.com/selassiefest-web/selassiefest.git' -ForegroundColor Yellow
    return
}
Write-Host ("Remote origin: " + $remoteResult.Output.Trim()) -ForegroundColor Green
Write-Host ""

# ---------------------------------------------------------------
# 7. Find ONLY untracked files - individually, not grouped by
#    folder, and parsed by fixed position so filenames with spaces
#    do not break parsing.
# ---------------------------------------------------------------
$statusResult = Invoke-Git @("status", "--porcelain=v1", "--untracked-files=all")
if ($statusResult.ExitCode -ne 0) {
    Write-Host "ERROR: 'git status' failed:" -ForegroundColor Red
    Write-Host $statusResult.Output -ForegroundColor Red
    return
}

$statusLines = $statusResult.Output -split "`n" | Where-Object { $_.Length -gt 0 }
$newFiles = New-Object System.Collections.Generic.List[string]
$skippedJunk = New-Object System.Collections.Generic.List[string]

foreach ($line in $statusLines) {
    if ($line.Length -lt 4) { continue }
    $code = $line.Substring(0, 2)
    $path = $line.Substring(3)

    if ($code -ne "??") { continue }

    $fileName = Split-Path $path -Leaf
    $isJunk = $false
    foreach ($pattern in $junkPatterns) {
        if ($fileName -eq $pattern) { $isJunk = $true }
    }

    if ($isJunk) {
        $skippedJunk.Add($path)
    } else {
        $newFiles.Add($path)
    }
}

if ($skippedJunk.Count -gt 0) {
    Write-Host "Skipping known junk files (not added, not pushed):" -ForegroundColor Yellow
    foreach ($j in $skippedJunk) { Write-Host ("  - " + $j) -ForegroundColor Yellow }
    Write-Host ""
}

if ($newFiles.Count -eq 0) {
    Write-Host "No new (untracked) files found. Nothing to push. Existing tracked files are left untouched." -ForegroundColor Cyan
    return
}

# ---------------------------------------------------------------
# 8. Show exactly what will be added and ask for confirmation
#    before touching anything.
# ---------------------------------------------------------------
Write-Host ("Found " + $newFiles.Count + " new file(s) not currently on GitHub:") -ForegroundColor Cyan
foreach ($f in $newFiles) { Write-Host ("  + " + $f) -ForegroundColor Green }
Write-Host ""
Write-Host "Modified versions of files that already exist on GitHub will NOT be touched." -ForegroundColor Cyan
Write-Host "This script will not run 'git pull'. It will only push these new files." -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "Add, commit, and push these files now? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Stopped. Nothing was changed." -ForegroundColor Red
    return
}

# ---------------------------------------------------------------
# 9. Stage ONLY the untracked files, one at a time.
# ---------------------------------------------------------------
$addErrors = New-Object System.Collections.Generic.List[string]
foreach ($f in $newFiles) {
    $addResult = Invoke-Git @("add", "--", $f)
    if ($addResult.ExitCode -ne 0) {
        $addErrors.Add($f + " -- " + $addResult.Output)
    }
}

if ($addErrors.Count -gt 0) {
    Write-Host "ERROR: failed to stage the following file(s):" -ForegroundColor Red
    foreach ($e in $addErrors) { Write-Host ("  - " + $e) -ForegroundColor Red }
    Write-Host "Stopping before commit. Nothing was pushed." -ForegroundColor Red
    return
}

# ---------------------------------------------------------------
# 10. Safety net - verify everything staged is an ADDITION, never
#     a modification or deletion of an existing tracked file. If
#     anything unexpected got staged, stop before committing.
# ---------------------------------------------------------------
$diffResult = Invoke-Git @("diff", "--cached", "--name-status")
$diffLines = $diffResult.Output -split "`n" | Where-Object { $_.Length -gt 0 }
$unexpected = New-Object System.Collections.Generic.List[string]
foreach ($line in $diffLines) {
    if (-not $line.StartsWith("A")) { $unexpected.Add($line) }
}

if ($unexpected.Count -gt 0) {
    Write-Host "SAFETY STOP: staged changes include something other than a pure addition:" -ForegroundColor Red
    foreach ($u in $unexpected) { Write-Host ("  - " + $u) -ForegroundColor Red }
    Write-Host "Unstaging everything and stopping. Nothing was committed or pushed." -ForegroundColor Red
    Invoke-Git @("reset") | Out-Null
    return
}

Write-Host ""
Write-Host "Confirmed: all staged changes are new file additions only." -ForegroundColor Green

# ---------------------------------------------------------------
# 11. Commit.
# ---------------------------------------------------------------
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "Add " + $newFiles.Count + " new file(s) - " + $timestamp

$commitResult = Invoke-Git @("commit", "-m", $commitMessage)
if ($commitResult.ExitCode -ne 0) {
    Write-Host "ERROR: commit failed:" -ForegroundColor Red
    Write-Host $commitResult.Output -ForegroundColor Red
    return
}
Write-Host ("Committed: " + $commitMessage) -ForegroundColor Green

# ---------------------------------------------------------------
# 12. Push - no pull, no force. If it fails, explain why plainly.
# ---------------------------------------------------------------
Write-Host ""
Write-Host ("Pushing to origin/" + $branch + " ...") -ForegroundColor Cyan
$pushResult = Invoke-Git @("push", "origin", $branch)

if ($pushResult.ExitCode -ne 0) {
    Write-Host ""
    Write-Host "PUSH FAILED. Your commit is saved locally but not on GitHub yet." -ForegroundColor Red
    Write-Host "Git said:" -ForegroundColor Red
    Write-Host $pushResult.Output -ForegroundColor Red
    Write-Host ""
    Write-Host "This usually means GitHub has commits your machine does not have." -ForegroundColor Yellow
    Write-Host "As requested, this script will not pull or force-push automatically." -ForegroundColor Yellow
    Write-Host "Your new local commit is safe - nothing is lost. Let me know and we" -ForegroundColor Yellow
    Write-Host "can look at the right way to reconcile it." -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "=== DONE. New files pushed to GitHub. Existing tracked files were not touched. ===" -ForegroundColor Cyan
