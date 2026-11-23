#requires -Version 7.4
<#
.SYNOPSIS
    Finds attendance commitments in Microsoft 365 mail and creates private Outlook appointments.
.DESCRIPTION
    Default is a read-only Outlook preview (a local CSV is written). -Apply creates appointments.
    -Watch polls every 5 minutes by default while this process is running and the PC is awake.
    Outlook for Windows is optional. Requires Microsoft.Graph.Authentication and Microsoft sign-in.

    Windows: extract both files into the same folder and double-click
    Outlook-Calendar-Assistant.bat to set up dependencies, sign in, and start Watch.
    The launcher also opens Outlook in Month view and attempts to clear the calendar filter.
    Optional launcher arguments: preview, calendar, or backfill (14 days, then Watch).
    The launcher handles the PowerShell prerequisite through WinGet if needed.
    The script handles Microsoft Graph setup and delegated Microsoft sign-in.
    For direct PowerShell 7 use:
      .\Outlook-Calendar-Assistant.ps1 -AutoSetup
      .\Outlook-Calendar-Assistant.ps1 -AutoSetup -Apply -Watch
      .\Outlook-Calendar-Assistant.ps1 -SelfTest

    Preview scans the last 3 days by default. Apply resumes at the last completed scan
    with a 15-minute overlap. -Rescan forces a fresh lookback (e.g. -Rescan -LookbackDays 14).
    Preview never changes the apply checkpoint. Reports and checkpoint live in StateDirectory.
    Use one watch process per mailbox. Ctrl+C stops it. After reboot, run the same command.
    For Windows Task Scheduler, use a logon trigger for your own Windows account, select
    "Run only when user is logged on", and run the full pwsh.exe path with arguments
    -NoProfile -File "C:\path\Outlook-Calendar-Assistant.ps1" -Apply -Watch .
    Set "Do not start a new instance" and disable the task's maximum running time.
    Test the task manually while signed in. Conditional Access can require a fresh sign-in.
    If Microsoft asks for admin approval, the tenant administrator must approve delegated
    User.Read, Mail.Read and Calendars.ReadWrite. Preview requests Calendars.Read instead.
    Supply -TenantId with this mailbox's Entra tenant GUID/domain if Microsoft needs it.
    Authenticate as the mailbox owner, or use the mailbox owner's sign-in UPN with -Account.

    No message changes, mail forwarding, sending invitations, or external AI. Messages
    in Inbox and rule-filed folders are scanned. Standard junk, trash, drafts and sent
    folders (including descendants) are excluded. Hidden/online archive mail is outside
    scope. Real meeting requests and updates stay with Outlook's normal meeting workflow.
    Regular mail with an ICS attachment is sent to review so it can be imported once.
    PDFs, images, links and attachment contents are not opened.

    The parser handles common US-English dates, today/tomorrow, US time zones and UTC
    offsets. Missing year is interpreted from the email's received date, including close
    New Year rollover. Missing zone uses Central by default. Date-only, alternative
    times, daylight-saving ambiguity, cancellations and reschedules go to review.
    Without an explicit end time, the default appointment length is 60 minutes.
    Appointments are private, tentative, have one reminder (60 minutes by default),
    and link back to the source message. Existing appointments are never edited/deleted.
    Near-term appointments shorten the reminder lead time when possible. Actual delivery
    depends on Outlook reminder/device notification settings. Test with a real alert.
    Exact subject/start duplicates are suppressed. Differently titled duplicates may
    still require manual cleanup. Review CSVs contain subjects and Outlook links, so
    keep StateDirectory private. Old CSVs may be deleted; keep the checkpoint.
#>
[CmdletBinding()]
param(
    [string]$Account = 'stephen@selassiefest.com',
    [string]$TenantId,
    [string]$TimeZone = 'Central Standard Time',
    [ValidateRange(1, 365)][int]$LookbackDays = 3,
    [ValidateRange(1, 730)][int]$HorizonDays = 365,
    [ValidateRange(0, 10080)][int]$ReminderMinutes = 60,
    [ValidateRange(5, 720)][int]$DefaultDurationMinutes = 60,
    [ValidateRange(1, 60)][int]$PollMinutes = 5,
    [string]$StateDirectory = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'OutlookCalendarAssistant'),
    [switch]$AutoSetup,
    [switch]$OpenCalendar,
    [switch]$CalendarOnly,
    [switch]$Apply,
    [switch]$Watch,
    [switch]$Rescan,
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
$culture = [Globalization.CultureInfo]::GetCultureInfo('en-US')
$localZone = [TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)
$months = 'Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?'
$datePattern = "(?i)(?<![\w/.-])(?:\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}(?:/\d{4})?|(?:$months)\.?\s+\d{1,2}(?:st|nd|rd|th)?(?:,?\s+\d{4})?|\d{1,2}\s+(?:$months)\.?(?:[,]?\s+\d{4})?|today|tomorrow)(?:(?=T\d)|(?![\w/-]|\.\d))"
$clockPattern = '(?:\d{1,2}(?::[0-5]\d)?\s*[ap]\.?m\.?|\d{1,2}:[0-5]\d|noon|midnight)'
$zonePattern = '(?:Central(?:\s+(?:Standard|Daylight))?(?:\s+Time)?|Eastern(?:\s+(?:Standard|Daylight))?(?:\s+Time)?|Mountain(?:\s+(?:Standard|Daylight))?(?:\s+Time)?|Pacific(?:\s+(?:Standard|Daylight))?(?:\s+Time)?|(?:UTC|GMT)(?:\s*[+-]\d{1,2}(?::?[0-5]\d)?)?|[CEMP](?:ST|DT|T)|Z)'
$whenPattern = "(?i)^\s*(?:[,;]|\(|\bat\b|\bfrom\b|\btime:\s*|\bstarting at\b|\bstarts at\b|\bT(?=\d)|:(?=\s))*\s*(?<start>$clockPattern|\d{1,2}(?=\s*(?:-|–|—|\bto\b|\buntil\b)))(?:(?=[Zz]\b)|(?![\w:]))(?:\s*(?:-|–|—|\bto\b|\buntil\b)\s*(?<end>$clockPattern)(?:(?=[Zz]\b)|(?![\w:])))?(?:\s*(?<zone>$zonePattern)(?![\w:+-]))?"
$intent = '(?i)\b(?:meeting|appointment|interview|orientation|workshop|training|rehearsal|site visit|walkthrough|check[- ]in|office hours|conference|webinar|briefing|session|ceremony|lesson|audition|tour|call|join us|meet with|meet you|see you|scheduled for|scheduled to|your booking|your table|your flight|please attend|please arrive|you.re invited|you are invited|rsvp|attend(?:ance)?|arrive at|doors open|show starts)\b'
$changeCue = '(?i)\b(?:cancell?ed|cancellation|reschedul\w*|postpon\w*|new (?:date|time)|changed (?:the )?(?:date|time)|date (?:or|and) time changed)\b'
$uncertainCue = '(?i)\b(?:tentatively|proposed|to be confirmed|to be determined|tentative date|time tbd|date tbd|what time works|which (?:date|time)|does .{1,50} work for you|would .{1,50} work for you|either .{1,85} or|not (?:on |at |able to attend)|cannot attend|scheduled to ship)\b'
$excludedCue = '(?i)\b(?:shipping|shipment|ship date|delivery|invoice|order placed|order received|release date|offer ends|payment due|date of birth|deadline|reply by|respond by|rsvp by|register by|apply by|submission due|published on|last updated)\b'
$weekdayPattern = '(?i)\b(?<day>Mon(?:day)?|Tue(?:sday)?|Wed(?:nesday)?|Thu(?:rsday)?|Fri(?:day)?|Sat(?:urday)?|Sun(?:day)?)\.?,?\s*$'
$propertyId = 'String {b7d1241f-2993-4ac7-83b9-2677d0aa133a} Name MailAppointmentKey'
$headers = @{ Prefer = 'IdType="ImmutableId", outlook.body-content-type="text", outlook.timezone="UTC"' }
$messageClassExpand = [uri]::EscapeDataString(('singleValueExtendedProperties($filter=id eq ''String 0x001A'')'))

