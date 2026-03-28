# CMD Encyclopedia — Commands Starting with M

---

## MD / MKDIR

### Command Name
`MD` / `MKDIR` — Create a directory (folder)

### Syntax
```
MD [drive:]path
MKDIR [drive:]path
```

### Description
**Simple:** Creates a new folder. Can create a nested folder structure in one command.

**Technical:** `MD` and `MKDIR` are identical CMD internal commands. Unlike the Unix `mkdir`, the Windows version automatically creates intermediate directories in the specified path — no `/p` flag needed. For example, `md C:\one\two\three` creates all three directories even if none exist.

### Example Usage
```cmd
REM Create a single directory
md MyFolder

REM Create nested directories (all created at once)
md C:\Projects\2024\Reports\January

REM Create multiple directories
md Logs && md Output && md Temp

REM Create with a variable
set BACKUP_DIR=C:\Backups\%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%
md "%BACKUP_DIR%"

REM Create if it doesn't exist (idiomatic pattern)
if not exist "C:\MyLogs\" md "C:\MyLogs"
```

### Common Mistakes
- Forgetting quotes around paths with spaces: `md My Documents` creates two directories; `md "My Documents"` creates one
- Trying to create a directory that already exists — this produces an error but can be suppressed with `2>nul`

### Related Commands
`RD`, `RMDIR`, `CD`, `DIR`, `TREE`

---

## MORE

### Command Name
`MORE` — Display output one screen at a time

### Syntax
```
MORE [/E] [/C] [/P] [/S] [/T tabsize] [+n] [files]
MORE [options] < [drive:][path]filename
command | MORE [options]
```

### Description
**Simple:** Pauses output after each screen full of text, allowing you to read it before it scrolls away.

**Technical:** `MORE` is a filter command that reads stdin and buffers output, pausing after each screen (based on the console window height). Press Space for the next page, Enter for the next line, Q to quit. In the `/E` extended mode, it supports additional navigation: F (forward page), P (forward N lines), B (back page), = (show line number). Very useful with verbose commands like `SYSTEMINFO`, `NETSTAT`, `HELP`, and log file viewing.

### Example Usage
```cmd
REM Page through a large file
more bigfile.txt

REM Page through command output
systeminfo | more

REM Page through help
help | more

REM View a file starting at line 10
more +10 bigfile.txt

REM Compress consecutive blank lines
more /s bigfile.txt
```

### Related Commands
`TYPE`, `FIND`, `FINDSTR`, `SORT`

---

## MOVE

### Command Name
`MOVE` — Move files from one location to another (also renames files)

### Syntax
```
MOVE [/Y | /-Y] [drive:][path]filename1[,...] destination
```
| Switch | Meaning |
|---|---|
| `/Y` | Suppress overwrite confirmation |
| `/-Y` | Prompt before overwriting |

### Description
**Simple:** Moves files to a new location or renames them — like drag-and-drop in File Explorer.

**Technical:** `MOVE` is a CMD internal command. When moving within the same volume, it simply updates the directory entry (no data is physically moved). When moving across volumes, it copies the data and then deletes the original — equivalent to `COPY` + `DEL`. Unlike `COPY`, `MOVE` also works on directories (as a rename/move operation). MOVE does not support recursion for content inside directories when specifying wildcards.

### Example Usage
```cmd
REM Move a file to a different folder
move report.txt C:\Archive\

REM Move and rename
move oldname.txt newname.txt

REM Move all .log files to archive
move *.log C:\Logs\Archive\

REM Move a directory (rename)
move "Old Project" "New Project"

REM Suppress overwrite confirmation
move /y source.txt dest.txt
```

### Related Commands
`COPY`, `XCOPY`, `ROBOCOPY`, `DEL`, `REN`

---

## MSIEXEC

### Command Name
`MSIEXEC` — Windows Installer — install, modify, and perform operations on Windows Installer packages

### Syntax
```
msiexec /i package.msi [/quiet] [/norestart] [property=value ...]
msiexec /x package.msi [/quiet]
msiexec /a package.msi
msiexec /j[u|m] package.msi
msiexec /l[*vxoicewapuq] logfile
msiexec /q[n|b|r|f]
```
| Switch | Meaning |
|---|---|
| `/i` | Install a package |
| `/x` or `/uninstall` | Uninstall a package |
| `/quiet` | Silent install (no UI) |
| `/norestart` | Do not reboot after install |
| `/l*v logfile` | Verbose logging to a file |
| `/q` | Quiet mode: `/qn`=no UI, `/qb`=basic UI |

### Description
**Simple:** Installs, repairs, or removes software packaged as `.msi` (Windows Installer) files from the command line — useful for automated deployments.

**Technical:** `MSIEXEC.exe` is the Windows Installer service host. MSI packages are COM-structured storage files (essentially OLE databases) containing installation instructions, files, registry entries, and custom actions. `/l*v` enables maximum logging (useful for troubleshooting failed installs). Transform files (`.mst`) can modify MSI behavior: `msiexec /i package.msi TRANSFORMS=custom.mst`.

### Example Usage
```cmd
REM Install silently with no reboot
msiexec /i application.msi /quiet /norestart

REM Install with verbose log
msiexec /i application.msi /l*v install_log.txt

REM Uninstall silently
msiexec /x application.msi /quiet /norestart

REM Uninstall by product GUID
msiexec /x {GUID} /quiet

REM Repair an installation
msiexec /f application.msi

REM Get product GUID list
wmic product get name,identifyingnumber
```

### Related Commands
`WMIC product`, PowerShell `Get-Package`, `winget`

---

## MSG

### Command Name
`MSG` — Send a message to another user session

### Syntax
```
MSG {username | sessionname | sessionid | @filename | *} [/server:servername] [/time:seconds] [/v] [/w] [message]
```
| Switch | Meaning |
|---|---|
| `*` | Send to all sessions |
| `/server:` | Target a remote server |
| `/time:N` | Time (seconds) before message auto-dismisses |
| `/v` | Verbose |
| `/w` | Wait for user to dismiss the message |

### Description
**Simple:** Sends a pop-up message to another user currently logged into the same computer or a terminal server.

**Technical:** `MSG` uses the Terminal Services `WinStationSendMessage` API to display a message dialog in the target user's session. It replaces the older `NET SEND` command (which used the Messenger Service, disabled since Windows XP SP2). `MSG` only works for sessions on the same machine or terminal server — it is not a network broadcast tool. Requires sufficient privileges to message other users' sessions.

### Example Usage
```cmd
REM Send message to current user
msg %USERNAME% "System maintenance in 10 minutes"

REM Send to all sessions on this machine
msg * "Server will reboot in 5 minutes. Please save your work."

REM Send to a specific session ID
msg 2 "Your file has finished processing"

REM Send to a user by name
msg john.smith "Please call the help desk"

REM Send with auto-dismiss after 30 seconds
msg * /time:30 "This message will close in 30 seconds"
```

### Related Commands
`QUERY SESSION`, `QUERY USER`, `LOGOFF`

---

*Back to: [L.md](L.md) | Next: [N.md](N.md)*
