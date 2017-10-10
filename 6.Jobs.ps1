# Pipeline is not 'concurrent'/'parallel'
# using many sessions/windows

# but...

# background job
# use remote ps internals, parent job can spawn child jobs

# differnet types of jobs - focus on backgorund

Start-Job

Invoke-Command  -ComputerName a,b,c,d -AsJob #nameless job in background


# example

$jobHF = Start-Job { Get-HotFix } -Name HotFixFetch 

Get-Job
Get-Job -State Completed

Wait-Job $job2 -Timeout 10

Stop-Job $job2 # it is not immediate, child jobs required to end

Remove-job # clear queue of jobs, removed when sesions closed



# results are deserialzied objects due to remoting


Receive-Job $jobHF

# -keep to not clear results
$data = Receive-Job $jobHF -Keep
$data
$data | gm


# error here
$job2 = Start-Job {      
       Param($path)    
           Get-ChildItem $path -Recurse -File4444 | measure Length -Sum      
         } -Name DirSum -ArgumentList 'c:\temp'


Receive-Job  $job2 -Keep



# terminating

Start-Job { 1..1000 | ForEach-Object { $_; Start-Sleep -Seconds 3 } } -Name QuiteStupidJob

Get-Job QuiteStupidJob

Stop-Job QuiteStupidJob -PassThru
Receive-Job QuiteStupidJob -Keep


# advanced jobs
Start-Job -Authentication Kerberos -Credential -RunAs32 -ArgumentList


# to get child job failed reasons
$someFailedParentJob | Get-Job -ChildJobState Failed | Select-Object -ExpandProperty JobStateInfo | Select-Object -ExpandProperty Reason




 # scheduled job
 funcion Start-SomeComponent {
    Param([string]$data)

    Write-Output $data
 }

 Get-help New-JobTrigger 

 $trigger = New-JobTrigger -Daily -At '6:30 AM'
 $trigger

 $action = { Start-SomeComponent -data 'ping' }

 $options = New-ScheduledJobOption -RunElevated -WakeToRun 

 Register-ScheduledJob -Name 'Morning startup routine' -ScriptBlock $action -Trigger $trigger -ScheduledJobOption $options 


 # Windows->powershell->scheduled jobs
 taskschd.msc
 
 Get-ScheduledJob
 Disable-ScheduledJob
 Enable-ScheduledJob

