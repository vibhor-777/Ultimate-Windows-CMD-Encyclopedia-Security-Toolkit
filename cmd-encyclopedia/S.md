# CMD Encyclopedia — Commands Starting with S

---

## SC

### Command Name
`SC` — Service Control — configure and manage Windows services

### Syntax
```
sc [\\server] [command] [service name] [option1] [option2] ...
```
| Command | Meaning |
|---|---|
| `query` | Query service status |
| `start` | Start a service |
| `stop` | Stop a service |
| `config` | Modify service configuration |
| `create` | Create a new service |
| `delete` | Delete a service |
| `qc` | Query service configuration |
| `failure` | Configure failure actions |
| `sdshow` | Show service security descriptor |
| `sdset` | Set service security descriptor |
| `enumdepend` | Show dependent services |

### Description
**Simple:** The command-line tool for managing Windows services — start, stop, query, and configure services.

**Technical:** `SC` communicates with the Service Control Manager (SCM) via named pipe `\\.\pipe\svcctl`. Unlike `NET START/STOP`, SC provides access to the full service configuration including start type, failure actions, service SID, and dependencies. `SC QUERY` returns more detailed status information than `NET START`. Exit codes: 0=success, non-zero=error (check with `net helpmsg <code>`).

### Example Usage
```cmd
REM List all services and their status
sc query type= all state= all

REM Query a specific service
sc query wuauserv

REM Query service configuration
sc qc "Windows Update"

REM Start a service
sc start wuauserv

REM Stop a service
sc stop wuauserv

REM Check if a service exists and is running
sc query "spooler" | find "RUNNING"

REM List all auto-start services
sc query type= all start= auto

REM Change service start type to disabled
sc config wuauserv start= disabled

REM Change back to automatic
sc config wuauserv start= auto

REM Query services on remote machine
sc \\REMOTE-PC query

REM Show services that failed to start
sc query type= all state= inactive
```

### Output Explanation
```
SERVICE_NAME: wuauserv
DISPLAY_NAME: Windows Update
        TYPE               : 20  WIN32_SHARE_PROCESS
        STATE              : 4  RUNNING (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
```

### Related Commands
`NET START`, `NET STOP`, `TASKLIST /SVC`, `DRIVERQUERY`, PowerShell `Get-Service`

---

## SCHTASKS

### Command Name
`SCHTASKS` — Create, delete, query, and modify scheduled tasks

### Syntax
```
schtasks /create /tn taskname /tr command /sc schedule [options]
schtasks /query [/fo format] [/nh] [/v] [/tn taskname]
schtasks /delete /tn taskname [/f]
schtasks /run /tn taskname
schtasks /end /tn taskname
schtasks /change /tn taskname [options]
```

**Schedule types:** `MINUTE`, `HOURLY`, `DAILY`, `WEEKLY`, `MONTHLY`, `ONCE`, `ONSTART`, `ONLOGON`, `ONIDLE`, `ONEVENT`

### Description
**Simple:** Creates and manages scheduled tasks — programs that run automatically at specified times or events.

**Technical:** `SCHTASKS` interfaces with the Task Scheduler service and the XML-based task definition format (Windows Vista+). Tasks are stored as XML files in `C:\Windows\System32\Tasks`. Security: tasks run under a user account or SYSTEM; UAC elevation can be configured. `SCHTASKS` is the replacement for the deprecated `AT` command.

### Example Usage
```cmd
REM List all scheduled tasks
schtasks /query /fo list

REM List in table format
schtasks /query /fo table /nh

REM Query a specific task with verbose info
schtasks /query /tn "Windows Update" /v /fo list

REM Create a daily task
schtasks /create /tn "DailyCleanup" /tr "C:\Scripts\cleanup.bat" /sc daily /st 23:00

REM Create a task that runs at system startup
schtasks /create /tn "StartupScript" /tr "C:\Scripts\startup.bat" /sc onstart /ru SYSTEM

REM Create a weekly task (Monday at 8 AM)
schtasks /create /tn "WeeklyReport" /tr "C:\Scripts\report.bat" /sc weekly /d MON /st 08:00

REM Run a task immediately
schtasks /run /tn "DailyCleanup"

REM Delete a task
schtasks /delete /tn "DailyCleanup" /f
```

