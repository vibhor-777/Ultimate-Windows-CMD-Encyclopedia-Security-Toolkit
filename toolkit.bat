@echo off
REM ============================================================
REM  toolkit.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Interactive menu-driven launcher for all toolkit scripts
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for full functionality
REM           Double-click or right-click > Run as Administrator
REM  SAFETY:  This script only launches other scripts.
REM           Destructive operations require separate confirmation.
REM ============================================================

@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Set script root directory (where toolkit.bat lives)
REM ============================================================
set "ROOT=%~dp0"
REM Remove trailing backslash
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

REM ============================================================
REM  Check for Administrator privileges
REM ============================================================
net session > nul 2>&1
if %ERRORLEVEL% neq 0 (
    color 0C
    echo.
    echo   [WARNING] Not running as Administrator.
    echo   Some features may not work correctly.
    echo   Recommendation: Right-click toolkit.bat and choose
    echo   'Run as Administrator' for best results.
    echo.
    timeout /t 3 /nobreak > nul
)

REM ============================================================
REM  MAIN MENU LOOP
REM ============================================================
:MainMenu
cls
color 0A

echo.
echo  ==============================================================
echo   *                                                          *
echo   *     ULTIMATE WINDOWS CMD ENCYCLOPEDIA ^& TOOLKIT          *
echo   *                  by vibhor-777                           *
echo   *                                                          *
echo   *          [GitHub] vibhor-777/Ultimate-Windows-           *
echo   *          CMD-Encyclopedia-Security-Toolkit               *
echo   *                                                          *
echo  ==============================================================
echo.
echo   Computer : %COMPUTERNAME%     User: %USERDOMAIN%\%USERNAME%
echo   Date     : %DATE%             Time: %TIME%
echo.
echo  ==============================================================
echo.
echo   MAIN MENU
echo.
echo     [1]  Quick Health Check
echo     [2]  Full System Audit
echo     [3]  Security Scans  (submenu)
echo     [4]  Network Diagnostics  (submenu)
echo     [5]  Maintenance Tools  (submenu)
echo     [6]  CMD Encyclopedia  (open docs folder)
echo     [7]  Exit
echo.
echo  ==============================================================
echo.

REM Get user input
set "CHOICE="
set /p CHOICE=  Enter your choice (1-7): 

REM Validate input
if "%CHOICE%"=="1" goto :QuickHealthCheck
if "%CHOICE%"=="2" goto :FullSystemAudit
if "%CHOICE%"=="3" goto :SecurityMenu
if "%CHOICE%"=="4" goto :NetworkMenu
if "%CHOICE%"=="5" goto :MaintenanceMenu
if "%CHOICE%"=="6" goto :OpenEncyclopedia
if "%CHOICE%"=="7" goto :ExitToolkit

REM Invalid input
echo.
echo   [ERROR] Invalid choice. Please enter a number from 1 to 7.
timeout /t 2 /nobreak > nul
goto :MainMenu

REM ============================================================
REM  OPTION 1: Quick Health Check
REM ============================================================
:QuickHealthCheck
cls
echo.
echo   Launching Quick Health Check...
echo   (This will take approximately 30 seconds)
echo.
call "%ROOT%\scripts\system-check\quick_health_check.bat"
echo.
echo   Quick Health Check complete. Press any key to return to menu.
pause > nul
goto :MainMenu

REM ============================================================
REM  OPTION 2: Full System Audit
REM ============================================================
:FullSystemAudit
cls
echo.
echo   Launching Full System Audit...
echo   (This may take several minutes)
echo.
call "%ROOT%\scripts\system-check\full_system_audit.bat"
echo.
echo   Full System Audit complete. Press any key to return to menu.
pause > nul
goto :MainMenu

REM ============================================================
REM  OPTION 3: Security Scans Submenu
REM ============================================================
:SecurityMenu
cls
color 0E
echo.
echo  ==============================================================
echo   SECURITY SCANS - SUBMENU
echo  ==============================================================
echo.
echo   All scans are READ-ONLY. No changes are made to the system.
echo   Results are saved to the Logs\ folder.
echo.
echo     [1]  Detect Suspicious Processes
echo     [2]  Find Hidden Files
echo     [3]  Check Startup Programs
echo     [4]  Detect Unauthorized Users
echo     [5]  Network Connections Scan
echo     [6]  Run ALL Security Scans
echo     [0]  Back to Main Menu
echo.
echo  ==============================================================
echo.

