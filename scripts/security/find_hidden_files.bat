@echo off
REM ============================================================
REM  find_hidden_files.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Find hidden/system files in common locations
REM           where malware often hides files
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  SAFETY:  READ-ONLY. No files are modified or deleted.
REM  IMPORTANT: False positives are common. Many legitimate
REM             Windows files are hidden+system. Investigate
REM             findings carefully before taking any action.
REM  Output:  Screen summary + log in Logs\ subfolder
REM ============================================================

setlocal enabledelayedexpansion

REM ============================================================
REM  DISCLAIMER
REM ============================================================
echo.
echo  ============================================================
echo     HIDDEN FILES FINDER - SECURITY AUDIT
echo     READ-ONLY SCAN - No files will be modified
REM  ============================================================
echo     NOTE: Many legitimate Windows files have hidden+system
echo     attributes. This scan is informational only. Do NOT
echo     delete any file found here without manual research.
echo  ============================================================
echo.

REM ============================================================
REM  SETUP: Log directory and filename
REM ============================================================
set "SCRIPTDIR=%~dp0"
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\hidden_files_%LOGDATE%.txt"

title Hidden Files Finder - Running...
color 0E

REM Write log header
(
    echo ============================================================
    echo   HIDDEN FILES AUDIT REPORT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   NOTE: READ-ONLY scan. Manual investigation required.
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: Hidden+System Files in User's TEMP folder
REM ============================================================
echo [1/6] Scanning TEMP folder for hidden/system files...

call :WriteSection "HIDDEN AND SYSTEM FILES IN USER TEMP"
(
    echo   Location: %TEMP%
    attrib "%TEMP%\*" /s 2>nul | findstr /r "^..H\|^.SH\|^..SH\|^S..H"
) >> "%LOGFILE%"

echo.
echo   --- Hidden files in %TEMP% ---
attrib "%TEMP%\*" /s 2>nul | findstr /i " H "

REM ============================================================
REM  SECTION 2: Executable Files in TEMP (suspicious)
REM ============================================================
echo.
echo [2/6] Checking for .exe and .bat files in TEMP...

call :WriteSection "EXECUTABLE FILES IN TEMP (requires investigation)"
(
    echo   Location: %TEMP%
    dir /s /b /a:-d "%TEMP%\*.exe" 2>nul
    dir /s /b /a:-d "%TEMP%\*.bat" 2>nul
    dir /s /b /a:-d "%TEMP%\*.ps1" 2>nul
    dir /s /b /a:-d "%TEMP%\*.vbs" 2>nul
    dir /s /b /a:-d "%TEMP%\*.cmd" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Executables in TEMP ---
echo   .EXE files:
dir /s /b /a:-d "%TEMP%\*.exe" 2>nul | find /c /v ""
echo   files found. (See log for list)

echo   .BAT/.PS1/.VBS files:
dir /s /b /a:-d "%TEMP%\*.bat" "%TEMP%\*.ps1" "%TEMP%\*.vbs" 2>nul | find /c /v ""
echo   files found. (See log for list)

REM ============================================================
REM  SECTION 3: Hidden Files in APPDATA
REM ============================================================
echo.
echo [3/6] Checking APPDATA for hidden/system files...

call :WriteSection "HIDDEN AND SYSTEM FILES IN APPDATA"
(
    echo   Scanning: %APPDATA%
    attrib "%APPDATA%\*" 2>nul | findstr /r "^..H\|^.SH\|^..SH"
    echo.
    echo   Executables in APPDATA root (not subdirs):
    dir /b /a:-d "%APPDATA%\*.exe" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Executables in APPDATA root ---
dir /b /a:-d "%APPDATA%\*.exe" 2>nul
if %ERRORLEVEL% neq 0 echo   None found.

REM ============================================================
REM  SECTION 4: Startup Locations
REM ============================================================
echo.
echo [4/6] Checking startup folder contents...

call :WriteSection "STARTUP FOLDER CONTENTS"
(
    echo   User Startup Folder: %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
    dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
    echo.
    echo   All Users Startup Folder: %PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp
    dir "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Files in User Startup folder ---
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
if %ERRORLEVEL% neq 0 echo   No startup items found in user startup folder.

echo.
echo   --- Files in All Users Startup folder ---
dir /b "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\StartUp" 2>nul
if %ERRORLEVEL% neq 0 echo   No startup items found in all users startup folder.

REM ============================================================
REM  SECTION 5: User Profile Root (unusual files)
REM ============================================================
echo.
echo [5/6] Checking user profile root for unexpected files...

call :WriteSection "FILES IN USER PROFILE ROOT"
(
    echo   Location: %USERPROFILE%
    dir /a:-d "%USERPROFILE%\*.exe" 2>nul
    dir /a:-d "%USERPROFILE%\*.bat" 2>nul
    dir /a:-d "%USERPROFILE%\*.ps1" 2>nul
    dir /a:-d "%USERPROFILE%\*.vbs" 2>nul
    echo.
    echo   Hidden files in profile root:
    dir /ah "%USERPROFILE%\*.*" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Executables in User Profile root ---
dir /a:-d /b "%USERPROFILE%\*.exe" "%USERPROFILE%\*.bat" "%USERPROFILE%\*.ps1" 2>nul
if %ERRORLEVEL% neq 0 echo   No executables found directly in user profile root.

REM ============================================================
REM  SECTION 6: C:\ root level hidden files (non-recursive)
REM ============================================================
echo.
echo [6/6] Checking C:\ root for hidden/system files...

call :WriteSection "HIDDEN AND SYSTEM FILES IN C: ROOT"
(
    echo   Location: C:\ (non-recursive)
    attrib "C:\*" 2>nul
    echo.
    echo   Hidden files at C: root:
    dir /ah /b "C:\*" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Attribute listing of C:\ root ---
attrib "C:\*" 2>nul | findstr /i " H "
echo   (Full list saved to log file)

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   SCAN COMPLETE
    echo   End Time: %DATE% %TIME%
    echo.
    echo   INVESTIGATION NOTES:
    echo   - Hidden+System files in Windows/System32 are NORMAL
    echo   - Executables in TEMP/APPDATA/Profile root are suspicious
    echo   - Research any unknown file before taking action
    echo   - Check VirusTotal.com for file hash lookup
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   HIDDEN FILES SCAN COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   Review findings carefully. Many hidden+system files are
echo   legitimate Windows components.
echo ============================================================
echo.
color 07
title Hidden Files Finder - COMPLETE
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
