@echo off
REM ============================================================
REM  ip_diagnostics.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Comprehensive IP network diagnostics
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run from CMD (admin recommended for full output)
REM  Output:  Screen + log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  SETUP
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\ip_diagnostics_%LOGDATE%.txt"

REM ============================================================
REM  CUSTOMISE: Change these targets for your environment
REM ============================================================
set DNS_TEST=8.8.8.8
set WEB_TEST=google.com
set WEB_TEST2=microsoft.com

title IP Diagnostics - Running...
color 0A

echo.
echo  ============================================================
echo     IP NETWORK DIAGNOSTICS
echo     Computer : %COMPUTERNAME%
echo     Date     : %DATE%  Time: %TIME%
echo  ============================================================
echo.

REM Write log header
(
    echo ============================================================
    echo   IP NETWORK DIAGNOSTICS
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  STEP 1: Full IP Configuration
REM ============================================================
echo [1/6] Gathering IP configuration...

call :WriteSection "FULL IP CONFIGURATION (ipconfig /all)"
(
    ipconfig /all 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Your IP Addresses ---
ipconfig 2>nul | findstr /i "IPv4 IPv6 Default"

REM Extract the default gateway for subsequent tests
for /f "tokens=*" %%g in ('ipconfig 2^>nul ^| findstr "Default Gateway" ^| findstr /v "0\.0\.0\.0" ^| findstr /v "::1"') do (
    for /f "tokens=13" %%a in ("%%g") do set GATEWAY=%%a
)

if defined GATEWAY (
    echo.
    echo   Default Gateway found: %GATEWAY%
) else (
    echo.
    echo   WARNING: Could not determine default gateway.
    set GATEWAY=192.168.1.1
)

REM ============================================================
REM  STEP 2: Connectivity Tests
REM ============================================================
echo.
echo [2/6] Testing connectivity...
echo.

call :WriteSection "CONNECTIVITY TESTS"

REM Test 1: Loopback
echo   Testing loopback (127.0.0.1)...
ping -n 2 -w 1000 127.0.0.1 > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Loopback: OK
    echo   PASS: Loopback (127.0.0.1) >> "%LOGFILE%"
) else (
    echo   [FAIL] Loopback: FAILED - TCP/IP stack issue
    echo   FAIL: Loopback >> "%LOGFILE%"
)

REM Test 2: Default Gateway
echo   Testing default gateway (%GATEWAY%)...
ping -n 4 -w 2000 %GATEWAY% 2>nul >> "%LOGFILE%"
ping -n 2 -w 2000 %GATEWAY% > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Gateway (%GATEWAY%): Reachable
    echo   PASS: Gateway (%GATEWAY%) >> "%LOGFILE%"
) else (
    echo   [FAIL] Gateway (%GATEWAY%): UNREACHABLE - check router/cable
    echo   FAIL: Gateway (%GATEWAY%) >> "%LOGFILE%"
)

REM Test 3: Internet by IP
echo   Testing internet by IP (%DNS_TEST%)...
ping -n 4 -w 3000 %DNS_TEST% 2>nul >> "%LOGFILE%"
ping -n 2 -w 3000 %DNS_TEST% > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Internet by IP (%DNS_TEST%): Reachable
    echo   PASS: Internet by IP (%DNS_TEST%) >> "%LOGFILE%"
) else (
    echo   [FAIL] Internet by IP (%DNS_TEST%): UNREACHABLE - check ISP/firewall
    echo   FAIL: Internet by IP (%DNS_TEST%) >> "%LOGFILE%"
)

REM Test 4: Internet by hostname (DNS required)
echo   Testing internet by hostname (%WEB_TEST%)...
ping -n 4 -w 3000 %WEB_TEST% 2>nul >> "%LOGFILE%"
ping -n 2 -w 3000 %WEB_TEST% > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] DNS + Internet (%WEB_TEST%): Reachable
    echo   PASS: DNS + Internet (%WEB_TEST%) >> "%LOGFILE%"
) else (
    echo   [FAIL] DNS + Internet (%WEB_TEST%): FAILED - DNS or web access issue
    echo   FAIL: DNS + Internet (%WEB_TEST%) >> "%LOGFILE%"
)

REM ============================================================
REM  STEP 3: DNS Lookups
REM ============================================================
echo.
echo [3/6] Running DNS lookups...

call :WriteSection "DNS LOOKUPS"
(
    echo --- Lookup: %WEB_TEST% ---
    nslookup %WEB_TEST% 2>nul
    echo.
    echo --- Lookup: %WEB_TEST2% ---
    nslookup %WEB_TEST2% 2>nul
    echo.
    echo --- Lookup: %DNS_TEST% (reverse) ---
    nslookup %DNS_TEST% 2>nul
    echo.
    echo --- DNS Cache (sample) ---
    ipconfig /displaydns 2>nul | findstr "Record Name" | more
) >> "%LOGFILE%"

echo.
echo   --- DNS lookup for %WEB_TEST% ---
nslookup %WEB_TEST% 2>nul | findstr "Name\|Address"

REM ============================================================
REM  STEP 4: Routing Table
REM ============================================================
echo.
echo [4/6] Displaying routing table...

call :WriteSection "ROUTING TABLE"
(
    route print 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Default Routes ---
route print 2>nul | findstr "0\.0\.0\.0"

REM ============================================================
REM  STEP 5: ARP Cache
REM ============================================================
echo.
echo [5/6] Checking ARP cache...

call :WriteSection "ARP CACHE"
(
    arp -a 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Local Network Devices (ARP Cache) ---
arp -a 2>nul

REM ============================================================
REM  STEP 6: Active Connections Summary
REM ============================================================
echo.
echo [6/6] Summarising active connections...

call :WriteSection "ACTIVE CONNECTIONS SUMMARY"
(
    echo --- All Connections ---
    netstat -an 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Established connections ---
netstat -an 2>nul | findstr "ESTABLISHED" | find /c /v ""
echo   established connections

echo   --- Listening ports ---
netstat -an 2>nul | findstr "LISTENING" | find /c /v ""
echo   listening ports

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   DIAGNOSTICS COMPLETE
    echo   End Time: %DATE% %TIME%
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   IP DIAGNOSTICS COMPLETE
echo   Report saved to: %LOGFILE%
echo ============================================================
echo.
color 07
title IP Diagnostics - COMPLETE
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
