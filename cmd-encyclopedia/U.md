# CMD Encyclopedia — Commands Starting with U

---

## UNZIP (Note)

### Command Name
`UNZIP` — Extract compressed ZIP archives

> **Note:** There is no native `UNZIP` command in Windows CMD. ZIP extraction capabilities are available through several built-in methods described below.

---

### Built-in ZIP Extraction Options

**Option 1: PowerShell (recommended)**
```cmd
REM Extract a ZIP file using PowerShell (available on Windows 7+)
powershell -command "Expand-Archive -Path 'archive.zip' -DestinationPath 'C:\Extracted' -Force"

REM Or using the older COM method (Windows XP+)
powershell -command "(New-Object -com shell.application).namespace('C:\Extracted').CopyHere((New-Object -com shell.application).namespace('C:\archive.zip').items())"
```

**Option 2: Windows Shell (script approach)**
```bat
@echo off
REM Extract ZIP using Shell.Application COM object
set ZIPFILE=C:\archive.zip
set DESTDIR=C:\Extracted
if not exist "%DESTDIR%" mkdir "%DESTDIR%"
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%ZIPFILE%' -DestinationPath '%DESTDIR%'"
```

**Option 3: Third-party tools (common)**
- `7z.exe` from 7-Zip: `7z x archive.zip -oC:\Extracted`
- `unzip.exe` from GNU tools: `unzip archive.zip -d C:\Extracted`

**Option 4: TAR (Windows 10 1803+)**
```cmd
REM Windows 10+ includes a tar command that handles zip files
tar -xf archive.zip -C C:\Extracted
```

---

### Creating ZIP Archives from CMD

**Using PowerShell:**
```cmd
powershell -command "Compress-Archive -Path 'C:\FolderToZip' -DestinationPath 'archive.zip' -Force"
```

**Using tar (Windows 10+):**
```cmd
tar -czf archive.tar.gz C:\FolderToArchive
```

---

## USERACCOUNT (via WMIC)

### Command Name
`WMIC USERACCOUNT` — Manage user accounts via Windows Management Instrumentation

### Syntax
```
wmic useraccount [where condition] [get property [,property]] [/format:format]
wmic useraccount [where condition] [call method] [parameters]
```

### Description
**Simple:** Query and manage local user accounts through WMI — provides more detail than `NET USER` and supports filtering and scripting.

**Technical:** The `Win32_UserAccount` WMI class represents local and domain user accounts. `WMIC USERACCOUNT` provides structured access to account properties: SID, full name, description, account status (disabled, locked out, password required, etc.), and password policies. Unlike `NET USER`, WMIC output can be formatted as CSV, XML, or table for scripting.

> **Deprecation Note:** WMIC is deprecated in Windows 11 22H2+. Use PowerShell `Get-LocalUser` or `Get-ADUser` as modern alternatives.

### Example Usage
```cmd
REM List all user accounts
wmic useraccount list brief

REM List with full details
wmic useraccount list full

REM Show specific properties for all accounts
wmic useraccount get name,sid,disabled,lockout,passwordrequired

REM Find disabled accounts
wmic useraccount where disabled=true get name,sid

REM Find accounts with "Password Never Expires" set
wmic useraccount where passwordexpires=false get name

REM Get account details for a specific user
wmic useraccount where name="john.smith" get name,fullname,sid,disabled

REM Show accounts that don't require passwords
wmic useraccount where passwordrequired=false get name

REM Export user list to CSV
wmic useraccount get name,sid,fullname,disabled /format:csv > users.csv
```

### Output Explanation
```
AccountType  Caption          Description  Disabled  Domain         FullName    LocalAccount  Name         SID                      Status
512          WORKSTATION\Administrator  Built-in...  FALSE  WORKSTATION  Built-in Administrator  TRUE  Administrator  S-1-5-21-...-500  OK
512          WORKSTATION\John Smith  ...  FALSE  WORKSTATION  John Smith  TRUE  john.smith  S-1-5-21-...-1001  OK
```

**Key fields:**
- **Disabled:** True if account is disabled
- **Lockout:** True if account is locked out
- **SID:** Security Identifier (unique account identifier that persists even if username changes)
- **PasswordRequired:** False if blank password is allowed

### PowerShell Equivalents
```powershell
# List all local users
Get-LocalUser

# Find disabled users
Get-LocalUser | Where-Object Enabled -eq $false

# Get user details
Get-LocalUser -Name "john.smith"

# Domain users (requires ActiveDirectory module)
Get-ADUser -Filter * -Properties *
```

### Related Commands
`NET USER`, `WHOAMI`, `ICACLS`, `RUNAS`, `QUERY USER`

---

*Back to: [T.md](T.md) | Next: [V.md](V.md)*
