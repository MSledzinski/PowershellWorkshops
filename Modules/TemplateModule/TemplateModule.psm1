# Lookup function files
$privateFunctionsFiles = Get-ChildItem -Path .\Functions\Private -Filter '*.ps1' -File
$publicFunctionFiles = Get-ChildItem -Path .\Functions\Public -Filter '*.ps1' -File

# Import all functions
foreach($file in ($privateFunctionsFiles + $publicFunctionFiles))
{
    . $file.FullFileName
}

# Export public members
[string[]]$exportableNames = $publicFunctionFiles | Select-Object -Property FileName

Export-ModuleMember -Function $exportableNames