set "SEC_CHOICE="
set /p SEC_CHOICE=  Enter your choice (0-6): 

if "%SEC_CHOICE%"=="1" goto :SecProcesses
if "%SEC_CHOICE%"=="2" goto :SecHidden
if "%SEC_CHOICE%"=="3" goto :SecStartup
if "%SEC_CHOICE%"=="4" goto :SecUsers
if "%SEC_CHOICE%"=="5" goto :SecNetwork
if "%SEC_CHOICE%"=="6" goto :SecAll
if "%SEC_CHOICE%"=="0" goto :MainMenu

echo.
echo   [ERROR] Invalid choice.
timeout /t 2 /nobreak > nul
goto :SecurityMenu

:SecProcesses
cls
echo   Launching Suspicious Process Detection...
call "%ROOT%\scripts\security\detect_suspicious_processes.bat"
pause > nul
goto :SecurityMenu

:SecHidden
cls
echo   Launching Hidden Files Finder...
call "%ROOT%\scripts\security\find_hidden_files.bat"
pause > nul
goto :SecurityMenu

:SecStartup
cls
echo   Launching Startup Programs Audit...
call "%ROOT%\scripts\security\check_startup_programs.bat"
pause > nul
goto :SecurityMenu

:SecUsers
cls
echo   Launching User Account Audit...
call "%ROOT%\scripts\security\detect_unauthorized_users.bat"
pause > nul
goto :SecurityMenu

:SecNetwork
cls
echo   Launching Network Connections Scan...
call "%ROOT%\scripts\security\network_connections_scan.bat"
pause > nul
goto :SecurityMenu

:SecAll
cls
echo   Running ALL security scans...
echo   This may take several minutes.
echo.
call "%ROOT%\scripts\security\detect_suspicious_processes.bat"
call "%ROOT%\scripts\security\find_hidden_files.bat"
call "%ROOT%\scripts\security\check_startup_programs.bat"
call "%ROOT%\scripts\security\detect_unauthorized_users.bat"
call "%ROOT%\scripts\security\network_connections_scan.bat"
echo.
echo   All security scans complete. Results saved to Logs\ folder.
pause > nul
goto :SecurityMenu

REM ============================================================
REM  OPTION 4: Network Diagnostics Submenu
REM ============================================================
:NetworkMenu
cls
color 0B
echo.
echo  ==============================================================
echo   NETWORK DIAGNOSTICS - SUBMENU
echo  ==============================================================
echo.
echo     [1]  IP Diagnostics (full network check)
echo     [2]  Local Port Inventory
echo     [3]  Quick Ping Test (interactive)
echo     [4]  DNS Lookup (interactive)
echo     [5]  Show Network Configuration
echo     [0]  Back to Main Menu
echo.
echo  ==============================================================
echo.

set "NET_CHOICE="
set /p NET_CHOICE=  Enter your choice (0-5): 

if "%NET_CHOICE%"=="1" goto :NetIPDiag
if "%NET_CHOICE%"=="2" goto :NetPorts
if "%NET_CHOICE%"=="3" goto :NetPing
if "%NET_CHOICE%"=="4" goto :NetDNS
if "%NET_CHOICE%"=="5" goto :NetConfig
if "%NET_CHOICE%"=="0" goto :MainMenu

echo.
echo   [ERROR] Invalid choice.
timeout /t 2 /nobreak > nul
goto :NetworkMenu

:NetIPDiag
cls
echo   Launching IP Diagnostics...
call "%ROOT%\scripts\network\ip_diagnostics.bat"
pause > nul
goto :NetworkMenu

:NetPorts
cls
echo   Launching Local Port Inventory...
call "%ROOT%\scripts\network\port_scan_basic.bat"
pause > nul
goto :NetworkMenu

