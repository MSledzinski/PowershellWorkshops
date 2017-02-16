# When things go wrong

Get-Service BadServiceName

# exception written to error pipeline


#region Handling
# there is Trap - old concept, hard-ish to use, better use try, so we will skip trap { }
# also if ($?) not a good practice

function Get-WithHandling
{
    [CmdletBinding()]
    param()

    try
    {
        throw "Bad error happened"
    }
    catch
    {
        Write-Host "Got Exception"
        $_
    }
    finally
    {
        Write-Host "Inside finally block"
    }   
}

function Get-WithHandlingWE
{
    [CmdletBinding()]
    param()

    try
    {
        Get-Service BadServiceName
    }
    catch
    {
        Write-Host "Got Exception"
        $_
    }
    finally
    {
        Write-Host "Inside finally block"
    }   
}

Write-Host $Error.Count -ForegroundColor Green

Get-WithHandling 

Write-Host $Error.Count -ForegroundColor Green



Write-Host $Error.Count -ForegroundColor Green

Get-WithHandlingWE

Write-Host $Error.Count -ForegroundColor Green

# Write-Error - nonterminating errors
# throw - terminating errors (or -errorAction Stop)

throw 'Termination error'

Write-Error 'Non-terminating error'



# can be modified in scope - but it is dangerous to use it - as it has effect on whole scope
$ErrorActionPreference 
$global:ErrorActionPreference -eq $ErrorActionPreference

#Possible values:
# SilentlyContinue (0) - do not display anything - dangerous
# Stop (1)
# Continue (2) [default]
# Inquire (3)
# Ignore (4)

function Get-WithoutHandling
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Name)

        process
        {
            $ErrorActionPreference = 'Ignore'
            Get-Service $Name  |  #or Get-Service $Name -ErrorAction Continue
                Select-Object -Property Name,Status
        }
}

$ErrorActionPreference = 'Stop'

Write-Host $Error.Count -ForegroundColor Green
@('EventLog','BadServiceName','WinRM') | Get-WithoutHandling | Format-Table

Write-Host $Error.Count -ForegroundColor Green

$ErrorActionPreference

