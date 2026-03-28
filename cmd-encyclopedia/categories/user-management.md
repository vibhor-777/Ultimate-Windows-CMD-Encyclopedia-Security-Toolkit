# User Management Commands — Category Guide

A comprehensive guide to managing user accounts and permissions from the Windows Command Prompt.

---

## Overview

User account management is critical for both administration and security. This guide covers listing, creating, modifying, and auditing user accounts and group memberships using built-in CMD tools.

---

## 1. Listing Users

### Local User Accounts

```cmd
REM List all local users (brief)
net user

REM Detailed info for a specific user
net user john.smith

REM List via WMIC (more detail)
wmic useraccount list brief

REM List with SIDs
wmic useraccount get name,sid,disabled,fullname

REM List disabled accounts
wmic useraccount where disabled=true get name,fullname

REM List accounts with no password required
wmic useraccount where passwordrequired=false get name

REM List locked out accounts
wmic useraccount where lockout=true get name
```

### Domain Users (Domain-Joined Systems)

```cmd
REM List domain users
net user /domain

REM Info for a specific domain user
net user john.smith /domain

REM Query Active Directory
dsquery user -limit 0

REM Find disabled domain accounts
dsquery user -disabled
```

---

## 2. Creating Users

```cmd
REM Create a new local user
net user newuser Password123! /add

REM Create with full name and comment
net user newuser Password123! /add /fullname:"New User" /comment:"Department: IT"

REM Create and set password never expires
net user newuser Password123! /add /passwordchg:yes /expires:never

REM Create and specify home directory
net user newuser Password123! /add /homedir:C:\Users\newuser

REM Create an account that requires password change at first logon
net user newuser TempPass123! /add /logonpasswordchg:yes
```

> ⚠️ Never store passwords in scripts or log files. Use prompts or secure credential stores instead.

```bat
REM Safer: prompt for password
set /p NEWUSER=Enter new username:
net user %NEWUSER% * /add
REM The * causes net user to prompt for password (hides input)
```

---

## 3. Modifying Users

```cmd
REM Change a user's password
net user john.smith NewPassword123!

REM Disable an account
net user john.smith /active:no

REM Enable an account
net user john.smith /active:yes

REM Set account expiry
net user john.smith /expires:12/31/2024

REM Remove account expiry
net user john.smith /expires:never

REM Set password expiry policy
net user john.smith /passwordchg:yes

REM Unlock a locked account
net user john.smith /active:yes

REM Set logon hours (e.g., weekdays 8am-6pm)
net user john.smith /times:M-F,08:00-18:00

REM Remove logon hour restrictions
net user john.smith /times:all
```

---

## 4. Deleting Users

```cmd
REM Delete a local user account
net user john.smith /delete

REM Delete via WMIC
wmic useraccount where name="john.smith" delete
```

> ⚠️ Deleting a user account deletes their security identifier (SID). If the account is recreated with the same name, it gets a NEW SID and loses access to resources tied to the old SID.

---

## 5. Group Management

### Viewing Groups

```cmd
REM List all local groups
net localgroup

REM List members of a specific group
net localgroup Administrators
net localgroup "Remote Desktop Users"
net localgroup "Power Users"
net localgroup Users

REM List all groups via WMIC
wmic group list brief
```

### Managing Group Membership

```cmd
REM Add user to a group
net localgroup Administrators john.smith /add
net localgroup "Remote Desktop Users" john.smith /add

REM Remove user from a group
net localgroup Administrators john.smith /delete

REM Create a new group
net localgroup "Help Desk" /add /comment:"Help Desk Team"

REM Delete a group
net localgroup "OldGroup" /delete
```

### Domain Groups (Domain-Joined Systems)

```cmd
REM List domain group members
net group /domain

REM List members of a specific domain group
net group "Domain Admins" /domain

REM Add user to domain group (requires domain admin)
net group "Domain Admins" john.smith /add /domain
```

---

## 6. Permissions and Access Control

### Viewing Permissions

```cmd
REM View folder permissions
icacls "C:\MyFolder"

REM View permissions recursively
icacls "C:\MyFolder" /t

REM View permissions for a specific file
icacls "C:\Windows\System32\cmd.exe"
```

### Setting Permissions

