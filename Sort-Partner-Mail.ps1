#requires -Version 7.4
<#
.SYNOPSIS
    Sorts partner mail out of the stephen@selassiefest.com Outlook Inbox into the "Partnered" folder
    and saves each newly sorted message to C:\Users\mkepr\Downloads\BOB as an .eml file.
.DESCRIPTION
    1. Reads the compiled partner list (partner-senders.json: every partner, funder and contact address
       in the tracker, plus the partner domains). Claude refreshes that file on request; the script does
       not need Supabase.
    2. Signs in to Microsoft Graph as stephen@selassiefest.com (browser sign-in, same account as
       Export-Partnered-Mail.ps1) and reads the whole Inbox (or the last -Days days).
    3. A message is a PARTNER message when its sender address is a partner / contact address, or its
       domain is a partner domain (generic mail hosts such as gmail.com are matched by exact address only).
    4. With -Apply it moves those messages to Partnered and exports the newly moved ones to BOB.
       File names and the [key] in them are IDENTICAL to Export-Partnered-Mail.ps1, so the two scripts
       never save the same message twice.
    DRY RUN BY DEFAULT: nothing is moved or saved until you add -Apply (Sort-Partner-Mail.bat does that).
    Nothing is ever deleted. A moved message can be dragged back from Partnered to the Inbox.
.EXAMPLE
    pwsh .\Sort-Partner-Mail.ps1                 # dry run: lists what would move
    pwsh .\Sort-Partner-Mail.ps1 -Apply          # move + export new ones to BOB
    pwsh .\Sort-Partner-Mail.ps1 -Apply -Days 14 # only look at the last 14 days of the Inbox
    pwsh .\Sort-Partner-Mail.ps1 -InstallSchedule # also run it every hour in the background
    pwsh .\Sort-Partner-Mail.ps1 -SelfTest       # check the partner list and matching, no Microsoft sign-in
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$Scheduled,
    [switch]$InstallSchedule,
    [switch]$SelfTest,
    [int]$Days = 0,                                   # 0 = whole Inbox
    [string]$Destination = 'C:\Users\mkepr\Downloads\BOB',
    [string]$RepoPath = 'C:\Users\mkepr\Documents\GitHub\selassiefest',
    [string]$PartnerFile = 'C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\partner-sort\partner-senders.json'
)

$ErrorActionPreference = 'Stop'
$mailbox   = 'stephen@selassiefest.com'
$folderName = 'Partnered'
$taskName  = 'SelassieFest Partner Mail Sort'
$statePath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'SelassieFest\PartnerMailSort'
$logPath   = Join-Path $statePath 'Sort-Partner-Mail.log'
$graphHeaders = @{ Prefer = 'IdType="ImmutableId"' }

# Never treat these as a partner DOMAIN (they host everyone). Exact partner addresses at them still match.
$script:extraDomains = @()
$genericDomains = @(
    'gmail.com','googlemail.com','yahoo.com','ymail.com','outlook.com','hotmail.com','live.com','msn.com','aol.com',
    'icloud.com','me.com','mac.com','comcast.net','sbcglobal.net','att.net','bellsouth.net','verizon.net','protonmail.com',
    'proton.me','gmx.com','mail.com','zoho.com','selassiefest.com','facebook.com','instagram.com','linkedin.com','google.com',
    'wixsite.com','wix.com','squarespace.com','wordpress.com','weebly.com','godaddysites.com','linktr.ee','eventbrite.com',
    'youtube.com','tiktok.com','twitter.com','x.com','github.io','microsoft.com','office.com','sharepoint.com',
    # big consumer brands: their marketing mail would flood Partnered, so only the exact partner address matches
    'apple.com','aa.com','united.com','delta.com','southwest.com','uber.com','lyft.com','hilton.com','marriott.com','hyatt.com',
    'ihg.com','mcdonalds.com','mlb.com','whitesox.mlb.com','dell.com','samsung.com','lg.com','amazon.com','aboutamazon.com',
    'local.jewelosco.com','locations.tacobell.com','locations.53.com','globalgiving.org','idealist.org','joindeed.com','yamaha.com','comed.com'
)
# Optional edits without touching this file (one domain per line, in the PartnerMailSort state folder):
#   extra-partner-domains.txt     = ALWAYS treat mail from these domains as partner mail
#   exclude-partner-domains.txt   = NEVER match these domains by domain (exact partner addresses still match)
foreach ($pair in @(@('exclude-partner-domains.txt','x'), @('extra-partner-domains.txt','e'))) {
    $f = Join-Path $statePath $pair[0]
    if (Test-Path -LiteralPath $f) {
        $lines = @(Get-Content -LiteralPath $f | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ -and -not $_.StartsWith('#') })
        if ($pair[1] -eq 'x') { $genericDomains += $lines } else { $script:extraDomains = $lines }
    }
}

