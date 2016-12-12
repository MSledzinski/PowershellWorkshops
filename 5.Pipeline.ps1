#region Multiple pipelines


#region Pipeline binding


# so know lets talk why: Get-Data | Convert-Data | Out-File works

function Get-VirtualMachineConfiguration
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Name
    )

    return [PSCustomObject]@{ Name = $Name; VHost = 'HyperV1'; Type = 'VM' }
}

function Set-VirtualMachineData1_NVP
{

    param
    (
        [Parameter(Mandatory)]
        [PSCustomObject]$InputObject
    )
    
    process
    {
        Write-Host "$($InputObject.Name) on $($InputObject.VHost)"
    }
}

function Set-VirtualMachineData1
{

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSCustomObject]$InputObject
    )
    
    process
    {
        Write-Host "$($InputObject.Name) on $($InputObject.VHost)"
    }
}


function Set-VirtualMachineData1_5
{

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$InputObject
    )
    
    process
    {
       Write-Host "$($InputObject.Name) on $($InputObject.VHost)"
       
       Write-Host "$($InputObject) passed"
    }
}

function Set-VirtualMachineData2
{

    param
    (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$VHost
    )
    
    process
    {
        Write-Host "Machine: $Name on Host: $VHost"
    }
}

function Set-VirtualMachineData3
{

    param
    (
        [Parameter(ValueFromPipeline)]
        [PSCustomObject]$FirstObject,
        
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$SecondObject
    )
    
    process
    {
        $FirstObject.GetType()
        $SecondObject.GetType()

        Write-Host "-----------"
        Write-Host "Machine: $($FirstObject.Name) on Host: $($FirstObject.VHost)"
        Write-Host "Machine: $($SecondObject.Name) on Host: $($SecondObject.VHost)"
    }
}


Get-VirtualMachineConfiguration -Name 'Machine1' | Get-Member

# step 1 - has input with type
Get-VirtualMachineConfiguration -Name 'Machine1' | Set-VirtualMachineData1_NVP

Get-VirtualMachineConfiguration -Name 'Machine1' | Set-VirtualMachineData1

# step 2 - or can I cast it

Get-VirtualMachineConfiguration -Name 'Machine1'| Set-VirtualMachineData1_5 # but not PSObject -> string

# step 3 - by property
Get-VirtualMachineConfiguration -Name 'Machine1' | Set-VirtualMachineData2


# danger - type coersion, as PSObject is generic

#                          -> FileInfo ->
Get-Item 'c:\Windows\notepad.exe' | Set-VirtualMachineData3 



#endregion

#region Begin/Process/End blocks

# PS do not force you to use it but it is good practice

function Set-ManyThings
{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Value
    )
    
    begin
    {
        # I.e. Create file here, or setup Error Action preference..
        Write-Host "Inside Being, Value is: $Value" -ForegroundColor Green
    }

    process
    {
        Write-Host "Value is $Value" -ForegroundColor Yellow
    }

    end
    {
        # I.e. Remove PS session, temp files, closing connections....
        Write-Host "Inside End, Value is: $Value" -ForegroundColor Red
    }
}

function Get-ManyItems
{
    foreach($i in 1..3)
    {
        sleep -Seconds 3
        Write-Host "Processed value: $i - sending to output pipe" -ForegroundColor DarkRed
        Write-Output $i
    }
}

Get-ManyItems | Set-ManyThings
#endregion


#region Performance

# Sometimes pipeline is not good for given task - better to assign to variable and do ForEach (Enumeration) then pipe
# performance can be checked with Measure-Command { } 
Measure-Command { 

        Get-Process | Tee-Object 'C:\Temp\proc_dump.txt'
        get-content 'C:\Temp\proc_dump.txt' 

        }


#endregion