function Get-Hash([string]$Value) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Value)
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Normalize-Subject([string]$Subject) {
    ($Subject -replace '^\s*(?:(?:RE|FW|FWD)\s*:\s*)+' -replace '\s+', ' ').Trim()
}

function Convert-MailDate([string]$Value, [datetime]$ReceivedDay) {
    $value = ($Value -replace '(?<=\d)(st|nd|rd|th)\b' -replace '\bSept\b', 'Sep' -replace '\.').Trim()
    if ($value -ieq 'today') { return $ReceivedDay.Date }
    if ($value -ieq 'tomorrow') { return $ReceivedDay.Date.AddDays(1) }
    if ($value -match '^\d{4}-') {
        return [datetime]::ParseExact($value, 'yyyy-MM-dd', $culture)
    }
    if ($value -match '^\d{1,2}/\d{1,2}/\d{4}$') {
        return [datetime]::ParseExact($value, 'M/d/yyyy', $culture)
    }
    if ($value -match '\b\d{4}$') { return [datetime]::Parse($value, $culture).Date }
    $formats = @('M/d/yyyy','MMM d yyyy','MMMM d yyyy','d MMM yyyy','d MMMM yyyy')
    # A leap day without an explicit year is sent to review if the received year is invalid.
    $datedValue = "$value $($ReceivedDay.Year)" -replace '^(\d{1,2}/\d{1,2}) ', '$1/'
    $date = [datetime]::ParseExact($datedValue, [string[]]$formats, $culture, [Globalization.DateTimeStyles]::AllowWhiteSpaces)
    if ($date.Month -eq 1 -and $ReceivedDay.Month -eq 12 -and $date.AddYears(1) -le $ReceivedDay.AddDays(45)) {
        return $date.AddYears(1)
    }
    $date
}

function Convert-Clock([string]$Value) {
    $value = ($Value -replace '\.' -replace '\s').ToLowerInvariant()
    if ($value -eq 'noon') { return [timespan]::FromHours(12) }
    if ($value -eq 'midnight') { return [timespan]::Zero }
    $parsed = [datetime]::ParseExact($value, [string[]]@('h:mmtt','htt','H:mm'), $culture, [Globalization.DateTimeStyles]::NoCurrentDateDefault)
    $parsed.TimeOfDay
}

function Convert-StartOrEnd([datetime]$WallTime, [string]$Zone) {
    $Zone = $Zone.Trim().ToUpperInvariant()
    if ($Zone -in @('Z','UTC','GMT')) {
        return [datetime]::SpecifyKind($WallTime, [DateTimeKind]::Utc)
    }
    if ($Zone -match '^(?:UTC|GMT)\s*(?<sign>[+-])(?<hour>\d{1,2})(?::?(?<minute>[0-5]\d))?$') {
        $offset = [timespan]::FromMinutes((60 * [int]$Matches.hour + [int]$Matches.minute) * $(if ($Matches.sign -eq '-') { -1 } else { 1 }))
        return [datetimeoffset]::new($WallTime, $offset).UtcDateTime
    }
    $fixed = @{ EST=-5; EDT=-4; CST=-6; CDT=-5; MST=-7; MDT=-6; PST=-8; PDT=-7 }
    if ($fixed.ContainsKey($Zone)) {
        return [datetimeoffset]::new($WallTime, [timespan]::FromHours($fixed[$Zone])).UtcDateTime
    }
    $resolved = switch -Regex ($Zone) {
        '^(CT|CENTRAL\b)' { 'Central Standard Time'; break }
        '^(ET|EASTERN\b)' { 'Eastern Standard Time'; break }
        '^(MT|MOUNTAIN\b)' { 'Mountain Standard Time'; break }
        '^(PT|PACIFIC\b)' { 'Pacific Standard Time'; break }
        default { $null }
    }
    if ($Zone -match '\b(STANDARD|DAYLIGHT)\b') {
        $label = $Zone -replace '\s+TIME$', ''
        $offset = @{
            'CENTRAL STANDARD'=-6; 'CENTRAL DAYLIGHT'=-5; 'EASTERN STANDARD'=-5; 'EASTERN DAYLIGHT'=-4
            'MOUNTAIN STANDARD'=-7; 'MOUNTAIN DAYLIGHT'=-6; 'PACIFIC STANDARD'=-8; 'PACIFIC DAYLIGHT'=-7
        }[$label]
        return [datetimeoffset]::new($WallTime, [timespan]::FromHours($offset)).UtcDateTime
    }
    $zoneInfo = if ($resolved) { [TimeZoneInfo]::FindSystemTimeZoneById($resolved) } else { $localZone }
    if ($zoneInfo.IsInvalidTime($WallTime) -or $zoneInfo.IsAmbiguousTime($WallTime)) {
        throw 'Local time is ambiguous or invalid at a daylight-saving transition.'
    }
    [TimeZoneInfo]::ConvertTimeToUtc($WallTime, $zoneInfo)
}

