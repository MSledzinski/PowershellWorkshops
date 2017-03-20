#region Basic functions

#input (param) -> output (steam write-/out-, last value)

# never display, always return objects!
# add second function to display or formatter

# Verb-Noun

function Get-Stuff
{
    Write-host "Stuff"
}

function Get-Stuff2()
{
    Write-host "Stuff"
}

function Get-StuffWithParams($parameter)
{
    Write-host ("Stuff" + $parameter)
}

function Get-StuffWithParams2([string]$parameter)
{
    Write-host ("Stuff" + $parameter)
}

function Get-StuffWithParams3
{
    Param(
        [string]$parameter)

    Write-host ("Stuff" + $parameter)
}

function Get-StuffWithParams3
{
    <#
        .SYNOPSIS
        This function does something important

        .DESCRIPTION
        It runs some heavy machinery to do stuff

        .EXAMPLE
        Get-StuffWithParams3 -paramter "ABC"

        .NOTES
        Function returns terminating error if it is too late
    #>

    Param(
        [string]$parameter)

    Write-host ("Stuff" + $parameter)
}

Get-Help Get-StuffWithParams3 

Get-Help Get-StuffWithParams3 -Examples



#region Parmeters and Validation

# Fail Fast

function Get-WithMandatoryParameter
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$value
    )

    Write-Host $value -ForegroundColor Green
}

Get-WithMandatoryParameter


function Get-FolderItemsCount
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ 
                if(-not (Test-Path $_) )
                {
                    throw "Folder not found [$_]"
                } 
                else
                {
                    $true
                }
            })]
        [ValidatePattern('^[c|C]:\\')]
        [string]$path
    )

    Get-ChildItem -Path $path | Measure-Object | Select-Object -Property Count
}

Get-FolderItemsCount 'c:\temp'

Get-FolderItemsCount 'c:\temp4'


function Set-VMMemoryLimit
{
    param(
        [Parameter(Mandatory)]
        [ValidateSet('abc','def')]
        [string]$value,

        [ValidateRange(100MB, 10GB)]
        [int]$memory
    )

    Write-Host "Value is $value, $memory"
}

Set-VMMemoryLimit "abc" -memory 101MB

Set-VMMemoryLimit "abc" -memory 10MB

Set-VMMemoryLimit "xyz"

#endregion


#region Parameters Set - out of scope

function New-ImportantItem
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$IdValue,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [ValidateNotNullOrEmpty()]
        [string]$GenericName
    )

    if ($PSCmdlet.ParameterSetName -eq 'ByName')
    {
        Write-Host 'Creating by name'
    }
    else
    {
        Write-Host 'Creating by Id'
    }

}

New-ImportantItem -Name 'abc'

New-ImportantItem -IdValue 1 -GenericName 'z'

New-ImportantItem -Name 'abc' -IdValue 1
#endregion



# output - output stream

function Get-DataR
{
    return 1 
    return 2
    Write-Host "At the end of  Get-DataR"
}

function Get-DataR2
{
    $temp = {
        return 1 
    } 

    return 2
    Write-Host "At the end of  Get-DataR"
}

function Get-DataWO
{
    Write-Output 1
    Write-Output 2
    Write-Host "At the end of Get-DataWO"
}

function Get-Data
{
    1
    2
    Write-Host "At the end of  Get-Data" 
}

function Get-DataMix
{
    Clear-Host

    Write-Output (Get-DataWO)

    Get-DataWO 

    Write-Host "At the end of  Get-DataMix" 
}


$result = Get-DataR
$result

# remark -  'return' - termination of scope
$result = Get-DataR2
$result


$result = Get-DataWO
$result

$result = Get-Data
$result

Get-DataMix

# why things displayed in console
Get-Process # | Use-FormatterIfAny | Print-OnHostStdOut 



#endregion




#region Rember about Out .. once again!
# Out-Null to help us!

function Set-NetworkState
{
    Param([string]$state)

    $statusCode = 3

    # Do some system state change

#region Change that came later...
    if(($state -eq 'Off') -and ($statusCode -gt 1))
    {
        $statusCode
    }
#endregion
}

function Get-FromRemote
{
     Write-Output 100
     Write-Output 200
     Write-Output 300
}

function Invoke-SomeDataFetch
{
    Set-NetworkState -state 'On' 

    foreach($item in Get-FromRemote)
    {
        Write-Output $item
    }   
        
    Set-NetworkState -state 'Off'
}

function Interpret-Values
{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [int]$Value
    )

    process
    {
        if ($Value -lt 10) 
        {
            Write-Host "Emergency! Value [$Value] too low. Call Admin" -ForegroundColor Red
        } 
        else 
        {
            Write-Host "Value [$Value] ok." -ForegroundColor Green
        }
    }
}

Invoke-SomeDataFetch | Interpret-Values

#endregion

# controlled by preference variables

function Set-VerboseThings
{
    [CmdletBinding()]
    param()

    Write-Debug "from debug pipe..."
    Write-Verbose "from verbose pipie..."

    Write-Output "from output pipe..."
    Write-Warning "be careful"
}

Set-VerboseThings 
Set-VerboseThings -Verbose
Set-VerboseThings -Debug

#endregion
