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
        Get-Service BadServiceName
    }
    catch
    {
        Write-Host "Got Exception"
        $_
    }
    finally
    {
        Write-Host "Inside handling block"
    }   
}

Write-Host $Error.Count -ForegroundColor Green

Get-WithHandling 

Write-Host $Error.Count -ForegroundColor Green



# Write-Error - nonterminating errors
# throw - terminating errors

throw 'Termination error'

Write-Error 'Non-terminating error'



# can be modified in scope - but it is dangerous to use it - as it has effect on whole scope
$ErrorActionPreference 

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
            Get-Service $Name -ErrorAction SilentlyContinue | 
                                Select-Object -Property Name,Status
        }
}

@('EventLog','BadServiceName','WinRM') | Get-WithoutHandling | Format-Table


