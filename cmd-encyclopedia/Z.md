# CMD Encyclopedia — Commands Starting with Z

---

## Overview

There are **no standard built-in Windows CMD commands** that begin with the letter **Z**.

---

## ZIP Compression (No Native Z Command)

Windows has no native `ZIP` or `ZLIB` command in CMD. See [U.md](U.md) for the `UNZIP` section which covers all archive/compression options including the built-in PowerShell alternatives.

---

## Suggested PowerShell Alternatives

The following PowerShell cmdlets cover functionality that might be called "Z-related" in other contexts:

### Archive / Compress
```powershell
# Compress to ZIP
Compress-Archive -Path "C:\MyFolder" -DestinationPath "archive.zip"

# Expand ZIP
Expand-Archive -Path "archive.zip" -DestinationPath "C:\Extracted"

# Append to existing ZIP
Compress-Archive -Path "newfile.txt" -DestinationPath "archive.zip" -Update
```

### Zone Identifier (Download Flag)
Files downloaded from the internet receive a "Zone Identifier" alternate data stream. This is relevant to "Z" because the Zone is labeled with a number:

```cmd
REM View Zone Identifier ADS (alternate data stream)
more < file.exe:Zone.Identifier

REM Output looks like:
REM [ZoneTransfer]
REM ZoneId=3
REM (3 = Internet zone; 0 = local; 1 = intranet; 2 = trusted sites)

REM Remove Zone Identifier (unblock a file)
powershell -command "Unblock-File -Path 'script.bat'"

REM Or delete the ADS directly
more < file.exe:Zone.Identifier  REM view it first
REM To remove: right-click -> Properties -> Unblock, or:
powershell Unblock-File .\script.bat

REM View all files with Zone Identifiers in a folder
dir /r | find "Zone.Identifier"
```

### PowerShell Equivalents for Common Admin Tasks

Since CMD has no Z commands, here are PowerShell alternatives for common tasks this toolkit covers:

```powershell
# Zero out (wipe) free space
cipher /w:C:\   # CMD method (see C.md)

# PowerShell: get disk info
Get-PSDrive -PSProvider FileSystem
Get-Volume

# PowerShell: zero-fill (format with overwrite)
# Use cipher /w from CMD for this task

# PowerShell: check for zombie processes (not responding)
Get-Process | Where-Object { $_.Responding -eq $false }

# PowerShell: zip and encrypt (password protected)
# Requires 7-Zip or similar; PowerShell built-in Compress-Archive doesn't support passwords

# List all PATH entries (zero-in on path issues)
$env:PATH -split ';'

# Zero-width issues: check for BOM in text files
[System.IO.File]::ReadAllBytes("file.txt") | Select-Object -First 3
```

---

## CMD Alphabet Gaps Summary

For reference, the letters with no native CMD commands are:

| Letter | Status |
|---|---|
| J | No standard commands (see J.md) |
| Y | No standard commands (see Y.md) |
| Z | No standard commands (this file) |

All other letters (A through X, W) have at least one significant CMD command documented in this encyclopedia.

---

*Back to: [Y.md](Y.md) | Return to: [Encyclopedia Index](../README.md)*
