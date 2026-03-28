# CMD Encyclopedia — Commands Starting with T

---

## TASKKILL

### Command Name
`TASKKILL` — Terminate one or more processes

### Syntax
```
taskkill [/s system] [/u username [/p password]] [/fi filter] [/pid processid | /im imagename] [/t] [/f]
```
| Switch | Meaning |
|---|---|
| `/pid N` | Kill by Process ID |
| `/im name` | Kill by image (executable) name |
| `/f` | Force terminate (SIGKILL equivalent) |
| `/t` | Kill process tree (including child processes) |
| `/fi filter` | Filter criteria |

**Filter examples:**
```
/fi "USERNAME eq DOMAIN\user"
/fi "STATUS eq NOT RESPONDING"
/fi "MEMUSAGE gt 1000000"
```

### Description
**Simple:** Terminates a running process by name or PID — the command-line version of "End Task" in Task Manager.

**Technical:** `TASKKILL` sends `WM_CLOSE` to the main window of the target process (allowing graceful shutdown). With `/F`, it calls `TerminateProcess` Win32 API, which immediately kills the process without cleanup — equivalent to a forced kill. `/T` kills the entire process tree, useful for processes that spawn children. Requires appropriate privileges to kill processes owned by other users.

### Example Usage
```cmd
REM Kill by name
taskkill /im notepad.exe

REM Force kill by name
taskkill /f /im chrome.exe

REM Kill by PID
taskkill /pid 1234

REM Kill process and all children
taskkill /f /t /pid 1234

REM Kill all unresponsive processes
taskkill /f /fi "STATUS eq NOT RESPONDING"

REM Kill all processes from a specific user
taskkill /f /fi "USERNAME eq DOMAIN\john.smith"

REM Kill on remote machine
taskkill /s REMOTE-PC /f /im badprocess.exe
```

### Common Mistakes
- Killing system processes (like `svchost.exe` or `lsass.exe`) without the correct PID — always verify the PID with `TASKLIST` first
- Forgetting `/f` for processes that don't respond to WM_CLOSE

### Related Commands
`TASKLIST`, `QUERY PROCESS`, `SC STOP`, `WMIC process`

---

## TASKLIST

### Command Name
`TASKLIST` — Display a list of running processes

### Syntax
```
tasklist [/s system] [/u username [/p password]] [/m [module] | /svc | /v] [/fi filter] [/fo format] [/nh]
```
| Switch | Meaning |
|---|---|
| `/v` | Verbose (include window title, memory, CPU time) |
| `/svc` | Show services hosted in each process |
| `/m` | Show loaded modules (DLLs) per process |
| `/m module` | Show processes that have a specific DLL loaded |
| `/fo` | Output format: TABLE, LIST, CSV |
| `/fi filter` | Filter by various criteria |

### Description
**Simple:** Lists all running processes — the command-line equivalent of the Task Manager Processes tab.

**Technical:** `TASKLIST` uses the PSAPI (Process Status API) and NtQuerySystemInformation to enumerate running processes. `/svc` reads the Service Control Manager to map service names to their host processes (critical for understanding `svchost.exe` instances). `/m` reads the module list of each process. Exit code is always 0.

### Example Usage
```cmd
REM List all processes
tasklist

REM Verbose list with memory and window title
tasklist /v

REM Show services per process
tasklist /svc

REM Filter: show only chrome.exe
tasklist /fi "imagename eq chrome.exe"

REM Filter: processes using more than 100MB
tasklist /fi "memusage gt 102400"

REM CSV output for scripting
tasklist /fo csv /nh

REM Find a specific process
tasklist | find /i "notepad"

REM Show on remote machine
tasklist /s REMOTE-PC

REM Check if a process is running
tasklist /fi "imagename eq notepad.exe" | find /i "notepad" > nul && echo RUNNING || echo NOT RUNNING
```

### Related Commands
`TASKKILL`, `SC`, `QUERY PROCESS`, `WMIC process`, PowerShell `Get-Process`

---

## TIMEOUT

### Command Name
`TIMEOUT` — Pause execution for a specified number of seconds

