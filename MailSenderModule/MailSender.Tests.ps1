$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'MailSender'
$moduleFile = "$here\$module.psm1"

Get-Module SampleModule | Remove-Module -Force
Import-Module $moduleFile -Force

Describe -Tags ('Unit', 'Acceptance') "$module Tests" {
    
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