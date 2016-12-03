#region Basic functions
function Get-Stuff
{
    "Stuff"
}

function Get-StuffWithParams([string]$parameter)
{
    "Stuff" + $parameter
}
#endregion
# talk about scopes Global: Script: Private:

#region Advanved
function Get-DataBasic
{
    param(
        [string]$value
    )

}

function Get-DataAdcanved
{
    [CmdletBinding()]
    param(
        
    )
}
#endregion

# show - and possibilities

# error, warnign variable

#region Parmeters

function Get-WithMandatoryParameter
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$value
    )


}

(Get-Command -Name 'Get-WithMandatoryParameter').Parameters.Value.Attributes

#endregion

#region Validation
function Get-FolderItemsCount
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ 
            if(-not (Test-Path $_ -PathType Container) )
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

    Get-ChildItem $path | Measure-Object | Select-Object -Property Count
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

function New-WithParamterSet
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

New-WithParamterSet -Name 'abc'

New-WithParamterSet -Id 1 -GenericName 'z'
#endregion
