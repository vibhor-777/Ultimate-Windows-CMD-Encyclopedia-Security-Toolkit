# Hidden Commands and Power Techniques

Unlock the full potential of the Windows Command Prompt with lesser-known commands, hidden switches, and advanced techniques.

---

## Table of Contents
1. [Lesser-Known But Powerful Commands](#1-lesser-known-but-powerful-commands)
2. [Hidden Switches of Common Commands](#2-hidden-switches-of-common-commands)
3. [CMD Tricks and Shortcuts](#3-cmd-tricks-and-shortcuts)
4. [Environment Variable Tricks](#4-environment-variable-tricks)
5. [Advanced FOR Loop Techniques](#5-advanced-for-loop-techniques)
6. [Batch File Advanced Techniques](#6-batch-file-advanced-techniques)
7. [Top 50 Most Useful Commands](#7-top-50-most-useful-commands)

---

## 1. Lesser-Known But Powerful Commands

### CLIP — Pipe Output to Clipboard

```cmd
REM Copy command output to clipboard
dir | clip
systeminfo | clip
ipconfig /all | clip

REM Copy file contents to clipboard
type readme.txt | clip

REM Copy a list of filenames to clipboard
dir /b *.txt | clip
```
**Why it's great:** Instantly copies any command output so you can paste it into an email, document, or ticket.

---

### MKLINK — Create Symbolic Links and Junctions

```cmd
REM Create a symbolic link (file)
mklink newlink.txt C:\actual\file.txt

REM Create a symbolic link (directory - requires admin)
mklink /d C:\LinkToFolder C:\Actual\Folder

REM Create a junction (like symlink for directories, same volume)
mklink /j C:\JunctionName C:\TargetFolder

REM Create a hard link (two directory entries for same file)
mklink /h hardlink.txt original.txt
```

---

### FORFILES — Process Files Based on Date/Attribute

```cmd
REM List files older than 30 days
forfiles /p "C:\Logs" /s /d -30 /c "cmd /c echo @path @fdate"

REM Delete log files older than 90 days
forfiles /p "C:\Logs" /s /m *.log /d -90 /c "cmd /c del @path"

REM Find large files
forfiles /p "C:\Data" /s /c "cmd /c if @fsize gtr 104857600 echo @path @fsize"
```

---

### OPENFILES — Track Open File Handles

```cmd
REM Enable tracking (requires reboot)
openfiles /local on

REM Show open files (after reboot with tracking enabled)
openfiles /query /v

REM CSV format for analysis
openfiles /query /fo csv
```

---

### ICACLS with Inheritance

```cmd
REM Show inheritance details
icacls "C:\Folder" /t /q

REM Disable inheritance and copy parent permissions
icacls "C:\Folder" /inheritance:d

REM Disable inheritance and remove inherited permissions
icacls "C:\Folder" /inheritance:r

REM Re-enable inheritance
icacls "C:\Folder" /inheritance:e
```

---

### WEVTUTIL — Advanced Event Log Queries

```cmd
REM Get last 10 system errors
wevtutil qe System /q:"*[System[Level=2]]" /c:10 /rd:true /f:text

REM Get failed logon events (Event ID 4625)
wevtutil qe Security /q:"*[System[EventID=4625]]" /c:20 /rd:true /f:text

REM Export events to XML file
wevtutil epl System C:\Logs\system_events.evtx

REM Clear event log (use carefully!)
REM wevtutil cl Application

REM Get log file statistics
wevtutil gl System
```

---

### CERTUTIL — Swiss Army Knife

```cmd
REM Base64 encode a file
certutil -encode input.txt output.b64

REM Base64 decode
certutil -decode input.b64 output.txt

REM Calculate file hash
certutil -hashfile C:\file.exe MD5
certutil -hashfile C:\file.exe SHA256

REM Check certificate
certutil -verify certificate.cer

REM List installed certificates
certutil -store
```

---

### NETSTAT Hidden Power

```cmd
REM Show owning executable for each connection (admin required)
netstat -b

REM Show both IPv4 and IPv6
netstat -ano

REM Refresh every 2 seconds
netstat -ano 2

REM Show protocol statistics
netstat -s -p tcp
netstat -s -p udp
```

---

## 2. Hidden Switches of Common Commands

### DIR Hidden Switches

```cmd
REM /X - Show short (8.3) filenames alongside long names
dir /x

REM /Q - Show owner of files
dir /q

REM /O - Sort output
dir /o:n    REM by name
dir /o:s    REM by size (smallest first)
dir /o:-s   REM by size (largest first)
dir /o:d    REM by date (oldest first)
dir /o:-d   REM by date (newest first)

REM /T - Use specific timestamp field
dir /t:c    REM creation time
dir /t:a    REM last access time
dir /t:w    REM last write time

REM /AL - Show reparse points (symlinks, junctions)
dir /al

REM Combine for most useful output
dir /a:-d /o:-s /q    REM all files, by size desc, with owner
```

---

### TASKLIST Hidden Switches

```cmd
REM /SVC - Map services to processes
tasklist /svc

REM /M - Show loaded modules per process
tasklist /m

REM /M with module name - find processes using a DLL
tasklist /m kernel32.dll

REM Filter by multiple criteria
tasklist /fi "status eq running" /fi "memusage gt 50000"

REM Machine-readable CSV output
tasklist /fo csv /nh

REM Verbose: includes CPU time, window title, username
tasklist /v
```

---

### PING Hidden Switches

```cmd
REM -f : Set "Don't Fragment" bit (for MTU testing)
ping -f -l 1472 gateway_ip

REM -r : Record route (shows hops in the reply, max 9)
ping -r 5 google.com

REM -i : Set TTL (hops before expiry)
ping -i 3 8.8.8.8     REM Will only reach 3 hops

REM -s : Timestamp each ping
ping -s 4 google.com

REM -j : Loose source route (rarely useful today)
REM -k : Strict source route (rarely useful today)

REM Combine flags
ping -n 10 -l 1024 -f -w 500 google.com
```

---

### XCOPY Hidden Switches

```cmd
REM /L : List files that would be copied (dry run!)
xcopy C:\Source D:\Dest /e /l

REM /D : Copy only files newer than target
xcopy C:\Source D:\Dest /d

REM /M : Copy only Archive-flagged files, clear Archive bit
xcopy C:\Source D:\Backup /m /e

REM /N : Use short (8.3) filenames
xcopy C:\Source D:\Dest /n

REM /EXCLUDE : Use an exclusion list file
echo *.tmp > exclusions.txt
echo *.log >> exclusions.txt
xcopy C:\Source D:\Dest /e /exclude:exclusions.txt
```

---

### ROBOCOPY Gems

```cmd
REM /DCOPY:T - Copy directory timestamps (not just files)
robocopy C:\Source D:\Dest /e /dcopy:t

REM /TEE - Output to log AND screen simultaneously
robocopy C:\Source D:\Dest /e /log:copy.log /tee

REM /UNILOG - Unicode log file
robocopy C:\Source D:\Dest /e /unilog:copy.log

REM /BYTES - Print file sizes in bytes in output
robocopy C:\Source D:\Dest /e /bytes

REM /TS - Include source file timestamps in output
robocopy C:\Source D:\Dest /e /ts

REM /FP - Include full file path in output
robocopy C:\Source D:\Dest /e /fp

REM /256 - Allow paths longer than 256 characters
robocopy C:\Source D:\Dest /e /256

REM Mirror without deleting (safer than /MIR for first sync)
robocopy C:\Source D:\Dest /e /xx
```

---

## 3. CMD Tricks and Shortcuts

### Console Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `F1` | Paste previous command one character at a time |
| `F3` | Paste previous command |
| `F7` | Show command history popup |
| `F8` | Cycle through history matching current input |
| `F9` | Select command by history number |
| `↑` / `↓` | Navigate command history |
| `Ctrl+C` | Abort current command |
| `Ctrl+Z` | EOF (end of file input) |
| `Ctrl+L` or `cls` | Clear screen |
| `Ctrl+Break` | Strong cancel |
| `Tab` | Autocomplete file/path |
| `Alt+F4` | Close CMD window |

### Redirection Tricks

```cmd
REM Redirect stdout to file
command > output.txt

REM Append stdout to file
command >> output.txt

REM Redirect stderr only
command 2> errors.txt

REM Redirect both stdout and stderr
command > output.txt 2>&1

REM Discard output completely
command > nul

REM Discard errors only
command 2> nul

REM Pipe through FIND and save
netstat -an | find "ESTABLISHED" > connections.txt

REM Use HERE-document style
(
    echo Line 1
    echo Line 2
    echo Line 3
) > multi.txt
```

### Chaining Commands

```cmd
REM Run second command only if first succeeds
command1 && command2

REM Run second command only if first fails
command1 || command2

REM Always run both commands
command1 & command2

REM Combine all three
mkdir C:\Output && copy *.txt C:\Output && echo Done || echo Something failed
```

### Running Multiple Commands in One Line

```cmd
REM Three commands in sequence
cd C:\Projects & dir & cd..

REM Ping and show result
ping -n 1 8.8.8.8 >nul && echo ONLINE || echo OFFLINE
```

---

## 4. Environment Variable Tricks

### Built-in Dynamic Variables

```cmd
REM Current date components (format varies by locale)
echo %DATE%       REM Full date string
echo %TIME%       REM Current time

REM Random number (0-32767)
echo %RANDOM%

REM System information
echo %COMPUTERNAME%     REM Machine name
echo %USERNAME%         REM Current user
echo %USERPROFILE%      REM User's home folder
echo %APPDATA%          REM AppData\Roaming
echo %LOCALAPPDATA%     REM AppData\Local
echo %TEMP%             REM Temp folder
echo %SYSTEMROOT%       REM Windows folder (usually C:\Windows)
echo %PROGRAMFILES%     REM Program Files
echo %PROGRAMFILES(X86)%  REM Program Files (x86)
echo %WINDIR%           REM Windows folder
echo %PATHEXT%          REM Executable extensions

REM Processor information
echo %PROCESSOR_ARCHITECTURE%   REM AMD64, x86, ARM64
echo %NUMBER_OF_PROCESSORS%     REM CPU core count
```

### Batch File Special Variables

```bat
REM %0 = Script name
REM %1-%9 = Command line arguments
REM %* = All arguments
REM %~f0 = Full path of script
REM %~d0 = Drive letter of script
REM %~p0 = Path of script (without drive)
REM %~n0 = Filename without extension
REM %~x0 = Extension of script
REM %~dp0 = Drive+path (useful for script-relative paths)

REM Example: Get files relative to script location
set "SCRIPT_DIR=%~dp0"
set "CONFIG=%SCRIPT_DIR%config.ini"
set "LOGS=%SCRIPT_DIR%Logs"
```

### String Manipulation

```bat
REM Extract date components (locale-dependent)
set YEAR=%DATE:~10,4%
set MONTH=%DATE:~4,2%
set DAY=%DATE:~7,2%
set TIMESTAMP=%YEAR%%MONTH%%DAY%

REM String replacement
set STR=Hello World
set STR_MODIFIED=%STR:World=CMD%
echo %STR_MODIFIED%   REM Output: Hello CMD

REM Convert to uppercase (via cmd extension)
set STR=hello world
for /f "tokens=* usebackq" %%s in (`powershell "'%STR%'.ToUpper()"`) do set UPPER=%%s

REM String length
set STR=Hello
set /a LEN=0
:LenLoop
if defined STR (
    set /a LEN+=1
    set "STR=%STR:~1%"
    goto :LenLoop
)
echo Length: %LEN%
```

---

## 5. Advanced FOR Loop Techniques

### FOR /F — Parse Command Output

```bat
REM Get the IP address
for /f "tokens=14" %%i in ('ipconfig ^| findstr "IPv4 Address"') do set MY_IP=%%i

REM Get Windows build number
for /f "tokens=3" %%b in ('ver') do set WIN_BUILD=%%b

REM Process each line of a file
for /f "tokens=1,2,3 delims=," %%a in (data.csv) do (
    echo Name: %%a  Value: %%b  Date: %%c
)

REM Skip header line
for /f "skip=1 tokens=*" %%l in (data.txt) do echo %%l

REM Use tab as delimiter
for /f "tokens=1,2 delims=	" %%a in (tabfile.txt) do echo %%a - %%b

REM Parse key=value file
for /f "tokens=1,2 delims==" %%k in (config.ini) do (
    echo Key: %%k  Value: %%v
)
```

### FOR /R — Recursive File Operations

```bat
REM Count all .txt files recursively
set COUNT=0
for /r C:\Documents %%f in (*.txt) do set /a COUNT+=1
echo Total .txt files: %COUNT%

REM Find and rename all .log files to .bak
for /r C:\Logs %%f in (*.log) do ren "%%f" "%%~nf.bak"

REM Copy only files newer than a date
for /r C:\Source %%f in (*.*) do (
    for /f "tokens=1" %%d in ('dir /a:-d "%%f" ^| findstr "%%~nxf"') do (
        REM Process each file
    )
)

REM Process all subdirectories
for /r /d %%d in (*) do echo Directory: %%d
```

### FOR /L — Numeric Ranges

```bat
REM Count from 1 to 10
for /l %%n in (1,1,10) do echo %%n

REM Countdown from 10 to 1
for /l %%n in (10,-1,1) do echo %%n

REM Test 10 IP addresses
for /l %%n in (1,1,10) do (
    ping -n 1 -w 500 192.168.1.%%n > nul
    if !ERRORLEVEL! equ 0 echo 192.168.1.%%n is UP
)
```

---

## 6. Batch File Advanced Techniques

### Creating a Configuration File

```bat
REM Write a config file
(
    echo [Settings]
    echo LogLevel=INFO
    echo MaxRetries=3
    echo Timeout=30
) > config.ini

REM Read from config file
for /f "tokens=1,2 delims==" %%k in (config.ini) do (
    if "%%k"=="LogLevel" set LOG_LEVEL=%%l
    if "%%k"=="Timeout" set TIMEOUT=%%l
)
echo Log Level: %LOG_LEVEL%
echo Timeout: %TIMEOUT%
```

### Progress Indicators

```bat
REM Simple progress counter
set TOTAL=100
for /l %%i in (1,1,%TOTAL%) do (
    set /a PCTS=%%i*100/%TOTAL%
    title Processing: !PCTS!%% complete
    REM Do work here
)
```

### Sending Reports via Blat (if installed)

```bat
REM Email a report (requires Blat SMTP tool)
REM blat report.txt -to admin@company.com -subject "Daily Report" -server smtp.company.com
```

---

## 7. Top 50 Most Useful Commands

| Rank | Command | Purpose |
|------|---------|---------|
| 1 | `ipconfig /all` | Full network configuration |
| 2 | `netstat -ano` | All connections with PIDs |
| 3 | `tasklist /v` | All running processes verbose |
| 4 | `systeminfo` | Complete system information |
| 5 | `whoami /all` | Current user, groups, privileges |
| 6 | `net user` | List local user accounts |
| 7 | `net localgroup Administrators` | Who is an admin? |
| 8 | `sc query type= all state= all` | All services and status |
| 9 | `schtasks /query /fo list` | All scheduled tasks |
| 10 | `reg query "HKLM\...\Run"` | Startup registry items |
| 11 | `chkdsk C:` | Filesystem health check |
| 12 | `wmic diskdrive get status,model` | SMART disk health |
| 13 | `wmic logicaldisk get deviceid,freespace,size` | Disk space |
| 14 | `ping -t 8.8.8.8` | Continuous connectivity test |
| 15 | `tracert google.com` | Network path trace |
| 16 | `nslookup -type=MX domain.com` | DNS MX record lookup |
| 17 | `pathping google.com` | Path trace with packet loss |
| 18 | `arp -a` | ARP cache / local devices |
| 19 | `route print` | Routing table |
| 20 | `ipconfig /flushdns` | Clear DNS cache |
| 21 | `netsh advfirewall show allprofiles` | Firewall status |
| 22 | `netsh wlan show profiles` | Saved WiFi networks |
| 23 | `dir /s /b *.ext` | Find files recursively |
| 24 | `findstr /s /i "text" *.*` | Search file contents |
| 25 | `robocopy C:\Src D:\Dst /mir` | Mirror directories |
| 26 | `xcopy C:\Src D:\Dst /e /h /k` | Copy tree with attributes |
| 27 | `icacls "path"` | View file permissions |
| 28 | `attrib -h -s "C:\*" /s` | Unhide files |
| 29 | `cipher /w:C:\` | Wipe free space |
| 30 | `gpresult /r` | Applied Group Policy |
| 31 | `gpupdate /force` | Force policy refresh |
| 32 | `bcdedit /enum all` | Boot configuration |
| 33 | `wmic process get name,executablepath` | Process paths |
| 34 | `wmic useraccount get name,sid,disabled` | User account details |
| 35 | `wmic bios get serialnumber` | Hardware serial number |
| 36 | `wmic qfe list brief` | Installed hotfixes |
| 37 | `driverquery /si` | Drivers with signature status |
| 38 | `auditpol /get /category:*` | Audit policy settings |
| 39 | `wevtutil qe Security /c:20 /f:text` | Security event log |
| 40 | `query user` | Logged-on users |
| 41 | `shutdown /r /t 0` | Immediate restart |
| 42 | `runas /user:Admin cmd` | Run as different user |
| 43 | `takeown /f "path" /r` | Take file ownership |
| 44 | `compact /c /s:"path"` | NTFS compress folder |
| 45 | `dism /online /cleanup-image /restorehealth` | Repair Windows image |
| 46 | `sfc /scannow` | Repair system files |
| 47 | `netsh int ip reset` | Reset TCP/IP stack |
| 48 | `certutil -hashfile file SHA256` | Calculate file hash |
| 49 | `forfiles /p "path" /d -30 /c "cmd /c echo @path"` | Files older than 30 days |
| 50 | `clip` | Pipe output to clipboard |

---

*Back to: [README](../README.md) | See also: [advanced_admin_commands.md](advanced_admin_commands.md)*
