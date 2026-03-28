# CMD Encyclopedia — Commands Starting with Y

---

## Overview

There are **no standard built-in Windows CMD commands** that begin with the letter **Y**.

---

## Alternatives and Y-Adjacent Topics

### YES-style Input Automation
When scripts prompt for confirmation, you can automate the "Y" input using pipes or `ECHO`:

```cmd
REM Automatically confirm a prompt
echo Y | format D: /q

REM Confirm a DEL wildcard prompt
echo Y | del /p *.tmp
```

> ⚠️ Use auto-confirmation carefully — always verify what the command will do before automating the response.

---

### YEAR — Working with Year Values in Batch Scripts
While not a command, extracting the year from `%DATE%` is a very common batch technique:

```bat
REM Extract year from %DATE% (depends on locale/format)
REM Format: MM/DD/YYYY
set YEAR=%DATE:~10,4%
set MONTH=%DATE:~4,2%
set DAY=%DATE:~7,2%
echo Today: %YEAR%-%MONTH%-%DAY%

REM Create a dated folder
set DATESTAMP=%YEAR%%MONTH%%DAY%
mkdir Backup_%DATESTAMP%
```

---

## PowerShell Y-Equivalents

```powershell
# Confirm before executing (Y/N prompt)
$answer = Read-Host "Continue? (Y/N)"
if ($answer -eq "Y") { Write-Host "Continuing..." }

# Get current year
(Get-Date).Year

# Create a dated folder
$date = Get-Date -Format "yyyy-MM-dd"
New-Item -ItemType Directory -Path "Backup_$date"

# Yes to all with -Confirm:$false
Remove-Item "C:\Folder" -Recurse -Confirm:$false
```

---

## Top Commands That Start with Y in Other Shells

For reference, "Y" commands in related environments:

| Shell | Command | Description |
|---|---|---|
| PowerShell | (none major with Y) | |
| Bash/Linux | `yes` | Repeatedly outputs "y" (useful for piping to prompts) |
| Python | | |
| Unix | `ypcat`, `ypwhich` | NIS (yellow pages) lookup commands |

---

*Back to: [X.md](X.md) | Next: [Z.md](Z.md)*
