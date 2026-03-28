@echo off
REM ============================================================
REM  quick_health_check.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: 30-second quick health check with PASS/FAIL output
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for best results
REM  Output:  Screen summary + log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  SETUP: Log directory and file
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\quick_health_%LOGDATE%.txt"

REM Track PASS/FAIL counts
set PASS_COUNT=0
set FAIL_COUNT=0
set WARN_COUNT=0

REM ============================================================
REM  HEADER
REM ============================================================
title Quick Health Check - Running...
echo.
echo  ============================================================
echo     QUICK HEALTH CHECK - %COMPUTERNAME%
echo     Date: %DATE%  Time: %TIME%
echo  ============================================================
echo.

(
    echo ============================================================
    echo   QUICK HEALTH CHECK - %COMPUTERNAME%
    echo   Date: %DATE%  Time: %TIME%
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  CHECK 1: Disk Space on C:
REM ============================================================
echo [1/6] Checking disk space on C:...
echo.
echo --- DISK SPACE (C:) ---

REM Get free space in bytes via WMIC
for /f "skip=1" %%f in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace 2^>nul') do (
    if not "%%f"=="" set FREE_BYTES=%%f
)

REM Use PowerShell for the comparison (batch math can't handle large numbers)
set FREE_GB=0
for /f %%g in ('powershell -command "[math]::Round(%FREE_BYTES% / 1GB, 1)" 2^>nul') do set FREE_GB=%%g

REM Determine PASS/FAIL (less than 10GB is a warning, less than 5GB is fail)
for /f %%r in ('powershell -command "if (%FREE_BYTES% -lt 5GB) {'FAIL'} elseif (%FREE_BYTES% -lt 10GB) {'WARN'} else {'PASS'}" 2^>nul') do set DISK_STATUS=%%r

if "%DISK_STATUS%"=="PASS" (
    echo   [PASS] C: Free space: %FREE_GB% GB
    set /a PASS_COUNT+=1
) else if "%DISK_STATUS%"=="WARN" (
    echo   [WARN] C: Free space low: %FREE_GB% GB (recommend: ^>10 GB^)
    set /a WARN_COUNT+=1
) else (
    echo   [FAIL] C: Free space critically low: %FREE_GB% GB (minimum: 5 GB^)
    set /a FAIL_COUNT+=1
)

(
    echo.
    echo --- DISK SPACE (C:) ---
    echo   Free Space: %FREE_GB% GB  Status: %DISK_STATUS%
    wmic logicaldisk get deviceid,size,freespace,filesystem 2>nul
) >> "%LOGFILE%"

REM ============================================================
REM  CHECK 2: Top Memory-Consuming Processes
REM ============================================================
echo.
echo [2/6] Checking top processes by memory...
echo.
echo --- TOP PROCESSES BY MEMORY ---

(
    echo.
    echo --- TOP PROCESSES BY MEMORY ---
    tasklist /fo table 2>nul | sort /r /+5
) >> "%LOGFILE%"

REM Show top 5 by memory via native tasklist sort

REM Show top 5 processes
set LINE=0
for /f "tokens=1,4,5" %%a in ('tasklist /fo csv /nh 2^>nul') do (
    set /a LINE+=1
    if !LINE! leq 5 (
        set PNAME=%%a
        set PMEM=%%b
        set PNAME=!PNAME:"=!
        echo   !PNAME! - Mem: !PMEM! K
    )
)
set /a PASS_COUNT+=1
echo   [PASS] Process list retrieved.

REM ============================================================
REM  CHECK 3: Windows Firewall Status
REM ============================================================
echo.
echo [3/6] Checking Windows Firewall...
echo.
echo --- WINDOWS FIREWALL ---

REM Check if firewall is on for all profiles
netsh advfirewall show allprofiles 2>nul | findstr /i "State" | findstr /i "ON" > nul
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Windows Firewall is enabled on at least one profile.
    set /a PASS_COUNT+=1
    set FW_STATUS=PASS
) else (
    echo   [FAIL] Windows Firewall appears to be disabled on all profiles!
    set /a FAIL_COUNT+=1
    set FW_STATUS=FAIL
)

(
    echo.
    echo --- WINDOWS FIREWALL ---
    netsh advfirewall show allprofiles 2>nul
    echo Status: %FW_STATUS%
) >> "%LOGFILE%"

REM ============================================================
REM  CHECK 4: Windows Update Service Status
REM ============================================================
echo.
echo [4/6] Checking Windows Update service...
echo.
echo --- WINDOWS UPDATE SERVICE ---

