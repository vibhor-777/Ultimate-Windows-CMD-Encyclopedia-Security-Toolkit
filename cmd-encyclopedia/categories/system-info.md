# System Information Commands — Category Guide

A comprehensive guide to gathering system information from the Windows Command Prompt.

---

## Overview

Understanding what is running on a system is fundamental to administration and security. This guide covers all the built-in CMD commands for gathering hardware info, OS details, process lists, service status, and event logs.

---

## 1. Operating System Information

### Quick OS Version

```cmd
REM Display Windows version
ver

REM Detailed OS info
systeminfo | findstr /i "OS Name"
systeminfo | findstr /i "OS Version"
systeminfo | findstr /i "OS Manufacturer"
systeminfo | findstr /i "System Type"

REM Open graphical version info window
winver
```

### Full System Information

```cmd
REM Complete system info dump
systeminfo

REM Export as CSV for analysis
systeminfo /fo csv > system_info.csv

REM Query specific fields
systeminfo | findstr /i "Total Physical Memory"
systeminfo | findstr /i "Available Physical Memory"
systeminfo | findstr /i "Hotfix"
systeminfo | findstr /c:"[KB"
```

**Command:** `SYSTEMINFO` — See [S.md](../S.md) | `VER` — See [V.md](../V.md)

---

## 2. Hardware Information (WMIC)

> **Note:** WMIC is deprecated in Windows 11 22H2+. PowerShell alternatives are provided.

### Computer System

```cmd
REM Manufacturer and model
wmic computersystem get manufacturer,model,name,totalphysicalmemory

REM Full computer system info
wmic computersystem list full
```

### CPU Information

```cmd
REM CPU name, cores, speed
wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed

REM CPU architecture
wmic cpu get caption,architecture
```

### Memory (RAM)

```cmd
REM Total RAM
wmic computersystem get totalphysicalmemory

REM Individual RAM sticks
wmic memphysical get capacity,speed,manufacturer,serialnumber

REM Available memory
wmic os get freephysicalmemory,totalvisiblememorysize
```

### BIOS

```cmd
REM BIOS info (useful for warranty/support)
wmic bios get serialnumber,manufacturer,version,releasedate,smbiosbiosversion
```

### Storage

```cmd
REM Physical disk drives
wmic diskdrive get model,size,status,serialnumber,interfacetype

REM Logical drives (partitions/volumes)
wmic logicaldisk get deviceid,size,freespace,filesystem,volumename,drivetype
```

### PowerShell Equivalents

```powershell
# Computer system
Get-CimInstance Win32_ComputerSystem | Select Manufacturer, Model, TotalPhysicalMemory

# CPU
Get-CimInstance Win32_Processor | Select Name, NumberOfCores, MaxClockSpeed

# RAM sticks
Get-PhysicalMemory

# Disks
Get-PhysicalDisk
Get-Volume
```

---

## 3. Processes and Applications

### List Running Processes

```cmd
REM Basic process list
tasklist

REM Verbose list with memory, window title
tasklist /v

REM CSV format for scripting
tasklist /fo csv

REM Find a specific process
tasklist | find /i "notepad"

REM Check if a process is running
tasklist /fi "imagename eq chrome.exe"

REM Sort by memory usage (pipe to sort)
tasklist /fo csv /nh | sort /+5
```

### Processes and Services

```cmd
REM Show services running inside each svchost.exe
tasklist /svc

REM Show loaded DLLs per process
tasklist /m

REM Find which process has a specific DLL loaded
tasklist /m kernel32.dll
```

### Process Details via WMIC

```cmd
REM Process names and executable paths
wmic process get name,processid,executablepath,commandline

REM Sort by memory
wmic process get name,processid,workingsetsize | sort

REM Find specific process
wmic process where name="notepad.exe" get processid,executablepath

REM List processes from unusual locations
wmic process get name,executablepath | find /i "temp"
wmic process get name,executablepath | find /i "appdata"
```

**Command:** `TASKLIST` — See [T.md](../T.md)

---

## 4. Services

### List Services

```cmd
REM List all running services
net start

REM List ALL services (running and stopped)
sc query type= all state= all

REM List only running services
sc query type= all state= active

REM List stopped/inactive services
sc query type= all state= inactive

REM Get details for a specific service
sc query wuauserv
sc qc wuauserv

REM List via WMIC
wmic service list brief

REM Show auto-start services
wmic service where startmode="auto" get name,state,displayname
```

### Service Status Check

```cmd
REM Check if a critical service is running
sc query "Windows Defender Antivirus Service" | find "RUNNING"
if %ERRORLEVEL% neq 0 echo WARNING: Windows Defender is not running!

REM Check multiple services
for %%s in (wuauserv mpssvc wscsvc) do (
    sc query %%s | find "RUNNING" > nul
    if !ERRORLEVEL! equ 0 (echo %%s: RUNNING) else (echo %%s: STOPPED)
)
```

