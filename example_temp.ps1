$logs = Set-StrictMode -Version Latest
 (Get-WinEvent -ListLog * | Where-Object { $_.RecordCount }).LogName

$fitlers = @{
    'StartTime' = [datetime]'2016-11-28 16:00:00'
    'EndTime' = [datetime]'2016-11-30 18:00:00'
    'LogName' = 'aaaaa'
    'Level' =2 
}

Get-WinEvent -FilterHashtable $fitlers | Get-Member

# 1. find command to get event, commands - very readalbe names, slef describing
Get-Command -Verb Get -Noun *Event*

Get-Help Get-winEvent # cannot find hel probably -lets try online

Get-Help Get-winEvent -Online

# 2. add paramter - loglevel, add paramter logname, start, end time

# 2. make it paramter
# 3. validate in code
# validate in param
# gm
# format table, list - mention custom formatters, not best idea to return end script with display better ->
# objects on output 
# nad lest handle errors - ingore them :)
#-- objects
# create output object
# aadd property if contains word 'service'
# handle errors - try catch, write-error
# at this point we have input->output function - next requirments in new function

# module ->
# test
# second function

# scheduled job

# post to service information about count
