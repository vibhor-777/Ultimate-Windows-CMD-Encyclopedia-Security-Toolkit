# Real-World Use Cases — CMD Solutions for Common IT Problems

This guide presents 10 common IT scenarios with step-by-step CMD solutions, explanations, and PowerShell alternatives.

---

## Scenario 1: Troubleshooting a Slow Internet Connection

### Problem Statement
A user reports their internet is slow or intermittent. You need to diagnose whether the issue is local (their machine/router) or upstream (ISP or internet).

### CMD Solution (Step by Step)

**Step 1: Verify your IP address and gateway**
```cmd
ipconfig /all
```
*Check: Do you have an IP address? Is the gateway correct? Is DNS configured?*

**Step 2: Test your local TCP/IP stack**
```cmd
ping 127.0.0.1
```
*If this fails, TCP/IP is broken on the machine itself. Reinstall TCP/IP or run `netsh int ip reset`*

**Step 3: Test your gateway/router**
```cmd
ping 192.168.1.1 -n 20
```
*Replace with your actual gateway IP. High packet loss or high RTT indicates a local network problem.*

**Step 4: Test internet connectivity by IP (bypasses DNS)**
```cmd
ping 8.8.8.8 -n 20
```
*If gateway works but this fails, the problem is between your router and the internet (ISP issue).*

**Step 5: Test DNS resolution**
```cmd
nslookup google.com
nslookup google.com 8.8.8.8
```
*If 8.8.8.8 works but your DNS server fails, switch DNS servers.*

**Step 6: Trace the route to find the slow hop**
```cmd
pathping google.com
```
*Look for hops with high packet loss percentage — that's where the problem is.*

**Step 7: Flush DNS cache (fixes some slow browsing)**
```cmd
ipconfig /flushdns
```

### Explanation
Slow internet can have many causes. This systematic approach isolates the problem layer by layer: local stack → local network → ISP → internet. `PATHPING` is the key diagnostic tool because it shows you exactly WHICH router hop has issues.

### PowerShell Alternative
```powershell
Test-NetConnection -ComputerName google.com -DiagnoseLevels DetailedAndSummary
Test-Connection 8.8.8.8 -Count 20 | Select-Object Address, Latency, Status
```

---

## Scenario 2: Finding Which Process Is Using a Port

### Problem Statement
An application can't start because "port 8080 is already in use." You need to find and optionally stop the process occupying that port.

### CMD Solution (Step by Step)

**Step 1: Find what's listening on port 8080**
```cmd
netstat -ano | find ":8080"
```
*Note the PID number in the last column (e.g., 1234)*

**Step 2: Identify the process by PID**
```cmd
tasklist /fi "pid eq 1234"
```

**Step 3: Get more details about the process**
```cmd
wmic process where processid=1234 get name,executablepath,commandline
```

**Step 4 (Optional): Stop the process**
```cmd
REM Graceful stop:
taskkill /pid 1234

REM Force stop:
taskkill /f /pid 1234
```

**One-liner approach:**
```cmd
for /f "tokens=5" %p in ('netstat -ano ^| find ":8080 "') do tasklist /fi "pid eq %p"
```

### Explanation
`NETSTAT -ANO` shows all connections and listening ports with the Process ID (PID) column. Cross-referencing the PID with `TASKLIST` tells you the program name. Always identify the process before terminating it — it may be a legitimate service.

### PowerShell Alternative
```powershell
Get-NetTCPConnection -LocalPort 8080 | Select LocalAddress, LocalPort, State, OwningProcess |
    ForEach-Object { $_ | Add-Member -NotePropertyName ProcessName -NotePropertyValue (Get-Process -Id $_.OwningProcess).Name -PassThru }
```

---

## Scenario 3: Auditing Who Has Admin Rights

### Problem Statement
Security audit requires you to document all accounts with administrator privileges on a machine or identify unexpected admin accounts.

### CMD Solution (Step by Step)