### Related Commands
`AT` (deprecated), `SC`, PowerShell `Get-ScheduledTask`, `New-ScheduledTask`

---

## SET

### Command Name
`SET` — Display, set, or remove environment variables

### Syntax
```
SET [variable=[string]]
SET /A expression
SET /P variable=[promptstring]
```
| Mode | Meaning |
|---|---|
| `SET VAR=value` | Set a variable |
| `SET VAR=` | Delete a variable |
| `SET` | Display all variables |
| `SET prefix` | Display variables starting with prefix |
| `SET /A` | Arithmetic operations |
| `SET /P` | Prompt user for input |

### Description
**Simple:** Creates, modifies, deletes, and displays environment variables — the way CMD scripts store and retrieve values.

**Technical:** Environment variables are stored in the process environment block (PEB). `SET` without arguments dumps all variables. Changes made with `SET` are local to the current CMD session. `SETX` makes changes permanent. `SET /A` supports arithmetic (integers only): `+`, `-`, `*`, `/`, `%` (modulo), `<<`, `>>`, `&`, `|`, `^`, `~`, `!`. `SET /P` reads a line from stdin — how batch scripts get user input.

### Example Usage
```cmd
REM Set a variable
set MYVAR=Hello World

REM Use a variable
echo %MYVAR%

REM Delete a variable
set MYVAR=

REM Display all variables
set

REM Display variables starting with "PATH"
set path

REM Arithmetic
set /a RESULT=10 * 5 + 3
echo %RESULT%

REM Modulo
set /a REMAINDER=17 %% 5
echo %REMAINDER%

REM User input
set /p ANSWER=Do you want to continue? (Y/N):
if /i "%ANSWER%"=="Y" echo Continuing...

REM Add to PATH temporarily
set PATH=%PATH%;C:\MyTools
```

### Related Commands
`SETX` (permanent), `SETLOCAL`, `ENDLOCAL`, `ECHO`, `IF`

---

## SETLOCAL

### Command Name
`SETLOCAL` — Begin localisation of environment changes

### Syntax
```
SETLOCAL [ENABLEEXTENSIONS | DISABLEEXTENSIONS] [ENABLEDELAYEDEXPANSION | DISABLEDELAYEDEXPANSION]
```

### Description
**Simple:** Creates a "sandbox" for environment variables — changes made after SETLOCAL are undone when ENDLOCAL is called or the script ends.

**Technical:** See `ENDLOCAL` entry for full technical details. `ENABLEDELAYEDEXPANSION` is the critical flag for FOR loops — it enables `!variable!` syntax for variables that change within a loop iteration. Without it, `%variable%` is evaluated once when the line is parsed (before loop execution), so you see stale values.

### Example Usage
```bat
@echo off
setlocal enabledelayedexpansion

set COUNT=0
for %%f in (*.txt) do (
    set /a COUNT+=1
    echo Processing file !COUNT!: %%f
)

echo Total files processed: !COUNT!
endlocal
```

### Related Commands
`ENDLOCAL`, `SET`, `FOR`

---

## SFC

### Command Name
`SFC` — System File Checker — scan and repair protected Windows system files

### Syntax
```
sfc /scannow
sfc /scanonce
sfc /scanboot
sfc /revert
sfc /purgecache
sfc /cachesize=x
sfc /verifyonly
sfc /scanfile=path
sfc /verifyfile=path
sfc /offbootdir=d:\ /offwindir=d:\windows
```

### Description
**Simple:** Scans Windows system files for corruption and repairs them from a cached copy.

**Technical:** `SFC` (System File Checker) scans all protected Windows system files (~4,000 files) and compares their hashes against a reference stored in `C:\Windows\WinSxS` (the Component Store). Corrupted or modified files are replaced. `SFC` requires the Component Store to be healthy — run `DISM /Online /Cleanup-Image /RestoreHealth` first if SFC keeps failing. Results are logged to `C:\Windows\Logs\CBS\CBS.log`. Requires Administrator.

