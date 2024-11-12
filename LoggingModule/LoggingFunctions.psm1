# LoggingFunctions.psm1
# This module defines a `Logger` object for handling logging configuration, log file management, and writing log entries.

# Developer Version
$Logger = [PSCustomObject]@{
    DevVersion         = "1.5.0"  # Updated for object-oriented refactor
    Verbosity          = "Debug"  # Default verbosity level
    LogRootDirectory   = "C:\Logs"  # Default log root directory
    LogFolderName      = "DefaultFolderName"  # Default folder name for logs
    MaxLogFileSizeMB   = 5  # Maximum log file size in MB
    MaxLogFiles        = 5  # Maximum number of log files to keep
    DateTimeFormat     = "24hr"  # Date and time format (12hr, 24hr)
    UseUTC             = $false  # Use UTC time for timestamps
    LogFilePath        = ""  # Path to the current log file
    LogFileType        = "Text"  # Log file format (Text, JSON, CSV)

    # Method: Initialize
    Initialize = {
        param (
            [ValidateSet("Silent", "Minimal", "Normal", "Verbose", "Debug")]
            [string]$Verbosity = "Debug",

            [string]$LogRootDirectory = "C:\Logs",
            [string]$LogFolderName = "",
            [int]$MaxLogFileSizeMB = 5,
            [int]$MaxLogFiles = 5,
            [ValidateSet("12hr", "24hr", "Short", "Long")]
            [string]$DateTimeFormat = "24hr",
            [bool]$UseUTC = $false,
            [ValidateSet("Text", "JSON", "CSV")]
            [string]$LogFileType = "Text"
        )

        # Update Logger properties
        $this.Verbosity = $Verbosity
        $this.LogRootDirectory = $LogRootDirectory
        $this.LogFolderName = if ([string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
            "UnknownLogFolder"
        } else {
            [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
        }
        $this.MaxLogFileSizeMB = $MaxLogFileSizeMB
        $this.MaxLogFiles = $MaxLogFiles
        $this.DateTimeFormat = $DateTimeFormat
        $this.UseUTC = $UseUTC
        $this.LogFileType = $LogFileType

        # Determine log folder path and create if necessary
        $logFolderPath = Join-Path -Path $this.LogRootDirectory -ChildPath $this.LogFolderName
        try {
            if (-not (Test-Path -Path $logFolderPath)) {
                [System.IO.Directory]::CreateDirectory($logFolderPath) | Out-Null
            }
        }
        catch {
            Write-Host "Failed to create log directory: $_" -ForegroundColor Red
            return
        }

        # Set the log file path
        $this.LogFilePath = $this.GetLogFilePath($logFolderPath)
    }

    # Method: GetLogFilePath
    GetLogFilePath = {
        param ([string]$LogFolderPath)

        # Determine base file name and extension
        $baseFileName = $this.LogFolderName
        $extension = switch ($this.LogFileType) {
            "JSON" { ".json" }
            "CSV"  { ".csv" }
            default { ".log" }
        }

        # Generate a unique log file name using timestamp
        $logFileName = "{0}_{1:yyyyMMdd_HHmmss}{2}" -f $baseFileName, (Get-Date), $extension

        # Return the full log file path
        return Join-Path -Path $LogFolderPath -ChildPath $logFileName
    }

    # Method: WriteLog
    WriteLog = {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Message,

            [Parameter(Mandatory = $true)]
            [ValidateSet("Debug", "Info", "Warning", "Error", "Critical")]
            [string]$Level
        )

        # Log level mapping
        $logLevels = @{
            "Debug"    = 1
            "Info"     = 2
            "Warning"  = 3
            "Error"    = 4
            "Critical" = 5
        }

        # Determine the logging threshold based on verbosity
        $threshold = switch ($this.Verbosity) {
            "Silent"  { 6 }
            "Minimal" { 4 }
            "Normal"  { 3 }
            "Verbose" { 2 }
            "Debug"   { 1 }
            default   { 3 }
        }

        # Log the message if it meets the verbosity threshold
        if ($logLevels[$Level] -ge $threshold) {
            # Generate timestamp
            $timestamp = if ($this.UseUTC) {
                (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
            } else {
                Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }

            # Construct log entry based on file type
            $logEntry = switch ($this.LogFileType) {
                "JSON" { @{ Version = $this.DevVersion; Timestamp = $timestamp; Level = $Level; Message = $Message } | ConvertTo-Json -Depth 3 }
                "CSV" {
                    if (-not (Test-Path $this.LogFilePath)) {
                        "Version,Timestamp,Level,Message" | Out-File -FilePath $this.LogFilePath -Append
                    }
                    "$this.DevVersion,$timestamp,$Level,$Message"
                }
                default { "[$this.DevVersion] [$timestamp] [$Level] $Message" }
            }

            # Write the log entry to file and console
            try {
                Add-Content -Path $this.LogFilePath -Value $logEntry
                Write-Host $logEntry
            }
            catch {
                Write-Host "Failed to write to log file: $_" -ForegroundColor Red
            }
        }
    }
}