**Step 1: List Administrators group members**
```cmd
net localgroup Administrators
```

**Step 2: Get more detail on each member**
```cmd
REM For each user found, run:
net user username
wmic useraccount where name="username" get name,sid,disabled,fullname
```

**Step 3: Check who is currently logged in with admin rights**
```cmd
query user
whoami /groups | find "S-1-5-32-544"
```
*(S-1-5-32-544 is the SID for the Administrators group)*

**Step 4: Check for domain admin accounts (if domain-joined)**
```cmd
net group "Domain Admins" /domain
```

**Step 5: Export findings**
```cmd
(
    echo === LOCAL ADMINISTRATORS ===
    net localgroup Administrators
    echo.
    echo === DOMAIN ADMINS (if domain-joined) ===
    net group "Domain Admins" /domain 2>nul
    echo.
    echo === CURRENT USER PRIVILEGES ===
    whoami /all
) > admin_audit.txt
```

### Explanation
Every account in the Administrators group has full control over the system. The principle of least privilege says only necessary accounts should be administrators. This audit helps identify "admin creep" — accounts that were given admin rights temporarily and never removed.

### PowerShell Alternative
```powershell
Get-LocalGroupMember -Group "Administrators" | Select Name, ObjectClass, PrincipalSource
```

---

## Scenario 4: Recovering from a Failed Windows Update

### Problem Statement
Windows Update has failed, left the system in an inconsistent state, or you need to diagnose what went wrong.

### CMD Solution (Step by Step)

**Step 1: Check Windows Update service status**
```cmd
sc query wuauserv
sc qc wuauserv
```

**Step 2: View recent Windows Update errors**
```cmd
wevtutil qe System /q:"*[System[Provider[@Name='Microsoft-Windows-WindowsUpdateClient'] and Level=2]]" /c:10 /f:text
```

**Step 3: Check pending operations**
```cmd
dism /online /cleanup-image /checkhealth
```

**Step 4: Repair Windows image**
```cmd
dism /online /cleanup-image /restorehealth
```

**Step 5: Repair system files**
```cmd
sfc /scannow
```

**Step 6: Clear Windows Update cache (start fresh)**
```cmd
REM Stop Windows Update services
net stop wuauserv
net stop cryptsvc
net stop bits
net stop msiserver

REM Rename the update cache folders (backup, not delete)
ren C:\Windows\SoftwareDistribution SoftwareDistribution.bak
ren C:\Windows\System32\catroot2 catroot2.bak

REM Restart services
net start wuauserv
net start cryptsvc
net start bits
net start msiserver
```

**Step 7: Re-check for updates**
```cmd
usoclient startscan
```

### Explanation
Windows Update failures often stem from a corrupted update cache or corrupted system files. The sequence repairs these in order: image integrity → system files → update cache reset. Renaming (not deleting) the cache folders means you can restore them if something goes wrong.

### PowerShell Alternative
```powershell
# Check Windows Update history
Get-WindowsUpdateLog    # Creates WindowsUpdate.log on Desktop
# Install PSWindowsUpdate module for more control:
# Install-Module PSWindowsUpdate
# Get-WindowsUpdate
# Install-WindowsUpdate -AcceptAll
```

---

## Scenario 5: Cleaning Up Disk Space

### Problem Statement
A drive is running low on space. You need to identify what is using space and clean it up safely.

### CMD Solution (Step by Step)

**Step 1: Check current disk usage**
```cmd
wmic logicaldisk get deviceid,size,freespace,filesystem
```

**Step 2: Find largest folders (PowerShell needed for accuracy)**
```cmd
powershell -command "Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue | Group-Object DirectoryName | Sort-Object {($_.Group | Measure-Object -Property Length -Sum).Sum} -Descending | Select-Object -First 20 | Format-Table -AutoSize"
```

**Step 3: Clean temporary files**
```cmd
del /q /f /s "%TEMP%\*.*" 2>nul
del /q /f /s "%SystemRoot%\Temp\*.*" 2>nul
```

