# Get-member
Get-Service | gm



# Annonymous object tpyes, calculated properties
 Get-Service | Select-Object -Property @{ Name='SN'; Expression={$_.Name + "_1" }} 


# Manipulate pipe
Get-Service | Select-Object -First 1 # top 1
Get-Service | Where-Object { } | ForEach-Object {} | Tee-Object {} | Group-Object {}


# Diffrent outputs
Out-Null

Out-File

# not ps, but handy
Get-Process | Select-Object -First 1| % Path | clip



# join-path to avoid checking for /
Join-Path 'c:\temp\' '\folder\aa.txt'
Join-Path 'c:/temp/' 'folder\aa.txt'


# Providers
# Set-Item, Get-Item in PSDrive abstraction
Get-PSProvider
 
Get-ChildItem -Path Cert:\LocalMachine -Recurse | 
    Where-Object { $_.Subject -eq 'CN=localhost' } | 
    Select-Object -Property Subject,Thumbprint



# Working with SQL  - IMPORTANT: better use standalone SQLServer ps module
Import-Module SQLPS 

Get-Command -Module SQLPS

Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery;" -ServerInstance "localhost" 


# list databases
Get-ChildItem -Path "SQLSERVER:\SQL\$($env:COMPUTERNAME)\default\Databases"

Set-Location SQLServer:



# Web IIS
Import-Module WebAdministration
Get-ChildItem –Path IIS:\AppPools

# now remember appcmd :)

Import-Module WebAdministration
New-Item –Path IIS:\AppPools\App1
Set-ItemProperty -Path IIS:\AppPools\App1 -Name managedRuntimeVersion -Value 'v4.0'


Remove-WebAppPool -Name App1


# WinRM - complex topic - but easy to setup inside a domain (+kerberos)
# PSExec
$cred = Get-Credential 'domain\user'
$session = Enter-PSSession -ComputerName computername -Credential $cred


Exit-PSSession $session
Get-Service -ComputerName fp-pc2686.fp.lan,computer2,computer3 




# Splatting
Get-Content -Path C:\MyText.txt -ReadCount 1 -TotalCount 3 -Force -Delimiter "," -Filter '*' -Include * -Exclude 'a'

$getContentParameters = @{
   'Path'       = 'C:\MyText.txt'
   'ReadCount'  = 1
   'TotalCount' = 3
   'Force'      = $true
   'Delimiter'  = ','
   'Filter'     = '*'
   'Include'    = '*'
   'Exclude'    = 'a'
}
Get-Content @getContentParameters


# WMI and invoke-command

Get-WmiObject Win32_USBControllerDevice  


# CIM/WMI out of scope
Get-CimInstance win32_logicaldisk -Filter "drivetype=3" |
    Select-Object -Property DeviceID,VolumeName,@{N='FreeGB';E={[math]::Round($_.Freespace/1GB,2)}} 


# bootsrap project modules in profile



# Calling web requests
Invoke-WebRequest 'www.google.com' -UseBasicParsing # rember about parse!

Invoke-RestMethod 'http://someservice.com/api/items' -Method Get -Headers {}





# Call WinApi when needed 
$Signature = @"
[DllImport("user32.dll")]public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@
$ShowWindowAsync = Add-Type -MemberDefinition $Signature -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru 

# Minimize the Windows PowerShell console
$ShowWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)

# Restore it
$ShowWindowAsync::ShowWindowAsync((Get-Process -Id $Pid).MainWindowHandle, 4)




# Add .Net code
$sourceCode = @"
public class BasicMath
{
  public static int AddStatic(int a, int b)
  {
        return a + b;
  }

  public int Add(int a, int b)
  {
        return a + b;
  }
}
"@

Add-Type -TypeDefinition $sourceCode 

[BasicMath]::AddStatic(2, 2)

$object = New-Object BasicMath
$object.Add(5, 2)




# scheduled job

$trigger = New-JobTrigger -RepetitionInterval (New-TimeSpan -Hours 1)

Register-ScheduledJob -Name PsAppErrorEventsCheck -Trigger $trigger -ScriptBlock { 
   
    Import-Module AppEventAggregator

    Send-MailIfErrors #params
}


# include
. \scripts.ps1 # same scope

& .\script.ps1 # another scope