# script modules, binary modules

# psm1 file - simle as that

# why modules - easier function managment - where are your scripts.., portability (deliver scirpts to customer - not bunch of scirpts),\
# share on repository etc.

$env:PSModulePath -split ";"

Get-Module -ListAvailable


Import-Module SQLPS # -DisableNameChecking

Get-Command -Module SQLPS

Remove-Module SQLPS

# Export-ModuleMember -function 'Get-*','New-*'

# module manifest

# psd1 file, placed in folder root, meta information, module dependencies
# list of external files that are part of module

New-ModuleManifest 

# package providers - usefule inside containers
Get-PackageProvider
Find-Package -Name "Git" -Provider "Chocolatey"

Find-Package -Name "DSCAccelerator" -MinimumVersion "1.5.0" -MaximumVersion "2.1" -AllVersions

