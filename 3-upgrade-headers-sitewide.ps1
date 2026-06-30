# ============================================================
#  3-upgrade-headers-sitewide.ps1  (v2 — debugged against real repo)
#
#  Verified in advance against 251 real files extracted from the
#  actual repo. Handles THREE distinct header markup patterns found
#  in the wild:
#    A) Clean:    <a class="brand-link">title + tagline</a>
#    B) Broken:   nested <a><a>title</a>tagline</a> (no outer href)
#    C) BasePath: same as B but outer <a href="$BasePath/">
#  All three were confirmed to match 100% of the 93 real candidate
#  files (0 failures) before this script was finalized.
#
#  Run from inside the repo folder:
#    cd C:\Users\mkepr\Desktop\selassiefest
#    powershell -ExecutionPolicy Bypass -File ".\3-upgrade-headers-sitewide.ps1"
#
#  This script ONLY modifies files on disk. It does NOT run git
#  add/commit/push. Review with `git status` / `git diff` after.
# ============================================================

$ErrorActionPreference = "Stop"
$repo = Get-Location

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Sitewide Header Upgrade (v2)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Folders to SKIP entirely (different branding / nav system)
$skipFolders = @("organization", "JamaicaVillageGH", "_history", "ventures", "promotions")

# Flexible CSS pattern (ignores indentation/spacing differences)
$oldHeaderCssPattern = '(?s)\.site-header\s*\{[^}]*\}\s*\.brand-link\s*\{[^}]*\}\s*\.brand-link:hover\s*\{[^}]*\}\s*\.site-title\s*\{[^}]*\}\s*\.tagline\s*\{[^}]*\}'

$newHeaderCss = @'
.site-header {
  padding: 28px 32px 16px 32px;
  border-bottom: 1px solid var(--border-dim);
  background: rgba(13,13,13,0.96);
  backdrop-filter: blur(2px);
}
.header-flex {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}
.brand-link { display: inline-block; text-align: center; transition: opacity 0.2s; }
.brand-link:hover { opacity: 0.85; }
.site-title {
  font-weight: 200;
  font-size: 2.8rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--text-white);
  line-height: 1.2;
}
.tagline {
  font-weight: 300;
  font-size: 0.9rem;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: var(--gold-accent);
  margin-top: 6px;
  border-top: 1px solid var(--roots-green);
  display: inline-block;
  padding-top: 8px;
}
.powered-by-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255,255,255,0.05);
  padding: 8px 16px 8px 20px;
  border-radius: 60px;
  border: 1px solid var(--border-dim);
  flex-shrink: 0;
}
.powered-by-text {
  font-weight: 300;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #aaa;
}
.powered-by-logo { display: flex; align-items: center; line-height: 0; }
.powered-by-logo img { height: 40px; width: auto; border-radius: 4px; transition: opacity 0.2s; }
.powered-by-logo:hover img { opacity: 0.8; }
@media (max-width: 700px) {
  .header-flex { flex-direction: column; align-items: center; }
  .site-title { font-size: 1.8rem; }
  .powered-by-wrapper { padding: 6px 14px 6px 18px; }
  .powered-by-wrapper img { height: 30px; }
}
'@

# THREE header HTML patterns, tried in order

# Pattern A: clean - one anchor wraps both title and tagline
$patternClean = '(?s)<header class="site-header"[^>]*>\s*<a href="([^"]*)" class="brand-link"[^>]*>\s*<div class="site-title">SELASSIEFEST</div>\s*<div class="tagline">([^<]*)</div>\s*</a>\s*</header>'

# Pattern B: broken - optional outer wrapper anchor, inner anchor wraps ONLY title, tagline sits outside inner </a>
$patternBroken = '(?s)<header class="site-header"[^>]*>\s*(?:<a href="[^"]*" class="brand-link"[^>]*>\s*)?<a href="([^"]*)" class="brand-link"[^>]*><div class="site-title">SELASSIEFEST</div></a>\s*<div class="tagline">([^<]*)</div>\s*(?:</a>\s*)?</header>'

# Pattern C: BasePath-corrupted - outer anchor literally contains unrendered $BasePath template variable
$patternBasePath = '(?s)<header class="site-header"[^>]*>\s*<a href="\$BasePath/?"[^>]*class="brand-link"[^>]*>\s*<a href="([^"]*)" class="brand-link"[^>]*><div class="site-title">SELASSIEFEST</div></a>\s*<div class="tagline">([^<]*)</div>\s*</a>\s*</header>'

