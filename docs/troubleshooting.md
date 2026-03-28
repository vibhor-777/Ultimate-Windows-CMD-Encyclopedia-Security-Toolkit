# Troubleshooting Guide

## Quick Diagnostic Checklist

Before diving into specific issues, run through this checklist:

- [ ] Are you running the script **as Administrator**?
- [ ] Is your **antivirus** blocking or quarantining the `.bat` file?
- [ ] Is the **Logs\\** directory writable?
- [ ] Are you running on **Windows** (not Wine, WSL, or a VM with limited access)?
- [ ] Is the script in a path that **contains no spaces** (or are spaces quoted properly)?

---

## Common Errors and Fixes

### Error: "Access Denied"

**Symptoms:**
```
Access is denied.
The requested operation requires elevation.
Error 5: Access denied.
```

**Causes and Fixes:**

| Cause | Fix |
|---|---|
| Script not run as Administrator | Right-click → Run as Administrator |
| UAC is preventing elevation | Check UAC settings in Control Panel |
| File/folder permissions restrict access | Run `icacls <path>` to inspect permissions |
| Domain Group Policy blocks the command | Check with your IT department |
| Antivirus is intercepting the command | Temporarily disable AV, re-test, re-enable |

**Step-by-step fix:**
1. Close the current CMD window
2. Press `Win + S`, type `cmd`
3. Right-click **Command Prompt** → **Run as Administrator**
4. Click **Yes** on the UAC prompt
5. Navigate to the script and run it manually:
   ```cmd
   cd C:\path\to\toolkit
   scripts\system-check\quick_health_check.bat
   ```

---

### Error: Script Won't Run / "Windows protected your PC"

**Symptom:** Windows SmartScreen blocks the `.bat` file with a blue warning dialog.

**Fix:**
1. Right-click the `.bat` file → **Properties**
2. At the bottom of the General tab, check **"Unblock"** if present
3. Click **Apply** → **OK**
4. Try running again

**Alternative fix via CMD:**
```cmd
REM Remove the Mark of the Web from a file
icacls "scripts\system-check\quick_health_check.bat" /grant Everyone:F
```

**Why this happens:** Files downloaded from the internet get a "Mark of the Web" (Zone Identifier) alternate data stream that triggers SmartScreen. Unblocking removes this flag.

---

### Error: Script Won't Run / Execution Restriction

**Symptom:**
```
This file does not have a program associated with it...
```
or the CMD window flashes and closes immediately.

**Fixes:**

1. **Associate `.bat` with CMD:** Right-click `.bat` file → Open with → Windows Command Processor

2. **Run directly from CMD:**
   ```cmd
   cmd.exe /c "C:\path\to\script.bat"
   ```

3. **Check if the file is actually a .bat:** In File Explorer, ensure "Show file extensions" is enabled (View → Show → File name extensions). The file should end in `.bat`, not `.bat.txt`.

---

### Error: "The system cannot find the path specified"

**Symptom:**
```
The system cannot find the path specified.
The system cannot find the file specified.
```

