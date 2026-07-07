# repair-10.ps1
# Sitewide sweep for href="#" placeholder links.
# Run from the repo root (same convention as repair-9.ps1): scan all *.html,
# report counts, rewrite in place where the fix is known, log the rest.
#
# What this DOES fix automatically:
#   - Social icons with aria-label="Instagram" -> https://www.instagram.com/selassiefest
#   - Social icons with aria-label="YouTube"    -> https://www.youtube.com/@selassie7291
#   (same URLs already live in the root site footer, so this brings every
#   other page's copy of the nav/footer up to match)
#
# What this REMOVES entirely, and why:
#   - Social icons with aria-label="SoundCloud" or aria-label="Spotify" --
#     there is no account on either platform, so the icon is deleted rather
#     than pointed at a fake or dead link.
#
# What this DOES NOT touch, and why:
#   - "card-link" (press release cards), "download-btn" (press-kit media),
#     and the handful of one-off buttons -- these point at pages/files that
#     don't exist yet. No regex fixes that; it needs a real decision (write
#     the page, add the file, or remove the link/card).
#
# Everything not fixed or removed is logged to link-audit-log.txt with file,
# line number, and surrounding context, so nothing silently falls through.
#
# Idempotent: a fixed link no longer matches href="#", and a removed line is
# gone, so running this again is a no-op for anything already handled.

$ErrorActionPreference = "Stop"

$root = Get-Location
$htmlFiles = Get-ChildItem -Path $root -Recurse -Filter *.html -File

$fixedCount = 0
$removedCount = 0
$flaggedCount = 0
$auditLines = New-Object System.Collections.Generic.List[string]

# Known-good replacements: aria-label -> real URL. Add to this table as more
# real destinations become known.
$knownFixes = @{
    "Instagram" = "https://www.instagram.com/selassiefest"
    "YouTube"   = "https://www.youtube.com/@selassie7291"
}

# aria-labels whose icon should be deleted outright rather than linked.
$removeLabels = @("SoundCloud", "Spotify")

foreach ($file in $htmlFiles) {
    $lines = Get-Content -Path $file.FullName
    $newLines = New-Object System.Collections.Generic.List[string]
    $changed = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]

        if ($line -notmatch 'href="#"') {
            $newLines.Add($line)
            continue
        }

        # A line consisting of just one placeholder anchor (the social-icon
        # pattern) gets dropped entirely if it's a SoundCloud/Spotify icon.
        $soloAnchorMatch = [regex]::Match($line, '^\s*<a href="#" aria-label="([^"]+)">.*?</a>\s*$')
        if ($soloAnchorMatch.Success -and $removeLabels -contains $soloAnchorMatch.Groups[1].Value) {
            $changed = $true
            $removedCount++
            continue
        }

        $anchorMatches = [regex]::Matches($line, '<a href="#"[^>]*>.*?</a>')

        foreach ($anchor in $anchorMatches) {
            $anchorText = $anchor.Value
            $ariaMatch = [regex]::Match($anchorText, 'aria-label="([^"]+)"')
            $classMatch = [regex]::Match($anchorText, 'class="([^"]+)"')
            $innerText = [regex]::Replace($anchorText, '<[^>]+>', '').Trim()

            $label = $null
            if ($ariaMatch.Success) { $label = $ariaMatch.Groups[1].Value }

            if ($label -and $removeLabels -contains $label) {
                # Inline SoundCloud/Spotify anchor sharing a line with other
                # content -- strip just this anchor, keep the rest of the line.
                $line = $line.Replace($anchorText, "")
                $changed = $true
                $removedCount++
            }
            elseif ($label -and $knownFixes.ContainsKey($label)) {
                $realUrl = $knownFixes[$label]
                $fixedAnchor = $anchorText -replace 'href="#"', "href=`"$realUrl`" target=`"_blank`" rel=`"noopener noreferrer`""
                $line = $line.Replace($anchorText, $fixedAnchor)
                $changed = $true
                $fixedCount++
            }
            else {
                $context = if ($label) { "aria-label=$label" }
                    elseif ($classMatch.Success) { "class=$($classMatch.Groups[1].Value)" }
                    elseif ($innerText) { "text=`"$innerText`"" }
                    else { "(no aria-label, class, or text)" }

                $relPath = $file.FullName.Substring($root.Path.Length + 1)
                $auditLines.Add("$relPath`:$($i + 1) -- $context")
                $flaggedCount++
            }
        }

        $newLines.Add($line)
    }

    if ($changed) {
        Set-Content -Path $file.FullName -Value $newLines
    }
}

$auditLines | Sort-Object | Set-Content -Path (Join-Path $root "link-audit-log.txt")

Write-Host "Fixed automatically: $fixedCount (Instagram/YouTube icons)"
Write-Host "Removed: $removedCount (SoundCloud/Spotify icons, no account)"
Write-Host "Flagged for manual review: $flaggedCount -- see link-audit-log.txt"