function New-Decision([string]$Status, [string]$Reason, $Start = $null, $End = $null) {
    [pscustomobject]@{ Status=$Status; Reason=$Reason; Start=$Start; End=$End }
}

function Get-AppointmentCandidates([string]$Subject, [string]$Content, [datetimeoffset]$Received, [datetime]$NowUtc) {
    if ($Content.Length -gt 60000) { $Content = $Content.Substring(0, 60000) }
    $Content = $Content -replace '[\u00A0\u202F]', ' ' -replace '(?i)(\p{L})(https?://)', '$1 $2'
    $lines = [Collections.Generic.List[string]]::new()
    if ($Subject) { $lines.Add($Subject) }
    foreach ($line in ($Content -split '\r?\n')) {
        $clean = ($line -replace 'https?://\S+', ' ' -replace '\s+', ' ').Trim()
        if ($clean -match '(?i)^(?:On .{3,200} wrote:|[- ]{2,}(?:Original Message|Forwarded message)|From:\s|Sent from my\b|_{5,}$)') { break }
        if (!$clean -or $clean.StartsWith('>')) { continue }
        if ($lines.Count -gt 1 -and $clean -match '(?i)^Time\s*:') {
            $lines[$lines.Count - 1] += " $clean"
            continue
        }
        $lines.Add($clean)
    }
    $text = $lines -join "\n"
    if ($text -notmatch $intent -and $Subject -notmatch '^(?:meeting|appointment|interview|rehearsal|workshop|training|conference|webinar)\b') { return }
    if ($text -match $changeCue) { return New-Decision 'Review' 'Possible cancellation or reschedule' }
    if ($text -match $uncertainCue) { return New-Decision 'Review' 'Proposed, declined or uncertain appointment' }
    if ($text -match '(?i)\b(?:every (?:other )?(?:day|week|month|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)|weekly|biweekly|recurring)\b') {
        return New-Decision 'Review' 'Possible recurring appointment'
    }

    $receivedDay = [TimeZoneInfo]::ConvertTime($Received, $localZone).Date
    $results = [Collections.Generic.List[object]]::new()
    $sawDate = $false
    $incompleteDates = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $completeDates = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $subjectHasIntent = $Subject -match $intent
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $prior = if ($i -gt 0) { $lines[$i - 1] } else { '' }
        $next = if ($i + 1 -lt $lines.Count) { $lines[$i + 1] } else { '' }
        if ($line -match $excludedCue) { continue }
        if (!$subjectHasIntent -and "$prior $line $next" -notmatch $intent) { continue }
        $dates = [regex]::Matches($line, $datePattern)
        if (!$dates.Count) { continue }
        $sawDate = $true
        if ($dates.Count -gt 1) { return New-Decision 'Review' 'Multiple dates on the same line' }
        $dateMatch = $dates[0]
        $before = $line.Substring(0, $dateMatch.Index)
        $after = $line.Substring($dateMatch.Index + $dateMatch.Length)
        $when = [regex]::Match($after, $whenPattern)
        if (!$when.Success) {
            try {
                $keyDate = (Convert-MailDate $dateMatch.Value $receivedDay).ToString('yyyy-MM-dd', $culture)
                [void]$incompleteDates.Add($keyDate)
            } catch {
                return New-Decision 'Review' 'Unrecognized or invalid calendar date'
            }
            continue
        }
        $rest = $after.Substring($when.Length)
        if ($rest -match "(?i)^\s*(?:or\b|/|[-–—]\s*\d|to\s+\d|until\s+\d|[+-]\d)" -or
            $rest -cmatch '^\s*\(?[A-Z]{2,5}\b(?!\s*\w)' -or
            $rest -match '(?i)^\s*(?:\(|\s)*(?:local time|UK time|London time|European time|IST|BST|CET|CEST|AEST|AEDT|JST|HKT|SGT|NZST)\b' -or
            $rest -match "(?i)(?:\bor\b|/|,|\band\b)\s*$clockPattern") {
            return New-Decision 'Review' 'Alternative time or unsupported time zone'
        }
        try {
            $day = Convert-MailDate $dateMatch.Value $receivedDay
            if ($before -match $weekdayPattern -and $day.DayOfWeek.ToString().Substring(0,3) -ine $Matches.day.Substring(0,3)) {
                return New-Decision 'Review' 'Weekday disagrees with calendar date'
            }
            $startText = $when.Groups['start'].Value
            $endText = $when.Groups['end'].Value
            if ($endText -match '(?i)[ap]\.?m\.?$' -and $startText -match '^\d{1,2}(?::\d{2})?$') {
                $startText += [regex]::Match($endText, '(?i)[ap]\.?m\.?$').Value
            }
            if ($startText -match '^\d{1,2}$') { return New-Decision 'Review' 'Start time has no AM/PM' }
            if ($endText -match '^\d{1,2}$') { return New-Decision 'Review' 'End time has no AM/PM' }
            if ($endText -and $startText -match '(?i)[ap]\.?m\.?$' -and $endText -match '^\d{1,2}:[0-5]\d$' -and [int]($endText.Split(':')[0]) -le 12) {
                return New-Decision 'Review' 'End time has no AM/PM'
            }
            if ($startText -match '^(?:[1-9]|1[0-2]):[0-5]\d$' -and !$after.TrimStart().StartsWith('T', [StringComparison]::OrdinalIgnoreCase)) {
                return New-Decision 'Review' 'Time could be AM or PM. Use an AM/PM marker or unambiguous 24-hour time.'
            }
            $zone = $when.Groups['zone'].Value
            $start = Convert-StartOrEnd ($day + (Convert-Clock $startText)) $zone
            $end = $start.AddMinutes($DefaultDurationMinutes)
            if ($endText) { $end = Convert-StartOrEnd ($day + (Convert-Clock $endText)) $zone }
            if ($end -le $start -or ($end - $start).TotalHours -gt 18) {
                return New-Decision 'Review' 'End time implies an overnight or invalid appointment'
            }
        } catch {
            return New-Decision 'Review' ('Invalid or ambiguous date/time: ' + $_.Exception.GetBaseException().Message)
        }
        [void]$completeDates.Add($day.ToString('yyyy-MM-dd', $culture))
        if ($start -le $NowUtc) { continue }
        if ($start -gt $NowUtc.AddDays($HorizonDays)) { return New-Decision 'Review' 'Appointment is outside the configured horizon' }
        $reason = if ($zone) { "Explicit zone: $zone" } else { "Assumed zone: $TimeZone" }
        if (!$endText) { $reason += "; default duration: $DefaultDurationMinutes minutes" }
        $results.Add((New-Decision 'Candidate' $reason $start $end))
    }
    if ($results.Count) {
        $results | Sort-Object -Property Start -Unique
        $incompleteDates.ExceptWith($completeDates)
        if ($incompleteDates.Count) {
            New-Decision 'Review' ('Additional date(s) with no confirmed start time: ' + (($incompleteDates | Sort-Object) -join ', '))
        }
        return
    }
    if ($sawDate -or $text -match '(?i)\b(?:next week|next month|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|this weekend)\b') {
        return New-Decision 'Review' 'Date detected but no complete future date and start time could be confirmed'
    }
}

