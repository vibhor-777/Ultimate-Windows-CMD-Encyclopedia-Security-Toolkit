# CMD Encyclopedia — Commands Starting with R

---

## RECOVER

### Command Name
`RECOVER` — Recover readable information from a bad or defective disk

### Syntax
```
recover [drive:][path]filename
```

### Description
**Simple:** Attempts to recover a file from a disk with bad sectors by reading as much as possible and skipping unreadable sectors.

**Technical:** `RECOVER` reads a file sector by sector and recovers sectors that are readable, skipping bad sectors (which are replaced with zeros). This is a last-resort tool — it does not repair the filesystem or the disk. The recovered file may be incomplete or corrupted where bad sectors existed. For better recovery options, use `CHKDSK /R` first, or third-party tools like Recuva or TestDisk.

### Example Usage
```cmd
REM Attempt to recover a file from a drive with bad sectors
recover D:\damaged\important.docx
```

### Related Commands
`CHKDSK`, `FSUTIL`, `XCOPY /C` (copy, continue on errors)

---

## RD / RMDIR

### Command Name
`RD` / `RMDIR` — Remove (delete) a directory

### Syntax
```
RD [/S] [/Q] [drive:]path
RMDIR [/S] [/Q] [drive:]path
```
| Switch | Meaning |
|---|---|
| `/S` | Remove all files and subdirectories (recursive) |
| `/Q` | Quiet mode — no confirmation |

### Description
**Simple:** Deletes an empty directory, or with `/S` deletes a directory and all its contents.

**Technical:** Without `/S`, `RD` only removes empty directories. With `/S`, it recursively deletes all files and subdirectories — the equivalent of a recursive `DEL` followed by directory removal. `/Q` suppresses the "Are you sure? (Y/N)" prompt when using `/S`. Like `DEL`, files removed by `RD /S` do NOT go to the Recycle Bin.

> ⚠️ **WARNING:** `RD /S /Q` permanently and immediately deletes an entire directory tree without confirmation and without using the Recycle Bin.

### Example Usage
```cmd
REM Remove an empty directory
rd emptydir

REM Remove a directory and all contents (with confirmation)
rd /s "OldProjects"

REM Remove without confirmation (use with extreme care)
rd /s /q "TempFiles"

REM Remove current directory's contents (go up first)
cd ..
rd /s "OldFolder"
```

### Common Mistakes
- Running `rd /s /q` on the wrong path — there is no undo
- Trying to delete the current directory — navigate out first
- Forgetting that `RD` without `/S` fails on non-empty directories

### Related Commands
`MD`, `DEL`, `DIR`, `TREE`

---

## REG

### Command Name
`REG` — Registry operations — query, add, delete, compare, export, import

### Syntax
```
reg query KeyName [/v ValueName | /ve] [/s] [/f Data] [/k] [/d] [/c] [/e] [/t Type] [/z] [/se Separator] [/reg:32 | /reg:64]
reg add KeyName [/v ValueName] [/ve] [/t Type] [/s Separator] [/d Data] [/f]
reg delete KeyName [/v ValueName | /ve | /va] [/f]
reg export KeyName FileName [/y]
reg import FileName
reg compare KeyName1 KeyName2 [/v ValueName] [/ve] [/oa | /od | /os | /on] [/s]
reg save KeyName FileName
reg restore KeyName FileName
```

### Description
**Simple:** Read and write Windows Registry keys from the command line — the command-line equivalent of `REGEDIT`.

**Technical:** `REG` provides full CRUD operations on the Windows Registry. The registry is a hierarchical database of configuration settings. Keys are like folders; values are like files with names, types, and data. Main hives: `HKLM` (machine-wide), `HKCU` (current user), `HKCR` (file associations), `HKU` (all users), `HKCC` (hardware config). Registry changes take effect immediately but some require an application or Windows restart. `/reg:32` and `/reg:64` access the 32-bit or 64-bit registry views on 64-bit Windows.

> ⚠️ **CAUTION:** Incorrect registry modifications can cause system instability. Always export a backup before making changes.

### Example Usage
```cmd
REM Read-only: Query a key and all its values
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

REM Query a specific value
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName

REM Query with search (find all keys containing "java")
reg query HKLM /f "java" /s /k

REM Check startup items (read-only audit)
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

REM Export a key to file (backup)
reg export "HKLM\SOFTWARE\MyApp" myapp_backup.reg

REM Import from file
reg import myapp_backup.reg

REM Add a registry value (requires admin for HKLM)
reg add "HKCU\SOFTWARE\MyApp" /v Setting1 /t REG_SZ /d "MyValue" /f

REM Delete a value (requires admin for HKLM)
reg delete "HKCU\SOFTWARE\MyApp" /v OldSetting /f

REM Compare two registry keys
reg compare "HKCU\SOFTWARE\MyApp" "HKCU\SOFTWARE\MyApp.backup"
```

