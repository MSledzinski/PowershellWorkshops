Set-StrictMode -Version Latest

$logs = (Get-WinEvent -ListLog * | Where-Object { $_.RecordCount }).LogName

$fitlers = @{
    'StartTime' = [datetime]'2016-11-28 16:00:00'
    'EndTime' = [datetime]'2016-11-30 18:00:00'
    'LogName' = 'aaaaa'
    'Level' =2 
}

Get-WinEvent -FilterHashtable $fitlers | Get-Member