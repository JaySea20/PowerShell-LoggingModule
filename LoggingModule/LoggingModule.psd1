@{
    ModuleVersion = '1.3.0'
    Author = 'JaySea20'
    Description = 'A PowerShell module for enhanced logging functionality.'
    RootModule = 'LoggingFunctions.psm1'
    FunctionsToExport = @('Log-Initialize', 'Write-Log')
    CmdletsToExport = @()
    VariablesToExport = @('DevVersion')
    AliasesToExport = @()
}
