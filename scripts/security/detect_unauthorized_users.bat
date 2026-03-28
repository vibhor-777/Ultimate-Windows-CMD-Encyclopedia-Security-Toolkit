@echo off
REM ============================================================
REM  detect_unauthorized_users.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: Audit local user accounts and group memberships
REM  Author:  vibhor-777
REM  Version: 1.0
REM  Usage:   Run as Administrator for complete results
REM  SAFETY:  READ-ONLY. No accounts are created, modified,
REM           or deleted.
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
set "LOGFILE=%LOGDIR%\user_audit_%LOGDATE%.txt"

title User Account Audit - Running...
color 0A

echo.
echo  ============================================================
echo     USER ACCOUNT SECURITY AUDIT
echo     Computer : %COMPUTERNAME%
echo     Date     : %DATE%
echo     READ-ONLY scan - no accounts modified
echo  ============================================================
echo.

REM Write log header
(
    echo ============================================================
    echo   USER ACCOUNT SECURITY AUDIT
    echo   Computer : %COMPUTERNAME%
    echo   User     : %USERDOMAIN%\%USERNAME%
    echo   Date     : %DATE%  Time: %TIME%
    echo   READ-ONLY - No accounts modified
    echo ============================================================
) > "%LOGFILE%"

REM ============================================================
REM  SECTION 1: All Local User Accounts
REM ============================================================
echo [1/8] Enumerating all local user accounts...

call :WriteSection "ALL LOCAL USER ACCOUNTS"
(
    echo --- NET USER Listing ---
    net user 2>nul
    echo.
    echo --- Detailed WMIC Account Info ---
    wmic useraccount get name,sid,disabled,lockout,fullname,passwordrequired,passwordexpires 2>nul
) >> "%LOGFILE%"

echo.
echo   --- All Local Users ---
net user 2>nul
echo.
echo   --- Account Status (Disabled/Locked) ---
wmic useraccount get name,disabled,lockout 2>nul

REM ============================================================
REM  SECTION 2: Members of Administrators Group
REM ============================================================
echo.
echo [2/8] Listing members of Administrators group...

call :WriteSection "MEMBERS OF ADMINISTRATORS GROUP"
(
    net localgroup Administrators 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Administrators Group Members ---
net localgroup Administrators 2>nul
echo.
echo   NOTE: Only known, authorised accounts should be listed above.
echo         Investigate any unexpected accounts.

REM ============================================================
REM  SECTION 3: Remote Desktop Users
REM ============================================================
echo.
echo [3/8] Listing Remote Desktop Users...

call :WriteSection "MEMBERS OF REMOTE DESKTOP USERS GROUP"
(
    net localgroup "Remote Desktop Users" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Remote Desktop Users ---
net localgroup "Remote Desktop Users" 2>nul
if %ERRORLEVEL% neq 0 echo   Group not found or no members.

REM ============================================================
REM  SECTION 4: Power Users Group
REM ============================================================
echo.
echo [4/8] Listing Power Users group...

call :WriteSection "MEMBERS OF POWER USERS GROUP"
(
    net localgroup "Power Users" 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Power Users ---
net localgroup "Power Users" 2>nul
if %ERRORLEVEL% neq 0 echo   Group not found or empty.

REM ============================================================
REM  SECTION 5: Guest Account Status
REM ============================================================
echo.
echo [5/8] Checking Guest account status...

call :WriteSection "GUEST ACCOUNT STATUS"
(
    net user Guest 2>nul
) >> "%LOGFILE%"

net user Guest 2>nul | findstr "Account active" > nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%a in ('net user Guest 2^>nul ^| findstr "Account active"') do (
        echo   --- Guest Account: %%a ---
        echo %%a >> "%LOGFILE%"
    )
    REM Check if it's actually active (enabled)
    net user Guest 2>nul | findstr "Account active" | findstr "Yes" > nul
    if !ERRORLEVEL! equ 0 (
        echo.
        echo   [SECURITY ALERT] Guest account is ENABLED!
        echo   Recommendation: Disable Guest account unless specifically required.
        echo   [ALERT] Guest account is ENABLED >> "%LOGFILE%"
    ) else (
        echo   [OK] Guest account is DISABLED (recommended setting)
        echo   [OK] Guest account is disabled >> "%LOGFILE%"
    )
) else (
    echo   Guest account not found or cannot be queried.
)

REM ============================================================
REM  SECTION 6: Disabled Accounts
REM ============================================================
echo.
echo [6/8] Listing disabled accounts...

call :WriteSection "DISABLED USER ACCOUNTS"
(
    wmic useraccount where disabled=true get name,fullname,sid 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Disabled Accounts ---
wmic useraccount where disabled=true get name,fullname 2>nul

REM ============================================================
REM  SECTION 7: Currently Logged-on Users
REM ============================================================
echo.
echo [7/8] Checking currently logged-on users...

call :WriteSection "CURRENTLY LOGGED-ON USERS"
(
    echo --- Query User Sessions ---
    query user 2>nul
    echo.
    echo --- Query Sessions ---
    query session 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Currently Logged-on Users ---
query user 2>nul
if %ERRORLEVEL% neq 0 echo   Could not enumerate sessions (may need admin rights).

REM ============================================================
REM  SECTION 8: Accounts with Security Concerns
REM ============================================================
echo.
echo [8/8] Checking for security-relevant account settings...

call :WriteSection "ACCOUNT SECURITY CONCERNS"
(
    echo --- Accounts Not Requiring Password ---
    wmic useraccount where passwordrequired=false get name,fullname 2>nul
    echo.
    echo --- Accounts with Non-Expiring Passwords ---
    wmic useraccount where passwordexpires=false get name,fullname 2>nul
    echo.
    echo --- Locked Out Accounts ---
    wmic useraccount where lockout=true get name,fullname 2>nul
    echo.
    echo --- Account Policy ---
    net accounts 2>nul
) >> "%LOGFILE%"

echo.
echo   --- Accounts NOT requiring a password ---
wmic useraccount where passwordrequired=false get name 2>nul

echo.
echo   --- Accounts with non-expiring passwords ---
wmic useraccount where passwordexpires=false get name 2>nul

echo.
echo   --- Current account policy ---
net accounts 2>nul

REM ============================================================
REM  SUMMARY
REM ============================================================
(
    echo.
    echo ============================================================
    echo   AUDIT COMPLETE
    echo   End Time: %DATE% %TIME%
    echo.
    echo   KEY SECURITY CHECKS:
    echo   [x] Are there unexpected members in Administrators group?
    echo   [x] Is the Guest account disabled?
    echo   [x] Are there accounts with blank passwords?
    echo   [x] Are there unrecognised user accounts?
    echo   [x] Are there unexpected active sessions?
    echo.
    echo   Contact your IT security team if you find anomalies.
    echo ============================================================
) >> "%LOGFILE%"

echo.
echo ============================================================
echo   USER AUDIT COMPLETE
echo   Report saved to: %LOGFILE%
echo.
echo   Review the following key security questions:
echo   1. Are all accounts in Administrators group authorised?
echo   2. Is the Guest account disabled?
echo   3. Are there any accounts you don't recognise?
echo ============================================================
echo.
color 07
title User Account Audit - COMPLETE
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
