$eventLogName = 'PSWorkshopService'

New-EventLog -LogName PSWorkshopService -Source scripts

Limit-EventLog -LogName PSWorkshopService -OverflowAction OverwriteAsNeeded -MaximumSize 1MB

Get-WinEvent -ListLog * | ? LogName -eq PSWorkshopService

Write-EventLog -LogName PSWorkshopService -Source scripts -Message “COOL!” -EventId 0 -EntryType information

$registryPath = 'HKLM:\SOFTWARE\PsWorkshop'
if (-not (Test-Path $registryPath))
{
    New-Item $registryPath
    New-ItemProperty -Path $registryPath -Name 'AppLogName' -Value $eventLogName -PropertyType String -Force | Out-Null
}

