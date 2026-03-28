@echo off
REM ============================================================
REM  full_system_audit.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Comprehensive read-only system audit
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  Output:  Screen + timestamped log in Logs\ subfolder
REM ============================================================

REM Enable delayed expansion for variables inside loops
setlocal enabledelayedexpansion

REM ============================================================
REM  SETUP: Configure paths and create Logs directory
REM ============================================================
REM Set the script root (directory this script lives in)
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"

REM Create Logs directory if it does not exist
if not exist "%LOGDIR%\" (
    mkdir "%LOGDIR%"
)

REM Build a timestamped filename
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%-%RAWDATE:~12,2%
set "LOGFILE=%LOGDIR%\full_system_audit_%LOGDATE%.txt"

REM ============================================================
REM  HEADER: Display banner and start logging
REM ============================================================
color 0A
title Full System Audit - Running...
call :PrintHeader
goto :MainMenu

REM ============================================================
REM  SUBROUTINE: Print the ASCII header banner
REM ============================================================
:PrintHeader
echo.
echo  ============================================================
echo     ULTIMATE WINDOWS CMD SECURITY TOOLKIT
echo     Full System Audit
echo  ============================================================
echo   Computer : %COMPUTERNAME%
echo   User     : %USERDOMAIN%\%USERNAME%
echo   Date     : %DATE%
echo   Time     : %TIME%
echo   Log File : %LOGFILE%
echo  ============================================================
echo.
goto :EOF

REM ============================================================
REM  MAIN MENU: Navigate to all audit sections
REM ============================================================
:MainMenu
REM Write the header to the log file
(
    echo ============================================================
    echo   FULL SYSTEM AUDIT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%
    echo   Time     : %TIME%
    echo ============================================================
) > "%LOGFILE%"

REM Run all sections in order
call :SectionOS
call :SectionUsers
call :SectionGroups
call :SectionProcesses
call :SectionServices
call :SectionNetworkConfig
call :SectionNetworkConnections
call :SectionStartup
call :SectionDiskHealth
call :SectionHotfixes
call :SectionDrivers
call :SectionGroupPolicy
call :SectionSummary
goto :End

REM ============================================================
REM  SECTION 1: Operating System Information
REM ============================================================
:SectionOS
call :SectionHeader "OPERATING SYSTEM INFORMATION"

REM Gather OS info and write to screen + log
systeminfo /fo list 2>nul >> "%LOGFILE%"
systeminfo /fo list 2>nul | findstr /i "OS Name OS Version System Type Total Physical"
goto :EOF

REM ============================================================
REM  SECTION 2: Local User Accounts
REM ============================================================
:SectionUsers
call :SectionHeader "LOCAL USER ACCOUNTS"

(
    echo [All Local Users]
    net user 2>nul
    echo.
    echo [User Account Details via WMIC]
    wmic useraccount get name,sid,disabled,fullname,lockout,passwordrequired 2>nul
) >> "%LOGFILE%"

echo [Users] Writing to log...
wmic useraccount get name,disabled,fullname 2>nul
goto :EOF

REM ============================================================
REM  SECTION 3: Group Memberships
REM ============================================================
:SectionGroups
call :SectionHeader "LOCAL GROUP MEMBERSHIPS"

(
    echo [Administrators Group]
    net localgroup Administrators 2>nul
    echo.
    echo [Remote Desktop Users Group]
    net localgroup "Remote Desktop Users" 2>nul
    echo.
    echo [Power Users Group]
    net localgroup "Power Users" 2>nul
    echo.
    echo [All Local Groups]
    net localgroup 2>nul
) >> "%LOGFILE%"

echo [Groups] Administrators:
net localgroup Administrators 2>nul
goto :EOF

REM ============================================================
REM  SECTION 4: Running Processes
REM ============================================================
:SectionProcesses
call :SectionHeader "RUNNING PROCESSES"

(
    echo [Process List - Brief]
    tasklist /fo table 2>nul
    echo.
    echo [Process Executable Paths]
    wmic process get name,processid,executablepath 2>nul
) >> "%LOGFILE%"

echo [Processes] Writing %COMPUTERNAME% process list to log...
tasklist /fo table /nh 2>nul | find /c /v ""
echo processes found.
goto :EOF

REM ============================================================
REM  SECTION 5: Windows Services
REM ============================================================
:SectionServices
call :SectionHeader "WINDOWS SERVICES"

(
    echo [All Services Status]
    sc query type= all state= all 2>nul
    echo.
    echo [Auto-Start Services via WMIC]
    wmic service where startmode="auto" get name,state,displayname 2>nul
) >> "%LOGFILE%"

echo [Services] Auto-start services:
wmic service where startmode="auto" get name,state 2>nul | find "Stopped"
goto :EOF

REM ============================================================
REM  SECTION 6: Network Configuration
REM ============================================================
:SectionNetworkConfig
call :SectionHeader "NETWORK CONFIGURATION"

