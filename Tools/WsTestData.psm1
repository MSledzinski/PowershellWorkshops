$here = Split-Path $PSScriptRoot
$applications = (Get-Content -Path (Join-Path $here '.\Data\applications.json')) | ConvertFrom-Json | % applications

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

function Test-WorkshopLog
{
    param([string]$eventLogName)

    ((Get-WinEvent -ListLog * | ? LogName -eq $eventLogName | Measure-Object | % Count) -gt 0)        
}

function Remove-TestData
{
   foreach($appItem in $applications)
    { 
       $eventLogName = $appItem.name
       $registryKey = $appItem.registryKey

        if(Test-WorkshopLog $eventLogName)
        {
            Remove-EventLog -LogName $eventLogName
        }

        $registryPath = "HKLM:\SOFTWARE\$registryKey"
        if (Test-Path $registryPath)
        {
            Remove-Item $registryPath
        }
    }    
}

function Set-Pester {
    Install-Module Pester
}

function New-TestData
{
    $healthCheckSource = 'HealthCheckSystem'

    if ([System.Diagnostics.EventLog]::SourceExists($healthCheckSource) -eq $false)
    {
        [System.Diagnostics.EventLog]::CreateEventSource($healthCheckSource, "Application")
    }


    foreach($appItem in $applications)
    {
        $eventLogName = $appItem.name
        $appName =  $appItem.name
        $registryKey = $appItem.registryKey
        $source = "scripts$($appItem.otherStting)"

        if(-not (Test-WorkshopLog $eventLogName))
        {
            New-EventLog -LogName $eventLogName -Source $source

            Limit-EventLog -LogName $eventLogName -OverflowAction OverwriteAsNeeded -MaximumSize 1MB

            Get-WinEvent -ListLog * | ? LogName -eq $eventLogName
        }

        # produce some events - custom log


        1..10 | Foreach { Write-ToEvents -LogName $eventLogName -Source $source -Message "Error from service $appName" -EntryType Error }
        1..5 | Foreach { Write-ToEvents -LogName $eventLogName -Source $source -Message "Some information about $appName" -EntryType Information }

        # 1..3 | Foreach { Write-ToEvents -LogName 'Application' -Source $healthCheckSource -Message "Uncaught exception from $appName. check service health." -EntryType Error }

        # setup information about application
        $registryPath = "HKLM:\SOFTWARE\$registryKey"
        if (-not (Test-Path $registryPath))
        {
            New-Item $registryPath
            New-ItemProperty -Path $registryPath -Name 'AppLogName' -Value $eventLogName -PropertyType String -Force | Out-Null
        }
    }
}

Export-ModuleMember -Function New-TestData, Remove-TestData