**Common causes:**
- Running the script from the wrong working directory (scripts use relative paths)
- The `Logs\` directory was manually deleted and cannot be recreated

**Fix:**
Always run scripts from the **repository root** or use the `toolkit.bat` launcher:
```cmd
cd C:\path\to\Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit
toolkit.bat
```

Or create the Logs directory manually:
```cmd
mkdir Logs
```

---

### Error: Missing Output / Empty Log File

**Symptom:** Script runs but the log file is empty or much shorter than expected.

**Possible causes and fixes:**

| Cause | Fix |
|---|---|
| Insufficient privileges | Run as Administrator |
| Command not available on your Windows version | Check `ver` and compare with command's documented requirements |
| Output redirection failed (path with spaces) | Move the repository to a path without spaces (e.g., `C:\Tools\`) |
| The command produced no output (no items to list) | This is valid — e.g., no startup programs found means an empty section |

**Check for errors in output:**
```cmd
scripts\system-check\quick_health_check.bat 2>&1 | more
```
The `2>&1` redirects error output to the screen so you can see what failed.

---

### Error: "WMIC is deprecated" Warning

**Symptom:** On Windows 11 22H2+, WMIC commands show:
```
WMIC is deprecated and might be removed in a future version of Windows.
```

**Fix:** This is a warning, not an error — WMIC still works. The warning can be suppressed by redirecting stderr:
```cmd
wmic process list brief 2>nul
```

**Long-term fix:** The PowerShell equivalents noted throughout the encyclopedia and scripts will continue to work after WMIC is eventually removed.

---

### Error: "Netsh" or "SC" Commands Fail

**Symptom:**
```
The parameter is incorrect.
An error occurred while processing your request.
```

**Fixes:**
1. Run as Administrator
2. Ensure the Windows Firewall service is running:
   ```cmd
   sc query mpssvc
   sc start mpssvc
   ```
3. Check if the command syntax matches your Windows version (some `netsh` subcommands differ between versions)

---

### Error: Antivirus Flags Scripts as Malware

**Symptom:** Antivirus quarantines or blocks `.bat` scripts with names like "detect_suspicious_processes.bat".

**Why it happens:** Security-related script names and the use of commands like `netstat`, `tasklist`, and `reg query` can trigger heuristic detection in some antivirus products.

**Fix:**
1. Add the toolkit folder to your antivirus exclusions list
2. Verify the scripts are safe by reviewing the source code (all scripts in this toolkit are plain text and easily readable)
3. Submit a false positive report to your AV vendor

**Verification steps:**
- Open any `.bat` file in Notepad and review line by line
- All commands should be recognisable Windows built-ins
- No web requests, no binary downloads, no encoded payloads

---

### Issue: Script Output Is Garbled / Special Characters Missing

**Symptom:** Output contains `?` characters or garbled text instead of accented characters or line-drawing characters.

**Fix:** Set the correct code page:
```cmd
chcp 65001
```
Or add to the script:
```bat
chcp 65001 > nul
```

For legacy ASCII art in scripts, use:
```bat
chcp 437 > nul
```

---

### Issue: `timeout` Command Pauses Script Indefinitely

**Symptom:** Script seems to hang at a "Press any key" or countdown pause.

**Fix:** When running non-interactively (piped input or Task Scheduler), add `/nobreak`:
```bat
timeout /t 5 /nobreak > nul
```

---

### Issue: FOR Loops Not Working as Expected

**Symptom:** Variables inside a FOR loop always show empty or wrong values.

**Fix:** Enable delayed expansion at the top of the script block:
```bat
setlocal enabledelayedexpansion
for /f ... do (
    echo !VARIABLE!   REM Use ! instead of % inside loops
)
```

See `power-tools\hidden_commands.md` for a full explanation.

---

## False Positives in Security Scripts

Security audit scripts use heuristics and pattern matching that **will** produce false positives. Before acting on any finding:

### Investigation Checklist
1. **Search the process name** on Google and the Microsoft Process Library
2. **Check the file path** — legitimate Windows processes run from `C:\Windows\System32\` or `C:\Program Files\`
3. **Check the publisher** in Task Manager → Details → right-click → Properties → Digital Signatures
4. **Cross-reference** with the full WMIC output: `wmic process where name="suspect.exe" get executablepath`
5. **Check VirusTotal** by uploading the file hash (never upload the file itself if you suspect it is malicious)

### Known Legitimate False Positives
| Process/Finding | Why Flagged | Likely Legitimate |
|---|---|---|
| `svchost.exe` in unusual location | Malware impersonation check | Verify it's in `System32` |
| Processes without a signed executable | Heuristic flag | Many legitimate apps are unsigned |
| Temp folder executables | Location check | Some installers extract here temporarily |
| Listening on high ports | Port range check | Gaming, development servers, VPNs |

---

## Getting Help

### Within This Toolkit
- **Encyclopedia:** `cmd-encyclopedia\<letter>.md` — command-by-command reference
- **How-To:** `docs\how-to-use.md` — usage guide
- **Power Tools:** `power-tools\` — advanced reference
- **Examples:** `examples\real_world_use_cases.md` — scenario walkthroughs

### Built-in Windows Help
```cmd
help                          REM List all built-in commands
help <command>                REM Help for a specific command
<command> /?                  REM Alternative help syntax
```

### External Resources
- [Microsoft Docs — Command-Line Reference](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)
- [SS64 CMD Reference](https://ss64.com/nt/)
- [Stack Overflow — Windows Batch tag](https://stackoverflow.com/questions/tagged/batch-file)

### Reporting Issues
If you believe a script has a bug or produces incorrect output, please:
1. Open an issue on the GitHub repository
2. Include: Windows version (`ver` output), the exact command run, and the full output (sanitise any sensitive data)
3. See `CONTRIBUTING.md` for issue templates

---

*Back to: [introduction.md](introduction.md) | [how-to-use.md](how-to-use.md)*
