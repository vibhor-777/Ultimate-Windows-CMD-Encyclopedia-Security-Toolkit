# CMD Encyclopedia — Commands Starting with D

---

## DEL / ERASE

### Command Name
`DEL` / `ERASE` — Delete one or more files

### Syntax
```
DEL [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names
ERASE [/P] [/F] [/S] [/Q] [/A[[:]attributes]] names
```
| Switch | Meaning |
|---|---|
| `/P` | Prompt for confirmation before deleting |
| `/F` | Force deletion of read-only files |
| `/S` | Delete from all subdirectories |
| `/Q` | Quiet mode (no confirmation for wildcards) |
| `/A` | Delete based on attributes (H=hidden, R=readonly, S=system) |

### Description
**Simple:** Permanently deletes files (bypasses the Recycle Bin when used from CMD).

**Technical:** `DEL` marks file clusters as available in the filesystem allocation table but does not immediately overwrite data — the data remains on disk until overwritten by new files. This means deleted files can potentially be recovered with forensic tools unless the drive is subsequently overwritten. `DEL` and `ERASE` are identical; both are CMD internal commands.

> ⚠️ **WARNING:** Files deleted with `DEL` from CMD do NOT go to the Recycle Bin. They are immediately unlinked.

### Example Usage
```cmd
REM Delete a specific file
del report.txt

REM Delete with confirmation prompt (safer)
del /p important.doc

REM Delete all .tmp files in current folder
del *.tmp

REM Delete all .log files recursively (be careful!)
del /s /q *.log

REM Force delete a read-only file
del /f protected.txt

REM Delete hidden files
del /a:h hiddenfile.txt
```

### Common Mistakes
- Using `del /s /q *.*` without testing the path first — this deletes ALL files recursively without prompting
- Expecting deleted files to be in the Recycle Bin — they are not when deleted via CMD
- Not using `/p` when deleting important files

### Related Commands
`RD`, `RMDIR`, `ATTRIB`, `CIPHER /W` (secure delete), `MOVE`

---

## DIR

### Command Name
`DIR` — Display a list of files and subdirectories in a directory

### Syntax
```
DIR [drive:][path][filename] [/A[[:]attributes]] [/B] [/C] [/D] [/L] [/N] [/O[[:]sortorder]] [/P] [/Q] [/R] [/S] [/T[[:]timefield]] [/W] [/X] [/4]
```
| Switch | Meaning |
|---|---|
| `/A` | Display files with specified attributes (H=hidden, S=system, D=dirs, R=readonly) |
| `/B` | Bare format (no header, sizes, dates) |
| `/S` | Include all subdirectories |
| `/O` | Sort order (N=name, S=size, E=extension, D=date, G=group dirs first) |
| `/P` | Pause after each screen |
| `/Q` | Show file owner |
| `/R` | Show alternate data streams |
| `/W` | Wide format |
| `/X` | Show short 8.3 filenames |

### Description
**Simple:** Lists files and folders in a directory, similar to viewing a folder in File Explorer.

**Technical:** `DIR` reads directory entries from the filesystem. On NTFS, it reads the `$MFT` (Master File Table) records for the specified directory. The `/R` switch reveals NTFS Alternate Data Streams (ADS), which can be used to hide data or as the Zone Identifier. `/A:H /A:S` reveals hidden and system files that are normally invisible.

### Example Usage
```cmd
REM List current directory
dir

REM List all files including hidden and system files
dir /a

REM Recursive listing (all files in all subfolders)
dir /s

REM Just filenames, no formatting
dir /b

REM Sort by size, largest first
dir /o:-s

REM Show files modified today
dir /o:d

REM Find all .exe files recursively
dir /s /b *.exe

REM Show file owner
dir /q

REM Show alternate data streams
dir /r

REM List only directories
dir /a:d /b
```

### Output Explanation
```
 Volume in drive C is Windows
 Volume Serial Number is ABCD-1234

 Directory of C:\Users\John

01/15/2024  10:30 AM    <DIR>          Documents
01/15/2024  09:15 AM            45,231 report.docx
               1 File(s)         45,231 bytes
               1 Dir(s)  123,456,789,012 bytes free
```

### Related Commands
`CD`, `ATTRIB`, `FIND`, `FINDSTR`, `TREE`

---

## DISKPART

### Command Name
`DISKPART` — Disk partitioning utility (interactive)

### Syntax
```
diskpart
```
Then at the DISKPART prompt:
```
list disk
list volume
list partition
select disk N
select volume N
select partition N
detail disk
detail volume
detail partition
```

### Description
**Simple:** A powerful interactive tool for managing hard drives, SSDs, partitions, and volumes.

**Technical:** `DISKPART` is a command-line interpreter for the Windows Disk Management infrastructure (`dmconfig.dll`). It provides full control over disk geometry, partition tables (MBR and GPT), volume management (including dynamic disks and software RAID/spanned volumes), and removable media. `DISKPART` requires Administrator privileges. Destructive operations (like `clean`, `format`, `delete partition`) are irreversible without backup.

### Example Usage
```cmd
REM Start diskpart (type commands at the DISKPART> prompt)
diskpart

REM Then at DISKPART> prompt:
list disk
list volume
select disk 0
detail disk
list partition
select partition 1
detail partition
exit
```

### Script mode (run commands from a file):
```cmd
REM Create a script file
echo list disk > diskpart_script.txt
echo list volume >> diskpart_script.txt
diskpart /s diskpart_script.txt
```

### Common Mistakes
- Running destructive commands (`clean`, `delete partition`, `format`) without selecting the correct disk first
- Forgetting `exit` — diskpart stays open otherwise

### Related Commands
`FORMAT`, `CHKDSK`, `FSUTIL`, `CONVERT`