function Write-SortLog([string]$Message) {
    $line = '{0:yyyy-MM-dd HH:mm:ss zzz}  {1}' -f (Get-Date), $Message
    if (Test-Path -LiteralPath $statePath -PathType Container) { Add-Content -LiteralPath $logPath -Value $line -Encoding utf8 }
    Write-Host $line
}

# ---------------------------------------------------------------------------------------------
# 1. The partner list (from the tracker)
# ---------------------------------------------------------------------------------------------
function Get-DomainOf([string]$text) {
    if (-not $text) { return $null }
    $t = $text.Trim().ToLowerInvariant()
    if ($t -match '@([a-z0-9.\-]+\.[a-z]{2,})$') { return $Matches[1] }
    if ($t -match '^(?:https?://)?(?:www\.)?([a-z0-9\-]+(?:\.[a-z0-9\-]+)*\.[a-z]{2,})(?:[/:?#]|$)') { return $Matches[1] }
    return $null
}

function Get-PartnerSenders {
    # The compiled partner list (every partner, funder and contact address from the tracker) lives in a file.
    # Claude regenerates it with: python "Claude outputs\partner-sort\compile-partners.py"
    if (-not (Test-Path -LiteralPath $PartnerFile -PathType Leaf)) {
        throw "Partner list not found: $PartnerFile. Ask Claude to compile it (compile-partners.py)."
    }
    $saved = Get-Content -LiteralPath $PartnerFile -Raw | ConvertFrom-Json
    $emails  = [Collections.Generic.HashSet[string]]::new([string[]]@($saved.emails),  [StringComparer]::OrdinalIgnoreCase)
    $domains = [Collections.Generic.HashSet[string]]::new([string[]]@($saved.domains), [StringComparer]::OrdinalIgnoreCase)
    foreach ($x in @($script:extraDomains)) { if ($x) { [void]$domains.Add($x) } }
    foreach ($x in @($genericDomains)) { [void]$domains.Remove($x) }   # exclude-partner-domains.txt and the built-in list
    $aliases  = [Collections.Generic.HashSet[string]]::new([string[]]@($saved.aliases), [StringComparer]::OrdinalIgnoreCase)
    $platform = @($saved.platformSenders | ForEach-Object { "$_".ToLowerInvariant() })
    @{ Emails = $emails; Domains = $domains; Aliases = $aliases; Platform = $platform; Source = "file compiled $($saved.savedAt)" }
}

function Test-PartnerSender($Partners, [string]$Address) {
    if (-not $Address -or $Address -notmatch '@') { return $null }
    $a = $Address.Trim().ToLowerInvariant()
    if ($Partners.Emails.Contains($a)) { return 'partner address' }
    $domain = $a.Split('@')[-1]
    if ($genericDomains -contains $domain) { return $null }
    foreach ($d in $Partners.Domains) {
        if ($domain -eq $d -or $domain.EndsWith(".$d")) { return "partner domain $d" }
    }
    $null
}

function Test-OwnAddress([string]$Address) {
    $a = $Address.Trim().ToLowerInvariant()
    $a.EndsWith('@selassiefest.com') -or $a -eq 'selassiefest@gmail.com'
}

