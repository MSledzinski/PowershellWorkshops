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

Export-ModuleMember -Function Out-*