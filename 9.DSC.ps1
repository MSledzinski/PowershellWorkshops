$PsVersionTable

Get-Command Get-DscConfigurationStatus

Get-Command Find-Module

Import-Module PSDesiredStateConfiguration
Get-Command -module PSDesiredStateConfiguration

# from imperative to declarative
# we can write custom ps script/module

$feature = Get-WindowsFeature -Name Telnet-client
if(-not $feature.Installed)
{
    Add-WindowsFeature $feature
}

# but what if it has a lot of settings? reboot required, error handling -> gets messy quite soon...?
# responsibility of coping with them

WindowsFeature Telnet-client {
    Name = 'Telnet-client'
    Ensure = 'Present'
}




Configuration ServicesDscConfiguration {

    param(
        [string[]]$ComputerName = "localhost"
    )

    Node $ComputerName {

        WindowsFeature RsatService {
            Ensure = "Present"
            Name =    "RSAT"
        }

        WindowsFeature BitlockerService {
            Ensure = "Present"
            Name = "Bitlocker"
        }
    }
}



# process flow
# Authoring (write and compile to MOF - platform independent) -> Staging (push or pull, client receives) -> 'make it so' (LCM)


# LCM - get document and apply it (MOF)
# example configuring LCM - configure LCM agent on machine, not exactly machine state itself, meta-configuration
# creates metadata.mof



# configure client agent
[DSCLocalConfigurationManager()] 
Configuration LCMPush
{
    # in older previews  set differently

    Node 'localhost'
    {
        Settings    
        {
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyAndAutoCorrect' # 'ApplyOnce' 'Monitor'
            RefreshMode = 'Push'
            RefreshFrequencyMins = 30
            CertificateID = 'Thumbprint here'
        }
    }
}



$OutPath = 'c:/DSC/LCM'
LCMPush -OutputPath $OutPath 

# show MOF - Meta-Object Facility - http://www.omg.org/spec/MOF/2.4.2/ , instance of OMI in MOF
cd $OutPath 

# set
Set-DscLocalConfigurationManager -ComputerName vm2 -Path $OutPath -Verbose

# check what was set
Get-DscLocalConfigurationManager -CimSession vm2





# push and pull mode
[DSCLocalConfigurationManager()]
Configuration LCM_HTTP_Pull
{
    param(
         [Parameter(Mandatory=$true)]
         [string[]]$nodeNames,

         [Parameter(Mandatory=$true)]
         [string]$guid)

    Node $nodeNames
    {
        Settings
        {
            # guid for configuration
            ConfigurationID = $guid

            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyAndAutoCorrect'

            # set as pull mode
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
        }

        <#
        ConfigurationRepositoryShare DSCSMB 
        {
            Name = 'DSCSMB'
            SourcePath = '\\machine\smb_repo'
        }
        #>

        ConfigurationRepositoryWeb DSCHTTP
        {
            ServerURL = 'http://vm1:8080/PSDSCPullServer.svc'
            AllowUnsecureConnection = $true
        }
    }
}


$nodeNames = "vm2"
$guid = [guid]::NewGuid()
$outp = "c:/DSC/HTTP"

LCM_HTTP_Pull -nodeNames $nodeNames -guid $guid -OutputPath $outp

# when mof is built
Set-DscLocalConfigurationManager -ComputerName $nodeNames -Path $outp -Verbose

# resources


# installed - from module paths
Get-DscResource

# available - X... and C...
Find-DscResource -OutVariable r | measure
$r | ogv




 # show example of module-resource

Get-DscResource File -Syntax



Install-module -Name cWindowsOS

Import-Module cWindowsOS

explorer (Split-Path ( Get-Module cWindowsOS | $ path))



# Example - DCS for ShP

# https://github.com/PowerShell/SharePointDsc/wiki

# https://gist.github.com/nivleshc/1106ff6a8333f8faec02cedec4c17506#file-createnewadforest-ps1


 # interesting cross machine dependencies
Get-DscResource WaitFor*
Get-DscResource WaitForAny -Syntax