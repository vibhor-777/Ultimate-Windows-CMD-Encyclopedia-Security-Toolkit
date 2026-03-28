# CMD Encyclopedia — Commands Starting with W

---

## WHERE

### Command Name
`WHERE` — Locate programs matching a pattern

### Syntax
```
WHERE [/Q] [/F] [/R dir] [/T] [$ENV:pattern | pattern]
```
| Switch | Meaning |
|---|---|
| `/Q` | Quiet mode (exit code only, no output) |
| `/F` | Print filenames in quotes |
| `/R dir` | Search recursively from a directory |
| `/T` | Print file size, timestamp, and name |

### Description
**Simple:** Finds the location of a program or file — similar to the Unix `which` command, but more powerful.

**Technical:** `WHERE` searches the directories listed in the `%PATH%` environment variable (and the current directory) for files matching the pattern. It can also search a specific directory tree with `/R`. Unlike `which` (Unix), `WHERE` shows ALL matches (not just the first), which is important when multiple versions of a program exist. Exit code 0 = found; 1 = not found.

### Example Usage
```cmd
REM Find where python.exe is
where python

REM Find where all java installations are
where java

REM Quiet mode (just check if it exists)
where /q git && echo Git is installed || echo Git NOT found

REM Find all .bat files in PATH
where *.bat

REM Search specific directory
where /r C:\Windows *.exe | find "notepad"

REM Show with file size and timestamp
where /t python
```

### Related Commands
`PATH`, `SET`, `DIR`, `ASSOC`, `FTYPE`

---

## WHOAMI

### Command Name
`WHOAMI` — Display current user, group, and privilege information

### Syntax
```
whoami [/upn] [/fqdn] [/logonid] [/user] [/groups] [/claims] [/priv] [/all] [/fo format] [/nh]
```
| Switch | Meaning |
|---|---|
| `/user` | Show current user name and SID |
| `/groups` | Show group memberships |
| `/priv` | Show privileges of current session |
| `/all` | Show user, groups, and privileges |
| `/upn` | Show User Principal Name (domain format) |
| `/logonid` | Show logon session ID |
| `/fo` | Format: TABLE, LIST, CSV |

### Description
**Simple:** Shows who you are currently logged in as, what groups you belong to, and what Windows privileges your session has.

**Technical:** `WHOAMI` queries the current process's access token via `GetTokenInformation` Win32 API. The access token contains: user SID, group SIDs (including special groups like Administrators, INTERACTIVE, Authenticated Users), and privilege list (enabled/disabled). `WHOAMI /PRIV` is essential for security auditing — it shows whether dangerous privileges like `SeDebugPrivilege`, `SeLoadDriverPrivilege`, or `SeTakeOwnershipPrivilege` are present and enabled.

### Example Usage
```cmd
REM Show current username
whoami

REM Show domain\username format
whoami /user

REM Show all group memberships
whoami /groups

REM Show privileges (security audit)
whoami /priv

REM Show everything
whoami /all

REM Check if running as administrator
whoami /groups | find "S-1-16-12288" > nul
if %ERRORLEVEL% equ 0 (echo Elevated - Running as Admin) else (echo NOT elevated)

REM Show User Principal Name (email format, domain-joined)
whoami /upn
```

### Output — /PRIV Example
```
PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== ========
SeShutdownPrivilege           Shut down the system           Disabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeUndockPrivilege             Remove computer from docking   Disabled
SeIncreaseWorkingSetPrivilege Increase a process working set Disabled
```
- **State:** Enabled = currently usable; Disabled = present but must be enabled by the application

### Related Commands
`NET USER`, `NET LOCALGROUP`, `ICACLS`, `RUNAS`, `QUERY USER`

---

## WMIC

### Command Name
`WMIC` — Windows Management Instrumentation Command-line

> ⚠️ **Deprecation Notice:** WMIC is deprecated as of Windows 11 22H2. It still works but may be removed in a future Windows version. Use PowerShell WMI cmdlets as modern equivalents.

### Syntax
```
wmic [global switches] alias [where clause] [verb clause]
```

**Key aliases:**
| Alias | WMI Class | Description |
|---|---|---|
| `process` | Win32_Process | Running processes |
| `service` | Win32_Service | Windows services |
| `useraccount` | Win32_UserAccount | User accounts |
| `os` | Win32_OperatingSystem | OS information |
| `computersystem` | Win32_ComputerSystem | Computer hardware |
| `cpu` | Win32_Processor | CPU information |
| `diskdrive` | Win32_DiskDrive | Physical disks |
| `logicaldisk` | Win32_LogicalDisk | Drive letters |
| `nic` | Win32_NetworkAdapter | Network adapters |
| `startup` | Win32_StartupCommand | Startup programs |
| `product` | Win32_Product | Installed software |
| `bios` | Win32_BIOS | BIOS information |
| `memphysical` | Win32_PhysicalMemory | RAM sticks |
| `netlogin` | Win32_NetworkLoginProfile | Network logon info |

