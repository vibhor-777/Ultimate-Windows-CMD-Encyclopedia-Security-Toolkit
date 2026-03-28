@echo off
REM ============================================================
REM  network_connections_scan.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Audit all network connections and listening ports
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  SAFETY:  READ-ONLY. Scans LOCAL machine only.
REM           Does NOT scan remote hosts or other systems.
REM  Output:  Screen summary + log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  DISCLAIMER
REM ============================================================
echo.
echo  ============================================================
echo     NETWORK CONNECTIONS SCAN
echo     LOCAL MACHINE ONLY - Read-only audit
echo.
echo     This script scans the LOCAL computer's network
echo     connections. It does NOT scan or probe remote hosts.
echo     Results are informational only.
echo  ============================================================
echo.

REM ============================================================
REM  SETUP
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\network_scan_%LOGDATE%.txt"

title Network Connections Scan - Running...
color 0A

REM Write log header
(
    echo ============================================================
    echo   NETWORK CONNECTIONS AUDIT REPORT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   Scope    : LOCAL MACHINE ONLY - Read-only scan
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: All Connections with PIDs
REM ============================================================
echo [1/7] Collecting all network connections with PIDs...

call :WriteSection "ALL ACTIVE CONNECTIONS WITH PROCESS IDs"
(
    netstat -ano 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Connection counts ---
netstat -an 2>nul | find "TCP" | find /c /v ""
echo   TCP connections
netstat -an 2>nul | find "UDP" | find /c /v ""
echo   UDP listeners

REM ============================================================
REM  SECTION 2: Listening Ports
REM ============================================================
echo.
echo [2/7] Listing all listening ports...

call :WriteSection "LISTENING PORTS"
(
    netstat -an 2>nul | findstr "LISTENING"
) >> "%LOGFILE%"

echo.
echo   --- Ports actively listening for connections ---
netstat -an 2>nul | findstr "LISTENING"

REM ============================================================
REM  SECTION 3: Established Connections
REM ============================================================
echo.
echo [3/7] Listing established connections...

call :WriteSection "ESTABLISHED CONNECTIONS"
(
    netstat -an 2>nul | findstr "ESTABLISHED"
) >> "%LOGFILE%"

echo.
echo   --- Currently established connections ---
netstat -an 2>nul | findstr "ESTABLISHED"

REM ============================================================
REM  SECTION 4: Process-to-Connection Mapping
REM ============================================================
echo.
echo [4/7] Mapping connections to processes...

call :WriteSection "PROCESS TO PORT MAPPING"
(
    echo --- All connections with owning process (netstat -b requires admin) ---
    netstat -b 2>nul
    echo.
    echo --- Process list for cross-reference ---
    tasklist /fo table 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Looking up processes for key ports ---
echo   (Cross-referencing PIDs - see log for full details)

REM Check specific common ports and show which process uses them
for %%p in (80 443 3389 445 139 135 22 21) do (
    for /f "tokens=5" %%i in ('netstat -ano 2^>nul ^| findstr ":%%p "') do (
        if not "%%i"=="" (
            for /f "tokens=1" %%n in ('tasklist /fi "pid eq %%i" /fo csv /nh 2^>nul') do (
                echo   Port %%p - PID %%i - Process: %%n
            )
        )
    )
)

REM ============================================================
REM  SECTION 5: ARP Table
REM ============================================================
echo.
echo [5/7] Checking ARP cache (local network devices)...

call :WriteSection "ARP CACHE (Local Network Device List)"
(
    arp -a 2>nul
) >> "%LOGFILE%"

echo.
echo   --- ARP Cache (devices seen on local network) ---
arp -a 2>nul

REM ============================================================
REM  SECTION 6: Routing Table
REM ============================================================
echo.
echo [6/7] Collecting routing table...

call :WriteSection "ROUTING TABLE"
(
    route print 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Network routes (summary) ---
route print 2>nul | findstr "Default Gateway\|0.0.0.0"

REM ============================================================
REM  SECTION 7: Network Adapter Configuration
REM ============================================================
echo.
echo [7/7] Collecting full network adapter information...

call :WriteSection "NETWORK ADAPTER CONFIGURATION"
(
    ipconfig /all 2>nul
) >> "%LOGFILE%"

echo.
echo   --- IP Addresses assigned to this machine ---
ipconfig 2>nul | findstr "IPv4\|IPv6"

REM ============================================================
REM  BONUS: Flag potentially unusual high ports
REM ============================================================
call :WriteSection "CONNECTIONS ON UNUSUAL/HIGH PORT RANGES (informational)"
(
    echo NOTE: High ports are commonly used by legitimate applications.
    echo This section is INFORMATIONAL only - investigate any you do not recognise.
    echo.
    echo Connections on ports > 49152 (ephemeral port range - usually normal):
    netstat -an 2>nul | findstr "LISTENING" | findstr /r ":[5-9][0-9][0-9][0-9][0-9] \|:[1-9][0-9][0-9][0-9][0-9][0-9] "
) >> "%LOGFILE%"

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   SCAN COMPLETE
    echo   End Time: %DATE% %TIME%
    echo.
    echo   KEY REVIEW POINTS:
    echo   1. Are there unexpected LISTENING ports?
    echo   2. Are there ESTABLISHED connections to unknown IPs?
    echo   3. Do you recognise all processes associated with connections?
    echo   4. Are there ARP entries for unknown MAC addresses?
    echo.
    echo   COMMON LEGITIMATE PORTS:
    echo   80/443 = Web (HTTP/HTTPS)
    echo   3389   = Remote Desktop
    echo   445    = File Sharing (SMB)
    echo   135    = RPC
    echo   53     = DNS
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   NETWORK SCAN COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   Review findings. Investigate any listening ports or
echo   established connections you do not recognise.
echo ============================================================
echo.
color 07
title Network Connections Scan - COMPLETE
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
