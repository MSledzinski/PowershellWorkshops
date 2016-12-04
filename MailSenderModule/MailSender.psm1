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
    
}

function Send-Mail
{  
        $emailBody += [System.Environment]::NewLine
   
        $emailBody += ((Get-MachineInfo) + [System.Environment]::NewLine)

        $configurationData = [xml](Get-Content -Path 'C:\Projects\PsWorkshop\configuration.xml')

        $SmtpServer = $configurationData.DocumentElement.smtp.server
        $SmtpServerPort = $configurationData.DocumentElement.smtp.port

        $Message = New-Object System.Net.Mail.MailMessage

        $Message.From = "notifier@company.com"
        $Message.To.Add("Destination@domain.com")
        $Message.Subject = "[$(Get-MachineName)] Error events!"
        $Message.IsBodyHtml = $false
        $Message.Body = $emailBody

        $SmtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpServerPort)

        $SmtpClient.Send($Message) 
}

# it is absolutelty not production ready function - no TLS, user/pass etc.!
function Out-ErrorEventMail
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Item,
        
        [Parameter(Mandatory)]
        [string]$ConfigurationFilePath
    )

    Begin {
        $emailBody =  "Errors found - $(Get-Date)" + [System.Environment]::NewLine
        $anything = $False
    }

    Process {

        $anything = $True
        $emailBody += ($Item + [System.Environment]::NewLine)
    }

    End {
        if (-not $anything) 
        {
            return
        }
        
        $emailBody += [System.Environment]::NewLine
   
        $emailBody += ((Get-MachineInfo) + [System.Environment]::NewLine)

        $configurationData = [xml](Get-Content -Path 'C:\Projects\PsWorkshop\configuration.xml')

        $SmtpServer = $configurationData.DocumentElement.smtp.server
        $SmtpServerPort = $configurationData.DocumentElement.smtp.port

        $Message = New-Object System.Net.Mail.MailMessage

        $Message.From = "notifier@company.com"
        $Message.To.Add("Destination@domain.com")
        $Message.Subject = "[$(Get-MachineName)] Error events!"
        $Message.IsBodyHtml = $false
        $Message.Body = $emailBody

        $SmtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpServerPort)

        $SmtpClient.Send($Message) 
    }
}

Export-ModuleMember -Function Out-*