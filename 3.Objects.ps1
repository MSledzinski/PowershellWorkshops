#region Introduction Types

# powersehll object nature - one of the main paradigm shift from cmd/bash

# object based management engine -> cmdlets and pipline are using it 

# remember there is .net underneath
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

$null

$null -eq $null


43 -is [int]

[string]$str = [char]0x263a
$str

$true -is [bool]

$true -eq $false

#endregion


#region Everything is an object

# symbol | means pipeline -> for now assume that there is 'magic' transition from output ot next input
# help drawing of 'lazy' stream

Get-Process #output is customized, not raw objects

Get-Process | Get-Member | Format-Table 

# Get-Process | gm
# AliasProperty, Property, PropertySet, ScriptProperties (dynamically calculated), NoteProperty (static), Method

Get-Process lsass | Select-Object -Property *


# Operations on object
Get-Command -Noun Object

# select (powerfull command)
Get-Process | 
    Select-Object -Property ID,Name,*MemorySize |
    Select-Object -First 1 

# sort 
Get-Process | 
    Sort-Object -Property PagedMemorySize -Descending | 
    Select-Object -Property ID,Name,*MemorySize 

# foreach
Get-Process | ForEach-Object { Write-Host "Processing: $($_.Name)" } # not a lot of sense :)

# filter
Get-Process |
    Where-Object { $_.StartTime -gt (Get-Date).AddHours(-1) }

# measure
Get-Process | Measure-Object 
Get-Process | Measure-Object -Property VirtualMemorySize -Sum


# group
Get-Process | Group-Object -Property Name

# tee
# really usefull
Get-Process | Tee-Object 'C:\Temp\proc_dump.txt'
notepad 'C:\Temp\proc_dump.txt'

(Get-Process | Select-Object -First 1).PSObject # reflection, well, kind of

#endregion



#region  Object Extensions and Creation

# @{ Name = <property name>; Expression={<expression>}}

Get-Process |
    Select-Object -Property Id,Name,StartTime,@{Name="Runtime";Expression={(Get-Date) - $_.StartTime}} | #ScriptProperty
    Sort-Object -Property Runtime

# CIM/WMI out of scope
Get-CimInstance win32_logicaldisk -Filter "drivetype=3" |
    Select-Object -Property DeviceID,VolumeName,@{N='FreeGB';E={[math]::Round($_.Freespace/1GB,2)}} 



# So, lets create some objects...

# Type accelerators
[string]$dataString = "abc"
$datetimeValue = [datetime]'11/11/2016'

# XML ... BTW it is realy handy
$contentXml = [xml]"<root><node>abc</node></root>"
$contentXml.DocumentElement.ChildNodes[0].InnerText
$contentXml.root.node


# exsiting types that can be 'accelerated'
[PSOBject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get



# New-Object
# Add-Member method

$object = New-Object –TypeName PSObject
Add-Member -InputObject $object –MemberType NoteProperty –Name MyProperty –Value 1 

$object
$object | gm

# From hashtable
# PSCustomObject and PsObject - are aliases for the same type, almost... PSCustomObject is more clever during creation

$objectProperties = @{ A=1; B=2; C="text" }

$object = New-Object -TypeName PSObject -Property $objectProperties

$object | Format-Table -AutoSize

$object2 = [PSCustomObject]$objectProperties
$object2 | Format-Table -AutoSize

# if I want to keep proiperty ordered

$object3 = [PSCustomObject][Ordered]@{ A=1;B=2;C="text" } #on hashtable only
$object3 | Format-Table -AutoSize

#endregion

#region Classes

# better - as uniform, shared 'definition', will be the 'right' way
# but problem for now - often there is win 2k12 without ps5 

# class canot be defined inside pipline - so annonymous objects have adentage there

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

$object4.Display()

#endregion