(
    echo [Full IP Configuration]
    ipconfig /all 2>nul
    echo.
    echo [ARP Cache]
    arp -a 2>nul
    echo.
    echo [Routing Table]
    route print 2>nul
    echo.
    echo [DNS Cache Sample]
    ipconfig /displaydns 2>nul | findstr "Record Name" | more
) >> "%LOGFILE%"

echo [Network] IP Configuration:
ipconfig | findstr "IPv4"
goto :EOF

REM ============================================================
REM  SECTION 7: Network Connections
REM ============================================================
:SectionNetworkConnections
call :SectionHeader "ACTIVE NETWORK CONNECTIONS"

(
    echo [All TCP/UDP Connections with PIDs]
    netstat -ano 2>nul
    echo.
    echo [Listening Ports]
    netstat -an 2>nul | findstr "LISTENING"
    echo.
    echo [Established Connections]
    netstat -an 2>nul | findstr "ESTABLISHED"
) >> "%LOGFILE%"

echo [Network Connections] Writing to log...
netstat -an 2>nul | find "LISTENING" | find /c /v ""
echo listening ports found.
goto :EOF

REM ============================================================
REM  SECTION 8: Startup Items
REM ============================================================
:SectionStartup
call :SectionHeader "STARTUP ITEMS AND SCHEDULED TASKS"

(
    echo [Registry Startup - HKLM Run]
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
    echo.
    echo [Registry Startup - HKCU Run]
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
    echo.
    echo [WMIC Startup List]
    wmic startup list full 2>nul
    echo.
    echo [Scheduled Tasks]
    schtasks /query /fo list 2>nul
) >> "%LOGFILE%"

echo [Startup] Writing startup items to log...
wmic startup list brief 2>nul | find /c /v ""
echo startup items found.
goto :EOF

REM ============================================================
REM  SECTION 9: Disk Health
REM ============================================================
:SectionDiskHealth
call :SectionHeader "DISK HEALTH AND SPACE"

(
    echo [Logical Disk Information]
    wmic logicaldisk get deviceid,size,freespace,filesystem,volumename 2>nul
    echo.
    echo [Physical Disk Status - SMART]
    wmic diskdrive get status,model,size,serialnumber 2>nul
    echo.
    echo [Volume Information]
    wmic volume get name,capacity,freespace,filesystem,label 2>nul
) >> "%LOGFILE%"

echo [Disk] Drive status:
wmic diskdrive get status,model 2>nul
goto :EOF

REM ============================================================
REM  SECTION 10: Installed Hotfixes and Updates
REM ============================================================
:SectionHotfixes
call :SectionHeader "INSTALLED HOTFIXES AND UPDATES"

(
    echo [Installed Hotfixes - Recent 20]
    wmic qfe get hotfixid,installedon,description /format:table 2>nul
) >> "%LOGFILE%"

echo [Hotfixes] Writing patch list to log...
wmic qfe get hotfixid,installedon 2>nul | find /c "KB"
echo hotfixes found.
goto :EOF

REM ============================================================
REM  SECTION 11: Installed Drivers
REM ============================================================
:SectionDrivers
call :SectionHeader "DEVICE DRIVERS"

(
    echo [Driver List with Signature Status]
    driverquery /si 2>nul
) >> "%LOGFILE%"

echo [Drivers] Checking for unsigned drivers...
driverquery /si 2>nul | findstr /i "false"
goto :EOF

REM ============================================================
REM  SECTION 12: Group Policy
REM ============================================================
:SectionGroupPolicy
call :SectionHeader "GROUP POLICY"

(
    echo [Applied Group Policy - Summary]
    gpresult /r 2>nul
) >> "%LOGFILE%"

echo [Group Policy] Writing GPO summary to log...
goto :EOF

REM ============================================================
REM  SECTION 13: Summary
REM ============================================================
:SectionSummary
(
    echo.
    echo ============================================================
    echo   AUDIT COMPLETE
    echo   End Time : %DATE% %TIME%
    echo ============================================================
) >> "%LOGFILE%"

color 0A
echo.
echo ============================================================
echo   AUDIT COMPLETE
echo ============================================================
echo   Results saved to:
echo   %LOGFILE%
echo.
echo   Open the log file to review all findings.
echo ============================================================
goto :EOF

REM ============================================================
REM  HELPER: Print a section header to screen and log
REM ============================================================
:SectionHeader
echo.
echo ============================================================
echo   %~1
echo ============================================================
echo.
(
    echo.
    echo ============================================================
    echo   %~1
    echo ============================================================
    echo.
) >> "%LOGFILE%"
goto :EOF

REM ============================================================
REM  END
REM ============================================================
:End
color 07
title Full System Audit - COMPLETE
echo.
echo Press any key to exit...
pause > nul
endlocal
