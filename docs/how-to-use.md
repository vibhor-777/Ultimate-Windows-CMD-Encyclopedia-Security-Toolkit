# How to Use the Ultimate Windows CMD Encyclopedia & Security Toolkit

## Prerequisites

### Windows Version
- **Minimum:** Windows 7 SP1 / Windows Server 2008 R2
- **Recommended:** Windows 10 / Windows 11 / Windows Server 2016+
- Some commands (e.g., `DISM`, advanced `NETSH` subcommands) require Windows 8+ or Server 2012+

### Required Permissions
Most scripts require **Administrator privileges** to collect full system information. Scripts that only run read-only commands on your own user space may work without elevation, but results will be incomplete.

> 💡 **Tip:** If you see "Access Denied" errors, you almost certainly need to re-run as Administrator.

### No Additional Software Required
All scripts use only tools built into Windows. No third-party downloads, no .NET dependencies, no PowerShell modules required (though PowerShell is noted as an alternative throughout).

---

## How to Run `.bat` Scripts

### Method 1 — Right-Click (Recommended for Most Users)
1. Open **File Explorer** and navigate to the script you want to run
2. **Right-click** the `.bat` file
3. Select **"Run as Administrator"**
4. Click **Yes** on the UAC prompt
5. The script will open a CMD window and execute

### Method 2 — From an Elevated CMD Window
1. Press `Win + S`, type `cmd`
2. Right-click **Command Prompt** → **Run as Administrator**
3. Navigate to the repository folder:
   ```cmd
   cd C:\path\to\Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit
   ```
4. Run the script:
   ```cmd
   scripts\system-check\full_system_audit.bat
   ```

### Method 3 — Using the Interactive Launcher
1. Right-click `toolkit.bat` (in the root of the repository) → **Run as Administrator**
2. Use the numbered menu to select tools
3. The launcher handles calling the correct scripts automatically

### Method 4 — Scheduled Execution (Advanced)
You can schedule scripts to run automatically using Task Scheduler:
```cmd
schtasks /create /tn "WeeklyHealthCheck" /tr "C:\path\to\scripts\system-check\quick_health_check.bat" /sc weekly /d MON /st 08:00 /ru SYSTEM
```

---

## Understanding the Output

### On-Screen Output
Scripts display output in sections separated by lines of `=` or `-` characters. Each section is labelled with what it shows (e.g., `[SYSTEM INFORMATION]`, `[RUNNING PROCESSES]`).

Color coding (where supported by the script):
- **White/Gray** — Informational output
- **Green** — PASS / OK status
- **Red** — FAIL / Warning / Attention needed
- **Yellow** — Notice / Review recommended

> Note: Windows CMD color applies to the entire window, not individual lines. Scripts use `color` command strategically.

### Log Files
Every script automatically creates a timestamped log file in the `Logs\` subfolder of the repository:

```
Logs\
├── full_system_audit_2024-01-15_10-30-00.txt
├── quick_health_check_2024-01-15_10-45-00.txt
├── security_processes_2024-01-15_11-00-00.txt
└── ...
```

**Log file format:**
```
==========================================
  Script Name - Full System Audit
  Run Date: 2024-01-15
  Run Time: 10:30:00
  Computer: WORKSTATION-01
==========================================

[SECTION NAME]
... output ...
```

> 💡 **Tip:** Log files are plain text. Open them in Notepad, VS Code, or any text editor for review. They do not contain any sensitive credentials.

---

## Log Files Location

By default, all logs are written to:
```
<repository root>\Logs\
```

For example, if you cloned the repo to `C:\Tools\CMD-Toolkit\`, logs go to:
```
C:\Tools\CMD-Toolkit\Logs\
```

The `Logs\` directory is created automatically on first run. It is listed in `.gitignore` (or should be — see Contributing guide) so your log files are not accidentally committed to version control.

To change the log location, edit the `SET LOGDIR=` line near the top of any script.

---

## Menu-Driven Toolkit Usage (`toolkit.bat`)

The root-level `toolkit.bat` is the recommended entry point for most users.

### Starting the Toolkit
```
Right-click toolkit.bat → Run as Administrator
```

### Main Menu Options

```
============================================================
   ULTIMATE WINDOWS CMD ENCYCLOPEDIA & SECURITY TOOLKIT
============================================================

  [1] Quick Health Check         (~30 seconds)
  [2] Full System Audit          (~2-5 minutes)
  [3] Security Scan              (submenu)
  [4] Network Diagnostics
  [5] Maintenance Tools          (submenu)
  [6] Open CMD Encyclopedia
  [7] Exit

  Enter your choice:
```

### Navigating Submenus
Security Scan and Maintenance Tools have their own submenus. Enter the number of your choice and press Enter. Invalid input is handled gracefully — the menu will re-display.

### Exiting
- Type `7` and press Enter from the main menu, or
- Close the CMD window, or
- Press `Ctrl+C` at any time to interrupt execution

---

## Customising Scripts

All scripts are designed to be readable and modifiable. Key customisation points are documented with `REM CUSTOMISE:` comments in the script files.

### Changing Output Location
Near the top of each script:
```bat
REM CUSTOMISE: Change this path to redirect logs elsewhere
SET LOGDIR=%~dp0Logs
```

### Changing Ping Targets
In `scripts\network\ip_diagnostics.bat`:
```bat
REM CUSTOMISE: Change these targets for your environment
SET GATEWAY=192.168.1.1
SET DNS_TEST=8.8.8.8
SET WEB_TEST=google.com
```

### Adjusting Timeouts
Scripts that use `timeout` or `ping -n` for timing can be adjusted:
```bat
REM CUSTOMISE: Increase for slower systems
ping -n 5 127.0.0.1 > nul
```

### Adding to the Encyclopedia
The encyclopedia files in `cmd-encyclopedia\` are plain Markdown. Add entries following the template in each file. See `CONTRIBUTING.md` for the standard format.

---

## Running Scripts in Batch (Non-Interactive)

Some scripts support being called non-interactively (e.g., from another script or Task Scheduler). Scripts that require confirmation (`set /p`) will pause when called non-interactively — pipe input if needed:

```cmd
REM Run cleanup non-interactively (auto-confirm)
echo Y | scripts\maintenance\clean_temp_files.bat
```

> ⚠️ Use auto-confirmation carefully. Always know what a script does before running it unattended.

---

## Checking Your Windows Version

Not sure if a command is available on your version of Windows? Check from CMD:
```cmd
ver
winver
systeminfo | findstr /i "OS Name"
```

---

## Getting the Most from the Encyclopedia

- **Searching:** Use `Ctrl+F` in your Markdown viewer or text editor
- **Category guides** in `cmd-encyclopedia\categories\` group commands by task — great for task-oriented learning
- **Letter files** (A.md through Z.md) are comprehensive references — use them when you know the command name
- **Power tools** in `power-tools\` are for advanced users who want to go beyond the basics

---

*Next: If something isn't working, see [troubleshooting.md](troubleshooting.md)*
