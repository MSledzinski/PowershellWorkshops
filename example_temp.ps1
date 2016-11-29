$logs = (Get-WinEvent -ListLog * | Where-Object { $_.RecordCount }).LogName

$fitlers = @{
    'StartTime' = [datetime]'2016-11-28 16:00:00'
    'EndTime' = [datetime]'2016-11-28 18:00:00'
    'LogName' = $logs
    'Level' =2 
}

Get-WinEvent -FilterHashtable $fitlers | Get-Member