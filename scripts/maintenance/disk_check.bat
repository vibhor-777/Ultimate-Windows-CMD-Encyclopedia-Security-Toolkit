@echo off
REM ============================================================
REM  disk_check.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Comprehensive disk health and space check
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for full results
REM  ============================================================
REM  SAFETY: This script performs READ-ONLY checks only.
REM          CHKDSK is run WITHOUT /f or /r flags, so no repairs
REM          are made and no reboot is required.
REM          No disk data is modified.
REM  ============================================================
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
set "LOGFILE=%LOGDIR%\disk_check_%LOGDATE%.txt"

title Disk Check - Running...
color 0A

echo.
echo  ============================================================
echo     DISK HEALTH CHECK
echo     Computer : %COMPUTERNAME%
echo     Date     : %DATE%
echo     READ-ONLY check - no repairs performed
echo  ============================================================
echo.

REM Write log header
(
    echo ============================================================
    echo   DISK HEALTH CHECK
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   READ-ONLY - CHKDSK without /f or /r flags
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: Logical Drive Space and Information
REM ============================================================
echo [1/5] Checking logical drive space...

call :WriteSection "LOGICAL DRIVE INFORMATION"
(
    echo --- Drive Space (WMIC) ---
    wmic logicaldisk get deviceid,drivetype,size,freespace,filesystem,volumename 2>nul
    echo.
    echo --- Volume Details ---
    wmic volume get name,capacity,freespace,filesystem,label,drivetype 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Drive Space Summary ---
wmic logicaldisk get deviceid,size,freespace,filesystem 2>nul

REM Use PowerShell for human-readable sizes
echo.
echo   --- Human-Readable Drive Space ---
powershell -NoProfile -Command "Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, @{N='Size_GB';E={[math]::Round($_.Size/1GB,2)}}, @{N='Free_GB';E={[math]::Round($_.FreeSpace/1GB,2)}}, @{N='Free_Pct';E={[math]::Round($_.FreeSpace/$_.Size*100,1)}} | Format-Table -AutoSize" 2>nul

REM Alert if any drive is low on space
for /f "skip=1 tokens=1,2,3" %%a in ('wmic logicaldisk where "drivetype=3" get deviceid,freespace,size 2^>nul') do (
    if not "%%b"=="" if not "%%c"=="" (
        REM Use PowerShell to check percentage
        for /f %%p in ('powershell -command "[math]::Round(%%b/%%c*100,0)" 2^>nul') do (
            if %%p lss 10 (
                echo   [WARNING] Drive %%a has only %%p%% free space!
            )
        )
    )
)

REM ============================================================
REM  SECTION 2: Physical Disk Status (SMART via WMIC)
REM ============================================================
echo.
echo [2/5] Checking physical disk health (SMART status)...

call :WriteSection "PHYSICAL DISK SMART STATUS"
(
    wmic diskdrive get status,model,size,serialnumber,interfacetype,mediatype 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Physical Disk SMART Status ---
echo   (Status should be 'OK' for healthy drives)
wmic diskdrive get status,model 2>nul

REM Alert for any non-OK status
for /f "skip=1 tokens=*" %%s in ('wmic diskdrive get status 2^>nul') do (
    echo %%s | findstr /v "OK\|^$\|Status" > nul
    if !ERRORLEVEL! equ 0 (
        echo   [WARNING] Disk health may be degraded! Status: %%s
    )
)

REM ============================================================
REM  SECTION 3: Read-Only CHKDSK on C:
REM ============================================================
echo.
echo [3/5] Running read-only CHKDSK on C: (no repairs)...
echo   (This may take a few minutes for large volumes)
echo.
echo   NOTE: Running WITHOUT /f or /r - read-only, no repairs,
echo         no reboot required.

call :WriteSection "CHKDSK C: (Read-Only - No Repairs)"
(
    echo Running: chkdsk C: (no /f or /r flags - read-only)
    chkdsk C: 2>&1
) >> "%LOGFILE%"

echo.
echo   CHKDSK results:
chkdsk C: 2>nul | findstr /i "error\|problem\|found\|clean\|Windows has"

REM ============================================================
REM  SECTION 4: Disk Dirty Flag Check
REM ============================================================
echo.
echo [4/5] Checking if volumes are flagged for chkdsk...

call :WriteSection "VOLUME DIRTY FLAGS (scheduled chkdsk check)"
(
    echo --- Checking dirty flag for mounted volumes ---
) >> "%LOGFILE%"

echo.
echo   --- Dirty volume check ---
for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "drivetype=3" get deviceid 2^>nul') do (
    if not "%%d"=="" (
        fsutil dirty query %%d 2>nul
        echo %%d: >> "%LOGFILE%"
        fsutil dirty query %%d 2>nul >> "%LOGFILE%"
    )
)

REM ============================================================
REM  SECTION 5: Volume Details
REM ============================================================
echo.
echo [5/5] Collecting volume and filesystem details...

call :WriteSection "VOLUME AND FILESYSTEM DETAILS"
(
    echo --- Volume Serial Numbers and Labels ---
    for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "drivetype=3" get deviceid 2^>nul') do (
        if not "%%d"=="" (
            echo.
            echo Volume %%d:
            vol %%d 2>nul
            fsutil fsinfo volumeinfo %%d 2>nul
        )
    )
) >> "%LOGFILE%"

echo.
echo   --- Volume Labels and Serial Numbers ---
for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where "drivetype=3" get deviceid 2^>nul') do (
    if not "%%d"=="" vol %%d 2>nul
)

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   CHECK COMPLETE
    echo   End Time: %DATE% %TIME%
    echo.
    echo   WHAT TO DO IF ISSUES FOUND:
    echo   - CHKDSK errors: run 'chkdsk C: /f' (requires reboot for C:)
    echo   - SMART status not OK: back up data immediately, replace disk
    echo   - Low disk space: run clean_temp_files.bat, clean up files
    echo   - Dirty flag set: disk will be checked at next reboot
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   DISK CHECK COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   If CHKDSK reported errors, run with /f flag to repair
echo   (requires Administrator and reboot for C: drive)
echo ============================================================
echo.
color 07
title Disk Check - COMPLETE
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
