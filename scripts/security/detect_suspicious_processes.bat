@echo off
REM ============================================================
REM  detect_suspicious_processes.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Audit running processes for suspicious indicators
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  IMPORTANT: This is an EDUCATIONAL tool. Results require
REM             manual investigation. False positives are common.
REM             Do NOT delete files based solely on this output.
REM  Output:  Screen + timestamped log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  DISCLAIMER - displayed at startup
REM ============================================================
echo.
echo  ============================================================
echo     SECURITY NOTICE
echo  ============================================================
echo   This tool performs a READ-ONLY audit of running processes.
echo   Results are INFORMATIONAL ONLY and may contain false positives.
echo   NEVER delete files, terminate processes, or take action
echo   based solely on the output of this script without
echo   thorough manual investigation.
echo  ============================================================
echo.
timeout /t 3 /nobreak > nul

REM ============================================================
REM  SETUP: Log directory and timestamped filename
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\suspicious_processes_%LOGDATE%.txt"

title Suspicious Process Detection - Running...
color 0E

REM Write file header
(
    echo ============================================================
    echo   SUSPICIOUS PROCESS DETECTION REPORT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   NOTE: EDUCATIONAL TOOL - Manual verification required
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: All Running Processes with PIDs
REM ============================================================
echo.
echo [1/5] Enumerating all running processes...
echo       (See log file for full details)

call :WriteSection "ALL RUNNING PROCESSES"
(
    tasklist /fo table /v 2>nul
) >> "%LOGFILE%"

REM ============================================================
REM  SECTION 2: Processes with Network Connections
REM ============================================================
echo [2/5] Identifying processes with network connections...

call :WriteSection "PROCESSES WITH NETWORK CONNECTIONS"
(
    echo --- Active Connections with Process IDs ---
    netstat -ano 2>nul
    echo.
    echo --- Cross-reference: PID to Process Name ---
    echo (Match PIDs above to process names below)
    tasklist /fo table 2>nul
) >> "%LOGFILE%"

REM Show established connections on screen
echo.
echo   Established connections (PID shown - cross-reference with tasklist):
netstat -an 2>nul | findstr "ESTABLISHED"

REM ============================================================
REM  SECTION 3: Processes Running from Unusual Locations
REM ============================================================
echo.
echo [3/5] Checking executable paths (unusual locations)...
echo.
echo   ALERT: Processes found in potentially suspicious locations:
echo   (Legitimate software can also appear here - investigate carefully)

call :WriteSection "PROCESSES WITH EXECUTABLE PATHS"
(
    wmic process get name,processid,executablepath 2>nul
) >> "%LOGFILE%"

call :WriteSection "PROCESSES IN SUSPICIOUS LOCATIONS (requires investigation)"

REM Check for processes in TEMP directories
echo.
echo   --- Processes running from TEMP directories ---
wmic process get name,processid,executablepath 2>nul | findstr /i "temp" | findstr /v "^$"
(
    echo --- Processes in TEMP directories ---
    wmic process get name,processid,executablepath 2>nul | findstr /i "temp" | findstr /v "^$"
) >> "%LOGFILE%"

REM Check for processes in APPDATA
echo.
echo   --- Processes running from APPDATA ---
wmic process get name,processid,executablepath 2>nul | findstr /i "appdata" | findstr /v "^$"
(
    echo --- Processes in APPDATA ---
    wmic process get name,processid,executablepath 2>nul | findstr /i "appdata" | findstr /v "^$"
) >> "%LOGFILE%"

REM Check for processes in Downloads
echo.
echo   --- Processes running from Downloads folder ---
wmic process get name,processid,executablepath 2>nul | findstr /i "downloads" | findstr /v "^$"
(
    echo --- Processes in Downloads ---
    wmic process get name,processid,executablepath 2>nul | findstr /i "downloads" | findstr /v "^$"
) >> "%LOGFILE%"

REM Check for processes with no path (may indicate injection)
echo.
echo   --- Processes with no executable path (may warrant investigation) ---
wmic process get name,processid,executablepath 2>nul | findstr /v "ExecutablePath\|C:\\\|^$" | findstr /v "^\s*$"
(
    echo --- Processes with unusual/empty paths ---
    wmic process get name,processid,executablepath 2>nul | findstr /v "ExecutablePath\|C:\\\|^$"
) >> "%LOGFILE%"

REM ============================================================
REM  SECTION 4: Services and Processes
REM ============================================================
echo.
echo [4/5] Checking service-hosted processes...

call :WriteSection "SERVICES HOSTED IN SVCHOST PROCESSES"
(
    tasklist /svc 2>nul | findstr "svchost"
) >> "%LOGFILE%"

echo.
echo   Services per svchost.exe instance:
tasklist /svc 2>nul | findstr "svchost" | head

REM ============================================================
REM  SECTION 5: Parent Process Relationships
REM ============================================================
echo.
echo [5/5] Collecting parent process information...

call :WriteSection "PROCESS PARENT RELATIONSHIPS"
(
    wmic process get name,processid,parentprocessid,executablepath 2>nul
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
    echo   IMPORTANT NOTES:
    echo   1. This is an informational audit only
    echo   2. False positives are COMMON - always investigate manually
    echo   3. Search process names online before taking any action
    echo   4. Never delete files based solely on this output
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   SCAN COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   REMINDER: Investigate all findings manually before acting.
echo   False positives are common in security scans.
echo ============================================================
echo.
color 07
title Suspicious Process Detection - COMPLETE
echo Press any key to exit...
pause > nul
endlocal
goto :EOF

REM ============================================================
REM  HELPER: Write a section header to log file
REM ============================================================
:WriteSection
(
    echo.
    echo ============================================================
    echo   %~1
    echo ============================================================
) >> "%LOGFILE%"
goto :EOF
