# Commands/functions
# cmdlet -> functions -> modules

# convention, readable, self-describing
Verb-Noun

Get-Item
Set-Item

Get-Acl
Set-Acl

# Do Something - To Something
# Get-Verb, Set-Verb

# Approved verbs: https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx

# Find help
Get-Command  *Service*

Get-Command -Verb Get -Noun *Service*


Get-Help

Get-Help Get-Service -Detailed 

Get-Help Get-Service  -Full


Get-Command Get-Service -Syntax


help #alias

# if something is unclear - google it :)


# sometimes detailed help missing
Update-Help


