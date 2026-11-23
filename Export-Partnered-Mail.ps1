#requires -Version 7.4
<#
.SYNOPSIS
    Copies the Partnered folder from SelassieFest Outlook to BOB as .eml files.
.DESCRIPTION
    Double-click Export-Partnered-Mail.bat to export now and install or refresh
    the 10 AM and 10 PM Windows Task Scheduler triggers.
    Keep the two files together in their permanent folder after setup.
    Scheduled runs use the same signed-in Windows profile and Microsoft Graph
    authentication cache. If Microsoft requires consent or MFA again, rerun the BAT.
    To stop scheduled runs, disable SelassieFest Partnered Mail Export in Task Scheduler.
#>
[CmdletBinding(DefaultParameterSetName='Manual')]
param(
    [Parameter(ParameterSetName='Manual')][switch]$InstallSchedule,
    [Parameter(ParameterSetName='Scheduled')][switch]$Scheduled,
    [Parameter(ParameterSetName='Manual')][string]$Destination = 'C:\Users\mkepr\Downloads\BOB'
)

$ErrorActionPreference = 'Stop'
$mailbox = 'stephen@selassiefest.com'
$folderName = 'Partnered'
$taskName = 'SelassieFest Partnered Mail Export'
$statePath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'SelassieFest\PartneredMailExport'
$logPath = Join-Path $statePath 'Export-Partnered-Mail.log'
$graphHeaders = @{ Prefer='IdType="ImmutableId"' }

function Write-ExportLog([string]$Message) {
    $line = '{0:yyyy-MM-dd HH:mm:ss zzz}  {1}' -f (Get-Date), $Message
    Add-Content -LiteralPath $logPath -Value $line -Encoding utf8
    Write-Host $line
}

