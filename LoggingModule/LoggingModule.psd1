# LoggingModule.psd1
# Module manifest for the PowerShell Logging Module

@{
    # General Information
    ModuleVersion        = '1.5.0'  # Updated for object-oriented refactor
    GUID                 = 'd9b6a9b3-5b5d-4c2a-b28f-1f37c1d0e4c4'
    Author               = 'JaySea20'
    CompanyName          = 'JaySea20 Company'
    Copyright            = '(c) 2024 Your Name. All rights reserved.'
    Description          = 'A PowerShell module for advanced logging capabilities using an object-oriented approach.'
    RequiredVersion      = ''

    # Module Details
    RootModule           = 'LoggingFunctions.psm1'
    NestedModules        = @()
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion    = '5.1'
    CLRVersion           = '4.0'
    ProcessorArchitecture = 'Any'

    # Dependencies
    RequiredModules      = @()
    RequiredAssemblies   = @()

    # Functions to Export
    FunctionsToExport    = @('Initialize', 'WriteLog')

    # Variables to Export (Empty since we're encapsulating in an object)
    VariablesToExport    = @()

    # Aliases to Export (None)
    AliasesToExport      = @()

    # Private Data
    PrivateData = @{}

    # Scripts to Process
    ScriptsToProcess     = @()

    # Types to Process (None)
    TypesToProcess       = @()

    # Formats to Process (None)
    FormatsToProcess     = @()

    # Miscellaneous
    AllowClobber         = $true
    PassThru             = $false
}
