# CMD Encyclopedia — Commands Starting with O

---

## Overview

The letter **O** has limited native CMD commands. The most notable is `OPENFILES`.

---

## OPENFILES

### Command Name
`OPENFILES` — Display or disconnect open files on a local or remote system

### Syntax
```
openfiles /query [/s system [/u [domain\]user] [/p password]] [/fo {TABLE|LIST|CSV}] [/nh] [/v]
openfiles /disconnect [/s system [...]] [/id openfileID | /a accessedby | /o openmode] [/op openfile]
openfiles /local [ON | OFF]
```
| Switch | Meaning |
|---|---|
| `/query` | List all open files |
| `/disconnect` | Close/disconnect an open file |
| `/local` | Enable/disable local open files tracking |
| `/fo` | Output format: TABLE, LIST, CSV |
| `/v` | Verbose (show paths) |

### Description
**Simple:** Shows which files are currently open and being used by processes on the system, and optionally which users have files open over the network.

**Technical:** `OPENFILES` has two modes: (1) tracking shared files accessed over the network (SMB shares), which works automatically on servers, and (2) tracking locally open files, which requires the global flag "maintain objects list" to be enabled via `openfiles /local on` — this incurs a small performance overhead and requires a reboot to take effect. The query mode reads from the Object Manager to enumerate open file handles.

> **Note:** For local file tracking to work, you must run `openfiles /local on` once (requires admin + reboot).

### Example Usage
```cmd
REM Enable local file tracking (requires admin + reboot to take effect)
openfiles /local on

REM List all open files (after enabling local tracking)
openfiles /query

REM List with verbose path information
openfiles /query /v

REM List in CSV format (for parsing)
openfiles /query /fo csv

REM Disconnect a specific open file by ID
openfiles /disconnect /id 1234

REM List remotely open files on a server (from an admin workstation)
openfiles /query /s FILESERVER01

REM Disconnect all files opened by a specific user
openfiles /disconnect /s FILESERVER01 /a DOMAIN\john.smith
```

### Output Explanation
```
Files Opened Remotely via Local Share Points

ID    Accessed By      Type   Open File (Path\executable)
----  ---------------  -----  ---------------------------
1     DOMAIN\john      Windows  C:\ShareFolder\report.docx
2     DOMAIN\mary      Windows  C:\ShareFolder\budget.xlsx
```

### Common Mistakes
- Expecting `openfiles /query` to work without first running `openfiles /local on` for local files
- Forgetting that enabling local tracking requires a reboot
- Using `openfiles /disconnect` carelessly — abruptly closing an open file can cause data loss for the user using it

### Use Cases
- Finding which process has a file locked (preventing deletion/modification)
- Auditing who has files open on a file server
- Cleaning up stale file handles before maintenance

### Related Commands
`TASKLIST`, `HANDLE.EXE` (Sysinternals — better tool for local file lock detection), `NET FILES`

---

## Other "O" Topics

### Object Linking (OLE / COM) — Not a CMD Command
OLE/COM operations are not directly accessible from CMD but can be scripted via:
- `REGSVR32` to register/unregister COM DLLs
- `WSCRIPT` / `CSCRIPT` to run VBScript/JScript that uses COM objects

### PowerShell "O" Alternatives
```powershell
# Get processes with open file handles (requires Sysinternals or this approach)
Get-Process | Select-Object Name, Id, Handles

# Get open network connections
Get-NetTCPConnection | Where-Object State -eq Established
```

---

*Back to: [N.md](N.md) | Next: [P.md](P.md)*
