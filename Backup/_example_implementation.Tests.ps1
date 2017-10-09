
. ((Split-Path -Parent $PSScriptRoot) -replace '.Tests','')

Describe "Example test" {
    
    Context "JSON deployed application settings" {

        It "should read well-formatted json file" {

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

            Mock Test-Path { $true } -ParameterFilter { $Path -eq 'c:\data.json' }
            Mock Get-Content { $jsonContent } -ParameterFilter { $Path -eq 'c:\data.json' }

            $configuration = Get-DeployedApplicationsInformation -ConfigFilePath 'c:\data.json'

            $configuration.Length | Should Be  2
            # and another assertsions here...
        }
    }
}