### Syntax
```
TIMEOUT /T seconds [/NOBREAK]
```
| Switch | Meaning |
|---|---|
| `/T N` | Wait N seconds (-1 = wait indefinitely) |
| `/NOBREAK` | Ignore key presses (don't allow early exit) |

### Description
**Simple:** Pauses a batch script for a specified number of seconds — a better alternative to the `ping -n` delay trick.

**Technical:** `TIMEOUT` shows a countdown and waits for the specified duration or until a key is pressed (unless `/NOBREAK` is specified). Unlike `SLEEP` (from the Resource Kit), `TIMEOUT` is built-in since Windows Vista. The `ping -n N 127.0.0.1 > nul` pattern (common in older scripts) works but is less readable than `TIMEOUT /T N /NOBREAK > nul`.

### Example Usage
```bat
REM Wait 10 seconds (user can press key to continue early)
timeout /t 10

REM Wait 5 seconds, ignore key presses
timeout /t 5 /nobreak

REM Silent wait (no output)
timeout /t 3 /nobreak > nul

REM Wait indefinitely until key pressed
timeout /t -1
```

### Related Commands
`PAUSE`, `PING` (used as delay), `CHOICE`

---

## TITLE

### Command Name
`TITLE` — Set the CMD window title

### Syntax
```
TITLE string
```

### Description
**Simple:** Changes the text displayed in the title bar of the CMD window — useful for identifying different script windows when multiple are open.

**Technical:** `TITLE` calls `SetConsoleTitle` Win32 API. It is a simple cosmetic command but invaluable when running multiple scripts — you can see at a glance which CMD window is running which script. The title is also shown in the taskbar tooltip.

### Example Usage
```bat
@echo off
title System Audit Script - Running...
echo Performing audit...
REM ... do work ...
title System Audit Script - COMPLETE
pause
```

```cmd
REM Set title from command line
title My Admin Session - SERVER01
```

### Related Commands
`COLOR`, `PROMPT`, `CLS`

---

## TRACERT

### Command Name
`TRACERT` — Trace the route packets take to a network host

### Syntax
```
tracert [-d] [-h maxhops] [-j hostlist] [-w timeout] [-R] [-S srcaddr] [-4] [-6] target
```
| Switch | Meaning |
|---|---|
| `-d` | Do not resolve addresses to hostnames (faster) |
| `-h N` | Maximum hop count (default: 30) |
| `-w N` | Wait N milliseconds per reply |
| `-4` | Force IPv4 |
| `-6` | Force IPv6 |

### Description
**Simple:** Shows the path your network traffic takes to reach a destination — each router ("hop") along the way and how long each takes.

**Technical:** `TRACERT` sends ICMP Echo Requests with incrementally increasing TTL values (starting at 1). Each router decrements TTL by 1; when TTL reaches 0, the router sends back an ICMP "Time Exceeded" message identifying itself. By collecting these messages, `TRACERT` maps the full path. Three probes are sent per hop; `* * *` means the router does not respond to ICMP (common for security-hardened routers). `TRACERT` identifies: routing changes, slow hops, asymmetric routing, and where packets are being dropped.

### Example Usage
```cmd
REM Trace route to a destination
tracert google.com

REM Skip DNS resolution (faster)
tracert -d 8.8.8.8

REM Limit to 15 hops
tracert -h 15 google.com

REM Trace to your gateway first
tracert 192.168.1.1
```

### Output Explanation
```
Tracing route to google.com [142.250.80.46] over a maximum of 30 hops:

  1     2 ms     2 ms     1 ms  192.168.1.1
  2    15 ms    14 ms    15 ms  isp-gateway.provider.net [10.20.30.1]
  3     *        *        *     Request timed out.
  4    20 ms    19 ms    20 ms  core1.provider.net [80.90.100.1]
  ...
 14    18 ms    17 ms    18 ms  142.250.80.46

Trace complete.
```
- Numbers: round-trip times for 3 probes in milliseconds
- `*`: no response from that hop (ICMP blocked)
- Each line is one router hop

### Related Commands
`PING`, `PATHPING`, `ROUTE`, `NETSTAT`

---

## TREE

### Command Name
`TREE` — Display directory structure as a tree

### Syntax
```
TREE [drive:][path] [/F] [/A]
```
| Switch | Meaning |
|---|---|
| `/F` | Display filenames in each directory |
| `/A` | Use ASCII characters instead of extended characters |

### Description
**Simple:** Shows the folder structure of a directory visually as a tree diagram.

**Technical:** `TREE` traverses the directory hierarchy and draws a visual tree using box-drawing characters (or ASCII with `/A`). Useful for: documenting folder structures, understanding project layouts, and creating directory maps for documentation.

### Example Usage
```cmd
REM Show folder structure of current directory
tree

REM Show structure with files
tree /f

REM Show specific directory
tree C:\Windows /f | more

REM Save structure to a file (ASCII mode for compatibility)
tree /f /a > folder_structure.txt

REM Document a project's structure
tree C:\MyProject /f /a
```

### Related Commands
`DIR`, `CD`, `MD`

---

## TYPE

### Command Name
`TYPE` — Display the contents of a text file

### Syntax
```
TYPE [drive:][path]filename
```

### Description
**Simple:** Prints the contents of a text file to the screen — like `cat` on Linux/Mac.

**Technical:** `TYPE` reads the file and writes its contents to stdout. Binary files will display garbled characters. For multiple files, specify them space-separated. Like all CMD output, `TYPE` output can be redirected (`>`) or piped (`|`). For paged display, use `TYPE file | MORE`.

### Example Usage
```cmd
REM Display a file
type readme.txt

REM Display with paging
type large_log.txt | more

REM Display multiple files
type file1.txt file2.txt

REM Concatenate files (same as COPY /B ... + ... trick)
type file1.txt file2.txt > combined.txt

REM View Windows hosts file
type C:\Windows\System32\drivers\etc\hosts

REM Search within a file (pipe to FIND)
type logfile.txt | find "ERROR"
```

### Related Commands
`MORE`, `FIND`, `FINDSTR`, `COPY`, `ECHO`

---

*Back to: [S.md](S.md) | Next: [U.md](U.md)*