# One Inbox message is PARTNER mail when ANY of these is true:
#   1. its sender is a partner / contact address, or from a partner domain
#   2. it was sent from us (stephen@ / hello@ copies of what we sent) and a To or Cc address is a partner
#   3. it comes from a form / ticket / grant platform (Jotform, Submittable, Zendesk ...) and its subject or
#      first lines name a partner or funder (the confirmations you get after filing an application)
function Test-PartnerMessage($Partners, $Message) {
    $from = [string]$Message.from.emailAddress.address
    $why = Test-PartnerSender $Partners $from
    if ($why) { return $why }

    if ($from -and (Test-OwnAddress $from)) {
        foreach ($r in @($Message.toRecipients) + @($Message.ccRecipients)) {
            $to = [string]$r.emailAddress.address
            if ($to -and -not (Test-OwnAddress $to)) {
                $w = Test-PartnerSender $Partners $to
                if ($w) { return "sent to $to ($w)" }
            }
        }
        return $null
    }

    $fromDomain = ($from.ToLowerInvariant().Split('@')[-1])
    $isPlatform = $false
    foreach ($p in $Partners.Platform) {
        if ($p -like '*@*') { if ($from.ToLowerInvariant() -eq $p) { $isPlatform = $true } }
        elseif ($fromDomain -eq $p -or $fromDomain.EndsWith(".$p")) { $isPlatform = $true }
    }
    if ($isPlatform) {
        $text = (' ' + (([string]$Message.subject + ' ' + [string]$Message.bodyPreview).ToLowerInvariant() -replace '[^a-z0-9]+', ' ') + ' ')
        $best = $null
        foreach ($al in $Partners.Aliases) {
            if ($al.Length -ge 5 -and $text.Contains(' ' + $al + ' ')) { if (-not $best -or $al.Length -gt $best.Length) { $best = $al } }
        }
        if ($best) { return "platform mail naming '$best'" }
    }
    $null
}