function Get-ForwardedAppointment([string]$Subject, [string]$Content, [string]$Sender,
    [datetimeoffset]$Received, [datetime]$NowUtc) {
    if ($Subject -notmatch $intent -or !$Content) { return }
    $forward = [regex]::Match($Content, '(?im)^\s*-{2,}\s*Forwarded message\s*-{2,}\s*$')
    if (!$forward.Success) { return }
    $thread = $Content.Substring($forward.Index + $forward.Length)
    $requests = [regex]::Matches($thread, '(?im)^\s*(?:>\s*)?Please pencil me in for\s*:?\s*(?<slot>[^\r\n]+)')
    if (!$requests.Count) { return }
    if ($Sender -notin @($Account, 'selassiefest@gmail.com')) {
        return New-Decision 'Review' 'Forwarded appointment request. Verify the sender and requested slot.'
    }
    if ($thread -match $changeCue) { return New-Decision 'Review' 'Forwarded thread mentions a cancellation or reschedule' }
    $slots = @($requests | ForEach-Object { $_.Groups['slot'].Value.Trim() } | Sort-Object -Unique)
    if ($slots.Count -ne 1 -or $slots[0] -match '(?i)\b(?:today|tomorrow|next|this)\b') {
        return New-Decision 'Review' 'Forwarded thread has competing or relative appointment dates'
    }
    $choices = @(Get-AppointmentCandidates $Subject $slots[0] $Received $NowUtc)
    if ($choices.Count -ne 1 -or $choices[0].Status -ne 'Candidate') {
        return New-Decision 'Review' 'Forwarded request needs a complete and unambiguous date and time'
    }
    $choices[0].Reason = 'Requested slot from your forwarded email. Confirm attendance with the organizer. ' + $choices[0].Reason
    $choices[0]
}

function Invoke-Graph([string]$Uri, [hashtable]$Payload) {
    if ($Uri.StartsWith('/')) { $Uri = "https://graph.microsoft.com$Uri" }
    $target = [uri]$Uri
    if ($target.Scheme -ne 'https' -or $target.Host -ne 'graph.microsoft.com' -or
        !$target.IsDefaultPort -or $target.UserInfo -or !$target.AbsolutePath.StartsWith('/v1.0/')) {
        throw 'Unexpected Microsoft Graph endpoint.'
    }
    $request = @{ Uri=$target.AbsoluteUri; Headers=$headers; OutputType='Hashtable'; Method='GET' }
    if ($null -ne $Payload) {
        $request.Method = 'POST'
        $request.Body = ConvertTo-Json -InputObject $Payload -Depth 10 -Compress
        $request.ContentType = 'application/json; charset=utf-8'
    }
    Invoke-MgGraphRequest @request
}

function Get-GraphCollection([string]$Uri) {
    while ($Uri) {
        $page = Invoke-Graph $Uri
        foreach ($entry in $page.value) { $entry }
        $Uri = $page.'@odata.nextLink'
    }
}