:NetPing
cls
echo   Quick Ping Test
echo   ---------------
set /p PING_HOST=  Enter hostname or IP to ping: 
if "%PING_HOST%"=="" goto :NetworkMenu
echo.
ping -n 5 %PING_HOST%
echo.
pause > nul
goto :NetworkMenu

:NetDNS
cls
echo   DNS Lookup
echo   ----------
set /p DNS_HOST=  Enter hostname to look up: 
if "%DNS_HOST%"=="" goto :NetworkMenu
echo.
nslookup %DNS_HOST%
echo.
pause > nul
goto :NetworkMenu

:NetConfig
cls
echo   Network Configuration
echo   ---------------------
echo.
ipconfig /all
echo.
pause > nul
goto :NetworkMenu

REM ============================================================
REM  OPTION 5: Maintenance Tools Submenu
REM ============================================================
:MaintenanceMenu
cls
color 0A
echo.
echo  ==============================================================
echo   MAINTENANCE TOOLS - SUBMENU
echo  ==============================================================
echo.
echo     [1]  Clean Temporary Files  (REQUIRES CONFIRMATION)
echo     [2]  Disk Health Check  (read-only)
echo     [0]  Back to Main Menu
echo.
echo  ==============================================================
echo.

set "MAINT_CHOICE="
set /p MAINT_CHOICE=  Enter your choice (0-2): 

if "%MAINT_CHOICE%"=="1" goto :MaintCleanTemp
if "%MAINT_CHOICE%"=="2" goto :MaintDiskCheck
if "%MAINT_CHOICE%"=="0" goto :MainMenu

echo.
echo   [ERROR] Invalid choice.
timeout /t 2 /nobreak > nul
goto :MaintenanceMenu

:MaintCleanTemp
cls
echo   Launching Temp File Cleanup...
echo   NOTE: You will be asked for confirmation before any files are deleted.
echo.
call "%ROOT%\scripts\maintenance\clean_temp_files.bat"
pause > nul
goto :MaintenanceMenu

:MaintDiskCheck
cls
echo   Launching Disk Health Check (read-only)...
call "%ROOT%\scripts\maintenance\disk_check.bat"
pause > nul
goto :MaintenanceMenu

REM ============================================================
REM  OPTION 6: Open CMD Encyclopedia
REM ============================================================
:OpenEncyclopedia
cls
color 0F
echo.
echo  ==============================================================
echo   CMD ENCYCLOPEDIA
echo  ==============================================================
echo.
echo   The CMD Encyclopedia is located in:
echo   %ROOT%\cmd-encyclopedia\
echo.
echo   Opening the encyclopedia folder in File Explorer...
echo.
echo   Quick Command Index:
echo     A.md  - ATTRIB, ARP, ASSOC, AUDITPOL
echo     B.md  - BCDEDIT, BITSADMIN
echo     C.md  - CD, CLS, COPY, CIPHER, CHKDSK, CMD
echo     D.md  - DEL, DIR, DISKPART, DISM, DRIVERQUERY
echo     E.md  - ECHO, ENDLOCAL, EVENTCREATE, EXIT
echo     F.md  - FC, FIND, FINDSTR, FOR, FORMAT, FSUTIL
echo     G.md  - GOTO, GPRESULT, GPUPDATE
echo     H.md  - HELP, HOSTNAME
echo     I.md  - ICACLS, IF, IPCONFIG
echo     ...and more (see cmd-encyclopedia folder)
echo.
echo   Categories folder covers:
echo     - file-management.md
echo     - networking.md
echo     - system-info.md
echo     - user-management.md
echo     - disk-operations.md
echo.

REM Open the encyclopedia folder
start "" "%ROOT%\cmd-encyclopedia"

echo   Encyclopedia folder opened in File Explorer.
echo   Press any key to return to the main menu.
pause > nul
color 0A
goto :MainMenu

REM ============================================================
REM  OPTION 7: Exit
REM ============================================================
:ExitToolkit
cls
color 07
echo.
echo  ==============================================================
echo   Thank you for using the Ultimate Windows CMD Toolkit!
echo   by vibhor-777
echo.
echo   Logs saved in: %ROOT%\Logs\
echo  ==============================================================
echo.
timeout /t 2 /nobreak > nul
endlocal
exit /b 0
