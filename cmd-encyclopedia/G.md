# CMD Encyclopedia — Commands Starting with G

---

## GOTO

### Command Name
`GOTO` — Jump to a labelled section of a batch file

### Syntax
```
GOTO label
GOTO :EOF
```

### Description
**Simple:** Makes a batch script jump to a specific labelled section, skipping over everything in between — the batch equivalent of a jump statement.

**Technical:** `GOTO` transfers execution to the line immediately after `:label` in the current batch file. Labels are defined with a colon prefix (`:mylabel`) and must be on their own line. `GOTO :EOF` is a special case (using CMD's implicit end-of-file label) that exits the current script or subroutine — equivalent to `EXIT /B`. Used extensively for creating menu systems, conditional branching, and subroutine-like structures in batch scripts.

### Example Usage
```bat
@echo off
echo Starting...
goto MainProcess

:ErrorHandler
echo An error occurred!
exit /b 1

:MainProcess
echo Doing main work...
if %ERRORLEVEL% neq 0 goto ErrorHandler
echo Done!
goto :EOF

:SubRoutine
echo This is a subroutine
goto :EOF
```

```bat
REM Menu system using GOTO
:menu
echo 1. Option A
echo 2. Option B
set /p choice=Enter choice:
if "%choice%"=="1" goto optionA
if "%choice%"=="2" goto optionB
echo Invalid choice
goto menu

:optionA
echo You chose A
goto :EOF

:optionB
echo You chose B
goto :EOF
```

### Common Mistakes
- Jumping to a label that doesn't exist — causes the script to terminate with an error
- Using GOTO inside a FOR loop or IF block in complex ways — can cause unexpected behaviour; consider using subroutines with CALL instead
- Forgetting that GOTO searches forward then wraps to the beginning of the file

### Related Commands
`CALL`, `IF`, `EXIT`, `FOR`

---

## GPRESULT

### Command Name
`GPRESULT` — Display Group Policy settings and Resultant Set of Policy (RSoP)

### Syntax
```
gpresult [/s computer] [/u domain\user] [/p password] [/user targetusername] [/scope {user|computer}] [/v] [/z] [/h HTMLfile] [/f] [/r]
```
| Switch | Meaning |
|---|---|
| `/r` | Summary of applied policies |
| `/v` | Verbose — all policy settings |
| `/z` | Super verbose — all GPO details |
| `/h file` | Output as HTML report |
| `/scope user` | Show only user policy |
| `/scope computer` | Show only computer policy |

### Description
**Simple:** Shows which Group Policy settings are applied to the current computer and user — essential for troubleshooting why a setting is enforced or why something is blocked.

**Technical:** `GPRESULT` queries the Group Policy infrastructure (WMI and the Policy engine) to report the Resultant Set of Policy (RSoP) — the net effect after all GPOs (Group Policy Objects) have been merged according to precedence (Local → Site → Domain → OU). It identifies which GPO is responsible for each setting, enabling administrators to diagnose policy conflicts and enforcement issues. Requires domain membership for domain policy; works with local policy on non-domain machines.

### Example Usage
```cmd
REM Summary of applied group policies
gpresult /r

REM Full verbose output
gpresult /v

REM Generate an HTML report (recommended for review)
gpresult /h C:\Reports\gp_report.html /f

REM Show computer policy only
gpresult /scope computer /v

REM Check policy for a specific user
gpresult /user DOMAIN\john.smith /v

REM Query remote computer
gpresult /s REMOTE-PC /r
```

### Output Explanation
```
RSOP data for DOMAIN\JohnSmith on WORKSTATION-01
OS Configuration:           Member Workstation
OS Version:                 10.0.22631
Group Policy was applied from: DC01.company.com
Group Policy slow link threshold:  500 kbps
Domain Name:                COMPANY
...
Applied Group Policy Objects
-----------------------------
    Corporate Security Policy
    Default Domain Policy
```

### Related Commands
`GPUPDATE`, `AUDITPOL`, `SECEDIT`, PowerShell `Get-GPResultantSetOfPolicy`

---

## GPUPDATE

### Command Name
`GPUPDATE` — Refresh Group Policy settings

### Syntax
```
gpupdate [/target:{computer|user}] [/force] [/wait:value] [/logoff] [/boot] [/sync]
```
| Switch | Meaning |
|---|---|
| `/force` | Reapply all policy settings even if unchanged |
| `/target:computer` | Update only computer policy |
| `/target:user` | Update only user policy |
| `/logoff` | Log off after update (for policies requiring logoff) |
| `/boot` | Reboot after update (for policies requiring reboot) |
| `/wait:N` | Wait N seconds for policy processing (0 = no wait) |

### Description
**Simple:** Forces Windows to immediately download and apply the latest Group Policy settings from the domain controller, instead of waiting for the normal refresh interval (typically 90–120 minutes).

**Technical:** Windows automatically refreshes Group Policy every 90 minutes (± 30-minute random offset) for users and computers. `GPUPDATE` triggers an immediate refresh by calling the Policy Engine (`gpEdit.dll` / Group Policy Client service). `/force` is needed when testing policy changes because without it, only changed policies are reapplied. Some policy settings (folder redirection, software installation) only take effect at logon/boot even with `/force`.

### Example Usage
```cmd
REM Refresh all policies immediately
gpupdate

REM Force reapplication of all policies
gpupdate /force

REM Update computer policy only
gpupdate /target:computer /force

REM Update user policy only
gpupdate /target:user

REM Force update and reboot if needed
gpupdate /force /boot
```

### Related Commands
`GPRESULT`, `AUDITPOL`, `SECEDIT`

---

*Back to: [F.md](F.md) | Next: [H.md](H.md)*
