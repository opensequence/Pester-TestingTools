Describe Remove-FunctionsFromScript {
    $ScriptPath = (get-item (Split-Path $script:MyInvocation.MyCommand.Path))

    #Dotsource in the Powershell Script
    . "$($ScriptPath.parent.FullName)\TestingTools.ps1"

    Context "Script Containing 2 Standard functions" {

        #Mocks

        #Assert
        #Add Parameters and call function
        $Parameters = @{
            path    = "$($ScriptPath.FullName)\Resources\FakeScript-2Functions.ps1"
            Verbose = $true
        }
        #Read in Original file for comparison
        [System.Collections.Generic.List[string]]$original = [System.IO.File]::ReadAllLines($Parameters.path)

        #Strip functions from List File
        [System.Collections.Generic.List[String]]$result = Remove-FunctionsFromScript @Parameters

        It "Result Should Not be Null" {
            $result | Should -Not -BeNullOrEmpty
        }

        It "Should Not Contain any Functions" {
            $result.where( { $_ -Like "*function *" }) | Should -Be $null
        }

        It "Result Should Be Shorter than Original Length" {
            $result.Count | Should -BeLessThan $original.Count
        }


    }

}

Describe Copy-FunctionsFromScript {
    $ScriptPath = (get-item (Split-Path $script:MyInvocation.MyCommand.Path))

    #Dotsource in the Powershell Script
    . "$($ScriptPath.parent.FullName)\TestingTools.ps1"

    Context "Script Containing 2 Standard functions" {

        #Mocks

        #Assert
        #Add Parameters and call function
        $testPath = Convert-Path TestDrive:
        $Parameters = @{
            path    = "$($ScriptPath.FullName)\Resources\FakeScript-2Functions.ps1"
            NewPath = "$($testPath)\FakeScript-Just2Functions.ps1"
            Verbose = $true
        }
        #Copy functions from List File
        Copy-FunctionsFromScript @Parameters

        #Read in New file for comparison
        [System.Collections.Generic.List[string]]$newFile = [System.IO.File]::ReadAllLines($Parameters.NewPath)

        It "Dot Sourcing the File Should not Throw" {
            { . "TestDrive:\FakeScript-Just2Functions.ps1" } | Should -Not -Throw
        }

        It "Should Contain 2 Standard PowerShell Functions" {
            $newFile.where( { $_ -Like "*function *" }).Count | Should -Be 2
        }

    }

    Context "Script Containing 2 Standard functions & 1 Class with Methods" {

        #Mocks

        #Assert
        #Add Parameters and call function
        $testPath = Convert-Path TestDrive:
        $Parameters = @{
            path    = "$($ScriptPath.FullName)\Resources\FakeScript-2FunctionsWithClassMethod.ps1"
            NewPath = "$($testPath)\FakeScript-Just2Functions.ps1"
            Verbose = $true
        }
        #Copy functions from List File
        Copy-FunctionsFromScript @Parameters

        #Read in New file for comparison
        [System.Collections.Generic.List[string]]$newFile = [System.IO.File]::ReadAllLines($Parameters.NewPath)

        It "Dot Sourcing the File Should not Throw" {
            { . "TestDrive:\FakeScript-Just2Functions.ps1" } | Should -Not -Throw
        }

        It "Should Contain 2 Standard PowerShell Functions" {
            $newFile.where( { $_ -Like "*function *" }).Count | Should -Be 2
        }

        It "Should NOT Contain A Seperated Class Method" {
            $newFile.where( { $_ -Like "SoundHorn ()*" }).Count | Should -Be 0
        }

    }

}