### Description
**Simple:** A powerful command that gives access to hundreds of Windows system properties and management functions from the command line.

**Technical:** WMIC is a command-line interface to the WMI (Windows Management Instrumentation) infrastructure, which provides a CIM (Common Information Model) compliant abstraction layer over Windows system data. WMI queries use WQL (WMI Query Language, similar to SQL). WMIC queries can target local or remote computers, making it valuable for remote administration and auditing.

### Example Usage
```cmd
REM ===== PROCESS MANAGEMENT =====
REM List all running processes
wmic process list brief

REM Get process names and executable paths
wmic process get name,executablepath,processid

REM Kill a process by name
wmic process where name="notepad.exe" delete

REM ===== SYSTEM INFORMATION =====
REM Get OS info
wmic os get caption,version,buildnumber,osarchitecture

REM Get computer model
wmic computersystem get manufacturer,model,name

REM Get BIOS info
wmic bios get serialnumber,version,manufacturer

REM Get CPU info
wmic cpu get name,numberofcores,maxclockspeed

REM Get RAM info
wmic memphysical get capacity,manufacturer,speed

REM ===== DISK INFORMATION =====
REM List logical drives
wmic logicaldisk get deviceid,size,freespace,filesystem,volumename

REM List physical disks
wmic diskdrive get status,model,size,serialnumber

REM ===== SERVICES =====
REM List all services
wmic service list brief

REM List auto-start services
wmic service where startmode="auto" get name,state,startmode

REM ===== SOFTWARE =====
REM List installed programs
wmic product get name,version,vendor

REM ===== NETWORK =====
REM Get network adapter config
wmic nic get name,macaddress,netconnectionstatus

REM Get NIC configuration (IP, DNS, gateway)
wmic nicconfig where IPEnabled=TRUE get IPAddress,DefaultIPGateway,DNSServerSearchOrder

REM ===== USER ACCOUNTS =====
REM List user accounts
wmic useraccount get name,sid,disabled,fullname

REM ===== STARTUP ITEMS =====
REM List startup programs
wmic startup list full

REM ===== EXPORT =====
REM Export to CSV
wmic process list brief /format:csv > processes.csv
wmic logicaldisk get deviceid,size,freespace /format:csv > disks.csv
```

### PowerShell Equivalents
```powershell
# wmic process list brief
Get-Process

# wmic os get caption,version
Get-WmiObject Win32_OperatingSystem | Select Caption, Version
# OR (newer):
Get-CimInstance Win32_OperatingSystem | Select Caption, Version

# wmic diskdrive get status,model
Get-PhysicalDisk

# wmic useraccount get name,disabled
Get-LocalUser

# wmic product get name,version
Get-Package
```

### Related Commands
`SYSTEMINFO`, `TASKLIST`, `NET USER`, `SC`, PowerShell `Get-WmiObject`, `Get-CimInstance`

---

## WUAUCLT

### Command Name
`WUAUCLT` — Windows Update Automatic Update Client

### Syntax
```
wuauclt [/detectnow] [/updatenow] [/reportnow] [/resetauthorization] [/showwindow]
```

> **Note:** `WUAUCLT` is largely superseded by `USOCLIENT.EXE` on Windows 10/11 and Server 2019+. Both are documented here.

### Description
**Simple:** Forces Windows Update to check for updates or start the update process from the command line.

**Technical:** `WUAUCLT.EXE` (Windows Update AutoUpdate Client) is the Windows XP–8.1 / Server 2003–2012 R2 era Windows Update client. On Windows 10/11, the Update Orchestrator Service (`UsoSvc`) managed by `USOCLIENT.EXE` handles updates. `WUAUCLT /detectnow` signals the Windows Update service to immediately check for updates rather than waiting for the scheduled check.

### Example Usage
```cmd
REM Check for updates immediately (Windows 7/8/8.1/Server 2012)
wuauclt /detectnow

REM Force an update check and install
wuauclt /updatenow

REM Show Windows Update dialog
wuauclt /showwindow

REM === MODERN ALTERNATIVE (Windows 10/11) ===
REM Check for updates
usoclient startscan

REM Download updates
usoclient startdownload

REM Install updates
usoclient startinstall

REM Reboot if updates are pending
usoclient restarttoupdate
```

### Related Commands
`SC` (stop/start wuauserv), `SCHTASKS`, PowerShell `Get-WindowsUpdate` (requires PSWindowsUpdate module)

---

*Back to: [V.md](V.md) | Next: [X.md](X.md)*
