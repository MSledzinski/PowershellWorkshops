# 1. find command to get event, commands - very readalbe names, slef describing
Get-Command -Verb Get -Noun *Event*

Get-Help Get-WinEvent # cannot find hel probably -lets try online

Get-Help Get-WinEvent -Online

# add paramter - loglevel, add paramter logname, start, end time - hash little dirty at this stage

# display result - Format-, why bad to display
# output -> gm -> objects [3]

# example - create pscustomobject on output using foreach()

# functions

# make it a function

# pipeline
# change foreach to |

# handle errors - try catch, write-error

# write next function Get-PSWsApplicationsToCheck and pipe it to 
# implement rest

# examples

# dsc
