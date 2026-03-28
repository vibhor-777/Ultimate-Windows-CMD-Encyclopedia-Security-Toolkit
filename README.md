# 🖥️ Ultimate Windows CMD Encyclopedia & Security Toolkit

> **The most comprehensive Windows Command Prompt reference and security toolkit — A to Z command coverage, production-ready audit scripts, and real-world IT solutions.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue.svg)](https://www.microsoft.com/windows)
[![CMD](https://img.shields.io/badge/Shell-CMD%20%2F%20Batch-green.svg)](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)
[![Educational](https://img.shields.io/badge/Purpose-Educational-orange.svg)](#disclaimer)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [How to Run Scripts](#how-to-run-scripts)
- [Security Scripts Overview](#security-scripts-overview)
- [CMD Encyclopedia Overview](#cmd-encyclopedia-overview)
- [PowerShell Comparisons](#powershell-comparisons)
- [Top 50 Commands Reference](#top-50-commands-reference)
- [Contributing](#contributing)
- [License](#license)
- [Disclaimer](#disclaimer)

---

## Overview

The **Ultimate Windows CMD Encyclopedia & Security Toolkit** is an open-source collection of:

- 📚 **A complete A-Z CMD command encyclopedia** — 80+ commands with syntax, examples, and technical explanations
- 🔒 **Safe security audit scripts** — read-only scripts to audit your system for suspicious activity
- 🌐 **Network diagnostic tools** — IP diagnostics, port inventory, connectivity testing
- 🔧 **Maintenance utilities** — disk health checks and temp file cleanup
- 💡 **Real-world IT scenarios** — 10 common problems solved step-by-step with CMD
- ⚡ **Power tools** — hidden switches, advanced techniques, and the top 50 most useful commands

All scripts are **educational, safe, and well-commented**. Security scripts are **read-only by default**. The only script that deletes files (`clean_temp_files.bat`) requires explicit confirmation before acting.

---

## Features

| Feature | Description |
|---------|-------------|
| 📚 Complete A-Z Encyclopedia | 80+ commands with full documentation |
| 🗂️ 5 Category Guides | File management, networking, system info, users, disks |
| 🔒 5 Security Audit Scripts | Safe, read-only system security checks |
| 🌐 2 Network Scripts | IP diagnostics and local port inventory |
| 🔧 2 Maintenance Scripts | Disk health and temp file cleanup |
| 🖥️ Interactive Toolkit | Menu-driven `toolkit.bat` launcher |
| 📊 Automatic Logging | All scripts log to timestamped files in `Logs\` |
| 💡 10 Real-World Scenarios | Practical IT problems solved with CMD |
| ⚡ Power Tools | Hidden commands, advanced techniques |
| 📖 3 Documentation Guides | Introduction, how-to-use, troubleshooting |

---

## Repository Structure

```
Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit/
│
├── 🚀 toolkit.bat                    ← START HERE — Interactive launcher
├── 📄 README.md
├── 📄 LICENSE                         MIT License
├── 📄 CONTRIBUTING.md
│
├── 📁 docs/
│   ├── introduction.md                What this toolkit is and who it's for
│   ├── how-to-use.md                  Setup and usage guide
│   └── troubleshooting.md             Common issues and fixes
│
├── 📁 cmd-encyclopedia/
│   ├── A.md    ATTRIB, ARP, ASSOC, AUDITPOL
│   ├── B.md    BCDEDIT, BITSADMIN, BOOTCFG, BREAK
│   ├── C.md    CD, CLS, COPY, CIPHER, CHKDSK, CMD, COMP, COMPACT, CONVERT
│   ├── D.md    DEL, DIR, DISKPART, DISM, DOSKEY, DRIVERQUERY, DSQUERY
│   ├── E.md    ECHO, ENDLOCAL, EVENTCREATE, EXPAND, EXIT
│   ├── F.md    FC, FIND, FINDSTR, FOR, FORMAT, FSUTIL, FTP, FTYPE
│   ├── G.md    GOTO, GPRESULT, GPUPDATE
│   ├── H.md    HELP, HOSTNAME
│   ├── I.md    ICACLS, IF, IPCONFIG
│   ├── J.md    (No major J commands — documented)
│   ├── K.md    KLIST
│   ├── L.md    LABEL, LOGOFF
│   ├── M.md    MD/MKDIR, MORE, MOVE, MSIEXEC, MSG
│   ├── N.md    NET, NETSH, NETSTAT, NSLOOKUP
│   ├── O.md    OPENFILES
│   ├── P.md    PATHPING, PAUSE, PING, POPD, PRINT, PROMPT, PUSHD, PSLIST
│   ├── Q.md    QUERY SESSION/PROCESS/USER, QWINSTA
│   ├── R.md    RECOVER, RD, REG, REGSVR32, REN, REPLACE, ROBOCOPY, ROUTE, RUNAS
│   ├── S.md    SC, SCHTASKS, SET, SETLOCAL, SFC, SHUTDOWN, SORT, START, SUBST, SYSTEMINFO
│   ├── T.md    TASKKILL, TASKLIST, TIMEOUT, TITLE, TRACERT, TREE, TYPE
│   ├── U.md    UNZIP (notes), USERACCOUNT (WMIC)
│   ├── V.md    VER, VERIFY, VOL
│   ├── W.md    WHERE, WHOAMI, WMIC, WUAUCLT
│   ├── X.md    XCOPY
│   ├── Y.md    (No standard Y commands — documented)
│   ├── Z.md    (No standard Z commands — PowerShell alternatives)
│   └── 📁 categories/
│       ├── file-management.md         COPY, MOVE, DEL, MKDIR, ATTRIB, ICACLS, ROBOCOPY...
│       ├── networking.md              IPCONFIG, PING, TRACERT, NETSTAT, ROUTE, ARP, NETSH...
│       ├── system-info.md             SYSTEMINFO, WMIC, TASKLIST, DRIVERQUERY, GPRESULT...
│       ├── user-management.md         NET USER, NET LOCALGROUP, ICACLS, RUNAS, WHOAMI...
│       └── disk-operations.md         CHKDSK, DISKPART, FORMAT, FSUTIL, DEFRAG, COMPACT...
│
├── 📁 scripts/
│   ├── 📁 system-check/
│   │   ├── full_system_audit.bat      Complete system audit (10+ sections)
│   │   └── quick_health_check.bat     30-second PASS/FAIL health check
│   ├── 📁 security/
│   │   ├── detect_suspicious_processes.bat    Process path and connection audit
│   │   ├── find_hidden_files.bat              Hidden files in suspicious locations
│   │   ├── check_startup_programs.bat         All startup items (registry + folders + tasks)
│   │   ├── detect_unauthorized_users.bat      User account and group audit
│   │   └── network_connections_scan.bat       Active connections and port inventory
│   ├── 📁 network/
│   │   ├── ip_diagnostics.bat                 Full IP + DNS + connectivity test
│   │   └── port_scan_basic.bat                Local port inventory with process mapping
│   └── 📁 maintenance/
│       ├── clean_temp_files.bat               Temp cleanup (requires confirmation)
│       └── disk_check.bat                     Disk space + SMART + CHKDSK (read-only)
│
├── 📁 power-tools/
│   ├── advanced_admin_commands.md     WMIC, NETSH, DISKPART, BCDEdit, SC, REG in depth
│   └── hidden_commands.md             Lesser-known commands, top 50 reference
│
├── 📁 examples/
│   └── real_world_use_cases.md        10 IT scenarios with step-by-step CMD solutions
│
└── 📁 Logs/                           Auto-created when scripts run
    └── (timestamped log files)
```

---

## Quick Start

### Option 1: Interactive Toolkit (Recommended)

```
Right-click toolkit.bat → "Run as Administrator"
```

Navigate the numbered menus to access all scripts.

### Option 2: Run Individual Scripts

```
Navigate to scripts\ subfolder
Right-click the .bat file → "Run as Administrator"
```

### Option 3: Browse the Encyclopedia

Open any `.md` file in `cmd-encyclopedia/` in your text editor or on GitHub.

---

## How to Run Scripts

### Prerequisites
- Windows 10 or Windows 11 (most scripts work on Windows 7/8/Server 2008+)
- Administrator privileges recommended (some checks are limited without admin)
- No additional software required — all scripts use built-in Windows tools

### Running as Administrator

**Method 1:** Right-click the `.bat` file → **"Run as Administrator"**

**Method 2:** Open CMD as Administrator, then run:
```cmd
cd C:\path\to\toolkit
scripts\system-check\quick_health_check.bat
```

**Method 3:** Via toolkit.bat (auto-checks for admin rights):
```cmd
REM Right-click toolkit.bat → Run as Administrator
```

### Script Output

All scripts:
- Display results on screen during execution
- Create a timestamped log file in `Logs\`
- Never require internet access
- Never modify system settings (except `clean_temp_files.bat` which requires confirmation)

---

## Security Scripts Overview

| Script | Purpose | Admin Needed? | Destructive? |
|--------|---------|---------------|-------------|
| `detect_suspicious_processes.bat` | Audits running processes and their executable paths | Recommended | ❌ No |
| `find_hidden_files.bat` | Searches common locations for hidden/system files | Recommended | ❌ No |
| `check_startup_programs.bat` | Lists all startup items (registry, folders, tasks) | Recommended | ❌ No |
| `detect_unauthorized_users.bat` | Audits user accounts and group memberships | Recommended | ❌ No |
| `network_connections_scan.bat` | Maps active connections to processes | Recommended | ❌ No |

All security scripts are **read-only**. They use `REG QUERY` (not ADD/DELETE), `NET QUERY`, and similar read-only operations. Results require **manual investigation** — false positives are common.

---

## CMD Encyclopedia Overview

The encyclopedia covers **80+ Windows CMD commands** across 26 letter files (A-Z).

Each entry includes:
- **Command Name** — Full name and one-line description
- **Syntax** — All switches with meanings
- **Description** — Simple explanation (for beginners) and Technical explanation (for advanced users)
- **Example Usage** — Multiple commented examples
- **Output Explanation** — What the output means
- **Common Mistakes** — What to avoid
- **Related Commands** — Cross-references

**Category guides** group commands by task:
- `file-management.md` — 50+ examples for working with files
- `networking.md` — Complete network diagnostic workflow
- `system-info.md` — Hardware, OS, process, and service information
- `user-management.md` — Account creation, groups, permissions
- `disk-operations.md` — Disk health, partitioning, optimization

---

## PowerShell Comparisons

Each encyclopedia entry and scenario includes PowerShell equivalents. Key mappings:

| CMD Command | PowerShell Equivalent |
|---|---|
| `TASKLIST` | `Get-Process` |
| `NET USER` | `Get-LocalUser` |
| `NETSTAT -ANO` | `Get-NetTCPConnection` |
| `SYSTEMINFO` | `Get-CimInstance Win32_OperatingSystem` |
| `WMIC DISKDRIVE` | `Get-PhysicalDisk` |
| `SCHTASKS` | `Get-ScheduledTask` / `New-ScheduledTask` |
| `SC QUERY` | `Get-Service` |
| `REG QUERY` | `Get-ItemProperty` |
| `ICACLS` | `Get-Acl` / `Set-Acl` |
| `ROBOCOPY` | `Copy-Item -Recurse` (less features) |

---

## Top 50 Commands Reference

See [`power-tools/hidden_commands.md`](power-tools/hidden_commands.md) for the full ranked list.

**Top 10 for quick reference:**

| Rank | Command | What It Does |
|------|---------|-------------|
| 1 | `ipconfig /all` | Full network configuration |
| 2 | `netstat -ano` | All connections with process IDs |
| 3 | `tasklist /v` | All running processes |
| 4 | `systeminfo` | Complete system information |
| 5 | `whoami /all` | Current user, groups, privileges |
| 6 | `net localgroup Administrators` | Who has admin rights? |
| 7 | `sc query type= all state= all` | All services and their status |
| 8 | `chkdsk C:` | Filesystem health check |
| 9 | `pathping google.com` | Network path with packet loss |
| 10 | `sfc /scannow` | Scan and repair system files |

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of conduct
- How to report bugs
- How to suggest features
- Coding standards for `.bat` files
- Documentation standards
- Testing requirements

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## Disclaimer

> **This toolkit is designed for legitimate system administration and educational purposes only.**

- All scripts use publicly documented Windows tools in their normal, intended manner
- Security scripts are **read-only** and do not modify any system settings
- Scripts are designed to run on systems **you own or have explicit permission to administer**
- Results from security scripts require **manual investigation** — false positives are common
- The authors accept **no responsibility for misuse** of this toolkit
- **Never use these tools on systems without proper authorization**

Unauthorized computer access is illegal under the Computer Fraud and Abuse Act (US), the Computer Misuse Act (UK), and equivalent laws worldwide.

---

<div align="center">

Made with ❤️ by [vibhor-777](https://github.com/vibhor-777)

⭐ Star this repo if you find it useful!

</div>
