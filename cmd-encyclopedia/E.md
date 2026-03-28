# CMD Encyclopedia — Commands Starting with E

---

## ECHO

### Command Name
`ECHO` — Display messages or turn command echoing on/off

### Syntax
```
ECHO [ON | OFF]
ECHO [message]
ECHO.
```

### Description
**Simple:** Prints text to the screen. Also controls whether commands are shown before they execute in batch scripts.

**Technical:** `ECHO` is a CMD internal command. `ECHO ON` (the default) causes CMD to print each command before executing it. `ECHO OFF` suppresses this — all batch scripts should begin with `@ECHO OFF` (the `@` suppresses the echo of the ECHO OFF command itself). `ECHO.` (with a period, no space) prints a blank line — this is more reliable than `ECHO ` (with a trailing space). ECHO output goes to stdout and can be redirected with `>` and piped with `|`.

### Example Usage
```cmd
REM Print a message
echo Hello, World!

REM Print a blank line (reliable method)
echo.

REM Turn off command echo in a batch script (put at top)
@echo off

REM Check current echo state
echo

REM Echo to a file
echo This is a log entry >> logfile.txt

REM Echo with date and time to a log
echo [%DATE% %TIME%] System check started >> log.txt

REM Use in a FOR loop
for %i in (1 2 3) do echo Item: %i
```

### Common Mistakes
- Using `ECHO ` (space) for a blank line — trailing spaces cause issues; use `ECHO.` instead
- Not using `@ECHO OFF` at the top of batch scripts (clutters output)
- Forgetting to redirect `ECHO` output when creating files — `echo text > file.txt` truncates; `echo text >> file.txt` appends

### Related Commands
`@`, `REM`, `SET`, `TYPE`

---

## ENDLOCAL

### Command Name
`ENDLOCAL` — End localisation of environment changes in a batch file

### Syntax
```
ENDLOCAL
```

### Description
**Simple:** Restores all environment variables to what they were before the matching `SETLOCAL` command.

**Technical:** `SETLOCAL` creates a snapshot of the environment block and pushes it to a stack. Subsequent changes to environment variables (via `SET`, `CD`, etc.) are scoped to the local block. `ENDLOCAL` pops the stack and restores the environment to the pre-`SETLOCAL` state. This prevents batch scripts from "polluting" the calling environment. CMD automatically calls `ENDLOCAL` at the end of a batch file if not explicitly called. Useful for creating functions or modules that clean up after themselves.

### Example Usage
```bat
@echo off
setlocal

REM These changes are local to this block
set TEMP_VAR=temporary_value
cd C:\SomeFolder

REM After endlocal, TEMP_VAR and the CD change are undone
endlocal

REM TEMP_VAR is no longer set here
echo %TEMP_VAR%  REM will print "%TEMP_VAR%" literally (empty)
```

**Passing a value out of a SETLOCAL block:**
```bat
setlocal
set RESULT=computed_value
endlocal & set RESULT=%RESULT%
REM RESULT is now set in the outer environment
```

### Related Commands
`SETLOCAL`, `SET`, `CALL`

---

## EVENTCREATE

### Command Name
`EVENTCREATE` — Create a custom event in the Windows Event Log

### Syntax
```
eventcreate [/s computer [/u domain\user [/p password]]] /id EventID /l {APPLICATION|SYSTEM|SECURITY} /t {ERROR|WARNING|INFORMATION|SUCCESSAUDIT|FAILUREAUDIT} /so source /d description
```
| Switch | Meaning |
|---|---|
| `/id` | Event ID (1–1000) |
| `/l` | Event log (APPLICATION, SYSTEM, SECURITY) |
| `/t` | Event type |
| `/so` | Source name |
| `/d` | Event description text |

### Description
**Simple:** Writes a custom message into the Windows Event Log — useful for marking the start/end of scripts or logging important events in automated tasks.

