Import-Module Pester

Get-Command -Module Pester

Describe "Examples" {
    
    Context "Math should work in PowerShell" {
        
        BeforeEach {
            Write-Host "Doing some setup" -ForegroundColor DarkCyan
        }

        AfterAll {
            Write-Host "Doing some global cleaup" -ForegroundColor DarkCyan
        }

        It "should add 2 and 2" {

            $expected = 4

            $actual = 2 + 2

            $expected | Should Be $actual
   
        }

         It "should throw when div by 0" {

            { 11 / 0 } | Should Throw 
   
        }

         It "should just fail" {

           $null | Should Not BeNullOrEmpty
   
        }
    }
}
