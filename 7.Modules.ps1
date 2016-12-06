# Script modules, binary modules

# psm1 file - simle as that

# Why use modules?
# easier function managment
# - where are your scripts.. 
# - portability (deliver scirpts to customer - not bunch of scirpts)
# - share on repository etc.

$env:PSModulePath -split ";"

Get-Module -ListAvailable

Get-PSRepository

Find-Module -Name *Git* | Select-Object -Property Name,Description | FT -AutoSize


# Loading module into PS Session
Import-Module SQLPS

Get-Command -Module SQLPS

Remove-Module SQLPS

Import-Module .\Modules\BadNames\BadNames.psm1
Import-Module .\Modules\BadNames\BadNames.psm1 -DisableNameChecking -Force

# Remember about PSProfile 
code $profile



# Template module
code .\Modules\TemplateModule

# Export-ModuleMember -Function 'Get-*','New-*'



# Module manifest

# psd1 file, placed in folder root, meta information, module dependencies
# list of external files that are part of module

New-ModuleManifest C:\Temp\NewModule.psd1



# Package providers - usefule inside containers, dsc etc.
# idea of oneget, unification of providers
# similar to Chocolatey - abstractoin over it
Get-PackageProvider

Find-Package -Name "Git" -Provider "Chocolatey"

Find-Package -Name "DSCAccelerator" -MinimumVersion "1.5.0" -MaximumVersion "2.1" -AllVersions

Install-Package