```cmd
REM Grant user read+execute access
icacls "C:\MyFolder" /grant DOMAIN\john:(RX)

REM Grant with inheritance (for folder contents)
icacls "C:\MyFolder" /grant DOMAIN\john:(OI)(CI)(RX)

REM Grant administrator full control recursively
icacls "C:\MyFolder" /grant Administrators:(OI)(CI)F /t

REM Grant user modify (read, write, execute, delete)
icacls "C:\MyFolder" /grant DOMAIN\john:(M)
```

### Removing Permissions

```cmd
REM Remove a specific user's explicit permissions
icacls "C:\MyFolder" /remove DOMAIN\john

REM Reset to inherited permissions only
icacls "C:\MyFolder" /reset /t

REM Save current permissions (for backup)
icacls "C:\MyFolder" /save acl_backup.txt /t

REM Restore saved permissions
icacls "C:\MyFolder" /restore acl_backup.txt
```

### Taking Ownership

```cmd
REM Take ownership of a file/folder (requires admin)
takeown /f "C:\OrphanedFolder" /r /d y

REM Then grant yourself full control
icacls "C:\OrphanedFolder" /grant %USERNAME%:F /t
```

**Command:** `ICACLS` — See [I.md](../I.md)

---

## 7. Running as Another User

```cmd
REM Run a command as Administrator
runas /user:Administrator "cmd.exe"

REM Run as a different user
runas /user:testaccount "notepad.exe"

REM Run as domain admin
runas /user:DOMAIN\admin "mmc.exe"

REM Run with network credentials only (useful for accessing network resources)
runas /netonly /user:DOMAIN\admin "explorer.exe"
```

**Command:** `RUNAS` — See [R.md](../R.md)

---

## 8. Querying Logged-on Users

### Current Sessions

```cmd
REM Show all logged-on users
query user

REM Show sessions on remote server
query user /server:RDSERVER01

REM Show all sessions (including disconnected)
query session

REM Show session details
qwinsta
```

### Recent Logons (via WMIC)

```cmd
REM Show network logon info
wmic netlogin get name,lastlogon,logonserver,numberOfLogons

REM Show user profile info
wmic userprofile list brief
```

---

## 9. Security Audit — User Account Checks

### Comprehensive User Audit

```bat
@echo off
echo ===== USER ACCOUNT SECURITY AUDIT =====
echo.
echo --- Local User Accounts ---
net user
echo.
echo --- Members of Administrators Group ---
net localgroup Administrators
echo.
echo --- Members of Remote Desktop Users ---
net localgroup "Remote Desktop Users"
echo.
echo --- Guest Account Status ---
net user Guest | findstr "Account active"
echo.
echo --- Disabled Accounts ---
wmic useraccount where disabled=true get name
echo.
echo --- Accounts with No Password ---
wmic useraccount where passwordrequired=false get name
echo.
echo --- Currently Logged-on Users ---
query user
echo.
```

### Checking for Privilege Abuse

```cmd
REM Who has administrator rights?
net localgroup Administrators

REM What privileges does current user have?
whoami /priv

REM Check if any local accounts besides built-in admin are in Admins group
net localgroup Administrators | findstr /v /i "Administrator\|The command"
```

---

## 10. Account Policies (Local)

```cmd
REM View current account policies
net accounts

REM Set password age (max 90 days)
net accounts /maxpwage:90

REM Set minimum password length
net accounts /minpwlen:8

REM Set lockout threshold (5 bad attempts)
net accounts /lockoutthreshold:5

REM Set lockout duration (30 minutes)
net accounts /lockoutduration:30
```

> **Note:** Domain-joined computers have these settings controlled by Group Policy. Check with `GPRESULT /R` to see the effective policies.

---

## 11. Quick Reference: User Management Commands

| Task | Command | Notes |
|---|---|---|
| List all users | `net user` | |
| User details | `net user username` | |
| Create user | `net user newuser * /add` | `*` prompts for password |
| Delete user | `net user username /delete` | |
| Disable user | `net user username /active:no` | |
| List groups | `net localgroup` | |
| Group members | `net localgroup groupname` | |
| Add to group | `net localgroup group user /add` | |
| Remove from group | `net localgroup group user /delete` | |
| View permissions | `icacls path` | |
| Grant permission | `icacls path /grant User:(RX)` | |
| Run as user | `runas /user:username program` | |
| Who am I | `whoami /all` | |
| Logged-on users | `query user` | |
| Account policies | `net accounts` | |

---

*Related guides:*
- [system-info.md](system-info.md) — System info including user sessions
- [file-management.md](file-management.md) — File permissions
- [networking.md](networking.md) — Network authentication