function Get-ExcludedFolders {
    $excluded = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $pending = [Collections.Generic.Queue[string]]::new()
    foreach ($alias in @('junkemail','deleteditems','sentitems','drafts','outbox')) {
        $folder = Invoke-Graph ('/v1.0/me/mailFolders/{0}?$select=id,childFolderCount' -f $alias)
        [void]$excluded.Add([string]$folder.id)
        if ($folder.childFolderCount -gt 0) { $pending.Enqueue([string]$folder.id) }
    }
    while ($pending.Count) {
        $id = [uri]::EscapeDataString($pending.Dequeue())
        foreach ($folder in (Get-GraphCollection ('/v1.0/me/mailFolders/{0}/childFolders?$select=id,childFolderCount' -f $id))) {
            if ($excluded.Add([string]$folder.id) -and $folder.childFolderCount -gt 0) {
                $pending.Enqueue([string]$folder.id)
            }
        }
    }
    return ,$excluded
}

function Get-CalendarDecision($Choice, $Mail, [string]$Title) {
    $start = [datetime]$Choice.Start
    $end = [datetime]$Choice.End
    $startText = $start.ToString('yyyy-MM-ddTHH:mm:ss', $culture)
    $endText = $end.ToString('yyyy-MM-ddTHH:mm:ss', $culture)
    $key = Get-Hash ("{0}|{1}" -f $Title.ToLowerInvariant(), $startText)
    $filter = [uri]::EscapeDataString("singleValueExtendedProperties/any(p:p/id eq '$propertyId' and p/value eq '$key')")
    $previous = Invoke-Graph ('/v1.0/me/calendar/events?$select=id&$top=1&$filter=' + $filter)
    if ($previous.value.Count -gt 0) { return 'Already on calendar' }

    # calendarView expands recurring events, including native invitations.
    $viewStart = [uri]::EscapeDataString($start.AddMinutes(-1).ToString('o', $culture))
    $viewEnd = [uri]::EscapeDataString($start.AddMinutes(1).ToString('o', $culture))
    $viewUri = '/v1.0/me/calendarView?startDateTime={0}&endDateTime={1}&$select=subject,start,isCancelled&$top=100' -f $viewStart, $viewEnd
    foreach ($item in (Get-GraphCollection $viewUri)) {
        if ($item.isCancelled -or (Normalize-Subject $item.subject) -ine $Title) { continue }
        $calendarStart = [datetimeoffset]::Parse($item.start.dateTime, $culture, [Globalization.DateTimeStyles]::AssumeUniversal).UtcDateTime
        if ([math]::Abs(($calendarStart - $start).TotalSeconds) -lt 60) { return 'Already on calendar' }
    }
    if (!$Apply) { return 'Would create' }

    $now = [datetime]::UtcNow
    if ($start -le $now) { return 'Start passed during scan' }
    $minutes = [math]::Max(0, [math]::Min($ReminderMinutes, [math]::Floor(($start - $now).TotalMinutes) - 1))
    $source = if ($Mail.webLink -match '^https://') { $Mail.webLink } else { 'Open Outlook and search for the subject.' }
    $cleanSender = [string]$Mail.from.emailAddress.address
    $note = @('Created from Outlook email. Verify details in the source message.', "Sender: $cleanSender", $Choice.Reason, '', $source) -join [Environment]::NewLine
    $appointment = @{
        subject = $Title
        start = @{ dateTime=$startText; timeZone='UTC' }
        end = @{ dateTime=$endText; timeZone='UTC' }
        body = @{ contentType='Text'; content=$note }
        showAs = 'tentative'
        sensitivity = 'private'
        isReminderOn = $true
        reminderMinutesBeforeStart = [int]$minutes
        transactionId = $key
        singleValueExtendedProperties = @(@{ id=$propertyId; value=$key })
    }
    $created = Invoke-Graph '/v1.0/me/calendar/events' $appointment
    if (!$created.id) { throw 'Microsoft Graph did not confirm the appointment ID.' }
    return 'Created'
}

function Convert-CsvText([string]$Value) {
    # Prevent sender-supplied text from being interpreted as a formula in Excel.
    if ($Value -match '^[\s\u200B\uFEFF]*[=+\-@]' -or $Value -match '^[\t\r\n]') { return "'$Value" }
    return $Value
}

function Add-ReportRow($Mail, [string]$Status, [string]$Reason, $Start = $null, $End = $null) {
    $startLocal = if ($Start) { [TimeZoneInfo]::ConvertTimeFromUtc($Start, $localZone).ToString('yyyy-MM-dd HH:mm', $culture) }
    $endLocal = if ($End) { [TimeZoneInfo]::ConvertTimeFromUtc($End, $localZone).ToString('yyyy-MM-dd HH:mm', $culture) }
    $row = [pscustomobject]@{
        Status=$Status; StartLocal=$startLocal; EndLocal=$endLocal; TimeZone=$TimeZone
        Subject=(Convert-CsvText $Mail.subject); Sender=(Convert-CsvText $Mail.from.emailAddress.address)
        ReceivedUtc=$Mail.receivedDateTime; Reason=(Convert-CsvText $Reason); OutlookLink=(Convert-CsvText $Mail.webLink)
    }
    $row | Export-Csv -LiteralPath $reportPath -Append -Encoding utf8BOM
    $counts[$Status] = 1 + [int]$counts[$Status]
}

