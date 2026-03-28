# Advanced Admin Commands — Power Tools Guide

A comprehensive reference for power users and system administrators covering advanced CMD and related tools.

---

## Table of Contents
1. [Advanced WMIC Commands](#1-advanced-wmic-commands)
2. [Advanced NETSH Commands](#2-advanced-netsh-commands)
3. [Advanced DISKPART Commands](#3-advanced-diskpart-commands)
4. [BCDEdit Usage](#4-bcdedit-usage)
5. [Advanced SC (Service Control)](#5-advanced-sc-service-control)
6. [Advanced REG Commands](#6-advanced-reg-commands)
7. [Scripting Techniques](#7-scripting-techniques)
8. [Running Scripts with Elevated Privileges](#8-running-scripts-with-elevated-privileges)

---

## 1. Advanced WMIC Commands

> **Note:** WMIC is deprecated in Windows 11 22H2+. PowerShell equivalents are provided.

### System Inventory Commands

```cmd
REM Full system hardware profile
wmic csproduct get name,identifyingnumber,uuid,vendor,version

REM Get system uptime (last boot time)
wmic os get lastbootuptime

REM Get system uptime in human form
for /f %%t in ('wmic os get lastbootuptime ^| findstr /v "Last"') do (
    echo Boot time: %%t
)

REM Find all installed hotfixes sorted by date
wmic qfe get hotfixid,installedon,description /format:csv | sort

REM Get memory details per stick
wmic memorychip get capacity,manufacturer,memorytype,speed,serialnumber

REM Get CPU temperature (may not work on all systems)
wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature
REM (Divide result by 10 and subtract 273.15 for Celsius)
```

### Process Management

```cmd
REM Kill a process by name (all instances)
wmic process where name="notepad.exe" delete

REM Kill processes consuming over 500MB RAM
wmic process where "workingsetsize > 524288000" get name,processid,workingsetsize

REM Get process command lines (useful for malware analysis)
wmic process get name,processid,commandline | more

REM Find processes running from temp directories
wmic process get name,executablepath | findstr /i "temp\|appdata\|downloads"

REM Get processes and their parent PIDs
wmic process get name,processid,parentprocessid | sort
```

### Network via WMIC

```cmd
REM Get all network adapters with IP
wmic nicconfig where IPEnabled=TRUE get Description,IPAddress,DefaultIPGateway,MACAddress,DNSServerSearchOrder

REM Get wireless adapter info
wmic nic where "Name like '%wireless%' or Name like '%wi-fi%'" get Name,MACAddress,NetConnectionStatus

REM Get network login profiles
wmic netlogin get name,lastlogon,logonserver,numberofrequests
```

### PowerShell Equivalents

```powershell
# System info
Get-CimInstance Win32_ComputerSystemProduct | Select Name, IdentifyingNumber, UUID

# Memory
Get-CimInstance Win32_PhysicalMemory | Select Capacity, Manufacturer, Speed

# Process with high memory
Get-Process | Where-Object WorkingSet -gt 500MB | Sort-Object WorkingSet -Descending

# Network adapters
Get-NetAdapter | Where-Object Status -eq Up | Select Name, MacAddress, LinkSpeed
Get-NetIPConfiguration
```

---

## 2. Advanced NETSH Commands

### Wireless Network Management

```cmd
REM Export all Wi-Fi profiles (backup)
netsh wlan export profile folder=C:\WiFiBackup

REM Import a Wi-Fi profile
netsh wlan add profile filename=C:\WiFiBackup\profile.xml

REM Show detailed Wi-Fi information
netsh wlan show interfaces

REM Show available networks with signal strength
netsh wlan show networks mode=bssid

REM Set a profile to connect automatically
netsh wlan set profileparameter name="MyNetwork" connectionmode=auto

REM Block Wi-Fi (emergency only)
netsh interface set interface "Wi-Fi" disable

REM Re-enable Wi-Fi
netsh interface set interface "Wi-Fi" enable
```

### Advanced Firewall Rules

```cmd
REM Show all firewall rules in detail
netsh advfirewall firewall show rule name=all verbose

REM Add inbound rule for a specific application
netsh advfirewall firewall add rule name="Allow App" program="C:\App\app.exe" action=allow dir=in

REM Add rule for a port range
netsh advfirewall firewall add rule name="Port Range 8000-9000" protocol=TCP dir=in localport=8000-9000 action=allow

REM Block outbound traffic to a specific IP
netsh advfirewall firewall add rule name="Block Bad IP" dir=out remoteip=1.2.3.4 action=block

REM Export firewall policy to file
netsh advfirewall export C:\Backup\firewall_policy.wfw

REM Restore firewall policy from file
netsh advfirewall import C:\Backup\firewall_policy.wfw

REM Reset firewall to defaults (nuclear option!)
netsh advfirewall reset
```

### IP Configuration and Troubleshooting

```cmd
REM Show all IP statistics
netsh interface ip show stats

REM Show TCP connections
netsh interface tcp show global

REM Enable/disable TCP auto-tuning
netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set global autotuninglevel=disabled

REM Show DNS client configuration
netsh dns show config

REM Enable DHCP on an interface
netsh interface ip set address "Ethernet" dhcp

REM Configure multiple IP addresses on one interface
netsh interface ip add address "Ethernet" 192.168.1.101 255.255.255.0

REM Remove secondary IP
netsh interface ip delete address "Ethernet" 192.168.1.101

REM Network trace capture (requires elevation)
netsh trace start capture=yes tracefile=C:\Traces\capture.etl
REM ... reproduce the issue ...
netsh trace stop
```

---

## 3. Advanced DISKPART Commands

> ⚠️ DISKPART commands can permanently destroy data. Always verify disk and volume numbers before executing.

### Information Gathering (Safe)

```cmd
REM Launch DISKPART
diskpart

REM List all disks with health status
DISKPART> list disk

REM List all volumes
DISKPART> list volume

REM Select and get detailed disk info
DISKPART> select disk 0
DISKPART> detail disk

REM List virtual disks (VHD)
DISKPART> list vdisk

REM Exit
DISKPART> exit
```

### Volume Operations

```cmd
REM Assign or change a drive letter
DISKPART> list volume
DISKPART> select volume 3
DISKPART> assign letter=E

REM Remove a drive letter
DISKPART> remove letter=E

REM Mount a volume to an empty NTFS folder (no drive letter)
DISKPART> assign mount=C:\MountPoint

REM Extend a volume (requires contiguous unallocated space)
DISKPART> select volume 2
DISKPART> extend
DISKPART> extend size=10240    REM extend by 10 GB (size in MB)

REM Shrink a volume
DISKPART> shrink desired=10240    REM shrink by 10 GB

REM Set partition as active (for boot partition)
DISKPART> select partition 1
DISKPART> active
```

### VHD (Virtual Hard Disk) Operations

```cmd
REM Create a VHD
DISKPART> create vdisk file=C:\VHDs\disk.vhd maximum=51200

REM Attach (mount) a VHD
DISKPART> select vdisk file=C:\VHDs\disk.vhd
DISKPART> attach vdisk

REM Detach (unmount) a VHD
DISKPART> detach vdisk

REM Create a VHD with automated script
(
    echo create vdisk file=C:\VHDs\backup.vhd maximum=102400 type=expandable
    echo select vdisk file=C:\VHDs\backup.vhd
    echo attach vdisk
    echo create partition primary
    echo format fs=ntfs label=Backup quick
    echo assign letter=V
    echo exit
) | diskpart
```

---

## 4. BCDEdit Usage

> ⚠️ BCDEdit changes can prevent Windows from booting. Back up the BCD before making changes.

### Viewing Boot Configuration

```cmd
REM View all boot entries
bcdedit /enum all

REM View only active boot entries
bcdedit /enum active

REM View Windows Boot Manager entry
bcdedit /enum {bootmgr}

REM Export BCD (backup before making changes)
bcdedit /export C:\Backup\bcd_backup
```

### Common BCDEdit Tasks

```cmd
REM Change boot menu timeout (seconds)
bcdedit /timeout 15

REM Set default boot entry
bcdedit /default {identifier}

REM Add description to an entry
bcdedit /set {current} description "Windows 11 Pro - Production"

REM Enable boot debugging
bcdedit /debug {current} on

REM Disable boot debugging
bcdedit /debug {current} off

REM Enable safe boot (minimal)
bcdedit /set {current} safeboot minimal

REM Disable safe boot (return to normal)
bcdedit /deletevalue {current} safeboot

REM Enable test signing (for unsigned drivers - dev use)
bcdedit /set testsigning on

REM Disable test signing (re-enable driver signature enforcement)
bcdedit /set testsigning off
```

### Restoring BCD

```cmd
REM Restore from backup
bcdedit /import C:\Backup\bcd_backup

REM Nuclear reset (from Windows installation media recovery)
REM bootrec /fixmbr
REM bootrec /fixboot
REM bootrec /rebuildbcd
```

---

## 5. Advanced SC (Service Control)

### Service Configuration

```cmd
REM View full service configuration
sc qc "Windows Update"

REM Change service start type
sc config wuauserv start= auto
sc config wuauserv start= demand
sc config wuauserv start= disabled

REM Configure failure actions (restart on failure)
sc failure wuauserv reset= 86400 actions= restart/60000/restart/60000/restart/60000

REM Show current failure actions
sc qfailure wuauserv

REM Add a description to a service
sc description wuauserv "Downloads and installs Windows updates"

REM Change service account
sc config myservice obj= "DOMAIN\serviceaccount" password= "P@ssw0rd"

REM Change service to run as LOCAL SYSTEM
sc config myservice obj= LocalSystem

REM Create a service entry (for an existing executable)
sc create MyService binpath= "C:\Tools\myservice.exe" start= auto displayname= "My Custom Service"

REM Delete a service entry (does not delete the binary)
sc delete MyService
```

### Service Dependencies

```cmd
REM Show what a service depends on
sc enumdepend "Windows Update"

REM Show services that depend on a specific service
sc enumdepend Dhcp

REM Set service dependencies
sc config myservice depend= Tcpip/Dhcp
```

### Remote Service Management

```cmd
REM Query service on remote machine
sc \\REMOTE-PC query wuauserv

REM Start service on remote machine
sc \\REMOTE-PC start wuauserv

REM Stop service on remote machine
sc \\REMOTE-PC stop wuauserv
```

---

## 6. Advanced REG Commands

### Advanced Registry Queries

```cmd
REM Search entire registry for a string (slow but comprehensive)
reg query HKLM /f "SearchString" /s

REM Search in keys only (faster)
reg query HKLM /f "SearchString" /s /k

REM Search in values only
reg query HKLM /f "SearchString" /s /d

REM Search in 32-bit registry view (on 64-bit Windows)
reg query HKLM\SOFTWARE /f "SearchString" /s /reg:32

REM Export with subtree
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" currentversion.reg

REM Query multiple values
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild
```

### Registry in Batch Scripts

```bat
REM Read a registry value into a variable
for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set OS_NAME=%%v
echo Operating System: %OS_NAME%

REM Check if a registry key exists
reg query "HKLM\SOFTWARE\MyApp" 2>nul
if %ERRORLEVEL% equ 0 (
    echo MyApp is installed
) else (
    echo MyApp is NOT installed
)

REM Compare two registry trees
reg compare "HKLM\SOFTWARE\MyApp" "HKLM\SOFTWARE\MyApp.backup" /s
```

---

## 7. Scripting Techniques

### Error Handling

```bat
@echo off
REM Run a command and capture exit code
some_command.exe argument
set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% neq 0 (
    echo ERROR: Command failed with exit code %EXIT_CODE%
    echo %DATE% %TIME% - ERROR %EXIT_CODE% in some_command >> error.log
    exit /b %EXIT_CODE%
)
echo Command succeeded.
```

### Advanced Variable Techniques

```bat
REM Substring extraction
set FULL_STRING=Hello World 2024
set FIRST_5=%FULL_STRING:~0,5%        REM "Hello"
set LAST_4=%FULL_STRING:~-4%          REM "2024"
set MIDDLE=%FULL_STRING:~6,5%         REM "World"

REM String replacement
set PATH_WITH_SPACES=C:\My Folder\file.txt
set PATH_ESCAPED=%PATH_WITH_SPACES: =^%20%

REM Count files using FOR /F and find
set FILE_COUNT=0
for /f %%n in ('dir /b /a:-d *.txt 2^>nul ^| find /c /v ""') do set FILE_COUNT=%%n
echo Found %FILE_COUNT% .txt files

REM Delayed expansion for loop variables
setlocal enabledelayedexpansion
set SUM=0
for %%n in (1 2 3 4 5) do set /a SUM=!SUM!+%%n
echo Sum: !SUM!
endlocal
```

### FOR Loop Patterns

```bat
REM Iterate over files
for %%f in (*.txt) do echo Processing: %%f

REM Iterate recursively
for /r C:\Source %%f in (*.txt) do echo Found: %%f

REM Iterate over lines in a file
for /f "tokens=*" %%l in (input.txt) do echo Line: %%l

REM Iterate over command output
for /f "tokens=1,2,3" %%a in ('ipconfig ^| findstr "IPv4"') do echo IP: %%c

REM Iterate over a number range
for /l %%n in (1,1,10) do echo Number: %%n

REM Iterate over directories
for /d %%d in (*) do echo Directory: %%d
```

### Functions via CALL and GOTO

```bat
@echo off
REM Call a "function" (subroutine)
call :LogMessage "Script started"
call :CheckDisk C:
call :LogMessage "Script complete"
goto :End

:LogMessage
echo [%DATE% %TIME%] %~1
goto :EOF

:CheckDisk
echo Checking disk %~1...
chkdsk %~1 > nul 2>&1
if %ERRORLEVEL% equ 0 (
    call :LogMessage "Disk %~1 OK"
) else (
    call :LogMessage "Disk %~1 has errors"
)
goto :EOF

:End
echo Done.
```

---

## 8. Running Scripts with Elevated Privileges

### Self-Elevation Pattern

```bat
@echo off
REM Check if already elevated
net session > nul 2>&1
if %ERRORLEVEL% equ 0 goto :AlreadyElevated

REM Not elevated - re-launch with UAC prompt
echo Requesting administrator privileges...
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:AlreadyElevated
echo Running with Administrator privileges.
REM Continue with the rest of the script
```

### Running a Specific Command Elevated

```cmd
REM Run a single command as admin via PowerShell
powershell -Command "Start-Process cmd -ArgumentList '/c command-here' -Verb RunAs -Wait"

REM Run a bat file as admin silently
powershell -Command "Start-Process 'script.bat' -Verb RunAs -WindowStyle Hidden -Wait"
```

### Scheduled Task for Elevated Execution

```cmd
REM Create a scheduled task that runs elevated without UAC prompt
schtasks /create /tn "ElevatedTask" /tr "C:\Scripts\myscript.bat" /sc once /st 00:00 /ru SYSTEM /f

REM Run it immediately (elevated, no UAC)
schtasks /run /tn "ElevatedTask"

REM Delete when done
schtasks /delete /tn "ElevatedTask" /f
```

---

*Back to: [README](../README.md) | See also: [hidden_commands.md](hidden_commands.md)*