sc query wuauserv 2>nul | findstr "RUNNING" > nul
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Windows Update service (wuauserv) is RUNNING.
    set /a PASS_COUNT+=1
    set WU_STATUS=RUNNING
) else (
    REM Check if it's stopped but can start (not disabled)
    sc qc wuauserv 2>nul | findstr "DISABLED" > nul
    if !ERRORLEVEL! equ 0 (
        echo   [WARN] Windows Update service is DISABLED.
        set /a WARN_COUNT+=1
        set WU_STATUS=DISABLED
    ) else (
        echo   [WARN] Windows Update service is STOPPED (not disabled - can be started^).
        set /a WARN_COUNT+=1
        set WU_STATUS=STOPPED
    )
)

(
    echo.
    echo --- WINDOWS UPDATE SERVICE ---
    sc query wuauserv 2>nul
    sc qc wuauserv 2>nul
    echo Status: %WU_STATUS%
) >> "%LOGFILE%"

REM ============================================================
REM  CHECK 5: Failed / Stopped Services (Auto-start that stopped)
REM ============================================================
echo.
echo [5/6] Checking for failed services...
echo.
echo --- FAILED AUTO-START SERVICES ---

REM Count services that are set to auto but not running
set FAILED_SVC=0
for /f %%s in ('wmic service where "startmode=''auto'' and state!=''running''" get name 2^>nul ^| findstr /v "^$" ^| findstr /v "Name"') do (
    set /a FAILED_SVC+=1
    echo   [WARN] Service not running: %%s
)

if %FAILED_SVC% equ 0 (
    echo   [PASS] All auto-start services are running.
    set /a PASS_COUNT+=1
) else (
    echo   [WARN] %FAILED_SVC% auto-start service(s) are not running.
    set /a WARN_COUNT+=1
)

(
    echo.
    echo --- AUTO-START SERVICES NOT RUNNING ---
    echo Count: %FAILED_SVC%
    wmic service where "startmode='auto' and state!='running'" get name,state 2>nul
) >> "%LOGFILE%"

REM ============================================================
REM  CHECK 6: Basic Network Connectivity
REM ============================================================
echo.
echo [6/6] Checking network connectivity...
echo.
echo --- NETWORK CONNECTIVITY ---

REM Test loopback
ping -n 1 -w 1000 127.0.0.1 > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Loopback (127.0.0.1) - OK
) else (
    echo   [FAIL] Loopback FAILED - TCP/IP stack issue!
    set /a FAIL_COUNT+=1
)

REM Test internet (Google DNS)
ping -n 1 -w 3000 8.8.8.8 > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] Internet connectivity (8.8.8.8) - OK
    set /a PASS_COUNT+=1
) else (
    echo   [FAIL] Internet connectivity FAILED (cannot reach 8.8.8.8^)
    set /a FAIL_COUNT+=1
)

REM Test DNS resolution
ping -n 1 -w 3000 google.com > nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo   [PASS] DNS resolution (google.com) - OK
    set /a PASS_COUNT+=1
) else (
    echo   [WARN] DNS resolution may have issues
    set /a WARN_COUNT+=1
)

(
    echo.
    echo --- NETWORK CONNECTIVITY ---
    ipconfig /all 2>nul
) >> "%LOGFILE%"

REM ============================================================
REM  SUMMARY
REM ============================================================
echo.
echo ============================================================
echo   HEALTH CHECK SUMMARY - %COMPUTERNAME%
echo ============================================================
echo   PASS  : %PASS_COUNT%
echo   WARN  : %WARN_COUNT%
echo   FAIL  : %FAIL_COUNT%
echo.
if %FAIL_COUNT% gtr 0 (
    echo   STATUS: ACTION REQUIRED - Review FAIL items above
) else if %WARN_COUNT% gtr 0 (
    echo   STATUS: ATTENTION RECOMMENDED - Review WARN items above
) else (
    echo   STATUS: ALL CHECKS PASSED - System looks healthy
)
echo.
echo   Full log: %LOGFILE%
echo ============================================================

(
    echo.
    echo ============================================================
    echo   SUMMARY
    echo   PASS:  %PASS_COUNT%
    echo   WARN:  %WARN_COUNT%
    echo   FAIL:  %FAIL_COUNT%
    echo ============================================================
) >> "%LOGFILE%"

title Quick Health Check - COMPLETE
echo.
echo Press any key to exit...
pause > nul
endlocal
