$eventLogName = 'PSWorkshopService'

$appName = 'PSWorkshopServiceApp'

$healthCheckSource = 'HealthCheckSystem'

if ([System.Diagnostics.EventLog]::SourceExists($healthCheckSource) -eq $false)
{
    [System.Diagnostics.EventLog]::CreateEventSource($healthCheckSource, "Application")
}

# create event log
function Test-WorkshopLog
{
    ((Get-WinEvent -ListLog * | ? LogName -eq $eventLogName | Measure-Object | % Count) -eq 1)        
}

if(-not (Test-WorkshopLog))
{
    New-EventLog -LogName PSWorkshopService -Source scripts

    Limit-EventLog -LogName PSWorkshopService -OverflowAction OverwriteAsNeeded -MaximumSize 1MB

    Get-WinEvent -ListLog * | ? LogName -eq PSWorkshopService
}

# produce some events - custom log
function Write-ToEvents
{
    param
    (
        [string]$LogName,
        [string]$Message,
        [string]$Source,
        [System.Diagnostics.EventLogEntryType]$EntryType
    )

    Write-EventLog -LogName $LogName -Source $Source -Message $Message -EventId 3005 -EntryType $EntryType
}

1..10 | Foreach { Write-ToEvents -LogName $eventLogName -Source 'Scripts' -Message "Error from service $appName" -EntryType Error }
1..5 | Foreach { Write-ToEvents -LogName $eventLogName -Source 'Scripts' -Message "Some information about $appName" -EntryType Information }

1..3 | Foreach { Write-ToEvents -LogName 'Application' -Source $healthCheckSource -Message "Uncaught exception from $appName. check service health." -EntryType Error }

# setup information about application
$registryPath = "HKLM:\SOFTWARE\$appName"
if (-not (Test-Path $registryPath))
{
    New-Item $registryPath
    New-ItemProperty -Path $registryPath -Name 'AppLogName' -Value $eventLogName -PropertyType String -Force | Out-Null
}

