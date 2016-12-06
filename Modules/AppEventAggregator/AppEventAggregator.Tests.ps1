$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'AppEventAggregator'
$moduleFile = "$here\$module.psm1"

Get-Module SampleModule | Remove-Module -Force
Import-Module $moduleFile -Force

Describe -Tags ('Unit', 'Acceptance') "$module Event Tests" {
    
    InModuleScope "$module" {
    
    $configurationXmlContent = @"
                <configuration>
                        <smtp>
                            <server>localhost</server>
                            <port>25</port>
                            <to>admin@support.com</to>
                        </smtp>
                </configuration>
"@
     Mock Get-Content -MockWith { $configurationXmlContent } -ParameterFilter { $Path -eq 'c:\data.xml' }

     Context "Information fetching" {
            
            It "reads configuration file" {
                
                $configuration = Get-SmptConfiguration -Path 'c:\data.xml'

                $configuration.Server | Should Be 'localhost'
                $configuration.Port | Should Be 25
                $configuration.To | Should Be 'admin@support.com'
            }
        }

      Context "Sending mail" {
            
            It "builds content and sends mail - from pipeline" {
                Mock Send-Mail

                'ABC','123' | Out-ErrorEventMail -ConfigurationFilePath 'c:\data.xml'

                Assert-MockCalled Send-Mail -Exactly 1 -Scope It -ParameterFilter { ($Content -like "*ABC*") -and ($Content -like "*123*" ) }
            }

            It "builds content and sends mail - from input object" {
                Mock Send-Mail

                Out-ErrorEventMail -InputObject @('ABC','123') -ConfigurationFilePath 'c:\data.xml'

                Assert-MockCalled Send-Mail -Exactly 1 -Scope It -ParameterFilter { ($Content -like "*ABC*") -and ($Content -like "*123*" ) }
            }
        }
    }
}

Describe -Tags ('Unit', 'Acceptance') "$module Mail Tests" {

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
                    $file = 'c:\data\applications.json'

                    Mock Get-Content { $jsonContent } -ParameterFilter { $Path -eq $file }

                    # when
                    $actualApplications = Get-PSWsApplicationsToCheck -ConfigurationFilePath $file

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
                Mock Get-EventsFromLast24h { $systemEvents }  -ParameterFilter { $LogName -eq 'Application' }

                $customEvents = @( [PSCustomObject]@{ At= $testTime.AddHours(-4); Message="Something was wrong" } )
                Mock Get-EventsFromLast24h { $customEvents } -ParameterFilter { $LogName -eq "AppLog" }
        
                # when
                $actualErrors = Search-PSWspApplicationError -Name $appName -RegistryKey $logName
        
                # then
                $actualErrors.Length | Should Be 2 # better assertion would be nice here
                $actualErrors | Where-Object { $_.Message -eq 'Another error' } | Measure-Object | % Count | Should Be 0
            }
        }

        Context "Mail notification" {
              Mock Get-PSWsApplicationsToCheck { 1..2 | ForEach-Object { Write-Output ([PSCustomObject][ordered]@{ Name='A'; RegistryKey='R' })} } -ParameterFilter { $AppConfigurationPath -eq 'c:\data.json' }
              Mock Test-Path { $true }
              Mock Search-PSWspApplicationError { [PSCustomObject][ordered]@{ At='1'; Message='Msg' } } 

            It "sends mail to proper server" {

                Mock Out-ErrorEventMail {} -Verifiable

                Send-MailIfErrors -AppConfigurationPath 'c:\data.json' -SmtpConfigurationPath 'c:\data.xml' -treshold 1

                Assert-MockCalled Out-ErrorEventMail -Exactly 1 -Scope It 
            }

            It "sends mail to proper server - treshold" {
          
                Mock Out-ErrorEventMail {} -Verifiable

                Send-MailIfErrors -AppConfigurationPath 'c:\data.json' -SmtpConfigurationPath 'c:\data.xml' -treshold 3

                Assert-MockCalled Out-ErrorEventMail -Exactly 0 -Scope It 
            }
        
    }

} # InModuleScope script block

# endregion

} # Describe script block