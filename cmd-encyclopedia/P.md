# CMD Encyclopedia — Commands Starting with P

---

## PATHPING

### Command Name
`PATHPING` — Trace a network route and report packet loss at each hop

### Syntax
```
pathping [-n] [-h maxhops] [-g host-list] [-p period] [-q numqueries] [-w timeout] [-i IPAddress] [-4] [-6] target
```
| Switch | Meaning |
|---|---|
| `-n` | Do not resolve addresses to hostnames |
| `-h N` | Maximum hops (default: 30) |
| `-p N` | Wait N milliseconds between pings (default: 250) |
| `-q N` | Number of queries per hop (default: 100) |
| `-w N` | Wait N ms for reply timeout |

### Description
**Simple:** Like `TRACERT` + `PING` combined — shows the route to a destination AND how much packet loss occurs at each hop along the way.

**Technical:** `PATHPING` first performs a `TRACERT`-style route discovery, then sends multiple ICMP packets to each hop simultaneously for a statistical measurement period (typically 25 seconds per hop). It computes packet loss percentage and round-trip time (RTT) for each node, making it far more useful than `TRACERT` for diagnosing intermittent network problems where a single ICMP probe might succeed but sustained traffic fails.

### Example Usage
```cmd
REM Basic pathping to a target
pathping google.com

REM Skip hostname resolution (faster)
pathping -n 8.8.8.8

REM Limit to 10 hops
pathping -h 10 192.168.1.1

REM More queries per hop for better statistics
pathping -q 200 google.com
```

### Output Explanation
```
Tracing route to google.com [142.250.80.46] over a maximum of 30 hops:
  0  WORKSTATION-01 [192.168.1.100]
  1  router.local [192.168.1.1]
  2  10.20.30.1
  ...

Computing statistics for 50 seconds...
Source to Here   This Node/Link
Hop  RTT    Lost/Sent = Pct  Lost/Sent = Pct  Address
  0                                           WORKSTATION-01
                               0/100 =  0%   |
  1    2ms     0/100 =  0%     0/100 =  0%   router.local
```
- **Lost/Sent:** Packets lost out of packets sent
- **Pct:** Packet loss percentage at this node

### Related Commands
`PING`, `TRACERT`, `NETSTAT`, `ROUTE`

---

## PAUSE

### Command Name
`PAUSE` — Pause execution of a batch script until a key is pressed

### Syntax
```
PAUSE
```

### Description
**Simple:** Stops a batch script and displays "Press any key to continue..." — waits for the user to press a key before proceeding.

**Technical:** `PAUSE` is a CMD internal command that writes "Press any key to continue . . ." to stdout and then reads a single keystroke from stdin. It is useful in batch scripts for: letting users read output before the window closes, confirming before a destructive action, and creating step-by-step interactive scripts.

### Example Usage
```bat
@echo off
echo Results will be displayed below:
dir C:\Windows\System32 | more
echo.
echo Script complete. Check the output above.
pause
```

### Customizing the Pause Message
```bat
REM Custom pause message
echo Press any key to begin the scan...
pause > nul
echo Starting scan...
```

### Related Commands
`TIMEOUT`, `SET /P`, `CHOICE`

---

## PING

### Command Name
`PING` — Test network connectivity by sending ICMP Echo Requests

### Syntax
```
ping [-t] [-a] [-n count] [-l size] [-f] [-i TTL] [-v TOS] [-r count] [-s count] [-w timeout] [-R] [-S srcaddr] [-c compartment] [-p] [-4] [-6] target
```
| Switch | Meaning |
|---|---|
| `-t` | Ping continuously until Ctrl+C |
| `-n N` | Send N pings (default: 4) |
| `-l N` | Packet size in bytes (default: 32) |
| `-a` | Resolve addresses to hostnames |
| `-f` | Set Don't Fragment flag (tests MTU) |
| `-i TTL` | Set Time to Live |
| `-4` | Force IPv4 |
| `-6` | Force IPv6 |
| `-w N` | Timeout in milliseconds |

### Description
**Simple:** Sends test packets to a host and measures how long they take to get there — the most basic network connectivity test.

**Technical:** `PING` sends ICMP Echo Request (type 8) packets and listens for ICMP Echo Reply (type 0) responses. Round-trip time (RTT) is the time between sending and receiving. `PING` failure can mean: host is down, ICMP is blocked by firewall, network path is unreachable, or DNS resolution failed. The `-f` flag enables MTU path discovery by setting the Don't Fragment bit. TTL starts at a configured value and decrements at each router; when it reaches 0, a "TTL expired" message is returned.

### Example Usage
```cmd
REM Basic connectivity test
ping google.com

REM Continuous ping (Ctrl+C to stop)
ping -t 8.8.8.8

REM Send 10 pings
ping -n 10 192.168.1.1

REM Use in a script - check if host is up
ping -n 1 -w 1000 192.168.1.1 > nul
if %ERRORLEVEL% equ 0 (echo HOST IS UP) else (echo HOST IS DOWN)

REM Force IPv4
ping -4 google.com

REM Large packet test (MTU discovery)
ping -f -l 1472 192.168.1.1

REM Resolve hostname from IP
ping -a 8.8.8.8
```

### Output Explanation
```
Pinging google.com [142.250.80.46] with 32 bytes of data:
Reply from 142.250.80.46: bytes=32 time=15ms TTL=115
Reply from 142.250.80.46: bytes=32 time=14ms TTL=115
...

Ping statistics for 142.250.80.46:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 14ms, Maximum = 16ms, Average = 15ms
```