# ---------------------------------------------------------------------------------------------
# 2. Microsoft Graph helpers (same sign-in pattern as Export-Partnered-Mail.ps1)
# ---------------------------------------------------------------------------------------------
function Connect-SortMailbox {
    if (!(Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        if ($Scheduled) { throw 'Microsoft.Graph.Authentication is missing. Run Sort-Partner-Mail.bat once to repair setup.' }
        Write-SortLog 'Installing Microsoft Graph Authentication from PowerShell Gallery.'
        Install-Module -Name Microsoft.Graph.Authentication -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module Microsoft.Graph.Authentication
    $scopes = if ($Apply) { @('User.Read','Mail.ReadWrite') } else { @('User.Read','Mail.Read') }
    $connection = @{ Scopes = $scopes; ContextScope = 'CurrentUser'; NoWelcome = $true }
    if ((Get-Command Connect-MgGraph).Parameters.ContainsKey('LoginHint')) { $connection.LoginHint = $mailbox }
    if (-not $Scheduled) { Write-SortLog "If Microsoft asks you to sign in or approve permissions, use $mailbox." }
    Connect-MgGraph @connection
    $identity = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/me?$select=mail,userPrincipalName' -OutputType Hashtable
    if ($identity.mail -ine $mailbox -and $identity.userPrincipalName -ine $mailbox) {
        throw "Microsoft connected as $($identity.userPrincipalName). Run again and select $mailbox."
    }
}

function Get-GraphPage([string]$Uri) {
    $target = [uri]$Uri
    if ($target.Scheme -ne 'https' -or $target.Host -ne 'graph.microsoft.com' -or !$target.IsDefaultPort -or
        $target.UserInfo -or !$target.AbsolutePath.StartsWith('/v1.0/')) { throw 'Unexpected Graph paging URL.' }
    Invoke-MgGraphRequest -Method GET -Uri $target.AbsoluteUri -Headers $graphHeaders -OutputType Hashtable
}

function Get-FolderByName([string]$Name) {
    $uri = 'https://graph.microsoft.com/v1.0/me/mailFolders?$select=id,displayName&$top=100'
    $found = while ($uri) {
        $page = Get-GraphPage $uri
        $page.value | Where-Object { $_.displayName -ieq $Name }
        $uri = $page.'@odata.nextLink'
    }
    $found = @($found)
    if ($found.Count -gt 1) { throw "More than one top-level folder named '$Name' in $mailbox." }
    if ($found.Count -eq 1) { return $found[0] }
    $null
}

function Get-InboxMessages {
    $filter = ''
    if ($Days -gt 0) {
        $since = (Get-Date).AddDays(-$Days).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $filter = '&$filter=receivedDateTime ge ' + $since
    }
    $uri = 'https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages?$select=id,subject,from,toRecipients,ccRecipients,bodyPreview,receivedDateTime&$orderby=receivedDateTime desc&$top=100' + $filter
    while ($uri) {
        $page = Get-GraphPage $uri
        foreach ($m in $page.value) { $m }
        $uri = $page.'@odata.nextLink'
    }
}

# ---------------------------------------------------------------------------------------------
# 3. Export to BOB (same file names and [key] as Export-Partnered-Mail.ps1)
# ---------------------------------------------------------------------------------------------
function Get-MessageKey([string]$MessageId) {
    $identity = [Text.Encoding]::UTF8.GetBytes("$mailbox/$MessageId")
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($identity)).Substring(0,16).ToLowerInvariant()
}

function Get-ExportFileName($Subject, $Received, [string]$Key, [string]$Directory) {
    $title = ([string]$Subject -replace '[<>:"/\\|?*\x00-\x1f]', '_' -replace '\s+', ' ').Trim(' ','.')
    if (!$title) { $title = 'No subject' }
    $capacity = [math]::Min(72, 220 - $Directory.Length - 37)
    if ($capacity -lt 1) { throw 'The export folder path is too long.' }
    if ($title.Length -gt $capacity) {
        $title = $title.Substring(0, $capacity)
        if ([char]::IsHighSurrogate($title[$title.Length - 1])) { $title = $title.Substring(0, $title.Length - 1) }
        $title = $title.TrimEnd(' ','.')
    }
    $date = [datetimeoffset]$Received
    '{0:yyyyMMdd-HHmmss}Z - {1} [{2}].eml' -f $date.UtcDateTime, $title, $Key
}

function Export-MovedMessage($Moved, [string]$Directory, $Known) {
    $key = Get-MessageKey ([string]$Moved.NewId)
    if ($Known.Contains($key)) { return 'skipped' }
    $file = Join-Path $Directory (Get-ExportFileName $Moved.Subject $Moved.Received $key $Directory)
    $temp = Join-Path $Directory ('.sorted-' + [guid]::NewGuid().ToString('N') + '.partial')
    try {
        $mime = 'https://graph.microsoft.com/v1.0/me/messages/{0}/$value' -f ([uri]::EscapeDataString([string]$Moved.NewId))
        Invoke-MgGraphRequest -Method GET -Uri $mime -Headers $graphHeaders -OutputFilePath $temp | Out-Null
        if (!(Test-Path -LiteralPath $temp -PathType Leaf) -or (Get-Item -LiteralPath $temp -Force).Length -eq 0) { throw 'Graph returned an empty message export.' }
        [IO.File]::Move($temp, $file, $true)
        [void]$Known.Add($key)
        return 'exported'
    } finally {
        if (Test-Path -LiteralPath $temp -PathType Leaf) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

# ---------------------------------------------------------------------------------------------
# 4. Hourly schedule (optional)
# ---------------------------------------------------------------------------------------------
function Register-SortSchedule {
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    $root = $service.GetFolder('\')
    $definition = $service.NewTask(0)
    $definition.RegistrationInfo.Description = 'Move partner mail from the Inbox to Partnered and save new ones to BOB, every hour.'
    $definition.Settings.StartWhenAvailable = $true
    $definition.Settings.DisallowStartIfOnBatteries = $false
    $definition.Settings.StopIfGoingOnBatteries = $false
    $definition.Settings.MultipleInstances = 2
    $definition.Settings.ExecutionTimeLimit = 'PT1H'
    $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $definition.Principal.UserId = $user
    $definition.Principal.LogonType = 3
    $definition.Principal.RunLevel = 0
    $trigger = $definition.Triggers.Create(2)   # daily, repeating every hour all day
    $trigger.DaysInterval = 1
    $trigger.StartBoundary = (Get-Date).Date.AddHours(6).ToString('yyyy-MM-ddTHH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
    $trigger.Repetition.Interval = 'PT1H'
    $trigger.Repetition.Duration = 'P1D'
    $action = $definition.Actions.Create(0)
    $action.Path = Join-Path $PSHOME 'pwsh.exe'
    $action.Arguments = '-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -Apply -Scheduled' -f $PSCommandPath
    $action.WorkingDirectory = $PSScriptRoot
    $registered = $root.RegisterTaskDefinition($taskName, $definition, 6, $user, $null, 3, $null)
    Write-SortLog "Scheduled '$($registered.Name)' to run every hour. Next run: $($registered.NextRunTime)"
}

# ---------------------------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------------------------
$lock = $null
try {
    if (!$IsWindows) { throw 'Run this on the Windows PC that owns the BOB folder.' }
    [void][IO.Directory]::CreateDirectory($statePath)
    $lockFile = Join-Path $statePath 'sort.lock'
    try { $lock = [IO.File]::Open($lockFile, 'OpenOrCreate', 'ReadWrite', 'None') }
    catch [IO.IOException] {
        if (($_.Exception.HResult -band 65535) -in @(32,33)) { Write-SortLog 'Another sort is already running.'; exit 0 }
        throw
    }

    $partners = Get-PartnerSenders
    Write-SortLog ("Partner list: {0} addresses and {1} domains ({2})." -f $partners.Emails.Count, $partners.Domains.Count, $partners.Source)

    if ($SelfTest) {
        foreach ($sample in @('stephen@selassiefest.com','someone@gmail.com') + @($partners.Emails | Select-Object -First 3)) {
            '{0,-55} => {1}' -f $sample, ($(Test-PartnerSender $partners $sample) ?? 'not a partner')
        }
        Write-Host 'Self-test finished. No Microsoft sign-in, nothing moved.' -ForegroundColor Green
        return
    }

    Write-SortLog ($Apply ? "Mode: APPLY (will move mail and export new .eml files to $Destination)" : 'Mode: DRY RUN (nothing will be moved or saved; add -Apply)')
    Connect-SortMailbox

    $partnered = Get-FolderByName $folderName
    if (-not $partnered) {
        if ($Apply) {
            $partnered = Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/me/mailFolders' -Body (@{ displayName = $folderName } | ConvertTo-Json) -ContentType 'application/json' -OutputType Hashtable
            Write-SortLog "Created folder $folderName."
        } else { Write-SortLog "[dry] The folder '$folderName' does not exist; -Apply would create it."; $partnered = @{ id = 'DRY' } }
    }

    $scanned = 0; $matched = @()
    foreach ($m in Get-InboxMessages) {
        $scanned++
        $addr = [string]$m.from.emailAddress.address
        $why = Test-PartnerMessage $partners $m
        if ($why) {
            $matched += [pscustomobject]@{
                Id = [string]$m.id; Subject = [string]$m.subject; Received = $m.receivedDateTime
                From = $addr; Why = $why
            }
        }
    }
    Write-SortLog ("Looked at {0} Inbox message(s); {1} are from partners." -f $scanned, $matched.Count)

    if (-not $Apply) {
        $matched | Select-Object -First 60 | ForEach-Object { '{0:yyyy-MM-dd HH:mm}  {1,-40} {2}  [{3}]' -f ([datetime]$_.Received).ToLocalTime(), $_.From, $_.Subject, $_.Why }
        if ($matched.Count -gt 60) { Write-Host "... and $($matched.Count - 60) more." }
        Write-Host 'Dry run finished. Nothing was changed. Run Sort-Partner-Mail.bat (option 2) or add -Apply to do it.' -ForegroundColor Cyan
        return
    }

    $exportDir = [IO.Directory]::CreateDirectory($Destination).FullName
    $known = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($eml in (Get-ChildItem -LiteralPath $exportDir -File -Filter '*.eml')) {
        if ($eml.Length -gt 0 -and $eml.Name -match '\[([a-f0-9]{16})\]\.eml$') { [void]$known.Add($Matches[1]) }
    }

    $movedCount = 0; $exported = 0; $skipped = 0; $failures = 0
    foreach ($msg in $matched) {
        try {
            $body = @{ destinationId = [string]$partnered.id } | ConvertTo-Json
            $moved = Invoke-MgGraphRequest -Method POST -Uri ("https://graph.microsoft.com/v1.0/me/messages/{0}/move" -f [uri]::EscapeDataString($msg.Id)) `
                        -Headers $graphHeaders -Body $body -ContentType 'application/json' -OutputType Hashtable
            $movedCount++
            $msg | Add-Member -NotePropertyName NewId -NotePropertyValue ([string]$moved.id) -Force
            switch (Export-MovedMessage $msg $exportDir $known) { 'exported' { $exported++ } 'skipped' { $skipped++ } }
        } catch {
            $failures++
            Write-SortLog ("Could not handle '{0}' from {1}: {2}" -f $msg.Subject, $msg.From, $_.Exception.GetBaseException().Message)
        }
    }
    Write-SortLog ("Moved {0} message(s) to {1}; exported {2} new .eml to {3}; {4} already saved; {5} failed." -f $movedCount, $folderName, $exported, $exportDir, $skipped, $failures)
    if ($InstallSchedule) { Register-SortSchedule }
    if ($failures) { throw "$failures message(s) failed. A later run retries whatever is still in the Inbox." }
} catch {
    $detail = $_.Exception.GetBaseException().Message
    if ($Scheduled) { $detail += ' If Microsoft sign-in is required, run Sort-Partner-Mail.bat.' }
    if (Test-Path -LiteralPath $statePath -PathType Container) { Write-SortLog $detail }
    Write-Error $detail -ErrorAction Continue
    exit 1
} finally {
    if ($lock) { $lock.Dispose() }
}
