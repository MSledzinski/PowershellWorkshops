# objects piped from one commadnto another get-data | convert-data | save-data

# -PassThru switch

#mutliple pipelines
# ErrorPipeline, WarningPipeline, VerbosePipeline, DebugPipeline
# not all cmdlets designed to use it

# controlled by preference variables

# output
Get-Service | Out-File -FilePath 'C:\Temp\service_dump.txt' -Append 

# stream redirection 
# Stream = value
# Pipeline (success) =1
# Errors = 2
# Warning = 3
# Verbose = 4
# Debug = 5

# write >
# append >>
# merge >&

function Set-VerboseThings
{
    [CmdletBinding()]
    param()

    Write-Debug "from debug pipe..."
    Write-Verbose "from verbose pipie..."

    Write-Output "from output pipe..."
}

Set-VerboseThings #-Verbose, -Debug, when Debug show $PSCmdlet

# merging example
Get-WmiObject wind32_logicaldisk 2>err.txt 4>verbose.txt

Get-WmiObject wind32_logicaldisk 2>&1 1>data.txt # any erros and output will be in the same file, can only merge to sucess stream


# Sometimes pipeline is not good for given task - better to assign to variable and do ForEach (Enumeration) then pipe
# performance can be checked with Measure-Command { } 


#region Pipeline binding

# so know lets talk why: Get-Data | Convert-Data | Out-File works

function Get-VirtualMachineData
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param
    (
        [Parameter(Mandatory)]
        [string]$Name
    )

    [PSCustomObject]@{ 'Name' = $name; 'Host' = 'HyperV1'; 'Type' = 'VM' }
}

function Set-VirtualMachineData1
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSCustomObject]$InputObject
    )
    
    process
    {
        Write-Host "$($InputObject.Name) on $($InputObject.Host)"
    }
}

function Set-VirtualMachineData2
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject]$FirstObject,
        
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$SecondObject
    )
    
    process
    {
        Write-Host "Machine: $($FirstObject.Name) on Host: $($FirstObject.Host)"
        Write-Host "Machine: $($SecondObject.Name) on Host: $($SecondObject.Host)"
    }
}

function Set-VirtualMachineData3
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Name
    )
    
    process
    {
        Write-Host "Value $Name"
    }
}

Get-VirtualMachineData -Name 'Machine1' | Get-Member

Get-VirtualMachineData -Name 'Machine1' | Set-VirtualMachineData2

Get-Item 'c:\Windows\notepad.exe' | Set-VirtualMachineData2 #danger - type coersion, as PSObject is generic

Get-VirtualMachineData -Name 'Machine1' | Set-VirtualMachineData3

#endregion

#region Begin/Process/End blocks

# PS do not force you to use it but it is good practice

function Set-ManyThings
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Name
    )
    
    begin
    {
        # I.e. Create file here, or setup Error Action preference..
        Write-Host "Inside Being, Name: $Name" -ForegroundColor Green
    }
    process
    {
        Write-Host "Value $Name" -ForegroundColor Yellow
    }
    end
    {
        # I.e. Remove PS session, temp files, closing connections....
        Write-Host "Inside End, Name: $Name" -ForegroundColor Red
    }
}

'abc','def','xyz' | Set-ManyThings
#endregion