function Invoke-MailScan {
    $scanEnd = [datetime]::UtcNow
    $since = $scanEnd.AddDays(-$LookbackDays)
    if ($Apply -and !$rescanPending -and (Test-Path -LiteralPath $checkpoint -PathType Leaf)) {
        $since = [datetimeoffset]::Parse((Get-Content -LiteralPath $checkpoint -Raw), $culture).UtcDateTime.AddMinutes(-15)
        if ($since -gt $scanEnd) { throw 'Checkpoint is in the future. Check the PC clock and use -Rescan to recover.' }
    }
    $reportPath = Join-Path $accountPath ('{0}-{1}.csv' -f $(if ($Apply) {'apply'} else {'preview'}), $scanEnd.ToString('yyyyMMdd-HHmmss-ffff'))
    $counts = @{}
    $scanned = 0
    $failed = 0
    $excluded = Get-ExcludedFolders
    $filter = [uri]::EscapeDataString("receivedDateTime ge $($since.ToString('o', $culture)) and receivedDateTime lt $($scanEnd.ToString('o', $culture)) and isDraft eq false")
    $uri = '/v1.0/me/messages?$select=id,subject,from,receivedDateTime,parentFolderId,hasAttachments,webLink&$top=100&$filter=' + $filter
    foreach ($mail in (Get-GraphCollection $uri)) {
        if ($excluded.Contains([string]$mail.parentFolderId)) { continue }
        $scanned++
        try {
            $id = [uri]::EscapeDataString([string]$mail.id)
            try {
                $full = Invoke-Graph ('/v1.0/me/messages/{0}?$select=uniqueBody,body,parentFolderId,isDraft&$expand={1}' -f $id, $messageClassExpand)
            } catch {
                if ([int]$_.Exception.ResponseStatusCode -eq 404) {
                    Add-ReportRow $mail 'Review' 'Message disappeared during scan'
                    continue
                }
                throw
            }
            if ($full.isDraft -or $excluded.Contains([string]$full.parentFolderId)) { continue }
            $messageClass = $full.singleValueExtendedProperties | Where-Object { $_.id -ieq 'String 0x001A' } | Select-Object -First 1
            if ([string]$full.'@odata.type' -match 'eventMessage' -or $messageClass.value -match '^IPM\.(?:Schedule\.Meeting|Appointment)(?:\.|$)') {
                Add-ReportRow $mail 'Outlook invitation' 'Handled by Outlook meeting workflow'
                continue
            }
            if ($mail.hasAttachments) {
                $attachments = '/v1.0/me/messages/{0}/attachments?$select=name,contentType&$top=50' -f $id
                $calendarAttachment = Get-GraphCollection $attachments | Where-Object {
                    $_.name -match '\.ics$' -or $_.contentType -match '^(text/calendar|application/ics)\b'
                } | Select-Object -First 1
                if ($calendarAttachment) {
                    Add-ReportRow $mail 'Review' 'Calendar attachment. Open the original invitation in Outlook.'
                    continue
                }
            }
            $received = [datetimeoffset]::Parse([string]$mail.receivedDateTime, $culture)
            $title = Normalize-Subject $mail.subject
            $now = [datetime]::UtcNow
            $choices = @()
            if ($full.uniqueBody.contentType -ieq 'text' -and $full.uniqueBody.content) {
                $choices = @(Get-AppointmentCandidates $title $full.uniqueBody.content $received $now)
            }
            if (!$choices.Count -and $full.body.contentType -ieq 'text') {
                $choices = @(Get-ForwardedAppointment $title $full.body.content $mail.from.emailAddress.address $received $now)
            }
            if (!$choices.Count -and ($full.uniqueBody.contentType -ine 'text' -or !$full.uniqueBody.content)) {
                Add-ReportRow $mail 'Review' 'No readable plain-text message body'
                continue
            }
            if (!$title) { $title = 'Appointment from Outlook mail' }
            if ($title.Length -gt 240) { $title = $title.Substring(0,240) }
            foreach ($choice in $choices) {
                $status = if ($choice.Status -eq 'Candidate') { Get-CalendarDecision $choice $mail $title } else { $choice.Status }
                Add-ReportRow $mail $status $choice.Reason $choice.Start $choice.End
            }
        } catch {
            $failed++
            Add-ReportRow $mail 'Error' ('Could not process message: ' + $_.Exception.GetBaseException().Message)
        }
    }
    $summary = ($counts.GetEnumerator() | Sort-Object Name | ForEach-Object { '{0}: {1}' -f $_.Key, $_.Value }) -join ', '
    if (!$summary) { $summary = "No calendar or review changes" }
    Write-Host ("{0:g} | Scanned {1} message(s) | {2}" -f (Get-Date), $scanned, $summary)
    if (Test-Path -LiteralPath $reportPath) { Write-Host "Review report: $reportPath" }
    if ($failed) { throw "$failed message(s) failed. The checkpoint stayed at the last successful scan." }
    if ($Apply) {
        $tempPath = "$checkpoint.tmp"
        Set-Content -LiteralPath $tempPath -Value $scanEnd.ToString('o', $culture) -Encoding utf8
        [IO.File]::Move($tempPath, $checkpoint, $true)
    }
}

