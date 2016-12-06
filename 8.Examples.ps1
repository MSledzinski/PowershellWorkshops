# Get-member
Get-Service | gm



# Annonymous object tpyes, calculated properties
 Get-Service | Select-Object @{ Name='SN'; Expression={$_.Name}} 



# Diffrent outputs
Out-null
Out-File



# Providers
# Set-Item, Get-Item in PSDrive abstraction
Get-PSProvider
 
Set-Location CERT:

Get-ChildItem -Path Cert:\LocalMachine -Recurse | 
    Where-Object { $_.Subject -eq 'CN=localhost' } | 
    Select-Object -Property Subject,Thumbprint

Set-Location SQLServer:
Set-Location HKLM:



# join-path to avoind checking for /
Join-Path 'c:/temp/' '\folder\aa.txt'
Join-Path 'c:/temp/' 'folder\aa.txt'



# WinRM - complex topic - but easy to setup inside a domain (+kerberos)
# PSExec
$cred = Get-Credential 'domain\user'
$session = Enter-PSSession -ComputerName computername-Credential $cred


Exit-PSSession $session
# Get-Service -ComputerName fp-pc2686.fp.lan,computer2,computer3 




# Web IIS
Import-Module WebAdministration
Get-ChildItem –Path IIS:\AppPools

$appPoolName = 'MyAppPool'
$scriptBlock = {
    Import-Module WebAdministration
    New-Item –Path IIS:\AppPools\$using:appPoolName
    Set-ItemProperty -Path 
    IIS:\AppPools\$using:appPoolName -Name 
    managedRuntimeVersion -Value 'v4.0'
    Remove-WebAppPool -Name $using:appPoolName
}

Invoke-Command –ComputerName SOMEIISSERVER –ScriptBlock $scriptBlock 

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
$class = “win32_bios”

Invoke-Command -cn serverName {param($class) Get-WmiObject -class $class} -ArgumentList $class

Get-WmiObject Win32_USBControllerDevice  |fl Antecedent,Dependent

# bootsrap project modules in profile

# Calling web requests
Invoke-WebRequest -UseBasicParsing 
Invoke-RestMethod -UseBasicParsing

# Working with SQL
Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery;" -ServerInstance "localhost" 

Get-Module -ListAvailable -Name Sqlps;
(Get-Module -ListAvailable -Name Sqlps | Select -First 1).ExportedCommands

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

Get-ScheduledJob -Id 1