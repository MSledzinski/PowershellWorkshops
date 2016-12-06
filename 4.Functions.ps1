#region Basic functions

#input (param) -> output (steam write-/out-, last value)

# Verb-Noun

function Get-Stuff
{
    Write-host "Stuff"
}

function Get-Stuff2()
{
    Write-host "Stuff"
}

function Get-StuffWithParams([string]$parameter)
{
    Write-host ("Stuff" + $parameter)
}

function Get-StuffWithParams2
{
    param(
        [string]$parameter)

    Write-host ("Stuff" + $parameter)
}


Get-Suff
Get-StuffWithParams -parameter "ABC"

# output - output stream
function Get-DataWO
{
    # it does not means function ends here
    Write-Output 1
    Write-Host "At the end of Get-DataWO"
}

function Get-DataR
{
    # it is over
    return 2
    Write-Host "At the end of  Get-DataR"
}

function Get-Data
{
    # it does not means function ends here, it is equivalent to: write-output 3 
    3
    Write-Host "At the end of  Get-Data" 
}

Get-DataWO
Get-DataR
Get-Data

# will there be the same result?
function Get-Data1
{
    6
}

function Get-Data2
{
    1 
    2
    3
    4
    5
    6
}

$resul1 = Get-Data1
$result2 = Get-Data2

$resul1 -eq $result2


#endregion


#region Advanced, or real-life functions

function Get-DataAdvanced
{
    [CmdletBinding()]
    param(     
    )
}

Get-DataAdvanced 

# show - and possibilities
# error, warning variable
# more on this in 'pipeline'

#endregion



#region Parmeters and Validation

function Get-WithMandatoryParameter
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$value
    )


}

(Get-Command -Name 'Get-WithMandatoryParameter').Parameters.Value.Attributes


function Get-FolderItemsCount
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ 
            if(-not (Test-Path $_) )
            {
                throw "Folder not found [$_]"
            } else
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

function Get-WithSetAndRange
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('abc','def')]
        [string]$value,

        [ValidateRange(100MB, 10GB)]
        [int]$memory
    )

    "Value is $value, $memory"
}

Get-WithSetAndRange "abc" -memory 101MB

Get-WithSetAndRange "abc" -memory 10MB

Get-WithSetAndRange "xyz"

get-help Get-WithSetAndRange

#endregion

#region Nulls
function Get-WithNull
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$value
    )

    "Value is $value"
}

Get-WithNull $null

Get-WithNull ''

Get-WithNull 'a'

# NotNull only when paramter is Mandatory only

#endregion

#region Parameters Set

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



#region Rember about Out .. once again!

function Set-NetworkState()
{
    $statusCode = 3
    # Do some system state change
    return $statusCode
}

function Get-FromRemote
{
     Write-Output 100
     Write-Output 200
     Write-Output 300
}

function Invoke-SomeDataFetch()
{
    foreach($item in Get-FromRemote)
    {
        Write-Output $item
    }   
    
    Set-NetworkState     
}

function Interpret-Values
{
    [CmdletBinding()]
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