**Technical:** `EVENTCREATE` calls the `ReportEvent` Win32 API to insert a record into the Windows Event Log. Security log requires SeAuditPrivilege (usually requires SYSTEM or Administrator with audit privilege). Application and System logs require Administrator. Event ID must be between 1 and 1000. This is valuable for creating audit trails in automated scripts — a log entry is created that can be monitored by SIEM tools and Windows Event Collector.

### Example Usage
```cmd
REM Log a script start event
eventcreate /id 100 /l APPLICATION /t INFORMATION /so "MyBackupScript" /d "Backup job started"

REM Log a warning
eventcreate /id 200 /l APPLICATION /t WARNING /so "DiskCheck" /d "Disk space below 10 percent"

REM Log an error
eventcreate /id 500 /l APPLICATION /t ERROR /so "MyScript" /d "Critical process failed"

REM View events created by a source
wevtutil qe Application /q:"*[System[Source='MyBackupScript']]" /f:text
```

### Related Commands
`WEVTUTIL`, `AUDITPOL`, `SC`

---

## EXPAND

### Command Name
`EXPAND` — Expand compressed files (Cabinet files)

### Syntax
```
EXPAND [-r] source destination
EXPAND -d source.cab [-f:files]
EXPAND source.cab -f:files destination
```
| Switch | Meaning |
|---|---|
| `-r` | Rename expanded files |
| `-d` | Display file list in the cabinet |
| `-f:files` | Expand specific files from a cabinet |

### Description
**Simple:** Extracts files from Windows cabinet (`.cab`) compressed archives, including those found on Windows installation media.

**Technical:** Cabinet (`.cab`) files are Microsoft's archive format, used throughout Windows for distributing system files, drivers, and updates. `EXPAND` calls the Cabinet API (`cabinet.dll`) to decompress and extract files. This is particularly useful for extracting individual files from Windows installation sources (e.g., `install.wim` on the DVD, or cab files in `C:\Windows\SoftwareDistribution`).

### Example Usage
```cmd
REM List files in a cabinet
expand -d driver.cab

REM Extract all files from a cabinet to a folder
expand C:\cabinet.cab -f:* C:\extracted\

REM Extract a specific file from a cabinet
expand source.cab -f:ntfs.sys C:\recovered\

REM Expand with original filenames
expand -r driver.cab C:\drivers\
```

### Related Commands
`DISM`, `MAKECAB`, `COPY`

---

## EXIT

### Command Name
`EXIT` — Exit the current CMD session or batch script

### Syntax
```
EXIT [/B] [exitcode]
```
| Switch | Meaning |
|---|---|
| `/B` | Exit current batch file only (not the CMD session) |
| `exitcode` | Set the %ERRORLEVEL% for the calling process |

### Description
**Simple:** Closes the CMD window or exits a batch script with an optional return code.

**Technical:** Without `/B`, `EXIT` terminates the `cmd.exe` process entirely, closing the window. With `/B`, it exits only the current batch script and returns control to the calling script or CMD prompt, which is essential for modular script design. The optional exit code sets `%ERRORLEVEL%` in the calling context, enabling error handling in parent scripts. Exit code `0` conventionally means success; non-zero means failure.

### Example Usage
```bat
@echo off
REM Exit with success
exit /b 0

REM Exit with error code
exit /b 1

REM Conditional exit
if not exist "required.txt" (
    echo ERROR: required.txt not found
    exit /b 1
)
```

```cmd
REM Close the CMD window
exit

REM Exit current script and report error to caller
exit /b 2
```

### Common Mistakes
- Using `EXIT` without `/B` in a subroutine — this closes the entire CMD window, not just returns from the subroutine
- Not setting meaningful exit codes — always exit `/b 0` on success and `/b 1` (or higher) on failure

### Related Commands
`ERRORLEVEL`, `IF`, `GOTO`, `CALL`

---

*Back to: [D.md](D.md) | Next: [F.md](F.md)*