**Step 4: Clean Windows component store**
```cmd
dism /online /cleanup-image /analyzecomponentstore
dism /online /cleanup-image /startcomponentcleanup
```

**Step 5: Run Windows Disk Cleanup**
```cmd
REM Configure cleanup categories (run once)
cleanmgr /sageset:1
REM Then run silently
cleanmgr /sagerun:1
```

**Step 6: Find and review large files**
```cmd
forfiles /p C:\ /s /m *.* /d -365 /c "cmd /c if @fsize gtr 104857600 echo @path @fsize"
```

**Step 7: NTFS compress old archive folders**
```cmd
compact /c /s:"C:\Archives"
```

### PowerShell Alternative
```powershell
# Find large files (>100MB)
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 100MB } |
    Sort-Object Length -Descending |
    Select-Object FullName, @{N='Size_MB';E={[math]::Round($_.Length/1MB,1)}}
```

---

## Scenario 6: Investigating Suspicious Network Activity

### Problem Statement
You suspect a machine has suspicious outbound connections — possibly malware communicating with a command-and-control server.

### CMD Solution (Step by Step)

**Step 1: See all current connections**
```cmd
netstat -ano
```

**Step 2: Look for unusual established connections**
```cmd
netstat -ano | findstr "ESTABLISHED"
```

**Step 3: Find the process behind each connection**
```cmd
REM For each suspicious PID from netstat:
tasklist /fi "pid eq PIDNUMBER"
wmic process where processid=PIDNUMBER get name,executablepath,commandline
```

**Step 4: Look for processes in unusual locations**
```cmd
wmic process get name,executablepath | findstr /i "temp\|appdata\|downloads\|public"
```

**Step 5: Check startup items for persistence**
```cmd
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
wmic startup list full
```

**Step 6: Look at recent files in temp and appdata**
```cmd
dir /o:-d /a:-d "%TEMP%\*.*" | more
dir /o:-d /a:-d "%APPDATA%\*.*" | more
```

**Step 7: Calculate hashes of suspicious files for research**
```cmd
certutil -hashfile "C:\SuspiciousFile.exe" SHA256
```
*Search the hash on VirusTotal.com*

### Explanation
This investigation follows the principle of "assume compromise, verify everything." The goal is to document what is connected where, map connections to processes, then examine those processes for legitimacy. Never delete suspected malware files without making a forensic copy first.

### PowerShell Alternative
```powershell
# Connections with process names
Get-NetTCPConnection -State Established |
    Select LocalAddress, LocalPort, RemoteAddress, RemotePort,
    @{N='Process';E={(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name}}
```

---

## Scenario 7: Automating System Backups with ROBOCOPY

### Problem Statement
You need to set up an automated file backup solution that runs daily, copies only changed files, and maintains a log.

### CMD Solution (Step by Step)

**Step 1: Create the backup script**

Create `daily_backup.bat`:
```bat
@echo off
setlocal

REM Configuration
set SOURCE=C:\ImportantData
set DEST=D:\Backup\Daily
set LOGDIR=D:\Backup\Logs
set MAXLOGS=30

REM Create directories
if not exist "%DEST%" mkdir "%DEST%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

REM Timestamped log file
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set LOGFILE=%LOGDIR%\backup_%LOGDATE%.txt

REM Run ROBOCOPY backup
robocopy "%SOURCE%" "%DEST%" /e /copyall /z /r:3 /w:10 /log:"%LOGFILE%" /tee /np /nfl /ndl

REM Check exit code
if %ERRORLEVEL% lss 8 (
    echo Backup completed successfully >> "%LOGFILE%"
) else (
    echo Backup had errors - check log >> "%LOGFILE%"
)

REM Cleanup old logs (keep last 30)
forfiles /p "%LOGDIR%" /m backup_*.txt /d -%MAXLOGS% /c "cmd /c del @path" 2>nul

endlocal
```

