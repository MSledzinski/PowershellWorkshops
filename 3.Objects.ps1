#region Introduction Types

# powersehll object nature - one of the main paradigm shift from cmd/bash

# object based management engine -> cmdlets and pipline are using it 

# remember there is .net underneath!
# always return object not display (ft, fl already there)

# [string]    Fixed-length string of Unicode characters
# [char]      A Unicode 16-bit character
# [byte]      An 8-bit unsigned character

# [int]       32-bit signed integer
# [long]      64-bit signed integer
# [bool]      Boolean True/False value

# [decimal]   A 128-bit decimal value
# [single]    Single-precision 32-bit floating point number
# [double]    Double-precision 64-bit floating point number

# [DateTime]  Date and Time

# [xml]       Xml object

# [array]     An array of values
# [hashtable] Hashtable object

# [PSCustomObject]

$variable = 1
[int]$variable = 1

$null

$null -eq $null


$array = @(1,2,3)
$array.Count

$hash = @{ A = 1; B = 2 }

$hash = @{ A = 1; A = 2}


43 -is [int]
43 -as [string]

# built-in conversions (Ps if very flexible here)
[string]$str = [char]0x263a
$str


[string]$str = 1234123
$str


[int]$value = "ABC"
$value



# bool

$true -is [bool]

$true -eq $false



# .Net Types
[System.Net.Mail.MailMessage]$message




#endregion


#region Everything is an object


# symbol | means pipeline -> for now assume that there is 'magic' transition from output ot next input
# help drawing of 'lazy' stream
#  [string]  ->     [hash]   ->  [void]
Get-SomeConfiguration | Set-SomethingBasedOnConfiguration

Get-Process #output is customized, not raw objects


Get-Process | Get-Member


# Get-Process | gm
# AliasProperty, Property, PropertySet, ScriptProperties (dynamically calculated), NoteProperty (static), Method



# Operations on object
Get-Command -Noun Object





# select (powerfull command)
Get-Process | 
    Select-Object -Property ID,Name  # | gm

Get-Process | 
    Select-Object -Property ID,Name,*MemorySize  # | gm


Get-Process | Select-Object -First 5 # -Last 1



# expand 
Get-Process | Select-Object -ExpandProperty Name 
Get-Process | Select-Object -ExpandProperty Name | gm

$firstStr = Get-Process | Select-Object -ExpandProperty Name  | Select-Object -first 1
Write-host "I'm:  $($firstStr.ToString())" -ForegroundColor Green

# vs

Get-Process | Select-Object -Property Name # not the same
Get-Process | Select-Object -Property Name | gm

$firstPrc = Get-Process | Select-Object -Property Name | Select-Object -First 1
Write-host "I'm:  $($firstPrc.ToString())" -ForegroundColor Red




# de-dup
@('abc','def','abc','xyz') | Select-Object -Unique # | gm




# sort 
Get-Process | 
    Sort-Object -Property PagedMemorySize -Descending | 
    Select-Object -First 1



# foreach
Get-Process | ForEach-Object { Write-Host "Processing: $($_.Name)" } # | gm # not a lot of sense :)




# filter
Get-Process |
    Where-Object { $_.StartTime -gt (Get-Date).AddHours(-1) }




# remark
[ScriptBlock]$hasStartedNoLongerThenAnHourAgo = {
    $_.StartTime -gt (Get-Date).AddHours(-1)
}

Get-Process | Where-Object -FilterScript $hasStartedNoLongerThenAnHourAgo


Get-Process | Where-Object $hasStartedNoLongerThenAnHourAgo


# measure
Get-Process | Measure-Object 
Get-Process | Measure-Object -Property VirtualMemorySize -Sum 


# group
Get-Process | Group-Object -Property Name

# tee
# really usefull
Get-Process | Tee-Object 'C:\Temp\proc_dump.txt'
notepad 'C:\Temp\proc_dump.txt'

#endregion



#region  Object Extensions and Creation



# So, lets create some objects...

# Type accelerators
[string]$dataString = "abc"
$dataString = [string]"abc"

$datetimeValue = [datetime]'11/11/2016'
$datetimeValue.DayOfWeek

$datetimeValue = [datetime]'13/13/2016'

# XML ... BTW it is realy handy
$contentXml = [xml]"<root><node>abc</node></root>"

$contentXml.DocumentElement.ChildNodes[0].InnerText

$contentXml.root.node

# verison
$version = [version]'8.0.1.33'

$version.Revision

$version = [version]'8.0.1aas.3aaa3'


# exsiting types that can be 'accelerated'
[PSOBject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get



# New-Object

# existing types
$version2 = New-Object -TypeName System.Version -ArgumentList '8.0.1.33'
$version2.Revision




# Add-Member method

$object = New-Object –TypeName PSCustomObject

Add-Member -InputObject $object –MemberType NoteProperty –Name IntProperty –Value 1 

$object | Add-Member –MemberType NoteProperty –Name SecondProperty –Value 'abc'

# .... 


$object

$object | gm | FL


# From hashtable
# PSCustomObject and PsObject - are aliases for the same type, almost... PSCustomObject is more clever during creation

$objectProperties = @{ A=1; B=2; C="text" }

$object = New-Object -TypeName PSCustomObject -Property $objectProperties

$object | Format-Table -AutoSize

$object2 = [PSCustomObject]$objectProperties
$object2 | Format-Table -AutoSize

# if I want to keep proiperty ordered

$object3 = [PSCustomObject][Ordered]@{ A=1;B=2;C="text" } #on hashtable only
$object3 | Format-Table -AutoSize


# extending

# @{ Name = <property name>; Expression={<expression>}}

$extendedObject =
Get-Process |
    Select-Object -Property Id,Name,StartTime,@{Name="Runtime";Expression={(Get-Date) - $_.StartTime}} 

$extendedObject | gm

$extendedObject | Format-Table -Property * -AutoSize


#endregion




# Exercise
# find all services that are running and then return only count
