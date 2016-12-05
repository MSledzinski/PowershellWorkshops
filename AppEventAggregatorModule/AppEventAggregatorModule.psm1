function Get-PSWsApplicationsToCheck
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory)]
        [string]$ConfigurationFilePath
    )

    $content = Get-Content -Path $ConfigurationFilePath | ConvertFrom-Json
    
   foreach($application in $content.applications)
   {
        Write-Output ([PSCustomObject][ordered]@{ Name=$application.name; RegistryKey=$application.registryKey })
   }

    # alternative
    # $content.applications | ForEach-Object { [PSObject][ordered]@{ Name=$_.name; RegistryKey=$_.registryKey } }
}

function Get-EventsFromLast24h
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param(
        [Parameter(Mandatory)]
        [string]$LogName
    )
        $eventsFilter = @{
                'StartTime' = (Get-Date).AddHours(-24)
                'EndTime' = (Get-Date)
                'LogName' = $LogName
                'Level' = 4 # Error
            }
        
        Get-WinEvent -FilterHashtable $eventsFilter | ForEach-Object { [PSCustomObject][Ordered]@{ At=$_.TimeCreated; Message=$_.Message } }
}

function Throw-WhenRegistryPathNotExist
{
    Param([string]$Path)

    if( -not (Test-Path $Path))
    {
        throw "Registry entry $("HKLM:/Software/$_") does not exist"
    }

    $true
}

function Search-PSWspApplicationError
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ApplicationName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Throw-WhenRegistryPathNotExist "HKLM:/Software/$_" })]
        [string]$RegsitryKey
    )    

    process 
    {
        [string]$registryEntry = "HKLM:/Software/$RegsitryKey"

        [string]$applicationLogName = Get-ItemProperty -Path $registryEntry | Select-Object -ExpandProperty AppLogName

        [PSObject[]]$systemEvents = Get-EventsFromLast24h 'System' | Where-Object { $_.Message -like "*$ApplicationName*" } 

        [PSObject[]]$customEvents = Get-EventsFromLast24h $applicationLogName

        foreach($event in ($systemEvents + $customEvents))
        {
            Write-Output ([PSCustomObject][ordered]@{ At=$event.At; Message=$event.Message })
        }
    }
}

function Send-MailIfErrors
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AppConfigurationPath,

        [Parameter(Mandatory)]
        [string]$SmtpConfigurationPath,

        [Paramter(Mandatory)]
        [int]$treshold
    )
    
    Import-Module MailSender

    Get-PSWsApplicationsToCheck -ConfigurationFilePath $AppConfigurationPath | 
    Search-PSWspApplicationError 
    Out-ErrorEventMail -ConfigurationFilePath $SmtpConfigurationPath

}


Export-ModuleMember -Function Search-PSWspApplicationError, Send-*