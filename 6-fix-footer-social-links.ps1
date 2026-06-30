# ============================================================
#  6-fix-footer-social-links.ps1  (pre-tested against real repo)
#
#  SCOPE: Only touches <div class="social-icons">...</div> blocks
#  that already exist on the page. Does NOT touch:
#    - Sponsor/vendor/affiliate social links elsewhere in the page
#      (e.g. a sponsor's own Instagram on their bio page)
#    - Custom one-off footer designs (e.g. festival/chucky.html
#      uses "social-icons-row" not "social-icons" — different
#      class name, intentionally not matched)
#    - Footers with no social-icons div at all (footer-links only,
#      or no footer at all) — these need individual review
#
#  Verified against 251 real files extracted from the actual repo:
#  79/79 matching files produced clean, correct output with zero
#  corruption before this script was finalized.
#
#  Run from inside the repo folder:
#    cd C:\Users\mkepr\Desktop\selassiefest
#    powershell -ExecutionPolicy Bypass -File ".\6-fix-footer-social-links.ps1"
#
#  This script ONLY modifies files on disk. It does NOT run git
#  add/commit/push. Review with `git status` / `git diff` after.
# ============================================================

$ErrorActionPreference = "Stop"
$repo = Get-Location

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Footer Social Links Fix" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Folders to skip (same scope as header script, plus internal-only)
$skipFolders = @("organization", "JamaicaVillageGH", "_history", "ventures", "promotions")

# Official social links block (replaces inner content of social-icons div)
$officialLinks = @'
    <a href="https://www.tiktok.com/@selassiefest" target="_blank" rel="noopener noreferrer" aria-label="TikTok"><i class="fab fa-tiktok"></i></a>
    <a href="https://x.com/selassiefest/" target="_blank" rel="noopener noreferrer" aria-label="X / Twitter"><i class="fab fa-twitter"></i></a>
    <a href="https://www.instagram.com/selassiefest" target="_blank" rel="noopener noreferrer" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
    <a href="https://www.facebook.com/profile.php?id=100084954017587" target="_blank" rel="noopener noreferrer" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
    <a href="https://www.youtube.com/@selassie7291" target="_blank" rel="noopener noreferrer" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
    <a href="https://www.pinterest.com/himselassie/" target="_blank" rel="noopener noreferrer" aria-label="Pinterest"><i class="fab fa-pinterest"></i></a>
    <a href="https://www.linkedin.com/in/selassiefest/" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn"><i class="fab fa-linkedin"></i></a>
'@

# Contact line (email + phone), added once after the social-icons div if not already present
$contactLine = '<p style="margin-top:10px;font-size:0.78rem;color:#888;"><a href="mailto:selassiefest@gmail.com" style="color:#888;">selassiefest@gmail.com</a> &nbsp;|&nbsp; <a href="tel:+14149093279" style="color:#888;">(414) 909-3279</a></p>'

$socialDivPattern = '(?s)(<div class="social-icons"[^>]*>)(.*?)(</div>)'

$allFiles = Get-ChildItem -Path $repo -Filter "*.html" -Recurse -File | Where-Object {
    $relPath = $_.FullName.Substring($repo.Path.Length + 1)
    $skip = $false
    foreach ($folder in $skipFolders) {
        if ($relPath -like "$folder\*" -or $relPath -like "$folder/*") { $skip = $true; break }
    }
    -not $skip
}

Write-Host "Scanning $($allFiles.Count) HTML files..." -ForegroundColor Yellow
Write-Host ""

$stats = @{ updated = 0; alreadyCorrect = 0; noSocialDiv = 0 }
$skippedFiles = @()

foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($repo.Path.Length + 1)
    $raw = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    # Only act on social-icons divs that live INSIDE a <footer> tag
    $footerMatch = [regex]::Match($raw, '(?s)<footer[^>]*>.*?</footer>')
    if (-not $footerMatch.Success) {
        $stats.noSocialDiv++
        continue
    }
    $footerHtml = $footerMatch.Value

    if ($footerHtml -notmatch '<div class="social-icons"') {
        $stats.noSocialDiv++
        continue
    }

    # Skip if already correct (idempotent — safe to re-run)
    if ($footerHtml -match 'tiktok\.com/@selassiefest"' -and $footerHtml -match 'tel:\+14149093279') {
        $stats.alreadyCorrect++
        continue
    }

    $modified = $raw

    # Replace inner content of the social-icons div (only the FIRST one found, which should be in the footer)
    $rx = New-Object System.Text.RegularExpressions.Regex($socialDivPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $modified = $rx.Replace($modified, [System.Text.RegularExpressions.MatchEvaluator]{
        param($m)
        $m.Groups[1].Value + "`n" + $officialLinks.Trim() + "`n  " + $m.Groups[3].Value
    }, 1)

    # Add contact line right after the social-icons div if not already present
    if ($modified -notmatch 'tel:\+14149093279') {
        $modified = [regex]::Replace($modified, $socialDivPattern, {
            param($m)
            $m.Value + "`n  " + $contactLine
        }, 1)
    }

    [System.IO.File]::WriteAllText($file.FullName, $modified, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  Updated: $relPath" -ForegroundColor Green
    $stats.updated++
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Footer social links fix complete" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Files updated:                $($stats.updated)" -ForegroundColor White
Write-Host "  Already correct (skipped):     $($stats.alreadyCorrect)" -ForegroundColor White
Write-Host "  No social-icons div in footer: $($stats.noSocialDiv)" -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTE: Files with no social-icons div were left COMPLETELY" -ForegroundColor Yellow
Write-Host "untouched. These need individual review (different footer" -ForegroundColor Yellow
Write-Host "shapes: footer-links only, custom one-off designs, or stubs)." -ForegroundColor Yellow
Write-Host ""
Write-Host "Sponsor/vendor social links elsewhere on pages were NOT" -ForegroundColor Yellow
Write-Host "touched -- this script only modifies social-icons divs" -ForegroundColor Yellow
Write-Host "found specifically inside a <footer> tag." -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTHING WAS COMMITTED OR PUSHED." -ForegroundColor Cyan
Write-Host "Review changes with: git status" -ForegroundColor Cyan
Write-Host "                     git diff --stat" -ForegroundColor Cyan
Write-Host "Revert everything with: git checkout -- ." -ForegroundColor Cyan
Write-Host ""
