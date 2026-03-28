# CMD Encyclopedia — Commands Starting with L

---

## LABEL

### Command Name
`LABEL` — Create, change, or delete the volume label of a disk

### Syntax
```
LABEL [drive:] [label]
LABEL [/MP] [volume] [label]
```

### Description
**Simple:** Sets or changes the name shown for a drive in File Explorer (e.g., "Local Disk" or "USB Drive").

**Technical:** The volume label is stored in the filesystem's volume boot record (VBR) for FAT/FAT32, or in the `$Volume` metadata file for NTFS. It is a cosmetic identifier up to 11 characters for FAT/FAT32 or 32 characters for NTFS. Labels can contain spaces and mixed case on NTFS. The label is displayed in File Explorer, `DIR`, `VOL`, and `DISKPART`. Changing the label does not affect file data or access.

### Example Usage
```cmd
REM Show current label of C:
vol C:

REM Set label for D:
label D: DataDrive

REM Remove label (just press Enter when prompted)
label D:

REM Set label with spaces (NTFS only)
label E: "My External Drive"
```

### Output / Interaction
```
Volume in drive D is OldLabel
Volume Serial Number is ABCD-1234
Type the new label for drive D (11 characters max for FAT):
```
Press Enter without typing to remove the label.

### Related Commands
`VOL`, `DISKPART`, `FORMAT`

---

## LOGOFF

### Command Name
`LOGOFF` — Log off a user session

### Syntax
```
LOGOFF [sessionname | sessionid] [/server:servername] [/v] [/vm]
```
| Switch | Meaning |
|---|---|
| (none) | Log off current session |
| `sessionname` | Log off a named session |
| `sessionid` | Log off by session ID number |
| `/server:` | Target a remote server |
| `/v` | Display information about actions |

### Description
**Simple:** Logs off the current user or a specified user session — closes all programs and ends the Windows session for that user.

**Technical:** `LOGOFF` calls the `WinStationReset` (or `LogoffUser`) Terminal Services API to end a logon session. Without arguments, it logs off the current interactive session. With a session ID or name (from `QUERY SESSION`), it can terminate other users' sessions — requires appropriate administrative privileges. This is commonly used in Terminal Server / Remote Desktop Services (RDS) environments to manage multiple user sessions. On single-user workstations, `LOGOFF` is equivalent to Start → Sign Out.

### Example Usage
```cmd
REM Log off current user session
logoff

REM Log off session by ID (get ID from: query session)
logoff 2

REM Log off a named session
logoff rdp-tcp#5

REM Log off session on a remote server
logoff 3 /server:RDSERVER01 /v

REM First, list sessions to find the right ID
query session
logoff 2 /v
```

### Common Mistakes
- Logging off the wrong session ID — always run `query session` first
- Not saving open work before logging off — all unsaved data is lost
- Confusing `LOGOFF` (ends session) with `LOCK` (locks screen but keeps session active — use `rundll32 user32.dll,LockWorkStation`)

### Related Commands
`QUERY SESSION`, `QUERY USER`, `SHUTDOWN`, `RUNAS`

---

*Back to: [K.md](K.md) | Next: [M.md](M.md)*
