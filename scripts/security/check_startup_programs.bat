@echo off
REM ============================================================
REM  check_startup_programs.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Audit all programs configured to run at startup
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  SAFETY:  READ-ONLY. Uses REG QUERY only (no REG ADD/DELETE).
REM           Does NOT modify any registry keys or startup items.
REM  Output:  Screen summary + log in Logs\ subfolder
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
set "LOGFILE=%LOGDIR%\startup_programs_%LOGDATE%.txt"

title Startup Programs Audit - Running...
color 0A

echo.
echo  ============================================================
echo     STARTUP PROGRAMS AUDIT
echo     Computer : %COMPUTERNAME%
echo     Date     : %DATE%
echo     READ-ONLY scan - no changes will be made
echo  ============================================================
echo.

REM Write log header
(
    echo ============================================================
    echo   STARTUP PROGRAMS AUDIT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   READ-ONLY scan - registry not modified
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: HKLM\Run (Machine-wide startup, all users)
REM ============================================================
echo [1/8] Checking HKLM Run registry key...

call :WriteSection "REGISTRY: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run (All Users)"
(
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- HKLM Run (system-wide startup) ---
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
if %ERRORLEVEL% neq 0 echo   No entries found or access denied.

REM ============================================================
REM  SECTION 2: HKCU\Run (Current user startup)
REM ============================================================
echo.
echo [2/8] Checking HKCU Run registry key...

call :WriteSection "REGISTRY: HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run (Current User)"
(
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- HKCU Run (current user startup) ---
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
if %ERRORLEVEL% neq 0 echo   No entries found.

REM ============================================================
REM  SECTION 3: HKLM\RunOnce (one-time startup, all users)
REM ============================================================
echo.
echo [3/8] Checking RunOnce registry keys...

call :WriteSection "REGISTRY: HKLM RunOnce and HKCU RunOnce"
(
    echo [HKLM RunOnce]
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" 2>nul
    echo.
    echo [HKCU RunOnce]
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" 2>nul
    echo.
    REM Check 64/32 bit views on 64-bit Windows
    echo [HKLM RunOnce - 32-bit view]
    reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- HKLM RunOnce entries ---
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" 2>nul
if %ERRORLEVEL% neq 0 echo   No entries found.

REM ============================================================
REM  SECTION 4: User Startup Folder
REM ============================================================
echo.
echo [4/8] Checking User Startup folder...

call :WriteSection "USER STARTUP FOLDER"
(
    echo   Path: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
    dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Files in User Startup folder ---
echo   Path: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
if %ERRORLEVEL% neq 0 echo   Folder is empty or does not exist.

REM ============================================================
REM  SECTION 5: All Users Startup Folder
REM ============================================================
echo.
echo [5/8] Checking All Users Startup folder...

call :WriteSection "ALL USERS STARTUP FOLDER"
(
    echo   Path: %PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp
    dir "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Files in All Users Startup folder ---
echo   Path: %PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp
dir /b "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp" 2>nul
if %ERRORLEVEL% neq 0 echo   Folder is empty or does not exist.

REM ============================================================
REM  SECTION 6: Scheduled Tasks
REM ============================================================
echo.
echo [6/8] Enumerating scheduled tasks...

call :WriteSection "SCHEDULED TASKS"
(
    schtasks /query /fo list 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Scheduled Tasks Summary ---
schtasks /query /fo table /nh 2>nul | find /c /v ""
echo   scheduled tasks found. (Full list in log file)

REM Show tasks that run at logon or startup
echo.
echo   --- Tasks that run at Logon/Startup ---
schtasks /query /fo list 2>nul | findstr /i "logon\|startup\|boot" 

REM ============================================================
REM  SECTION 7: Auto-Start Services
REM ============================================================
echo.
echo [7/8] Listing auto-start services...

call :WriteSection "SERVICES SET TO AUTO-START"
(
    wmic service where startmode="auto" get name,displayname,state,startmode 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Auto-start services and their current state ---
wmic service where startmode="auto" get name,state 2>nul | findstr /v "^$"

REM ============================================================
REM  SECTION 8: WMIC Startup Items (from MSConfig perspective)
REM ============================================================
echo.
echo [8/8] Checking WMIC startup list...

call :WriteSection "WMIC STARTUP ITEMS"
(
    wmic startup list full 2>nul
) >> "%LOGFILE%"

echo.
echo   --- WMIC Startup Programs ---
wmic startup list brief 2>nul

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   AUDIT COMPLETE
    echo   End Time: %DATE% %TIME%
    echo.
    echo   WHAT TO LOOK FOR:
    echo   - Programs you do not recognize in Run keys
    echo   - Unknown files in startup folders
    echo   - Suspicious scheduled tasks (e.g., running scripts from TEMP)
    echo   - Services with unusual names or paths
    echo.
    echo   INVESTIGATION TOOLS:
    echo   - Search process/program names online
    echo   - Check file paths in WMIC process output
    echo   - Use Autoruns (Sysinternals) for comprehensive startup audit
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   STARTUP AUDIT COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   Review all findings. Unknown startup items should be
echo   researched online before taking any action.
echo ============================================================
echo.
color 07
title Startup Programs Audit - COMPLETE
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