**Command:** `SC` — See [S.md](../S.md)

---

## 5. User and Identity Information

```cmd
REM Who am I?
whoami

REM Current user's SID and domain
whoami /user

REM Group memberships
whoami /groups

REM Privileges in current session
whoami /priv

REM All of the above
whoami /all

REM Check if elevated (admin)
whoami /groups | find "S-1-16-12288" > nul
if %ERRORLEVEL% equ 0 echo Running elevated (Administrator)
```

**Command:** `WHOAMI` — See [W.md](../W.md)

---

## 6. Driver Information

```cmd
REM List all installed drivers
driverquery

REM Verbose driver details
driverquery /v

REM Check driver signatures
driverquery /si

REM Export driver list as CSV
driverquery /fo csv > drivers.csv

REM Find unsigned drivers
driverquery /si | findstr /i "false"
```

**Command:** `DRIVERQUERY` — See [D.md](../D.md)

---

## 7. Group Policy Information

```cmd
REM Summary of applied policies
gpresult /r

REM Full verbose policy output
gpresult /v

REM Generate HTML report
gpresult /h C:\Reports\gp_report.html /f

REM Computer policy only
gpresult /scope computer /v

REM User policy only
gpresult /scope user /v
```

**Command:** `GPRESULT` — See [G.md](../G.md)

---

## 8. Event Logs

### Viewing Events

```cmd
REM List available logs
wevtutil el

REM Query System log for recent errors (last 50)
wevtutil qe System /c:50 /rd:true /f:text | more

REM Query Application log
wevtutil qe Application /c:50 /rd:true /f:text | more

REM Search for specific Event IDs
wevtutil qe Security /q:"*[System[EventID=4625]]" /f:text | more

REM Common Event IDs:
REM   4624 = Successful logon
REM   4625 = Failed logon
REM   4634 = Logoff
REM   7036 = Service started/stopped
REM   1074 = System shutdown/restart
```

### Creating Custom Events

```cmd
REM Log a script event to Application log
eventcreate /id 100 /l APPLICATION /t INFORMATION /so "MyScript" /d "Script started"
```

**Commands:** `WEVTUTIL`, `EVENTCREATE` — See [E.md](../E.md)

---

## 9. Hotfixes and Updates

```cmd
REM List installed hotfixes
systeminfo | findstr /c:"[KB"

REM Alternative: WMIC
wmic qfe list brief

REM Detailed hotfix info
wmic qfe get hotfixid,installedon,installedby,description

REM Find if a specific KB is installed
wmic qfe where hotfixid="KB5031354" get hotfixid,installedon
```

---

## 10. Startup and Boot Information

```cmd
REM View boot configuration
bcdedit /enum all

REM Check startup programs in registry
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

REM Check startup folder
dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
dir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

REM List scheduled tasks
schtasks /query /fo list | more

REM WMIC startup items
wmic startup list full
```

---

## 11. Comprehensive System Info Script

```bat
@echo off
echo ========================================
echo SYSTEM INFORMATION SUMMARY
echo ========================================
echo.
echo --- OS Information ---
ver
systeminfo | findstr /i "OS Name"
systeminfo | findstr /i "System Type"
systeminfo | findstr /i "Total Physical Memory"
echo.
echo --- Current User ---
whoami /user
echo.
echo --- Computer Name ---
hostname
echo.
echo --- IP Addresses ---
ipconfig | findstr "IPv4"
echo.
echo --- Running Services (count) ---
sc query type= all state= active | find /c "RUNNING"
echo services running
echo.
echo --- Process Count ---
tasklist | find /c /v ""
echo processes running
echo.
```

---

## 12. Quick Reference: System Information Commands

| Information Needed | Command | Notes |
|---|---|---|
| OS version | `ver` or `systeminfo` | |
| Computer model | `wmic computersystem get model` | |
| CPU info | `wmic cpu get name,numberofcores` | |
| RAM info | `wmic computersystem get totalphysicalmemory` | |
| Disk info | `wmic logicaldisk get deviceid,size,freespace` | |
| BIOS serial | `wmic bios get serialnumber` | |
| Running processes | `tasklist /v` | |
| Services | `sc query type= all state= all` | |
| Who am I | `whoami /all` | |
| Drivers | `driverquery /si` | |
| Group Policy | `gpresult /r` | |
| Hotfixes | `wmic qfe list brief` | |
| Startup programs | `wmic startup list full` | |
| Event logs | `wevtutil qe System /c:50 /f:text` | |

---

*Related guides:*
- [user-management.md](user-management.md) — User accounts and permissions
- [disk-operations.md](disk-operations.md) — Disk health and management
- [networking.md](networking.md) — Network configuration