### Example Usage
```cmd
REM Full system scan and repair (most common use)
sfc /scannow

REM Verify only (don't repair)
sfc /verifyonly

REM Verify a specific file
sfc /verifyfile=C:\Windows\System32\kernel32.dll

REM Scan and repair a specific file
sfc /scanfile=C:\Windows\System32\kernel32.dll

REM Repair offline (from recovery environment)
sfc /scannow /offbootdir=D:\ /offwindir=D:\Windows
```

### Related Commands
`DISM`, `CHKDSK`, `BCDEDIT`

---

## SHUTDOWN

### Command Name
`SHUTDOWN` — Shut down, restart, hibernate, or log off the computer

### Syntax
```
shutdown [/i | /l | /s | /sg | /r | /g | /a | /p | /h | /e | /o] [/hybrid] [/soft] [/fw] [/f] [/m \\computer] [/t xxx] [/d [p|u:]xx:yy] [/c "comment"]
```
| Switch | Meaning |
|---|---|
| `/s` | Shut down |
| `/r` | Restart |
| `/l` | Log off |
| `/h` | Hibernate |
| `/a` | Abort a pending shutdown |
| `/p` | Power off immediately (no timeout) |
| `/f` | Force running applications to close |
| `/t N` | Set timeout in seconds before shutdown |
| `/m \\computer` | Remote shutdown/restart |
| `/c "text"` | Comment to display |
| `/i` | Interactive (show dialog) |

### Description
**Simple:** Initiates or cancels a system shutdown, restart, logoff, or hibernate from the command line.

**Technical:** `SHUTDOWN` calls the `ExitWindowsEx` or `InitiateSystemShutdownEx` Win32 API. Remote shutdown uses the `WMI Win32_OperatingSystem.Win32Shutdown` method or the MSRPC remote registry interface. Requires `SeShutdownPrivilege` locally or appropriate admin rights remotely.

### Example Usage
```cmd
REM Restart immediately
shutdown /r /t 0

REM Shut down in 60 seconds with a message
shutdown /s /t 60 /c "System maintenance. Please save your work."

REM Abort a pending shutdown
shutdown /a

REM Log off
shutdown /l

REM Restart remote computer
shutdown /r /m \\REMOTE-PC /t 0

REM Hibernate
shutdown /h

REM Restart with forced app close
shutdown /r /f /t 0
```

### Common Mistakes
- Forgetting `/f` when remote computers have applications that block shutdown
- Using `/r /t 0` in a script on a remote system without being sure you're connected to the right machine

### Related Commands
`LOGOFF`, `QUERY SESSION`, `TASKKILL`

---

## SORT

### Command Name
`SORT` — Sort input and write to output

### Syntax
```
SORT [/R] [/+n] [/M kilobytes] [/L locale] [/REC recordbytes] [[drive1:][path1]filename1] [/T [drive2:][path2]] [/O [drive3:][path3]filename3]
```
| Switch | Meaning |
|---|---|
| `/R` | Reverse sort |
| `/+N` | Start sort at column N |
| `/O` | Output to file |

### Description
**Simple:** Sorts lines of text alphabetically (or in reverse). Commonly used in pipelines to sort command output.

**Technical:** `SORT` reads from stdin (or a file), sorts lines using the specified locale collation order, and writes to stdout (or a file). Default sort is ascending, case-insensitive. The `/+N` option allows sorting by a specific column offset, useful for sorting tabular output.

### Example Usage
```cmd
REM Sort a file
sort names.txt

REM Sort in reverse
sort /r names.txt

REM Sort output from a command
dir /b | sort

REM Sort and save to file
sort input.txt /o output.txt

REM Sort tasklist by process name
tasklist | sort

REM Sort numerically by column 20
dir | sort /+20
```

### Related Commands
`FIND`, `FINDSTR`, `MORE`

---

## START

### Command Name
`START` — Start a separate window to run a command or program

### Syntax
```
START ["title"] [/D path] [/I] [/MIN] [/MAX] [/SEPARATE | /SHARED] [/ABOVENORMAL | /BELOWNORMAL | /HIGH | /LOW | /NORMAL | /REALTIME] [/WAIT] [/B] [/MACHINE:x86] [command/program] [parameters]
```
| Switch | Meaning |
|---|---|
| `"title"` | Window title (required if command has spaces and no quotes) |
| `/WAIT` | Wait for the launched program to finish |
| `/MIN` | Start minimised |
| `/MAX` | Start maximised |
| `/B` | Don't create a new window (run in background) |
| `/D path` | Start in a different directory |
| `/HIGH` | Run at high CPU priority |