function Connect-ExportMailbox {
    if (!(Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        if ($Scheduled) { throw 'Graph Authentication is missing. Double-click Export-Partnered-Mail.bat to repair setup.' }
        Write-ExportLog 'Installing Microsoft Graph Authentication from PowerShell Gallery.'
        Install-Module -Name Microsoft.Graph.Authentication -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module Microsoft.Graph.Authentication
    $connection = @{ Scopes=@('User.Read','Mail.Read'); ContextScope='CurrentUser'; NoWelcome=$true }
    if ((Get-Command Connect-MgGraph).Parameters.ContainsKey('LoginHint')) {
        $connection.LoginHint = $mailbox
    }
    if (!$Scheduled) { Write-ExportLog "If Microsoft requests sign-in, select $mailbox." }
    Connect-MgGraph @connection
    $identity = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/me?$select=mail,userPrincipalName' -OutputType Hashtable
    if ($identity.mail -ine $mailbox -and $identity.userPrincipalName -ine $mailbox) {
        throw "Microsoft connected as $($identity.userPrincipalName). Run the BAT and select $mailbox."
    }
}

function Get-GraphPage([string]$Uri) {
    $target = [uri]$Uri
    if ($target.Scheme -ne 'https' -or $target.Host -ne 'graph.microsoft.com' -or
        !$target.IsDefaultPort -or $target.UserInfo -or !$target.AbsolutePath.StartsWith('/v1.0/')) {
        throw 'Unexpected Graph paging URL.'
    }
    Invoke-MgGraphRequest -Method GET -Uri $target.AbsoluteUri -Headers $graphHeaders -OutputType Hashtable
}

function Get-PartneredFolder {
    $uri = 'https://graph.microsoft.com/v1.0/me/mailFolders?$select=id,displayName&$top=100'
    $matches = while ($uri) {
        $page = Get-GraphPage $uri
        $page.value | Where-Object { $_.displayName -ieq $folderName }
        $uri = $page.'@odata.nextLink'
    }
    if (@($matches).Count -ne 1 -or !$matches.id) {
        throw "Expected one top-level folder named '$folderName' in $mailbox."
    }
    $matches
}

function Get-ExportFileName($Message, [string]$Key, [string]$Directory) {
    $title = ([string]$Message.subject -replace '[<>:"/\\|?*\x00-\x1f]', '_' -replace '\s+', ' ').Trim(' ','.')
    if (!$title) { $title = 'No subject' }
    $capacity = [math]::Min(72, 220 - $Directory.Length - 37)
    if ($capacity -lt 1) { throw 'The export folder path is too long.' }
    if ($title.Length -gt $capacity) {
        $title = $title.Substring(0, $capacity)
        if ([char]::IsHighSurrogate($title[$title.Length - 1])) { $title = $title.Substring(0,$title.Length - 1) }
        $title = $title.TrimEnd(' ','.')
    }
    $date = [datetimeoffset]$Message.receivedDateTime
    '{0:yyyyMMdd-HHmmss}Z - {1} [{2}].eml' -f $date.UtcDateTime, $title, $Key
}

function Export-PartneredMessages([string]$Directory) {
    $folder = Get-PartneredFolder
    $folderId = [uri]::EscapeDataString([string]$folder.id)
    $known = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($eml in (Get-ChildItem -LiteralPath $Directory -File -Filter '*.eml')) {
        if ($eml.Length -gt 0 -and $eml.Name -match '\[([a-f0-9]{16})\]\.eml$') { [void]$known.Add($Matches[1]) }
    }
    $exported = 0
    $skipped = 0
    $failures = 0
    $uri = 'https://graph.microsoft.com/v1.0/me/mailFolders/{0}/messages?$select=id,subject,receivedDateTime&$top=100' -f $folderId
    while ($uri) {
        $page = Get-GraphPage $uri
        foreach ($message in $page.value) {
            $key = $null
            $temp = $null
            try {
                if (!$message.id) { throw 'Graph returned a message without an ID.' }
                $identity = [Text.Encoding]::UTF8.GetBytes("$mailbox/$($message.id)")
                $key = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($identity)).Substring(0,16).ToLowerInvariant()
                if ($known.Contains($key)) { $skipped++; continue }

                $filename = Get-ExportFileName $message $key $Directory
                $destinationFile = Join-Path $Directory $filename
                $temp = Join-Path $Directory ('.partnered-' + [guid]::NewGuid().ToString('N') + '.partial')
                $id = [uri]::EscapeDataString([string]$message.id)
                $mimeUri = 'https://graph.microsoft.com/v1.0/me/messages/{0}/$value' -f $id
                Invoke-MgGraphRequest -Method GET -Uri $mimeUri -Headers $graphHeaders -OutputFilePath $temp | Out-Null
                if (!(Test-Path -LiteralPath $temp -PathType Leaf) -or (Get-Item -LiteralPath $temp -Force).Length -eq 0) {
                    throw 'Graph returned an empty message export.'
                }
                if ((Test-Path -LiteralPath $destinationFile -PathType Leaf) -and
                    (Get-Item -LiteralPath $destinationFile).Length -eq 0) {
                    [IO.File]::Move($temp, $destinationFile, $true)
                } else {
                    [IO.File]::Move($temp, $destinationFile)
                }
                [void]$known.Add($key)
                $exported++
            } catch {
                $failures++
                Write-ExportLog "Could not export message [$key]: $($_.Exception.GetBaseException().Message)"
            } finally {
                if ($temp -and (Test-Path -LiteralPath $temp -PathType Leaf)) {
                    Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
                }
            }
        }
        $uri = $page.'@odata.nextLink'
    }
    Write-ExportLog "Exported $exported new, $skipped already saved, $failures failed. Folder: $Directory"
    if ($failures) { throw "$failures message export(s) failed. A later run will retry files that were not saved." }
}

function Register-ExportSchedule {
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    $root = $service.GetFolder('\')
    $definition = $service.NewTask(0)
    $definition.RegistrationInfo.Description = 'Save Partnered Outlook messages to BOB at 10:00 AM and 10:00 PM.'
    $definition.Settings.StartWhenAvailable = $true
    $definition.Settings.DisallowStartIfOnBatteries = $false
    $definition.Settings.StopIfGoingOnBatteries = $false
    $definition.Settings.MultipleInstances = 2  # Ignore a new trigger while this task already runs.
    $definition.Settings.ExecutionTimeLimit = 'PT2H'
    $user = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    $definition.Principal.UserId = $user
    $definition.Principal.LogonType = 3  # Interactive token of the signed-in Windows user.
    $definition.Principal.RunLevel = 0
    foreach ($hour in @(10,22)) {
        $trigger = $definition.Triggers.Create(2)  # Daily.
        $trigger.DaysInterval = 1
        $trigger.StartBoundary = (Get-Date).Date.AddHours($hour).ToString('yyyy-MM-ddTHH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)
    }
    $action = $definition.Actions.Create(0)  # Execute an application.
    $action.Path = Join-Path $PSHOME 'pwsh.exe'
    $action.Arguments = '-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "{0}" -Scheduled' -f $PSCommandPath
    $action.WorkingDirectory = $PSScriptRoot
    # 6 is create-or-update. 3 is interactive token, with no stored Windows password.
    $registered = $root.RegisterTaskDefinition($taskName, $definition, 6, $user, $null, 3, $null)
    Write-ExportLog "Scheduled $($registered.Name) for 10:00 AM and 10:00 PM Windows local time. Next run: $($registered.NextRunTime)"
}

$lock = $null
try {
    if (!$IsWindows) { throw 'Run this exporter on the Windows PC that owns the BOB folder.' }
    [void][IO.Directory]::CreateDirectory($statePath)
    # Keep the scheduled destination consistent with the initial export.
    if ($InstallSchedule -and $Destination -ne 'C:\Users\mkepr\Downloads\BOB') {
        throw 'Schedule setup uses the default BOB folder.'
    }
    $exportDir = [IO.Directory]::CreateDirectory($Destination).FullName
    $lockFile = Join-Path $statePath 'export.lock'
    try {
        $lock = [IO.File]::Open($lockFile, 'OpenOrCreate', 'ReadWrite', 'None')
    } catch [IO.IOException] {
        if (($_.Exception.HResult -band 65535) -in @(32,33)) {
            Write-ExportLog 'Another Partnered export is already in progress.'
            exit 0
        }
        throw
    }
    Write-ExportLog "Checking $folderName in $mailbox."
    Connect-ExportMailbox
    Export-PartneredMessages $exportDir
    if ($InstallSchedule) { Register-ExportSchedule }
} catch {
    $detail = $_.Exception.GetBaseException().Message
    if ($Scheduled) { $detail += ' If Microsoft sign-in is required, double-click Export-Partnered-Mail.bat.' }
    if (Test-Path -LiteralPath $statePath -PathType Container) { Write-ExportLog $detail }
    Write-Error $detail -ErrorAction Continue
    exit 1
} finally {
    if ($lock) { $lock.Dispose() }
}
