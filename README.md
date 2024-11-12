# PowerShell Logging Module

![PowerShell Logging Module](https://img.shields.io/badge/PowerShell-Module-blue)
![Version](https://img.shields.io/badge/Version-1.5.0-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Overview

The **PowerShell Logging Module** is an object-oriented logging solution for PowerShell scripts. It provides configurable logging with support for multiple log levels, log file formats (Text, JSON, CSV), and automatic log file rotation.

## Features

- Object-oriented design using a `Logger` object.
- Supports log levels: `Debug`, `Info`, `Warning`, `Error`, `Critical`.
- Multiple log formats: `Text`, `JSON`, `CSV`.
- Automatic log file rotation based on file size.
- Customizable date and time formats (`12hr`, `24hr`).
- Uses timestamp-based log file naming for uniqueness.
- Error handling for directory creation and file writing.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/JaySea20/PowerShell-LoggingModule.git
