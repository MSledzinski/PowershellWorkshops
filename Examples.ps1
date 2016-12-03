# Get-member
Get-Service | gm

# Annonymous object tpyes, calculated properties
 Get-Service | Select-Object @{ Name='SN'; Expression={$_.Name}} 

# Providers
# Set-Item, Get-Item in PSDrive abstraction
Get-PSProvider
 
Set-Location CERT:

Get-ChildItem -Path Cert:\LocalMachine -Recurse | 
    Where-Object { $_.Subject -eq 'CN=localhost' } | 
    Select-Object -Property Subject,Thumbprint

Set-Location SQLServer:
Set-Location HKLM:


# WinRM - complex topic - but easy to setup inside a domain (+kerberos)
# PSExec
$cred = Get-Credential 'domain\user'
$session = Enter-PSSession -ComputerName computername-Credential $cred


Exit-PSSession $session

# Get-Service -ComputerName fp-pc2686.fp.lan,computer2,computer3 

# Web
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