**Step 2: Schedule the backup**
```cmd
schtasks /create /tn "DailyBackup" /tr "C:\Scripts\daily_backup.bat" /sc daily /st 02:00 /ru SYSTEM /f
```

**Step 3: Verify the task was created**
```cmd
schtasks /query /tn "DailyBackup"
```

**Step 4: Test run manually**
```cmd
schtasks /run /tn "DailyBackup"
```

### Explanation
ROBOCOPY's exit codes below 8 indicate success (0-1 = no errors, 2-7 = warnings but no failures). The `/COPYALL` flag preserves permissions, timestamps, and ownership. `/Z` enables restartable mode for large files over slow links. Automatic log cleanup prevents the log folder from growing unboundedly.

### PowerShell Alternative
```powershell
Start-Job -ScriptBlock {
    $source = "C:\ImportantData"
    $dest = "D:\Backup\Daily"
    Copy-Item -Path $source -Destination $dest -Recurse -Force
}
```

---

## Scenario 8: Setting Up Scheduled Maintenance Tasks

### Problem Statement
You need to set up a suite of scheduled maintenance tasks: weekly disk check, daily log cleanup, monthly audit.

### CMD Solution (Step by Step)

**Step 1: Create a weekly disk health check (Sunday 3 AM)**
```cmd
schtasks /create /tn "WeeklyDiskCheck" /tr "C:\Toolkit\scripts\maintenance\disk_check.bat" /sc weekly /d SUN /st 03:00 /ru SYSTEM /f
```

**Step 2: Create daily temp cleanup (every night at 1 AM)**
```cmd
REM Note: This requires a non-interactive version of clean_temp_files.bat
schtasks /create /tn "DailyTempClean" /tr "C:\Scripts\auto_clean.bat" /sc daily /st 01:00 /ru SYSTEM /f
```

**Step 3: Create monthly audit (1st of month at 4 AM)**
```cmd
schtasks /create /tn "MonthlyAudit" /tr "C:\Toolkit\scripts\system-check\full_system_audit.bat" /sc monthly /d 1 /st 04:00 /ru SYSTEM /f
```

**Step 4: List all scheduled tasks**
```cmd
schtasks /query /fo table
```

**Step 5: Test each task**
```cmd
schtasks /run /tn "WeeklyDiskCheck"
schtasks /run /tn "MonthlyAudit"
```

**Step 6: Review task history**
```cmd
schtasks /query /tn "WeeklyDiskCheck" /v /fo list
```

### PowerShell Alternative
```powershell
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
$action = New-ScheduledTaskAction -Execute "C:\Toolkit\scripts\maintenance\disk_check.bat"
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable $false
Register-ScheduledTask -TaskName "WeeklyDiskCheck" -Trigger $trigger -Action $action -Settings $settings -RunLevel Highest
```

---

## Scenario 9: Diagnosing Hardware Issues

### Problem Statement
A machine has intermittent crashes, blue screens, or performance problems. You need to identify hardware issues from the command line.

### CMD Solution (Step by Step)

**Step 1: Check SMART disk health**
```cmd
wmic diskdrive get status,model,serialnumber,size
```
*Status should be "OK" — anything else means drive is failing*

**Step 2: Review recent critical events**
```cmd
wevtutil qe System /q:"*[System[Level=1 or Level=2]]" /c:20 /rd:true /f:text | more
```
*Level 1 = Critical, Level 2 = Error*

**Step 3: Check for memory errors**
```cmd
wevtutil qe System /q:"*[System[Provider[@Name='Microsoft-Windows-MemoryDiagnostics-Results']]]" /c:5 /f:text
```

**Step 4: Check for disk errors in Event Log**
```cmd
wevtutil qe System /q:"*[System[Provider[@Name='disk'] and Level=2]]" /c:10 /f:text
```

