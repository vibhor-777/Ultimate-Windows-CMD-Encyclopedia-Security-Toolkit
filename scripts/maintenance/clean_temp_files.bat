@echo off
REM ============================================================
REM  clean_temp_files.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Clean temporary files to free disk space
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for full cleanup
REM  ============================================================
REM  SAFETY: This script REQUIRES explicit user confirmation
REM          before deleting anything. It will NOT delete files
REM          without your express approval.
REM  ============================================================
REM  What it cleans (ONLY with your confirmation):
REM    - User TEMP folder (%TEMP%)
REM    - Windows Temp folder (%SystemRoot%\Temp)
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
set "LOGFILE=%LOGDIR%\temp_cleanup_%LOGDATE%.txt"

title Temp File Cleanup - Ready
color 0A

echo.
echo  ============================================================
echo     TEMPORARY FILE CLEANUP TOOL
echo     Computer : %COMPUTERNAME%
echo     User     : %USERNAME%
echo  ============================================================
echo.

REM Write log header
(
    echo ============================================================
    echo   TEMP FILE CLEANUP LOG
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  STEP 1: Show what will be cleaned (before view)
REM ============================================================
echo [INFO] Analysing temp folders before cleanup...
echo.

REM Count files in user TEMP
set USER_TEMP_COUNT=0
for /f %%n in ('dir /s /b "%TEMP%\*.*" 2^>nul ^| find /c /v ""') do set USER_TEMP_COUNT=%%n

REM Count files in Windows TEMP
set WIN_TEMP_COUNT=0
for /f %%n in ('dir /s /b "%SystemRoot%\Temp\*.*" 2^>nul ^| find /c /v ""') do set WIN_TEMP_COUNT=%%n

echo   User TEMP   (%TEMP%):
echo     Files found: %USER_TEMP_COUNT%
echo.
echo   Windows TEMP (%SystemRoot%\Temp):
echo     Files found: %WIN_TEMP_COUNT%

(
    echo.
    echo --- PRE-CLEANUP ANALYSIS ---
    echo User TEMP (%TEMP%): %USER_TEMP_COUNT% files
    echo Windows TEMP (%SystemRoot%\Temp): %WIN_TEMP_COUNT% files
) >> "%LOGFILE%"

REM ============================================================
REM  STEP 2: CONFIRMATION REQUIRED BEFORE ANY DELETION
REM ============================================================
echo.
echo ============================================================
echo   CONFIRMATION REQUIRED
echo ============================================================
echo.
echo   The following directories will have their CONTENTS deleted:
echo   1. %TEMP%
echo   2. %SystemRoot%\Temp
echo.
echo   NOTE: These are temporary file folders. The folders
echo   themselves will NOT be deleted, only their contents.
echo   Files in use (locked) will be skipped.
echo.
echo   Type YES (in capitals) to confirm and proceed.
echo   Type anything else or press Enter to CANCEL.
echo.
set /p CONFIRM=Your answer: 

if not "%CONFIRM%"=="YES" (
    echo.
    echo   Cleanup CANCELLED. No files were deleted.
    echo   CANCELLED by user >> "%LOGFILE%"
    echo.
    goto :Cancelled
)

echo.
echo   Confirmed. Proceeding with cleanup...
echo   CONFIRMED by user - proceeding with cleanup >> "%LOGFILE%"

REM ============================================================
REM  STEP 3: Clean User TEMP folder
REM ============================================================
echo.
echo [1/3] Cleaning user TEMP folder...
echo   %TEMP%

(
    echo.
    echo --- Cleaning User TEMP: %TEMP% ---
    echo Start Time: %TIME%
) >> "%LOGFILE%"

REM Delete files (errors suppressed - files in use are skipped)
del /q /f /s "%TEMP%\*.*" 2>nul
echo   Files deleted (in-use files were skipped).

REM Try to remove empty subdirectories
for /d %%d in ("%TEMP%\*") do (
    rd /s /q "%%d" 2>nul
)

REM Count remaining files
set USER_TEMP_AFTER=0
for /f %%n in ('dir /s /b "%TEMP%\*.*" 2^>nul ^| find /c /v ""') do set USER_TEMP_AFTER=%%n

echo   Files remaining (in use, cannot delete): %USER_TEMP_AFTER%
(
    echo Files remaining (locked/in-use): %USER_TEMP_AFTER%
) >> "%LOGFILE%"

REM ============================================================
REM  STEP 4: Clean Windows TEMP folder (requires Admin)
REM ============================================================
echo.
echo [2/3] Cleaning Windows TEMP folder...
echo   %SystemRoot%\Temp

(
    echo.
    echo --- Cleaning Windows TEMP: %SystemRoot%\Temp ---
    echo Start Time: %TIME%
) >> "%LOGFILE%"

del /q /f /s "%SystemRoot%\Temp\*.*" 2>nul
echo   Files deleted (in-use files skipped, admin rights needed for some).

for /d %%d in ("%SystemRoot%\Temp\*") do (
    rd /s /q "%%d" 2>nul
)

set WIN_TEMP_AFTER=0
for /f %%n in ('dir /s /b "%SystemRoot%\Temp\*.*" 2^>nul ^| find /c /v ""') do set WIN_TEMP_AFTER=%%n

echo   Files remaining (in use, cannot delete): %WIN_TEMP_AFTER%
(
    echo Files remaining (locked/in-use): %WIN_TEMP_AFTER%
) >> "%LOGFILE%"

REM ============================================================
REM  STEP 5: Windows Disk Cleanup (cleanmgr)
REM ============================================================
echo.
echo [3/3] Windows Disk Cleanup information...

echo.
echo   Windows Disk Cleanup (cleanmgr) can remove additional items:
echo   browser cache, old Windows Update files, recycle bin, etc.
echo.
echo   To run an automated cleanup, you must first configure it:
echo.
echo   Step A (run once to configure, requires admin):
echo     cleanmgr /sageset:1
echo     (Select categories in the dialog, then close)
echo.
echo   Step B (run the configured cleanup):
echo     cleanmgr /sagerun:1
echo.
set /p RUNDISKCLEAN=Run Disk Cleanup now? (Y/N): 
if /i "%RUNDISKCLEAN%"=="Y" (
    echo   Launching Disk Cleanup for C: drive...
    cleanmgr /d C: 2>nul
    echo   Disk Cleanup launched (respond to any dialogs).
    echo   Disk Cleanup launched by user >> "%LOGFILE%"
) else (
    echo   Disk Cleanup skipped.
    echo   Disk Cleanup skipped by user >> "%LOGFILE%"
)

REM ============================================================
REM  SUMMARY
REM ============================================================
echo.
echo ============================================================
echo   CLEANUP SUMMARY
echo ============================================================
echo.
echo   User TEMP:
echo     Before: %USER_TEMP_COUNT% files
echo     After : %USER_TEMP_AFTER% files remaining (in use)
echo.
echo   Windows TEMP:
echo     Before: %WIN_TEMP_COUNT% files
echo     After : %WIN_TEMP_AFTER% files remaining (in use)
echo.
echo   Log: %LOGFILE%
echo ============================================================

(
    echo.
    echo ============================================================
    echo   CLEANUP SUMMARY
    echo   User TEMP before: %USER_TEMP_COUNT%  after: %USER_TEMP_AFTER%
    echo   Windows TEMP before: %WIN_TEMP_COUNT%  after: %WIN_TEMP_AFTER%
    echo   Completed: %DATE% %TIME%
    echo ============================================================
) >> "%LOGFILE%"

goto :End

:Cancelled
echo.
echo  No changes were made to your system.
echo  Cancellation recorded in log: %LOGFILE%
echo.

:End
color 07
title Temp File Cleanup - COMPLETE
echo Press any key to exit...
pause > nul
endlocal