function Invoke-ParserSelfTest {
    $received = [datetimeoffset]::Parse('2026-11-21T23:00:00Z', $culture)
    $now = $received.UtcDateTime
    $nl = [Environment]::NewLine
    $scenarios = @(
        @{ Body='Our meeting is Tuesday, November 24 at 3 p.m. CT.'; Expected='2026-11-24T21:00Z' }
        @{ Body="Please attend the workshop.$($nl)Date: 11/24/2026$($nl)Time: 19:00 UTC"; Expected='2026-11-24T19:00Z' }
        @{ Body='Your interview is tomorrow at noon ET.'; Expected='2026-11-22T17:00Z' }
        @{ Body='Site visit on 2026-11-24T15:30Z'; Expected='2026-11-24T15:30Z' }
        @{ Body='Join us on November 24 from 3–4 p.m. CT.'; Expected='2026-11-24T21:00Z'; End='2026-11-24T22:00Z' }
        @{ Body='Workshop November 24 at 3:00.'; Expected='Review' }
        @{ Body='Workshop November 24 at 15:00 CT.'; Expected='2026-11-24T21:00Z' }
        @{ Body='Workshop November 24 at 3 pm UTC+02:00.'; Expected='2026-11-24T13:00Z' }
        @{ Body="Workshop November 24 at 3 pm CT.$($nl)Workshop November 25 at 10 am CT."; Expected='2026-11-24T21:00Z,2026-11-25T16:00Z' }
        @{ Body="Workshop November 24 at 3 pm CT.$($nl)> Workshop November 25 at 10 am CT."; Expected='2026-11-24T21:00Z' }
        @{ Body='Workshop has been cancelled. It was on November 24 at 3 pm.'; Expected='Review' }
        @{ Body='Workshop on November 24.'; Expected='Review' }
        @{ Body='Workshop on November 24 at 3 or 4 pm.'; Expected='Review' }
        @{ Body='Workshop on November 24 at 3 pm or 4 pm.'; Expected='Review' }
        @{ Body='Workshop on November 24 at 3 pm AEST.'; Expected='Review' }
        @{ Body='Workshop on Monday, November 24 at 3 pm.'; Expected='Review' }
        @{ Body='Workshop on March 14, 2027 at 2:30 am CT.'; Expected='Review' }
        @{ Body='Order received November 24 at 12 pm.'; Expected='' }
        @{ Body='Workshop RSVP by November 24 at 3 pm.'; Expected='' }
    )
    foreach ($test in $scenarios) {
        $found = @(Get-AppointmentCandidates '' $test.Body $received $now)
        $actual = ($found | ForEach-Object {
            if ($_.Status -eq 'Candidate') { $_.Start.ToString("yyyy-MM-ddTHH:mm'Z'") } else { $_.Status }
        }) -join ','
        if ($actual -ne $test.Expected) {
            throw "Test failed for '$($test.Body)'. Expected '$($test.Expected)', got '$actual'. $($found.Reason -join ' ')"
        }
        if ($test.End -and $found[0].End.ToString("yyyy-MM-ddTHH:mm'Z'") -ne $test.End) {
            throw "End time test failed for '$($test.Body)'."
        }
    }
    $subject = 'Meeting request: Rainbow DJ Lab at Rainbow Beach'
    $forward = @('---------- Forwarded message ---------', 'From: Organizer', 'Hello', 'Please pencil me in for:', 'November 25th from 11:00 - 11:30am') -join $nl
    $choice = Get-ForwardedAppointment $subject $forward 'selassiefest@gmail.com' $received $now
    if (!$choice -or $choice.Status -ne 'Candidate' -or $choice.Start -ne [datetimeoffset]::Parse('2026-11-25T17:00:00Z').UtcDateTime -or $choice.End -ne [datetimeoffset]::Parse('2026-11-25T17:30:00Z').UtcDateTime) {
        throw "Forwarded test failed: $($choice.Reason)"
    }
    $external = Get-ForwardedAppointment $subject $forward 'external@example.com' $received $now
    if ($external.Status -ne 'Review') { throw 'External forwarded appointment must go to review.' }
    Write-Host "Passed $($scenarios.Count + 2) offline date and intent tests."
}

function Find-VisibleControl($Scope, [string[]]$Names, [string[]]$Types) {
    foreach ($name in $Names) {
        $condition = [Windows.Automation.PropertyCondition]::new(
            [Windows.Automation.AutomationElement]::NameProperty, $name,
            [Windows.Automation.PropertyConditionFlags]::IgnoreCase)
        foreach ($element in $Scope.FindAll([Windows.Automation.TreeScope]::Descendants, $condition)) {
            if (!$element.Current.IsOffscreen -and $element.Current.IsEnabled -and
                $element.Current.ControlType.ProgrammaticName -in $Types) { return $element }
        }
    }
}

function Press-CalendarControl($Control) {
    foreach ($pattern in @(
        [Windows.Automation.InvokePattern]::Pattern,
        [Windows.Automation.SelectionItemPattern]::Pattern,
        [Windows.Automation.ExpandCollapsePattern]::Pattern
    )) {
        $action = $null
        if (!$Control.TryGetCurrentPattern($pattern, [ref]$action)) { continue }
        if ($action -is [Windows.Automation.InvokePattern]) { $action.Invoke() }
        elseif ($action -is [Windows.Automation.SelectionItemPattern]) { $action.Select() }
        else { $action.Expand() }
        return $true
    }
    return $false
}

function Open-OutlookMonth {
    if (!$IsWindows) { Write-Warning 'Calendar view automation requires Windows.'; return }
    Start-Process 'https://outlook.cloud.microsoft/calendar/view/month'
    Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
    $buttons = @('ControlType.Button','ControlType.SplitButton','ControlType.TabItem','ControlType.MenuItem')
    $menuItems = $buttons + @('ControlType.CheckBox','ControlType.RadioButton','ControlType.ListItem')
    $documentCondition = [Windows.Automation.PropertyCondition]::new(
        [Windows.Automation.AutomationElement]::ControlTypeProperty, [Windows.Automation.ControlType]::Document)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $filterOpened = $false
    $monthRequested = $false
    while ($timer.Elapsed.TotalSeconds -lt 20) {
        foreach ($browser in (Get-Process -Name chrome,msedge,firefox,brave -ErrorAction SilentlyContinue)) {
            if (!$browser.MainWindowHandle) { continue }
            try {
                $window = [Windows.Automation.AutomationElement]::FromHandle($browser.MainWindowHandle)
                $address = Find-VisibleControl $window @('Address and search bar','Address bar','Search with Google or enter address') @('ControlType.Edit')
                if (!$address) { continue }
                $value = $null
                if (!$address.TryGetCurrentPattern([Windows.Automation.ValuePattern]::Pattern, [ref]$value)) { continue }
                if ($value.Current.Value -notmatch '^(?:https://)?outlook\.(?:cloud\.microsoft|office\.com|office365\.com)/calendar(?:[/?#]|$)') { continue }
                foreach ($page in $window.FindAll([Windows.Automation.TreeScope]::Descendants, $documentCondition)) {
                    if ($page.Current.IsOffscreen) { continue }
                    $month = Find-VisibleControl $page @('Month') $buttons
                    if (!$month) { continue }
                    if (!$monthRequested) { $monthRequested = Press-CalendarControl $month }
                    $filter = Find-VisibleControl $page @('Filter applied') $buttons
                    if (!$filter) {
                        $unfiltered = Find-VisibleControl $page @('Filter') $buttons
                        if ($unfiltered) {
                            Write-Host 'Outlook Calendar opened with no active filter visible.'
                            return
                        }
                        continue
                    }
                    if (!$filterOpened) {
                        $filterOpened = Press-CalendarControl $filter
                        continue
                    }
                    $clear = Find-VisibleControl $page @('Clear filters','Clear filter','Clear all filters','Reset filters','All events') $menuItems
                    if ($clear -and (Press-CalendarControl $clear)) {
                        $filterOpened = $false
                        Start-Sleep -Milliseconds 500
                    }
                }
            } catch [Windows.Automation.ElementNotAvailableException] {
                # The browser may replace the page during navigation.
            }
        }
        Start-Sleep -Milliseconds 500
    }
    Write-Warning 'Outlook was opened at the Month address. Clearing the filter could not be confirmed. If the toolbar still says Filter applied, click it to clear the selection.'
}