**Step 5: Review system uptime and reboots**
```cmd
wmic os get lastbootuptime
wevtutil qe System /q:"*[System[EventID=6006 or EventID=6008]]" /c:10 /f:text
REM 6006 = clean shutdown, 6008 = unexpected shutdown
```

**Step 6: Check CPU and thermal information**
```cmd
wmic cpu get name,currentclockspeed,maxclockspeed,loadpercentage,status
```

**Step 7: Run Windows Memory Diagnostic**
```cmd
REM Schedule memory test at next reboot
mdsched.exe
```

**Step 8: Check for disk filesystem errors**
```cmd
chkdsk C:
```

### Explanation
Hardware issues often leave traces in the Windows Event Log before they cause visible problems. Event IDs 6008 (unexpected shutdown) indicate crashes. SMART status "OK" doesn't guarantee a healthy drive, but non-OK status is a definite warning sign.

### PowerShell Alternative
```powershell
# Recent critical system events
Get-EventLog -LogName System -EntryType Error, Warning -Newest 20 | Format-List TimeGenerated, Source, Message

# Physical disk health
Get-PhysicalDisk | Select FriendlyName, HealthStatus, OperationalStatus, MediaType
```

---

## Scenario 10: Managing User Accounts in Bulk

### Problem Statement
You need to create 20 new user accounts from a CSV file, add them to appropriate groups, and send a report of what was created.

### CMD Solution (Step by Step)

**Preparation: Create users.csv**
```
username,fullname,department,isadmin
jsmith,John Smith,IT,Y
mjones,Mary Jones,Finance,N
bwilliams,Bob Williams,HR,N
```

**The batch script: create_users.bat**
```bat
@echo off
setlocal enabledelayedexpansion

set LOGFILE=user_creation_log.txt
echo User Creation Log - %DATE% %TIME% > %LOGFILE%

REM Read CSV (skip header line)
for /f "skip=1 tokens=1,2,3,4 delims=," %%a in (users.csv) do (
    set USERNAME=%%a
    set FULLNAME=%%b
    set DEPT=%%c
    set ISADMIN=%%d

    echo Processing: !USERNAME! (!FULLNAME!)

    REM Create the user account with a temporary password
    net user !USERNAME! TempPass123! /add /fullname:"!FULLNAME!" /comment:"Department: !DEPT!" /passwordchg:yes 2>nul
    if !ERRORLEVEL! equ 0 (
        echo   [OK] Created user: !USERNAME! >> %LOGFILE%

        REM Add to appropriate group
        if "!ISADMIN!"=="Y" (
            net localgroup Administrators !USERNAME! /add 2>nul
            echo   [OK] Added !USERNAME! to Administrators >> %LOGFILE%
        ) else (
            net localgroup Users !USERNAME! /add 2>nul
            echo   [OK] Added !USERNAME! to Users >> %LOGFILE%
        )
    ) else (
        echo   [ERROR] Failed to create: !USERNAME! >> %LOGFILE%
    )
)

echo.
echo User creation complete. See %LOGFILE% for details.
type %LOGFILE%
```

**Report all created users:**
```cmd
net user
wmic useraccount get name,fullname,disabled
```

### Explanation
Bulk user creation from CSV is a common IT onboarding task. The script processes each line, creates the account with a temporary password that must be changed at first login (`/passwordchg:yes`), and assigns the appropriate group membership. The log file tracks what succeeded and what failed for accountability.

### PowerShell Alternative
```powershell
Import-Csv users.csv | ForEach-Object {
    $params = @{
        Name        = $_.username
        FullName    = $_.fullname
        Description = "Department: $($_.department)"
        Password    = (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force)
        ChangePasswordAtLogon = $true
    }
    New-LocalUser @params
    Add-LocalGroupMember -Group "Users" -Member $_.username
    if ($_.isadmin -eq "Y") {
        Add-LocalGroupMember -Group "Administrators" -Member $_.username
    }
}
```

---

*Back to: [README](../README.md)*