### Registry Value Types
| Type | Meaning | Example |
|---|---|---|
| `REG_SZ` | String | `"Hello World"` |
| `REG_DWORD` | 32-bit integer | `0x00000001` |
| `REG_QWORD` | 64-bit integer | |
| `REG_BINARY` | Binary data | `ff 00 ff` |
| `REG_MULTI_SZ` | Multi-string (newline separated) | |
| `REG_EXPAND_SZ` | Expandable string (can contain env vars) | `%SystemRoot%\file` |

### Related Commands
`REGEDIT`, `AUDITPOL`, `GPRESULT`, PowerShell `Get-ItemProperty`, `Set-ItemProperty`

---

## REGSVR32

### Command Name
`REGSVR32` — Register or unregister COM/ActiveX DLLs and OCX controls

### Syntax
```
regsvr32 [/u] [/s] [/n] [/i[:cmdline]] dllname
```
| Switch | Meaning |
|---|---|
| `/u` | Unregister |
| `/s` | Silent (no dialog boxes) |
| `/n` | Do not call DllRegisterServer |
| `/i` | Call DllInstall with optional cmdline |

### Description
**Simple:** Registers a DLL or OCX file with Windows so that COM-dependent programs can find and use it.

**Technical:** `REGSVR32` calls the `DllRegisterServer` export function within the specified DLL, which writes the component's COM registration information (CLSIDs, ProgIDs, type library references) to the registry under `HKEY_CLASSES_ROOT\CLSID`. This is required for COM/ActiveX components to be discoverable by the COM runtime. The `/u` flag calls `DllUnregisterServer` to remove the registration.

### Example Usage
```cmd
REM Register a DLL
regsvr32 C:\path\to\component.dll

REM Unregister a DLL
regsvr32 /u C:\path\to\component.dll

REM Silent registration (no success dialog)
regsvr32 /s C:\path\to\component.dll
```

### Related Commands
`REG`, `MSIEXEC`

---

## REN / RENAME

### Command Name
`REN` / `RENAME` — Rename a file or directory

### Syntax
```
REN [drive:][path]filename1 filename2
RENAME [drive:][path]filename1 filename2
```

### Description
**Simple:** Renames a file or folder. The destination filename cannot include a drive or path — only the new name.

**Technical:** `REN` updates the directory entry for the file to use a new name. It cannot move files to a different directory (use `MOVE` for that). Wildcards are supported: `REN *.txt *.bak` renames all `.txt` files to `.bak`.

### Example Usage
```cmd
REM Rename a file
ren oldname.txt newname.txt

REM Rename all .log files to .bak
ren *.log *.bak

REM Rename a folder
ren "Old Project Name" "New Project Name"

REM Add a prefix to all files
for %f in (*.txt) do ren "%f" "archived_%f"
```

### Related Commands
`MOVE`, `COPY`, `DIR`

---

## REPLACE

### Command Name
`REPLACE` — Replace files in one directory with files from another

### Syntax
```
replace [drive1:][path1]filename [drive2:][path2] [/A] [/P] [/R] [/W] [/S] [/U]
```
| Switch | Meaning |
|---|---|
| `/A` | Add new files only (do not replace existing) |
| `/S` | Replace in subdirectories |
| `/U` | Replace only files older than source |
| `/P` | Prompt before replacing |

### Description
**Simple:** Replaces files in a target directory with newer or different versions from a source directory — useful for applying patches or updates to a file set.

**Technical:** `REPLACE` compares filenames and optionally timestamps between source and destination. `/U` makes it behave like a simple one-way sync (copy if source is newer). Less capable than `ROBOCOPY` for this use case but simpler for quick one-off replacements.

### Example Usage
```cmd
REM Replace existing files in target from source
replace C:\Updated\*.dll D:\Application\

REM Add only new files (don't overwrite)
replace C:\New\*.cfg D:\Target\ /a

REM Replace only if source is newer
replace C:\Source\* D:\Dest\ /u
```

### Related Commands
`COPY`, `XCOPY`, `ROBOCOPY`, `MOVE`

---

## ROBOCOPY

### Command Name
`ROBOCOPY` — Robust File Copy — advanced file copying and synchronization

### Syntax
```
robocopy source destination [files [...]] [options]
```

**Key options:**
| Option | Meaning |
|---|---|
| `/E` | Copy all subdirectories including empty ones |
| `/S` | Copy subdirectories (excluding empty) |
| `/MIR` | Mirror directory tree (deletes destination files not in source) |
| `/MOV` | Move (delete source after copy) |
| `/Z` | Restartable mode (for slow/unreliable links) |
| `/B` | Backup mode (bypass file ACL restrictions) |
| `/COPYALL` | Copy all file info (data, attributes, timestamps, ACLs, owner, audit) |
| `/R:N` | Retry N times on failure (default: 1,000,000) |
| `/W:N` | Wait N seconds between retries |
| `/LOG:file` | Output to log file |
| `/XF files` | Exclude files matching pattern |
| `/XD dirs` | Exclude directories |
| `/MT:N` | Multi-threaded (N threads, default: 8) |
| `/NP` | No progress percentage display |
| `/NDL` | No directory listing in output |

### Description
**Simple:** A powerful, reliable file copying tool that handles large transfers, network interruptions, and maintains file attributes and permissions — far superior to COPY or XCOPY for serious work.

