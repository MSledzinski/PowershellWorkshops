$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'MailSender'
$moduleFile = "$here\$module.psm1"

Get-Module SampleModule | Remove-Module -Force
Import-Module $moduleFile -Force

