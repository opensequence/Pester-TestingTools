# https://github.com/opensequence

#Testing Functions for use when testing Scripts using Pester
#Especially when scripts contain functions within the same file
#Remove-FunctionsFromScript - reads in a script and outputs a List containing all Scripts lines (excluding Functions)
#New-FunctionFromScript - reads in a List of Script lines and wraps it in a function start and end and writes to file.
#Copy-FunctionsFromScript - reads in a script and creates a new file containing just the functions from the source script
function Remove-FunctionsFromScript {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false, Position = 1)]
        [string]
        $path
    )
    #Set the error action preference to stop to handle errors as they occur
    $ErrorActionPreference = "Stop"

    # Build a full path out of relative path
    $path = Resolve-Path $path

    try {
        Write-Verbose "START: Reading In Current File from: $($path)"
        [System.Collections.Generic.List[string]]$fileLines = [System.IO.File]::ReadAllLines($path)
        Write-Verbose "SUCCESS: Reading In Current File from: $($path)"
    } catch {
        Write-Error "ERROR: Reading In Current File from: $($path)"
        Throw
    }


    try {
        Write-Verbose "START: Parsing Functions from: $($path)"
        # Get the AST of the file
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
        # Get only function definition ASTs
        $functionDefinitions = $ast.FindAll( {
                param([System.Management.Automation.Language.Ast] $Ast)
                $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        $offset = 0
        Write-Verbose "$($functionDefinitions.Count) Functions found"
        foreach ($function in $functionDefinitions) {
            Write-Verbose "Removing $($function.Name)"
            #Find Start and End Line Numbers of Function (minus 1 as the list starts from zero)
            #And AST line number starts from 1
            $start = ($function.Extent.StartLineNumber - 1)
            $end = ($function.Extent.EndLineNumber - 1)
            #Add 1 (so the RemoveRange include the last line)
            $count = ($end - $start) + 1
            #Remove All lines from List
            $fileLines.RemoveRange(($start - $offset), $count)
            $offset = $offset + $count
        }
        Write-Verbose "FINISH: Parsing Functions from: $($path)"
    } catch {
        Write-Error "ERROR: Parsing Functions from: $($path)"
        Throw
    }

    return $fileLines

}

function New-FunctionFromScript {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true, Position = 1, ValueFromPipeline)]
        [object]
        $fileLines,
        [parameter(Mandatory = $true, Position = 2)]
        [string]
        $FunctionName,
        [parameter(Mandatory = $true, Position = 3)]
        [string]
        $NewPath
    )
    #Set the error action preference to stop to handle errors as they occur
    $ErrorActionPreference = "Stop"

    try {
        Write-Verbose "START: Clearing Temporary File: $($NewPath )"
        remove-item $NewPath -Force
        Write-Verbose "SUCCESS: Clearing Temporary File: $($NewPath)"
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Verbose "WARNING: Clearing Temporary File: $($NewPath). File not Found."
    } catch {
        Write-Error "ERROR: Clearing Temporary File: $($NewPath )"
        exit
    }

    #Generate a function from the runbook
    Write-Output "Function $($FunctionName) {" | Out-File $NewPath
    foreach ($Line in $fileLines) {
        #Replace Exits with Throws (to allow us to test for them)
        $Line = $Line -ireplace [regex]::Escape("exit "), "Throw "
        #Comment out dot sources (specifiy them in testing)
        $Line = $Line -ireplace [regex]::Escape(". ."), "#. ."
        #Comment out dot sources (specifiy them in testing)
        $Line = $Line -ireplace [regex]::Escape(". "), "#. "
        Write-Output $Line | Out-File $NewPath -Append
    }
    Write-Output "}" | Out-File $NewPath -Append
}

function Copy-FunctionsFromScript {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true, Position = 1)]
        [string]
        $Path,
        [parameter(Mandatory = $false, Position = 2)]
        [string]
        $NewPath
    )
    #Set the error action preference to stop to handle errors as they occur
    $ErrorActionPreference = "Stop"

    # Build a full path out of relative path
    $path = Resolve-Path $path

    try {
        Write-Verbose "START: Clearing Temporary File: $($NewPath )"
        remove-item $NewPath -Force
        Write-Verbose "SUCCESS: Clearing Temporary File: $($NewPath)"
    } catch [System.Management.Automation.ItemNotFoundException] {
        Write-Verbose "WARNING: Clearing Temporary File: $($NewPath). File not Found."
    } catch {
        Write-Error "ERROR: Clearing Temporary File: $($NewPath )"
        Throw
    }
    try {
        Write-Verbose "START: Parsing Functions from: $($path)"
        # Get the AST of the file
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
        # Get only function definition ASTs
        $functionDefinitions = $ast.FindAll( {
                param([System.Management.Automation.Language.Ast] $Ast)
                $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        # Output the functions to a temporary file
        Write-Verbose "$($functionDefinitions.Count) Functions found"
        foreach ($function in $functionDefinitions) {
            Write-Verbose "Writing $($function.Name)"
            Write-Output $function.Extent.Text | Out-File $NewPath -Append
        }
        Write-Verbose "FINISH: Parsing Functions from: $($path)"
    } catch {
        Write-Error "ERROR: Parsing Functions from: $($path)"
        Throw
    }
}

