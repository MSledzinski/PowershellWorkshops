function Get-PSWsApplicationsToCheck
{
    [CmdletBinding()]
    [OutputType(PSObject)]
    param(
        [Parameter()]
        [string]$configurationPathRoot = 'C:\Projects\PsWorkshop\'
    )

    $filePath = Join-Path $configurationPathRoot 'configuration.xml'

    $content = Get-Content -Path $filePath | ConvertFrom-Json
    
   foreach($application in $content.applications)
   {
        Write-Output ([PSObject][ordered]@{ Name=$application.name; RegistryKey=$application.registryKey })
   }

    # alternative
    # $content.applications | ForEach-Object { [PSObject][ordered]@{ Name=$_.name; RegistryKey=$_.registryKey } }
}

function Get-EventsFromLast24h
{
    [CmdletBinding()]
    [Output(PSObject)]
    param(
        [Parameter(Mandatory)]
        [string]$logName
    )

        $eventsFilter = @{
                'StartTime' = (Get-Date).AddHours(-24)
                'EndTime' = (Get-Date)
                'LogName' = logName
                'Level' = 4 # Error
            }
        

       Get-WinEvent -FilterHashtable $eventsFilter 
}

function Search-PSWspApplicationError
{
    [CmdletBinding()]
    [Output(PSObject)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript( { if( -not (Test-Path "HKLM:/Software/$_"))
                           {
                                throw "Registry entry $("HKLM:/Software/$_") does not exist"
                           }
                         } )]
        [string]$regsitryKey
    )    

    process 
    {
        $registryEntry = "HKLM:/Software/$regsitryKey"

        $applicationLogName = Get-ItemProperty -Path $registryEntry -Name 'AppLogName'

        $systemEvents = Get-EventsFromLast24h 'System' | Where-Object { $_.Message -contains $name } 

        $customEvents = Get-EventsFromLast24h $applicationLogName

        foreach($event in ($systemEvents + $customEvents))
        {
            Write-Output ([PSObject][ordered]@{ Id = $event.Id; Log=$event.LogName; At=$event.TimeCreated; Message=$event.Message })
        }
    }
}

function Get-MachineInfo
{
    Get-CimInstance Win32_OperatingSystem | Select-Object -Property 
}

function Out-Mail()
{
    [CmdletBinding()]
    param(
        [PSObject]$item
    )

    Begin {
        $emailBody = "Errors found on $(Get-Date)\n"
        $anything = $False
    }

    Process {

        $anything = $True
        $emailBody += "$($item.At) $($item.Log) - $($item.Message)"
    }

    End {
        if (-not $anything) 
        {
            return
        }
               
        $configurationData = [xml](Get-Content -Path 'C:\Projects\PsWorkshop\configuration.xml')

        $SmtpServer = $configurationData.DocumentElement.Server
        $SmtpServerPort = $configurationData.DocumentElement.Port
        $SmtpUser = $configurationData.DocumentElement.User
        $SmtpPass = $configurationData.DocumentElement.Password

        $ServerName = "SQLServer01"

        $Message = New-Object System.Net.Mail.MailMessage
        $Message.From = "$ServerName@domain.com"
        $Message.To.Add("Destination@domain.com")
        $Message.Subject = "Check backup DB on $ServerName"
        $Message.IsBodyHtml = $True
        $Message.Body = "a"
        $SmtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpServerPort)
        $SmtpClient.EnableSsl = $true
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($SmtpUser, $SmtpPass);
 
        $SmtpClient.Send($Message) 
    }
}