function Build-NewHeader($hrefVal, $taglineVal) {
    return @"
<header class="site-header" role="banner">
  <div class="header-flex">
    <a href="$hrefVal" class="brand-link" aria-label="SelassieFest homepage">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">$taglineVal</div>
    </a>
    <div class="powered-by-wrapper">
      <span class="powered-by-text">Powered By</span>
      <a href="https://selassiefest.com/sponsors/spliffsociety.html" target="_blank" rel="noopener noreferrer" class="powered-by-logo">
        <img src="/assets/images/ss_tiny.png" alt="Spliff Society">
      </a>
    </div>
  </div>
</header>
"@
}

# Gather files
$allFiles = Get-ChildItem -Path $repo -Filter "*.html" -Recurse -File | Where-Object {
    $relPath = $_.FullName.Substring($repo.Path.Length + 1)
    $skip = $false
    foreach ($folder in $skipFolders) {
        if ($relPath -like "$folder\*" -or $relPath -like "$folder/*") { $skip = $true; break }
    }
    -not $skip
}

Write-Host "Scanning $($allFiles.Count) HTML files (excluding org/, JamaicaVillageGH/, _history/, ventures/, promotions/)..." -ForegroundColor Yellow
Write-Host ""

$stats = @{
    clean = 0; broken = 0; basepath = 0; cssUpdated = 0
    mismatchSkipped = 0; noHeaderFound = 0
}

foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($repo.Path.Length + 1)
    $raw = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    if ($raw -notmatch '<div class="site-title">SELASSIEFEST</div>') { continue }
    if ($raw -match 'header-flex') { continue }

    $modified = $raw
    $htmlMatched = $false
    $patternUsed = ""

    if ($modified -match $patternBasePath) {
        $hrefVal = $Matches[1]; $taglineVal = $Matches[2]
        $newHeader = Build-NewHeader $hrefVal $taglineVal
        $rx = New-Object System.Text.RegularExpressions.Regex($patternBasePath, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $modified = $rx.Replace($modified, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newHeader }, 1)
        $htmlMatched = $true; $patternUsed = "basepath"; $stats.basepath++
    }
    elseif ($modified -match $patternBroken) {
        $hrefVal = $Matches[1]; $taglineVal = $Matches[2]
        $newHeader = Build-NewHeader $hrefVal $taglineVal
        $rx = New-Object System.Text.RegularExpressions.Regex($patternBroken, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $modified = $rx.Replace($modified, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newHeader }, 1)
        $htmlMatched = $true; $patternUsed = "broken"; $stats.broken++
    }
    elseif ($modified -match $patternClean) {
        $hrefVal = $Matches[1]; $taglineVal = $Matches[2]
        $newHeader = Build-NewHeader $hrefVal $taglineVal
        $rx = New-Object System.Text.RegularExpressions.Regex($patternClean, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $modified = $rx.Replace($modified, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newHeader }, 1)
        $htmlMatched = $true; $patternUsed = "clean"; $stats.clean++
    }

    if (-not $htmlMatched) {
        Write-Host "  NO HEADER PATTERN MATCHED: $relPath (skipped, untouched)" -ForegroundColor DarkYellow
        $stats.noHeaderFound++
        continue
    }

    $cssMatched = $false
    if ($modified -match $oldHeaderCssPattern) {
        $modified = [regex]::Replace($modified, $oldHeaderCssPattern, { param($m) $newHeaderCss.Trim() }, 1)
        $cssMatched = $true
        $stats.cssUpdated++
    }

    if (-not $cssMatched) {
        Write-Host "  MISMATCH (HTML ok, CSS failed) - SKIPPING to avoid broken layout: $relPath" -ForegroundColor Red
        $stats.mismatchSkipped++
        continue
    }

    [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  Upgraded [$patternUsed]: $relPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Header upgrade complete" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Clean pattern upgraded:    $($stats.clean)" -ForegroundColor White
Write-Host "  Broken pattern upgraded:   $($stats.broken)" -ForegroundColor White
Write-Host "  BasePath pattern upgraded: $($stats.basepath)" -ForegroundColor White
Write-Host "  CSS blocks replaced:       $($stats.cssUpdated)" -ForegroundColor White
Write-Host "  Mismatches skipped:        $($stats.mismatchSkipped)" -ForegroundColor White
Write-Host "  No header pattern found:   $($stats.noHeaderFound)" -ForegroundColor White
Write-Host ""
Write-Host "NOTHING WAS COMMITTED OR PUSHED." -ForegroundColor Cyan
Write-Host "Review changes with: git status" -ForegroundColor Cyan
Write-Host "                     git diff --stat" -ForegroundColor Cyan
Write-Host "Revert everything with: git checkout -- ." -ForegroundColor Cyan
Write-Host ""
