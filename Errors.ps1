# when things go bad

Get-Service BadServiceName
# exception rised inside cmdlet and is written to Error pipeline

# can be modified in scope - but it is dangerous to use it - as it has effect on whole scope
$ErrorActionPreference 

#Possible values:
# SilentlyContinue (0) - do not display anything - dangerous
# Stop (1)
# Continue (2) [default]
# Inquire (3)
# Ignore (4)

#region Handling

# there is Trap - old concept, hard-ish to use, better use try, so we will skip trap { }

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

function Get-WithoutHandling
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Name)

        process
        {
         Get-Service $Name -ErrorVariable err | Select-Object -Property Name,Status
    }
}

@('EventLog','BadServiceName','WinRM') | Get-WithoutHandling -ErrorAction Continue -ErrorVariable err | Format-Table

$err

# error variable
 $err=@()
 stop-process 13 -ea silentlycontinue -ErrorVariable err
 $err.count