function Wait-ForNextScan {
    $next = (Get-Date).AddMinutes($PollMinutes)
    Write-Host ("Waiting for the next scan at {0:t}. Press Ctrl+C to stop." -f $next)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $seconds = $PollMinutes * 60
    try {
        while ($timer.Elapsed.TotalSeconds -lt $seconds) {
            $remaining = [math]::Ceiling($seconds - $timer.Elapsed.TotalSeconds)
            Write-Progress -Activity 'Outlook Calendar Assistant' -Status "Next scan at $($next.ToString('t'))" -SecondsRemaining $remaining -PercentComplete ([math]::Min(100, 100 * $timer.Elapsed.TotalSeconds / $seconds))
            Start-Sleep -Seconds 1
        }
    } finally {
        Write-Progress -Activity 'Outlook Calendar Assistant' -Completed
    }
}

if ($SelfTest) { Invoke-ParserSelfTest; return }
if ($CalendarOnly) {
    try { Open-OutlookMonth } catch { Write-Warning "Calendar view automation failed: $($_.Exception.GetBaseException().Message)" }
    return
}
if (!$Account -or $Account -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') { throw 'Supply a valid -Account email address.' }
if (!(Get-Module -ListAvailable Microsoft.Graph.Authentication)) {
    if (!$AutoSetup) {
        throw 'Run the BAT launcher or pass -AutoSetup to install Microsoft.Graph.Authentication.'
    }
    Write-Host 'Installing Microsoft Graph Authentication for your Windows user. This can take a minute.'
    try {
        Install-Module -Name Microsoft.Graph.Authentication -Repository PSGallery -Scope CurrentUser -Force -ErrorAction Stop
    } catch {
        throw "Microsoft Graph setup failed. Check that PowerShell Gallery is allowed and run the launcher again. $($_.Exception.GetBaseException().Message)"
    }
}
Import-Module Microsoft.Graph.Authentication
$accountPath = Join-Path $StateDirectory (Get-Hash $Account.ToLowerInvariant()).Substring(0,16)
[void][IO.Directory]::CreateDirectory($accountPath)
$checkpoint = Join-Path $accountPath 'checkpoint-utc.txt'
$lockPath = Join-Path $accountPath 'scan.lock'
try {
    $lock = [IO.File]::Open($lockPath, 'OpenOrCreate', 'ReadWrite', 'None')
} catch {
    throw "Could not lock $accountPath. Close the other scanner or check folder permissions."
}

try {
    $scopes = @('User.Read','Mail.Read',$(if ($Apply) {'Calendars.ReadWrite'} else {'Calendars.Read'}))
    $auth = @{ Scopes=$scopes; ContextScope='CurrentUser'; NoWelcome=$true }
    if ($TenantId) { $auth.TenantId = $TenantId }
    if ((Get-Command Connect-MgGraph).Parameters.ContainsKey('LoginHint')) { $auth.LoginHint = $Account }
    Write-Host "Connecting to Microsoft Outlook as $Account."
    Write-Host 'If Microsoft opens a sign-in window, choose this account and complete MFA or consent there.'
    Connect-MgGraph @auth
    $identityUri = '/v1.0/me?$select=id,displayName,mail,userPrincipalName'
    $me = Invoke-Graph $identityUri
    if ($me.mail -ine $Account -and $me.userPrincipalName -ine $Account) {
        Write-Host "Microsoft selected $($me.userPrincipalName). Reopening sign-in for $Account."
        Disconnect-MgGraph | Out-Null
        Connect-MgGraph @auth
        $me = Invoke-Graph $identityUri
        if ($me.mail -ine $Account -and $me.userPrincipalName -ine $Account) {
            Disconnect-MgGraph | Out-Null
            throw "Signed in as $($me.userPrincipalName). Expected $Account. Run again and select the intended account."
        }
    }
    Write-Host "Mailbox: $($me.displayName) ($Account)"
    Write-Host $(if ($Apply) {'Apply mode: clear matches create private tentative appointments.'} else {'Preview mode: Outlook is read-only.'})
    $calendarPending = $OpenCalendar
    $rescanPending = $Rescan
    do {
        Write-Host "Checking Outlook for email..."
        try {
            Invoke-MailScan
            $rescanPending = $false
        } catch {
            if (!$Watch) { throw }
            $failure = '{0:o} {1}' -f [datetime]::UtcNow, $_.Exception.GetBaseException().Message
            Add-Content -LiteralPath (Join-Path $accountPath 'watch-errors.log') -Value $failure -Encoding utf8
            Write-Warning "$failure. Retrying in $PollMinutes minute(s). If authentication expired, restart Watch and sign in."
        }
        if ($calendarPending) {
            $calendarPending = $false
            try { Open-OutlookMonth } catch { Write-Warning "Calendar view automation failed: $($_.Exception.GetBaseException().Message)" }
        }
        if ($Watch) { Wait-ForNextScan }
    } while ($Watch)
} finally {
    $lock.Dispose()
}
