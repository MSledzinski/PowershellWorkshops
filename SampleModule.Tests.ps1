$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$module = 'SampleModule'
$moduleFile = "$here\$module.psm1"

Get-Module SampleModule | Remove-Module -Force
Import-Module $moduleFile -Force

Describe -Tags ('Unit', 'Acceptance') "$module Tests" {

    Context 'Module Setup' {
        
        It "has root module $module.psm1" {
            $moduleFile | Should Exist
        }

        It "has valid Powershell code" {
            $psFile = Get-Content -Path $moduleFile -ErrorAction Stop

            $errors = $null
            [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)

            $errors.Count | Should Be 0
        }

        It "has correct code style" {
            #Install-Module PsScriptAnalyzer
            Import-Module PsScriptAnalyzer

            $errors = Invoke-ScriptAnalyzer -Path $moduleFile

            $errors.Count | Should Be 0
        }
    }
}