### Related Commands
`TRACERT`, `PATHPING`, `NSLOOKUP`, `IPCONFIG`, `NETSTAT`

---

## POPD

### Command Name
`POPD` — Restore the previous directory saved by PUSHD

### Syntax
```
POPD
```

### Description
**Simple:** Returns you to the directory you were in before you used `PUSHD` — like an "undo" for the `CD` command.

**Technical:** `PUSHD` and `POPD` maintain a stack of directory paths. Each `PUSHD` pushes the current directory onto the stack and changes to the specified directory. Each `POPD` pops the top entry and changes back to it. When used with a UNC path (`PUSHD \\server\share`), Windows automatically assigns a temporary drive letter to the share and maps it — `POPD` then disconnects that temporary drive.

### Example Usage
```cmd
REM Save location and go somewhere else
pushd C:\Windows\System32
dir *.dll | find "kernel"
popd
REM Now back to original directory

REM Useful in scripts
pushd %~dp0
REM ... do work relative to script location ...
popd
```

### Related Commands
`PUSHD`, `CD`, `MD`

---

## PRINT

### Command Name
`PRINT` — Print a text file to a printer

### Syntax
```
PRINT [/D:device] [drive:][path]filename[...]
```

### Description
**Simple:** Sends a text file to a printer from the command line.

**Technical:** `PRINT` sends raw text content to a printer device. It is a legacy command most useful for plain text files. For modern document printing (Word, PDF, etc.), use application-specific CLI options or `START /PRINT`.

### Example Usage
```cmd
REM Print to default printer
print report.txt

REM Print to a specific printer
print /d:\\server\HPLaserJet report.txt

REM Print using START (more flexible)
start /min notepad /p myfile.txt
```

### Related Commands
`START`, `COPY` (can copy to PRN device)

---

## PROMPT

### Command Name
`PROMPT` — Change the CMD command prompt appearance

### Syntax
```
PROMPT [text]
```

**Special codes:**
| Code | Meaning |
|---|---|
| `$P` | Current drive and path |
| `$G` | `>` character |
| `$N` | Current drive |
| `$D` | Current date |
| `$T` | Current time |
| `$L` | `<` character |
| `$Q` | `=` character |
| `$S` | Space |
| `$_` | New line |
| `$+` | One `+` per PUSHD depth |
| `$E` | Escape character (for ANSI colors) |

### Description
**Simple:** Customises what the command prompt looks like — useful for scripting and distinguishing different CMD windows.

**Technical:** `PROMPT` sets the `PROMPT` environment variable, which CMD reads to construct the prompt string before each command. ANSI escape sequences can be used with `$E` for coloured prompts (requires ANSI mode enabled with `ANSI.SYS` or VT processing on Windows 10+).

### Example Usage
```cmd
REM Default prompt
prompt $P$G

REM Prompt with time
prompt [$T]$P$G

REM Two-line prompt
prompt $P$_$G

REM Reset to default
prompt

REM Show PUSHD stack depth
prompt $+$P$G
```

### Related Commands
`TITLE`, `COLOR`, `SET`

---

## PUSHD

### Command Name
`PUSHD` — Save current directory and change to a new one

### Syntax
```
PUSHD [path | ..]
```

### Description
**Simple:** Saves your current directory location, then moves to a new one — you can return to the saved location with `POPD`.

**Technical:** See `POPD` entry for full technical details. Key feature: `PUSHD \\server\share` automatically maps the UNC path to a drive letter (Z:, Y:, X:, etc.) and navigates to it — useful because many CMD commands don't support UNC paths directly.

### Example Usage
```cmd
REM Save location and navigate
pushd D:\ProjectFiles
REM ... do work ...
popd

REM Navigate to a network share (auto-assigns drive letter)
pushd \\fileserver\shared
dir
popd

REM Stack multiple pushd calls
pushd C:\Folder1
pushd C:\Folder2
popd   REM returns to C:\Folder1
popd   REM returns to original location
```

### Related Commands
`POPD`, `CD`, `NET USE`

---

## PSLIST (Sysinternals)

### Command Name
`PSLIST` — List processes and their detailed information (Sysinternals tool)

> **Note:** `PSLIST` is NOT a built-in Windows command. It is part of the free **Sysinternals Suite** from Microsoft (https://docs.microsoft.com/sysinternals/). It must be downloaded separately.

### Syntax
```
pslist [-d] [-m] [-x] [-t] [-s [n] [-r n]] [\\computer] [-u username] [-p password] [name | pid]
```

### Description
**Simple:** A more detailed alternative to `TASKLIST` that shows CPU time, memory, and thread counts for processes.

**Technical:** `PSLIST` uses the NT Native API to enumerate processes and query performance counters (similar to Task Manager's detail view). Part of the broader PsTools suite which includes `PSEXEC` (remote execution), `PSKILL` (terminate processes), `PSINFO` (system info), and others.

### Download
```
https://docs.microsoft.com/en-us/sysinternals/downloads/pslist
```

### CMD Alternative (built-in)
```cmd
REM Similar to PSLIST using built-in tools
tasklist /v
wmic process get name,processid,workingsetsize,status
```

### Related Commands
`TASKLIST`, `TASKKILL`, `WMIC`

---

*Back to: [O.md](O.md) | Next: [Q.md](Q.md)*
