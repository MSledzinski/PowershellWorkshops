New-EventLog -LogName PSWorkshopService -Source scripts

Limit-EventLog -LogName PSWorkshopService -OverflowAction OverwriteAsNeeded -MaximumSize 1MB

Get-WinEvent -ListLog * | ? LogName -eq PSWorkshopService

Write-EventLog -LogName PSWorkshopService -Source scripts -Message “COOL!” -EventId 0 -EntryType information