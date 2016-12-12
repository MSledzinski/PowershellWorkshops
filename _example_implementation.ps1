function Get-DeployedApplicationsInformation
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            
            if(-not (Test-Path $_))
            {
                throw "Path not found [$_]"
            }
            elseif ([System.IO.Path]::GetExtension($_) -ne '.json')
            {
                throw "Provided path is not for json file [$_]"
            }

            Write-Output $true
        })]
        [string]$ConfigFilePath)

    $content = [string](Get-Content $configFilePath)
    $data = ConvertFrom-Json $content

    $jsonToObjectAppMapper = {
        [PSCustomObject][Ordered]@{ AppName = $_.name; RegKey = $_.registryKey }
    }

    $apps = $data.applications | ForEach-Object $jsonToObjectAppMapper

    Write-Output $apps
}


function Get-ErrorEvetLogName
{
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)]
        [string]$RegKey
    )

    process
    {
        $regPath = "HKLM:\Software\$RegKey"

        $logName = Get-ItemPropertyValue -Path $regPath -Name AppLogName

        Write-Output $logName
    }
}

function Get-ErrorEeventsFromWindowsLog
{
     param(
        [Parameter(Mandatory=$true, ValueFromPipeline)]
        [string]$LogName
    )

    process
    {
         $eventsFilter = @{
                    'StartTime' = (Get-Date).AddHours(-128)
                    'EndTime' = (Get-Date)
                    'LogName' = $LogName
                    'Level' = 4 # Error
                }
  
       Get-WinEvent -FilterHashtable $eventsFilter
    }
}

Get-DeployedApplicationsInformation -ConfigFilePath 'C:\Projects\PsWorkshop\Data\applications.json' |
    Get-ErrorEvetLogName |
         Get-ErrorEeventsFromWindowsLog | 
            Select-Object -Property TimeCreated,Message |
                Format-Table -AutoSize
                

       