---

## DISM

### Command Name
`DISM` — Deployment Image Servicing and Management

### Syntax
```
dism /online /cleanup-image /scanhealth
dism /online /cleanup-image /checkhealth
dism /online /cleanup-image /restorehealth
dism /online /get-features
dism /online /enable-feature /featurename:FeatureName
dism /online /disable-feature /featurename:FeatureName
dism /image:path /get-drivers
```

### Description
**Simple:** Repairs Windows system files, checks the health of the Windows image, and manages optional Windows features.

**Technical:** `DISM` (Deployment Image Servicing and Management) services Windows images (online running OS or offline `.wim`/`.vhd` files). `ScanHealth` checks if the component store has corruption. `RestoreHealth` downloads replacement files from Windows Update or a specified source to repair a corrupted component store. `SFC /scannow` works on individual files; DISM works on the component store that `SFC` draws from — run DISM before SFC if SFC fails.

### Example Usage
```cmd
REM Check if Windows image has detected corruption
dism /online /cleanup-image /checkhealth

REM Scan for corruption (takes several minutes)
dism /online /cleanup-image /scanhealth

REM Repair detected corruption from Windows Update
dism /online /cleanup-image /restorehealth

REM List all Windows features
dism /online /get-features /format:table

REM Enable .NET Framework 3.5
dism /online /enable-feature /featurename:NetFX3 /All /Source:D:\sources\sxs /LimitAccess

REM Check pending operations
dism /online /cleanup-image /analyzecomponentstore
```

### Common Mistakes
- Running SFC before DISM when SFC keeps failing (SFC needs DISM's component store to be healthy first)
- Not being connected to the internet when RestoreHealth needs to download files

### Related Commands
`SFC`, `CHKDSK`, `BCDEDIT`

---

## DOSKEY

### Command Name
`DOSKEY` — Command-line editing, command history, and macro creation

### Syntax
```
DOSKEY [/reinstall] [/listhistory] [/history] [/insert | /overstrike] [/exename=name] [macroname=[text]]
```

### Description
**Simple:** Lets you view your command history, recall previous commands, and create keyboard shortcuts (macros) for frequently used commands.

**Technical:** `DOSKEY` is a CMD add-in that enhances the command line with readline-style editing. It maintains a command history buffer (default 50 commands) and provides macro expansion at the command line. Macros support positional parameters (`$1` through `$9`), `$*` for all parameters, and `$T` to chain multiple commands. Macros are session-scoped and are lost when CMD closes.

### Example Usage
```cmd
REM Show command history
doskey /history

REM Create a macro
doskey ls=dir /b
doskey np=notepad $1
doskey sysinfo=systeminfo | more

REM Use the macro
ls
np myfile.txt

REM List all defined macros
doskey /macros

REM Save macros to a file for reuse
doskey /macros > my_macros.txt
```

### Related Commands
`CMD`, `SET`, `PROMPT`

---

## DRIVERQUERY

### Command Name
`DRIVERQUERY` — Display a list of installed device drivers

### Syntax
```
driverquery [/s computer] [/u domain\user /p password] [/fo format] [/nh] [/v] [/si]
```
| Switch | Meaning |
|---|---|
| `/fo` | Output format: TABLE (default), LIST, CSV |
| `/v` | Verbose (includes driver file, start mode, state) |
| `/si` | Show digital signature information |
| `/s` | Remote computer name |

### Description
**Simple:** Lists all device drivers installed on the system, including their names, types, and status.

**Technical:** `DRIVERQUERY` queries the Service Control Manager for services of type `DRIVER`. It reports both kernel-mode and user-mode drivers. The `/si` switch is particularly useful for security auditing — unsigned or improperly signed drivers can be a sign of malware (rootkits often operate as unsigned kernel drivers). Requires Administrator for complete output.

### Example Usage
```cmd
REM List all drivers
driverquery

REM Detailed driver information
driverquery /v

REM Check driver signatures
driverquery /si

REM Export as CSV
driverquery /fo csv > drivers.csv

REM Query remote computer
driverquery /s REMOTE-PC
```

### Related Commands
`SC`, `WMIC`, `DEVMGMT.MSC`

---

## DSQUERY

### Command Name
`DSQUERY` — Query Active Directory (requires AD tools)

### Syntax
```
dsquery user [-name name] [-desc description] [-upn upn] [-samid samid] [-inactive weeks]
dsquery computer [-name name] [-desc description] [-loc location]
dsquery group [-name name]
dsquery ou [-name name]
dsquery * "LDAP filter" [-scope subtree|onelevel|base] [-attr attributes]
```

### Description
**Simple:** Searches Active Directory for users, computers, groups, and other objects — for domain-joined computers only.

**Technical:** `DSQUERY` is part of the Active Directory Domain Services (AD DS) Tools package. It constructs LDAP queries against the domain controller and returns Distinguished Names (DNs) of matching objects. Output from `DSQUERY` is often piped into `DSGET`, `DSMOD`, `DSMOVE`, or `DSRM` for further operations. Requires AD tools to be installed and the computer to be domain-joined.

### Example Usage
```cmd
REM Find all users (on a domain-joined machine)
dsquery user -limit 0

REM Find disabled user accounts
dsquery user -disabled

REM Find computers in a specific OU
dsquery computer "OU=Workstations,DC=company,DC=com"

REM Find groups containing "admin"
dsquery group -name "*admin*"

REM Find users inactive for 4+ weeks
dsquery user -inactive 4
```

### Related Commands
`NET USER`, `NET LOCALGROUP`, `WHOAMI`, PowerShell `Get-ADUser`

---

*Back to: [C.md](C.md) | Next: [E.md](E.md)*
