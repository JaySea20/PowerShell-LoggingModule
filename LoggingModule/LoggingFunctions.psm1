# LoggingFunctions.psm1
$Global:DevVersion = "1.3.0"  # Updated for module conversion

# Global configuration variables
$Global:Verbosity = "Normal"
$Global:LogRootDirectory = ".\Logs"
$Global:LogFolderName = ""
$Global:MaxLogFileSizeMB = 5
$Global:MaxLogFiles = 5
$Global:DateTimeFormat = "24hr"
$Global:UseUTC = $false
$Global:LogFilePath = ""
$Global:LogFileType = "Text"

# Initialize logging function
function Log-Initialize {
    param (
        [ValidateSet("Silent", "Minimal", "Normal", "Verbose", "Debug")]
        [string]$Verbosity = "Normal",

        [string]$LogRootDirectory = ".\Logs",
        [string]$LogFolderName = "",
        [int]$MaxLogFileSizeMB = 5,
        [int]$MaxLogFiles = 5,
        [ValidateSet("12hr", "24hr", "Short", "Long")]
        [string]$DateTimeFormat = "24hr",
        [bool]$UseUTC = $false,
        [ValidateSet("Text", "JSON", "CSV")]
        [string]$LogFileType = "Text"
    )

    Write-Host "Initializing Logging (Dev Version: $Global:DevVersion)" -ForegroundColor Cyan

    $Global:Verbosity = $Verbosity
    $Global:LogRootDirectory = $LogRootDirectory
    $Global:LogFolderName = if ($LogFolderName -eq "") {
        [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
    } else {
        $LogFolderName
    }
    $Global:MaxLogFileSizeMB = $MaxLogFileSizeMB
    $Global:MaxLogFiles = $MaxLogFiles
    $Global:DateTimeFormat = $DateTimeFormat
    $Global:UseUTC = $UseUTC
    $Global:LogFileType = $LogFileType

    $logFolderPath = Join-Path -Path $Global:LogRootDirectory -ChildPath $Global:LogFolderName
    if (-not (Test-Path -Path $logFolderPath)) {
        New-Item -Path $logFolderPath -ItemType Directory | Out-Null
    }

    $Global:LogFilePath = Get-LogFilePath -LogFolderPath $logFolderPath
}

# Get log file path function
function Get-LogFilePath {
    param ([string]$LogFolderPath)

    $baseFileName = $Global:LogFolderName
    $extension = switch ($Global:LogFileType) {
        "JSON" { ".json" }
        "CSV"  { ".csv" }
        default { ".log" }
    }
    $revision = 1

    # Loop to find the next available log file name
    while (Test-Path -Path (Join-Path -Path $LogFolderPath -ChildPath ("{0}_{1}{2}" -f $baseFileName, ($revision.ToString()).PadLeft(3, '0'), $extension))) {
        $revision++
    }

    # Construct the log file path with the padded revision number
    $logFileName = "{0}_{1}{2}" -f $baseFileName, ($revision.ToString()).PadLeft(3, '0'), $extension
    return Join-Path -Path $LogFolderPath -ChildPath $logFileName
}


# Main logging function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Debug", "Info", "Warning", "Error", "Critical")]
        [string]$Level
    )

    $logLevels = @{
        "Debug"    = 1
        "Info"     = 2
        "Warning"  = 3
        "Error"    = 4
        "Critical" = 5
    }

    $threshold = switch ($Global:Verbosity) {
        "Silent"  { 6 }
        "Minimal" { 4 }
        "Normal"  { 3 }
        "Verbose" { 2 }
        "Debug"   { 1 }
        default   { 3 }
    }

    if ($logLevels[$Level] -ge $threshold) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = switch ($Global:LogFileType) {
            "JSON" { @{ Version = $Global:DevVersion; Timestamp = $timestamp; Level = $Level; Message = $Message } | ConvertTo-Json -Compress }
            "CSV"  { "$Global:DevVersion,$timestamp,$Level,$Message" }
            default { "[$Global:DevVersion] [$timestamp] [$Level] $Message" }
        }

        Add-Content -Path $Global:LogFilePath -Value $logEntry
        Write-Host $logEntry
    }
}
