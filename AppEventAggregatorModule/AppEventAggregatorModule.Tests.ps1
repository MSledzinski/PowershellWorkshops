$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'AppEventAggregatorModule'
$moduleFile = "$here\$module.psm1"

Get-Module SampleModule | Remove-Module -Force
Import-Module $moduleFile -Force

Describe -Tags ('Unit', 'Acceptance') "$module Tests" {

# region Module core tests
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
    }

# endregion

#region Read Applications list
InModuleScope "$module" {

    Context 'Applications configuration fetch' {
        
        $jsonContent = 
@"
                        {
                            "applications":[
                                {
                                    "name" : "App1",
                                    "registryKey": "Key1",
                                    "otherStting": 42
                                },
                                {
                                    "name" : "App2",
                                    "registryKey" : "Key2",
                                    "otherSetting" : 44
                                }
                            ]
                        }
"@
            It "can read defined applications info" {
                
                # given
                $path = 'c:\data\'
                $file = 'c:\data\applications.json'

                Mock Get-Content { $jsonContent } -ParameterFilter { $Path -eq $file }

                # when
                $actualApplications = Get-PSWsApplicationsToCheck -configurationPathRoot $path

                # then
                $actualApplications[0].Name | Should Be 'App1'
                $actualApplications[0].RegistryKey | Should Be 'Key1'
                $actualApplications[1].Name | Should Be 'App2'
                $actualApplications[1].RegistryKey | Should Be 'Key2'
            }
        
    }

    Context 'Event log search' {
        
        It "find all realted log entries" {
            # given
            $testTime = Get-Date
            $registryPath = "HKLM:/Software/AppLog"
            $logName = "AppLog"
            $appName = 'App1'

            Mock Throw-WhenRegistryPathNotExist { return $true } -ParameterFilter { $Path -eq $registryPath }
            Mock Get-ItemProperty { ([PSCustomObject][Ordered]@{ AppLogName=$logName }) } -ParameterFilter { $Path -eq $registryPath }

            $systemEvents = @( [PSCustomObject]@{ At= $testTime.AddHours(-4); Message="Error in $appName" }, [PSCustomObject]@{ At = $testTime.AddHours(-1); Message="Another error"} )
            Mock Get-EventsFromLast24h { $systemEvents }  -ParameterFilter { $LogName -eq 'System' }

            $customEvents = @( [PSCustomObject]@{ At= $testTime.AddHours(-4); Message="Something was wrong" } )
            Mock Get-EventsFromLast24h { $customEvents } -ParameterFilter { $LogName -eq "AppLog" }
        
            # when
            $actualErrors = Search-PSWspApplicationError -ApplicationName $appName -RegsitryKey $logName
        
            # then
            $actualErrors.Length | Should Be 2 # better assertion would be nice here
            $actualErrors | Where-Object { $_.Message -eq 'Another error' } | Measure-Object | % Count | Should Be 0
        }
    }

    Context "Mail notification" {
        
        It "sends mail to proper server" {
        }
    }

} # InModuleScope script block

# endregion

} # Describe script block