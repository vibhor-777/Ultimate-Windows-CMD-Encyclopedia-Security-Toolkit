@echo off
REM ============================================================
REM  port_scan_basic.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Display all ports in use on THIS local machine
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for process name mapping
REM  ============================================================
REM  IMPORTANT DISCLAIMER:
REM  This script ONLY examines the local machine's own ports.
REM  It does NOT perform any port scanning of remote hosts.
REM  It does NOT send any probes to external systems.
REM  It reads local TCP/IP stack information only.
REM  ============================================================
REM  Output:  Screen + log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  DISCLAIMER - displayed prominently at startup
REM ============================================================
echo.
echo  ============================================================
echo     LOCAL PORT INVENTORY - DISCLAIMER
echo  ============================================================
echo   This tool ONLY shows ports in use on THIS machine.
echo   It does NOT scan any remote computers or networks.
echo   It only reads your own machine's TCP/IP connection table.
echo  ============================================================
echo.
timeout /t 2 /nobreak > nul

REM ============================================================
REM  SETUP
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\local_ports_%LOGDATE%.txt"

title Local Port Inventory - Running...
color 0A

REM Write log header
(
    echo ============================================================
    echo   LOCAL PORT INVENTORY
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   SCOPE    : LOCAL MACHINE ONLY - read-only
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: All Ports in Use
REM ============================================================
echo [1/5] Collecting all ports in use on this machine...

call :WriteSection "ALL PORTS IN USE ON THIS MACHINE"
(
    netstat -ano 2>nul
) >> "%LOGFILE%"

echo.
echo   Total entries:
netstat -ano 2>nul | find /c /v ""
echo   connections/ports in table

REM ============================================================
REM  SECTION 2: Listening Ports (grouped)
REM ============================================================
echo.
echo [2/5] Listing all LISTENING ports...

call :WriteSection "LISTENING PORTS (services accepting connections)"
(
    echo NOTE: These are ports on THIS machine accepting incoming connections.
    echo.
    netstat -an 2>nul | findstr "LISTENING"
) >> "%LOGFILE%"

echo.
echo   --- All LISTENING ports ---
netstat -an 2>nul | findstr "LISTENING"
echo.
netstat -an 2>nul | findstr "LISTENING" | find /c /v ""
echo   listening ports total

REM ============================================================
REM  SECTION 3: Established Connections
REM ============================================================
echo.
echo [3/5] Listing all ESTABLISHED connections...

call :WriteSection "ESTABLISHED CONNECTIONS (active sessions)"
(
    echo NOTE: These are active two-way connections.
    echo.
    netstat -an 2>nul | findstr "ESTABLISHED"
) >> "%LOGFILE%"

echo.
echo   --- ESTABLISHED connections ---
netstat -an 2>nul | findstr "ESTABLISHED"
echo.
netstat -an 2>nul | findstr "ESTABLISHED" | find /c /v ""
echo   established connections

REM ============================================================
REM  SECTION 4: Group by State
REM ============================================================
echo.
echo [4/5] Grouping connections by state...

call :WriteSection "CONNECTION STATES SUMMARY"

REM Count each state
set LISTEN_COUNT=0
set ESTAB_COUNT=0
set TIMEWAIT_COUNT=0
set CLOSEWAIT_COUNT=0
set SYNSENT_COUNT=0

for /f %%n in ('netstat -an 2^>nul ^| findstr "LISTENING" ^| find /c /v ""') do set LISTEN_COUNT=%%n
for /f %%n in ('netstat -an 2^>nul ^| findstr "ESTABLISHED" ^| find /c /v ""') do set ESTAB_COUNT=%%n
for /f %%n in ('netstat -an 2^>nul ^| findstr "TIME_WAIT" ^| find /c /v ""') do set TIMEWAIT_COUNT=%%n
for /f %%n in ('netstat -an 2^>nul ^| findstr "CLOSE_WAIT" ^| find /c /v ""') do set CLOSEWAIT_COUNT=%%n

(
    echo   LISTENING    : %LISTEN_COUNT%  (services waiting for connections)
    echo   ESTABLISHED  : %ESTAB_COUNT%  (active two-way connections)
    echo   TIME_WAIT    : %TIMEWAIT_COUNT%  (connections closing, normal)
    echo   CLOSE_WAIT   : %CLOSEWAIT_COUNT%  (remote closed, local pending - may indicate issue if high)
) >> "%LOGFILE%"

echo.
echo   --- Connection State Summary ---
echo   LISTENING:    %LISTEN_COUNT%  (services waiting for connections)
echo   ESTABLISHED:  %ESTAB_COUNT%  (active connections)
echo   TIME_WAIT:    %TIMEWAIT_COUNT%  (closing - normal)
echo   CLOSE_WAIT:   %CLOSEWAIT_COUNT%  (may warrant investigation if high)

REM ============================================================
REM  SECTION 5: Cross-reference PIDs to Process Names
REM ============================================================
echo.
echo [5/5] Cross-referencing PIDs to process names...

call :WriteSection "PID TO PROCESS MAPPING"
(
    echo --- Running process list for PID cross-reference ---
    tasklist /fo table 2>nul
    echo.
    echo --- Listening ports with process names (netstat -b requires admin) ---
    netstat -b 2>nul | findstr /v "^$"
) >> "%LOGFILE%"

echo.
echo   --- Active listening ports and their processes ---
echo   (Requires Administrator for process names)
netstat -b 2>nul | findstr /i "listening\|\.exe\|\.dll" | more

REM ============================================================
REM  WELL-KNOWN PORT REFERENCE
REM ============================================================
call :WriteSection "WELL-KNOWN PORT REFERENCE"
(
    echo Common ports for reference:
    echo   20/21  = FTP (File Transfer - insecure, avoid)
    echo   22     = SSH (Secure Shell)
    echo   23     = Telnet (insecure, avoid)
    echo   25     = SMTP (Email sending)
    echo   53     = DNS (Domain Name System)
    echo   67/68  = DHCP
    echo   80     = HTTP (Web)
    echo   110    = POP3 (Email)
    echo   135    = RPC (Windows remote procedures)
    echo   137-139= NetBIOS (Windows file sharing)
    echo   143    = IMAP (Email)
    echo   389    = LDAP (Directory)
    echo   443    = HTTPS (Secure web)
    echo   445    = SMB (Windows file sharing)
    echo   1433   = SQL Server
    echo   3306   = MySQL
    echo   3389   = RDP (Remote Desktop)
    echo   5985   = WinRM (PowerShell remoting)
    echo   8080   = HTTP alternate
    echo   49152+ = Ephemeral/dynamic ports (normal for outbound connections)
) >> "%LOGFILE%"

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   SCAN COMPLETE - %DATE% %TIME%
    echo   REMINDER: This was a LOCAL ONLY scan.
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   LOCAL PORT INVENTORY COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   Summary:
echo   LISTENING:   %LISTEN_COUNT%  ports
echo   ESTABLISHED: %ESTAB_COUNT%  connections
echo ============================================================
echo.
color 07
title Local Port Inventory - COMPLETE
echo Press any key to exit...
pause > nul
endlocal
goto :EOF

REM ============================================================
REM  HELPER: Write section header to log
REM ============================================================
:WriteSection
(
    echo.
    echo ============================================================
    echo   %~1
    echo ============================================================
) >> "%LOGFILE%"
goto :EOF
