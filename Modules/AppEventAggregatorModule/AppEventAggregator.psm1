# module is currently implementing 2 functinalities - events aggregator and mail sender
# it should be split into two
# it is implemented in one for simplicity

#region Events
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
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Throw-WhenRegistryPathNotExist "HKLM:/Software/$_" })]
        [string]$RegistryKey
    )    

    process 
    {
        [string]$applicationLogName = Get-ItemProperty -Path "HKLM:/Software/$RegistryKey" | Select-Object -ExpandProperty AppLogName

        [PSObject[]]$systemEvents = Get-EventsFromLast24h 'Application' | Where-Object { $_.Message -like "*$Name*" } 

        [PSObject[]]$customEvents = Get-EventsFromLast24h $applicationLogName

        foreach($event in ($systemEvents + $customEvents))
        {
            Write-Output ([PSCustomObject][ordered]@{ At=$event.At; Message=$event.Message })
        }
    }
}

#endregion 

#region Mail
function Get-MachineInfo
{
    [OutputType([string])]
    Param()

   $os = Get-CimInstance Win32_OperatingSystem 
   $computer = Get-CimInstance Win32_ComputerSystem

   "MACHINE: $($computer.Name), CPU: $($computer.NumberOfLogicalProcessors). OS: $($os.Name) [$($os.Version)]"
}

function Get-MachineName
{
   [OutputType([string])]
   Param()

   (Get-CimInstance Win32_ComputerSystem).Name
}

function Get-SmptConfiguration
{    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path)

    $configurationData = [xml](Get-Content -Path $Path)

    [PSCustomObject][Ordered]@{
        Server = $configurationData.DocumentElement.smtp.server
        Port = [int]$configurationData.DocumentElement.smtp.port
        To = $configurationData.DocumentElement.smtp.to
    }
}

# it is absolutelty not production ready function - no TLS, user/pass etc.!
function Send-Mail
{  
     [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [string]$Content,
        
            [Parameter(Mandatory)]
            [string]$ConfigurationFilePath
        )

        $configurationData = Get-SmptConfiguration $ConfigurationFilePath

        $Message = New-Object System.Net.Mail.MailMessage

        $Message.From = "notifier@company.com"
        $Message.To.Add($configurationData.To)
        $Message.Subject = "[$(Get-MachineName)] Error events!"
        $Message.IsBodyHtml = $false
        $Message.Body = $Content

        $SmtpClient = New-Object System.Net.Mail.SmtpClient($configurationData.Server, $configurationData.Port)

        $SmtpClient.Send($Message) 
}

function Out-ErrorEventMail
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Stream')]
        [string]$Item,
              
        [Parameter(Mandatory, ParameterSetName = 'Object')]
        [string[]]$InputObject,

        [Parameter(Mandatory)]
        [string]$ConfigurationFilePath
    )

    Begin {
        $emailBody =  "Errors found - $(Get-Date)" + [System.Environment]::NewLine
        $anything = $False
    }

    Process {

        if ($PSCmdlet.ParameterSetName -eq 'Object')
        {
            $anything = $True
            foreach($line in $InputObject)
            {
                $emailBody += ($line + [System.Environment]::NewLine)
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Stream')
        {
            $anything = $True
            $emailBody += ($Item + [System.Environment]::NewLine)
        } 
        else 
        {
            throw 'Unrecognized paraters set'    
        }
    }

    End {
        if (-not $anything) 
        {
            return
        }

        $emailBody += [System.Environment]::NewLine
        $emailBody += ((Get-MachineInfo) + [System.Environment]::NewLine)

        Send-Mail -content $emailBody -configurationFilePath $ConfigurationFilePath
    }
}
#endregion

function Send-MailIfErrors
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AppConfigurationPath,

        [Parameter(Mandatory)]
        [string]$SmtpConfigurationPath,

        [Parameter(Mandatory)]
        [int]$treshold
    )
    
    [PSObject[]]$items = Get-PSWsApplicationsToCheck -ConfigurationFilePath $AppConfigurationPath | Search-PSWspApplicationError 

    if ($items.Length -ge $treshold)
    {
        Out-ErrorEventMail -ConfigurationFilePath $SmtpConfigurationPath -InputObject $items
    }
}


Export-ModuleMember -Function Search-PSWspApplicationError, Send-*