# Script modules, binary modules

# psm1 file - simle as that

# Why use modules?
# easier function managment
# - where are your scripts.. 
# - portability (deliver scirpts to customer - not bunch of scirpts)
# - share on repository etc.

$env:PSModulePath -split ";"

Get-Module -ListAvailable

Get-Command -Module PKI

Find-Module -Name *Git* | Select-Object -Property Name,Description | FT -AutoSize

Install-module

# Loading module into PS Session
Import-Module SQLPS

Get-Command -Module SQLPS

Remove-Module SQLPS

# cd C:\Projects\PsWorkshop

Import-Module .\Modules\BadNames\BadNames.psm1
Import-Module .\Modules\BadNames\BadNames.psm1 -DisableNameChecking -Force

# Remember about PSProfile 
code $profile


# So how module looks like
# Template module


# Export-ModuleMember -Function 'Get-*','New-*'


# Module manifest

# psd1 file, placed in folder root, meta information, module dependencies
# list of external files that are part of module

New-ModuleManifest C:\Temp\NewModule.psd1 

