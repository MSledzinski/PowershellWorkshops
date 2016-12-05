﻿# powersehll object nature - one of the main paradigm
# object based managment engine -> cmdlets and pipline are using it heavily
# remember there is .net underneath
# always  return object not display (ft, fl already there)

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

$null

$null -eq $null


43 -is [int]

[string]$str = [char]0x263a
$str

$true -is [bool]

$true -eq $false

# Everything is object in PS

Get-Process #output is customized

Get-Process | Get-Member | Format-Table 
Get-Process | Get-Member -MemberType Properties | Format-Table

#Get-Process | gm

# AliasProperty, Property, PropertySet, ScriptProperties (dynamically calculated), NoteProperty (static), Method

# show all properties
Get-Process lsass | Select-Object -Property *
Get-Process lsass | Format-List -Property *

# Operations on object
Get-Command -Noun Object

# sort 
Get-Process | 
    Sort-Object -Property PagedMemorySize -Descending | 
    Select-Object -Property ID,Name,*MemorySize -First 1 #Last

# filter
Get-Process |
    Where-Object { $_.StartTime -gt (Get-Date).AddHours(-1) }

# measure
Get-Process | Measure-Object 
Get-Process | Measure-Object -Property VirtualMemorySize -Sum

# foreach
Get-Process | ForEach-Object { Write-Host $_.Name } # not a lot of sense :)

# tee
# really usefull
Get-Process | Tee-Object 'C:\Temp\proc_dump.txt'
notepad 'C:\Temp\proc_dump.txt'

(Get-Process | Select-Object -First 1).PSObject # reflection, well, kind of

#################################
# Object Extensions and Creation
#################################

# Extending object members
# when input does not match output

# @{ Name = <property name>; Expression={<expression>}}

Get-Process |
    Where-Object { $_.StartTime -gt (Get-Date).AddHours(-1) } |
    Select-Object -Property Id,Name,Starttime,@{Name="Runtime";Expression={(Get-Date) - $_.StartTime}} |
    Sort-Object -Property Runtime

# CIM/WMI out of scope
# Get-WmiObject -List
Get-CimInstance win32_logicaldisk -Filter "drivetype=3" |
    Format-Table -GroupBy PSComputerName -Property DeviceID,VolumeName,@{N='FreeGB';E={[math]::Round($_.Freespace/1GB,2)}}







# So, lets create some objects...

# Type accelerators
[string]$dataString = "abc"
$datetimeValue = [datetime]'11/11/2016'

# XML is reaaly handy
[xml]$contentXml = "<root><node>abc</node></root>"
$contentXml.DocumentElement.ChildNodes[0].InnerText

# exsiting types that can be 'accelerated'
[PSOBject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get



# New-Object
# Add-Member method

$object = New-Object –TypeName PSObject
$object | Add-Member –MemberType NoteProperty –Name MyProperty –Value SomeValue

$object

# From hashtable
# PSCustomObject and PsObject - are aliases for the same type, almost... PSCustomObject is more clever during creation
$objectProperties = @{ A=1;B=2;C="text" }

$object = New-Object -TypeName PSObject -Property $objectProperties

$object | Format-Table -AutoSize

$object2 = [PSCustomObject]$objectProperties
$object2 | Format-Table -AutoSize

# if I want to keep proiperty oreder

$object3 = [PSCustomObject][Ordered]@{ A=1;B=2;C="text" } #on hashtable only
$object3 | Format-Table -AutoSize


###################
## Class ##########
###################

#new way of creating objects
# problem for now - often there is win 2k12 without ps5 
# class canot be defined inside pipline - so annonymous objects have this adentage
class Sample
{
    [int]$value
    static [string]$name

    Sample()
    {
        $this.value = 10
    }

    [void] Display()
    {
        Write-host "Sample value is $($this.value)" #interpolation remark $()
    }

}


$object4 = New-Object Sample
$object5 = [Sample]::new()

$object5.Display()



Get-ChildItem c:\Temp -Directory | ForEach-Object {
 
    $stats = Get-ChildItem $_.FullName -Recurse -File | Measure-Object length -Sum 
    Write-Output ([PSObject][ordered]@{ Name=$_.FullName; Size=$stats.Sum; Count=$stats.Count })

    } | 
    Sort-Object Size |
    Format-Table -AutoSize