**Technical:** `ROBOCOPY` (Robust File Copy) ships with Windows Vista+ and supports multi-threaded copying, restartable transfers, full metadata preservation (timestamps, ACLs, owners, alternate data streams), delta synchronization, and extensive exclusion filtering. Exit codes are meaningful: 0=no files copied (already in sync), 1=files copied successfully, 2=extra files in destination, 4=mismatched files, 8=errors, 16=fatal error. Exit codes are additive (e.g., 3 = 1+2 = files copied + extra files).

### Example Usage
```cmd
REM Basic copy (with subdirectories)
robocopy C:\Source D:\Destination /E

REM Mirror (keep destination identical to source)
robocopy C:\Source D:\Destination /MIR

REM Copy preserving all metadata
robocopy C:\Source D:\Destination /E /COPYALL

REM Copy with logging
robocopy C:\Source D:\Destination /E /LOG:robocopy.log /NP

REM Network backup with retry
robocopy C:\Important \\server\backup /E /Z /R:3 /W:10

REM Exclude specific folders
robocopy C:\Source D:\Dest /E /XD "C:\Source\Temp" "C:\Source\.git"

REM Exclude file types
robocopy C:\Source D:\Dest /E /XF *.tmp *.log

REM Multi-threaded copy (faster for many small files)
robocopy C:\Source D:\Dest /E /MT:16

REM Synchronise (MIR but keep log of what was deleted)
robocopy C:\Source D:\Dest /MIR /LOG+:sync_log.txt
```

### Exit Codes
| Code | Meaning |
|---|---|
| 0 | No files copied — destination already up to date |
| 1 | Files copied successfully |
| 2 | Extra files or directories found in destination |
| 4 | Mismatched files or directories found |
| 8 | Some files or directories could not be copied |
| 16 | Serious error — no files copied |

### Related Commands
`XCOPY`, `COPY`, `MOVE`, `ICACLS`

---

## ROUTE

### Command Name
`ROUTE` — Display or modify the network routing table

### Syntax
```
route [-f] [-p] [-4] [-6] command [destination] [MASK netmask] [gateway] [METRIC metric] [IF interface]
```
| Command | Meaning |
|---|---|
| `PRINT` | Display routing table |
| `ADD` | Add a route |
| `DELETE` | Delete a route |
| `CHANGE` | Modify an existing route |
| `-p` | Make route persistent (survives reboot) |
| `-f` | Clear all gateway entries |

### Description
**Simple:** Shows and manages the routing table — the set of rules that determine how network traffic is directed.

**Technical:** The routing table is a list of network destinations and the gateway/interface to use for each. When sending a packet, the OS looks up the most specific matching route (longest prefix match). The default route (0.0.0.0/0) catches all traffic not matched by more specific routes. `ROUTE ADD` adds temporary routes (lost on reboot) unless `-p` (persistent) is specified. Requires Administrator for ADD/DELETE/CHANGE.

### Example Usage
```cmd
REM Display routing table
route print

REM Display only IPv4 routes
route print -4

REM Add a static route (temporary)
route add 10.0.0.0 mask 255.255.255.0 192.168.1.1

REM Add a persistent static route
route add -p 10.0.0.0 mask 255.255.255.0 192.168.1.1

REM Delete a route
route delete 10.0.0.0

REM Change a route's gateway
route change 10.0.0.0 mask 255.255.255.0 192.168.1.254
```

### Related Commands
`NETSTAT -R`, `IPCONFIG`, `NETSH`, `PING`, `TRACERT`

---

## RUNAS

### Command Name
`RUNAS` — Execute a program as another user or with different credentials

### Syntax
```
runas [/profile | /noprofile] [/env] [/netonly] [/savecred] [/smartcard] [/showtrustlevels] [/trustlevel] /user:username program
```
| Switch | Meaning |
|---|---|
| `/user:` | User to run as (required) |
| `/savecred` | Save credentials for future use |
| `/netonly` | Use credentials for network access only |
| `/noprofile` | Do not load user profile |
| `/env` | Use current environment |

### Description
**Simple:** Run a program as a different user — similar to "Run as Administrator" but for any user account.

**Technical:** `RUNAS` creates a new logon session using the specified credentials via `CreateProcessWithLogonW` Win32 API. The launched process runs in a separate logon session with the specified user's token. `/netonly` is useful for domain scenarios where you want to run a program with your current local token but authenticate to network resources with different domain credentials — without needing to be domain-joined.

### Example Usage
```cmd
REM Run a program as Administrator
runas /user:Administrator "notepad.exe C:\Windows\System32\drivers\etc\hosts"

REM Run as a domain admin
runas /user:DOMAIN\admin "mmc.exe"

REM Run CMD as another user
runas /user:testuser cmd.exe

REM Run with network credentials only
runas /netonly /user:DOMAIN\admin "\\server\share\tool.exe"
```

### Related Commands
`WHOAMI`, `NET USER`, `ICACLS`, PowerShell `Start-Process -Credential`

---

*Back to: [Q.md](Q.md) | Next: [S.md](S.md)*
