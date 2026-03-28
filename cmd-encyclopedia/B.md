# CMD Encyclopedia — Commands Starting with B

---

## BCDEDIT

### Command Name
`BCDEDIT` — Boot Configuration Data (BCD) Store Editor

### Syntax
```
bcdedit /enum [ALL | ACTIVE | firmware | bootapp | bootsector | osloader | resume | memtest | inherit | {id}]
bcdedit /set {id} option value
bcdedit /delete {id}
bcdedit /copy {id} /d "Description"
bcdedit /export filename
bcdedit /import filename
bcdedit /default {id}
bcdedit /timeout seconds
```

### Description
**Simple:** Views and edits the Windows boot configuration — the settings that determine how Windows starts, what boot menu entries exist, and boot timeouts.

**Technical:** `BCDEDIT` manages the Boot Configuration Data (BCD) store, a binary registry hive stored in `\Boot\BCD` on the system partition. The BCD replaced the legacy `boot.ini` file starting with Windows Vista. It stores firmware-level and OS-loader-level boot parameters. Common use cases include: adding/removing OS entries from the boot menu, enabling/disabling test signing, enabling/disabling kernel debugging, and modifying boot timeouts. Requires Administrator. Misconfiguration can prevent Windows from booting — always export a backup first.

### Example Usage
```cmd
REM View all boot entries
bcdedit /enum all

REM View just the active boot entries
bcdedit /enum active

REM Export BCD as a backup (do this before making changes)
bcdedit /export C:\bcd_backup.bcd

REM Set boot menu timeout to 10 seconds
bcdedit /timeout 10

REM Set the default OS (use the GUID from /enum output)
bcdedit /default {current}

REM Enable boot logging (writes ntbtlog.txt)
bcdedit /set {current} bootlog yes

REM Disable boot logging
bcdedit /set {current} bootlog no
```

### Output Explanation
```
Windows Boot Manager
--------------------
identifier              {bootmgr}
device                  partition=\Device\HarddiskVolume1
description             Windows Boot Manager
locale                  en-US
default                 {current}
timeout                 30

Windows Boot Loader
-------------------
identifier              {current}
device                  partition=C:
path                    \Windows\system32\winload.exe
description             Windows 11
locale                  en-US
osdevice                partition=C:
systemroot              \Windows
```
- **identifier:** GUID used to reference this entry in other bcdedit commands
- **{current}:** Alias for the currently running OS
- **timeout:** Seconds to wait before booting the default entry

### Common Mistakes
- Not exporting a backup before modifying BCD settings
- Deleting `{bootmgr}` or `{current}` entries (can prevent booting — recovery media required)
- Confusing BCD edit with `boot.ini` editing (Windows XP era — not applicable to Vista+)

### Related Commands
`BOOTREC` (from recovery media), `MSCONFIG`, `STARTUP` repair

---

## BITSADMIN

### Command Name
`BITSADMIN` — Background Intelligent Transfer Service (BITS) Administration

### Syntax
```
bitsadmin /list [/allusers] [/verbose]
bitsadmin /info {job_ID} [/verbose]
bitsadmin /monitor [/allusers] [/refresh seconds]
bitsadmin /transfer jobname URL localfile
bitsadmin /cancel {job_ID}
bitsadmin /complete {job_ID}
bitsadmin /reset
```

### Description
**Simple:** Manages background file download and upload jobs that use spare network bandwidth. Windows Update uses BITS extensively.

**Technical:** BITS (Background Intelligent Transfer Service) is a Windows service that transfers files asynchronously using idle network bandwidth. It is throttle-aware and resumable across network interruptions and reboots. `BITSADMIN` is the command-line interface to the BITS COM API. Security note: BITS is sometimes abused by malware as a "living off the land" technique to download payloads without triggering firewall rules, because BITS traffic looks legitimate and uses HTTP/HTTPS. Monitoring BITS jobs is therefore a valid security task.

### Example Usage
```cmd
REM List all BITS jobs for current user
bitsadmin /list

REM List BITS jobs for all users (requires admin)
bitsadmin /list /allusers

REM List with verbose details
bitsadmin /list /allusers /verbose

REM Monitor jobs with auto-refresh every 5 seconds
bitsadmin /monitor /allusers /refresh 5

REM Create a simple download job
bitsadmin /transfer mydownload http://example.com/file.zip C:\Downloads\file.zip

REM Cancel a job
bitsadmin /cancel {GUID-of-job}

REM Cancel ALL BITS jobs (use with care)
bitsadmin /reset /allusers
```

### Output Explanation
```
GUID: {12345678-...}    DISPLAY: MyJob    TYPE: DOWNLOAD    STATE: TRANSFERRING
  50% complete (51200 of 102400 bytes transferred)
  Priority: NORMAL  Owner: DOMAIN\User
  Files: 1  Error count: 0
```
- **STATE:** `QUEUED`, `CONNECTING`, `TRANSFERRING`, `SUSPENDED`, `ERROR`, `TRANSIENT_ERROR`, `TRANSFERRED`, `ACKNOWLEDGED`, `CANCELLED`
- **Priority:** `FOREGROUND`, `HIGH`, `NORMAL`, `LOW`

### Common Mistakes
- Forgetting `/allusers` when looking for system-level BITS jobs (e.g., Windows Update)
- Not completing a BITS job after it transfers — files are in a temp location until `/complete` is called
- Using `/reset` carelessly — it cancels all queued jobs including Windows Update downloads

### Related Commands
`SC`, `NETSTAT`, `WUAUCLT`, PowerShell `Start-BitsTransfer`

---

## BOOTCFG (Deprecated)

### Command Name
`BOOTCFG` — Boot Configuration file editor (**DEPRECATED**)

### Deprecation Notice
> ⚠️ **BOOTCFG is deprecated.** It was used to edit `boot.ini` on Windows XP/2000/2003. It does not function on Windows Vista and later which use BCD instead of `boot.ini`. Use `BCDEDIT` on modern Windows.

### Historical Syntax (Reference Only)
```
bootcfg /query
bootcfg /ems ON|OFF|EDIT
bootcfg /raw /A "string" /ID id
```

### Modern Replacement
```cmd
REM Use BCDEDIT on Windows Vista/7/8/10/11/Server 2008+
bcdedit /enum all
```

### Related Commands
`BCDEDIT`, `MSCONFIG`

---

## BREAK

### Command Name
`BREAK` — Enable or disable extended CTRL+C checking

### Syntax
```
BREAK [ON | OFF]
```

### Description
**Simple:** An old DOS command that controlled whether CTRL+C was checked during disk operations. In modern Windows CMD, it is largely a no-op but accepted for compatibility.

**Technical:** In MS-DOS, CTRL+C checking only occurred during console I/O operations. `BREAK ON` caused the OS to check for CTRL+C during disk and other operations as well, allowing programs to be interrupted more readily. In Windows CMD (`cmd.exe`), the OS handles interrupt processing differently and `BREAK` has minimal practical effect. It is retained for backward compatibility with DOS-era batch scripts.

### Example Usage
```cmd
REM Check current break status
break

REM Enable extended break checking (historical)
break on

REM Disable extended break checking (historical)
break off
```

### Output Explanation
```
BREAK is off
```
Simply shows whether extended break checking is on or off.

### Common Mistakes
- Confusing CMD's `BREAK` with the `BREAK` keyword used inside FOR loops and IF statements in batch scripts (which is not the same thing — there is no `BREAK` loop control in CMD batch; use `GOTO` instead)

### Related Commands
No direct modern equivalent. For loop control, use `GOTO`.

---

*Back to: [A.md](A.md) | Next: [C.md](C.md)*