### Description
**Simple:** Launches a program, file, or URL in a new window or process — the CMD equivalent of double-clicking an icon.

**Technical:** `START` uses `ShellExecuteEx` Win32 API, which respects file associations (so `start report.pdf` opens the PDF with the default viewer). Without a command, it opens a new CMD window. With `/B`, no new window is created — useful for background processes in scripts. The title parameter (in quotes) is often required as the first argument when the path contains spaces.

### Example Usage
```cmd
REM Open a new CMD window
start

REM Open a file with default application
start report.pdf
start https://google.com

REM Start a program
start notepad.exe

REM Start and wait for completion
start /wait setup.exe
echo Installation complete.

REM Start minimised
start /min long_running_script.bat

REM Start in a specific directory
start /d "C:\MyProject" cmd.exe

REM Start with high priority
start /high computation.exe
```

### Related Commands
`CALL`, `CMD`, `TASKKILL`, `RUNAS`

---

## SUBST

### Command Name
`SUBST` — Associate a drive letter with a folder path

### Syntax
```
SUBST [drive1: [drive2:]path]
SUBST drive1: /D
```

### Description
**Simple:** Creates a "virtual drive" — makes a folder appear as a drive letter. For example, make `C:\Projects\MyApp` accessible as `P:`.

**Technical:** `SUBST` uses the `DefineDosDevice` Win32 API to create a device substitution in the DOS device namespace. The mapping exists only for the current user session and is lost on reboot unless scripted into startup. Useful for working with long paths or for compatibility with programs that require drive letters rather than UNC paths.

### Example Usage
```cmd
REM Create a virtual drive P: from a folder
subst P: C:\Projects\MyApp

REM List all current substitutions
subst

REM Delete a substitution
subst P: /d

REM Persist across reboots (add to startup script or scheduled task):
subst P: C:\Projects\MyApp
```

### Related Commands
`NET USE`, `PUSHD`, `MKLINK`

---

## SYSTEMINFO

### Command Name
`SYSTEMINFO` — Display detailed system configuration information

### Syntax
```
systeminfo [/s computer] [/u domain\user] [/p password] [/fo {TABLE|LIST|CSV}] [/nh]
```

### Description
**Simple:** Shows comprehensive information about the computer: OS version, install date, CPU, RAM, hotfixes, network adapters, and more — all in one command.

**Technical:** `SYSTEMINFO` collects data from multiple sources: WMI, registry, and Win32 APIs. It is one of the fastest ways to get a complete system snapshot. The `/fo csv` flag enables scripting and parsing. Commonly used in asset inventory, troubleshooting, and security audits. Note: `SYSTEMINFO` makes network calls to enumerate hotfixes and may be slower on systems with many network adapters.

### Example Usage
```cmd
REM Display all system info
systeminfo

REM Get specific info with findstr
systeminfo | findstr /i "OS Name"
systeminfo | findstr /i "Total Physical Memory"
systeminfo | findstr /i "Hotfix"

REM Export as CSV
systeminfo /fo csv > sysinfo.csv

REM Query remote computer
systeminfo /s REMOTE-PC

REM Show just hotfixes installed
systeminfo | findstr /c:"[KB"

REM Full info in list format
systeminfo /fo list
```

### Output Fields
```
Host Name:                 WORKSTATION-01
OS Name:                   Microsoft Windows 11 Pro
OS Version:                10.0.22631 N/A Build 22631
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Member Workstation
System Type:               x64-based PC
Total Physical Memory:     16,384 MB
Available Physical Memory: 8,192 MB
Hotfix(s):                 15 Hotfix(s) Installed.
                           [01]: KB5031354
                           ...
```

### Related Commands
`VER`, `WMIC`, `MSINFO32`, `DXDIAG`, `GPRESULT`

---

*Back to: [R.md](R.md) | Next: [T.md](T.md)*
