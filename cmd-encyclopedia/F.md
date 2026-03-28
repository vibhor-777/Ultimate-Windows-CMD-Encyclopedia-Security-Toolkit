# CMD Encyclopedia — Commands Starting with F

---

## FC

### Command Name
`FC` — File Compare — compare two files and display the differences

### Syntax
```
FC [/A] [/B] [/C] [/L] [/LBn] [/N] [/OFF[LINE]] [/T] [/U] [/W] [/nnnn] [drive1:][path1]filename1 [drive2:][path2]filename2
```
| Switch | Meaning |
|---|---|
| `/A` | Abbreviate output (show first and last line of each difference) |
| `/B` | Binary comparison |
| `/C` | Ignore case |
| `/L` | ASCII (text) comparison (default for text files) |
| `/N` | Show line numbers |
| `/T` | Do not expand tabs to spaces |
| `/W` | Compress whitespace for comparison |

### Description
**Simple:** Compares two files and shows you what is different between them, line by line (for text) or byte by byte (for binary).

**Technical:** `FC` performs a diff-like comparison. For ASCII mode (`/L`), it finds matching lines and reports blocks that differ. For binary mode (`/B`), it compares byte by byte and reports offsets and values of differing bytes. Unlike `COMP` (which only reports the first 10 differences), `FC` reports all differences. Exit code 0 = files are identical; 1 = files are different; 2 = error.

### Example Usage
```cmd
REM Compare two text files
fc file1.txt file2.txt

REM Compare ignoring case
fc /c file1.txt file2.txt

REM Binary comparison of executables
fc /b program_v1.exe program_v2.exe

REM Compare with line numbers
fc /n file1.txt file2.txt

REM Compare two config files (compress whitespace)
fc /w config1.ini config2.ini
```

### Output Explanation
```
Comparing files file1.txt and FILE2.TXT
***** file1.txt
This line is only in file1
***** FILE2.TXT
This line is only in file2
*****
```

### Related Commands
`COMP`, `FINDSTR`, `SORT`

---

## FIND

### Command Name
`FIND` — Search for a text string in files

### Syntax
```
FIND [/V] [/C] [/N] [/I] [/OFF[LINE]] "string" [[drive:][path]filename [...]]
```
| Switch | Meaning |
|---|---|
| `/V` | Display lines NOT containing the string |
| `/C` | Count lines containing the string |
| `/N` | Show line numbers |
| `/I` | Ignore case |

### Description
**Simple:** Searches one or more files for a specific piece of text and shows lines containing it.

**Technical:** `FIND` is a filter command — it reads stdin or files and outputs matching lines. It does literal string matching (no regex). For regular expression support, use `FINDSTR`. `FIND` is commonly used in pipelines to filter output: `netstat -ano | find "LISTENING"` or `tasklist | find /i "chrome"`.

### Example Usage
```cmd
REM Search a file for a string
find "error" logfile.txt

REM Case-insensitive search
find /i "ERROR" logfile.txt

REM Count occurrences
find /c "warning" logfile.txt

REM Show lines NOT containing "success"
find /v "success" results.txt

REM Filter command output
netstat -ano | find "LISTENING"
tasklist | find /i "notepad"
systeminfo | find "OS Name"
```

### Related Commands
`FINDSTR`, `GREP` (not built-in), `DIR`, `TYPE`

---

## FINDSTR

### Command Name
`FINDSTR` — Search for strings in files using regular expressions

### Syntax
```
FINDSTR [/B] [/E] [/L] [/R] [/S] [/I] [/X] [/V] [/N] [/M] [/O] [/P] [/F:file] [/C:string] [/G:file] [/D:dir list] [/A:colorattr] [strings] [[drive:][path]filename [...]]
```
| Switch | Meaning |
|---|---|
| `/R` | Use regular expressions |
| `/S` | Search subdirectories |
| `/I` | Ignore case |
| `/N` | Show line numbers |
| `/M` | Print only filenames of files containing a match |
| `/V` | Print lines that do NOT match |
| `/C:"string"` | Use exact string (allows spaces without quotes workaround) |
| `/F:file` | Read file list from a file |

### Description
**Simple:** A more powerful version of FIND that supports regular expressions and recursive file searching.

**Technical:** `FINDSTR` implements a subset of POSIX regular expressions (not full regex — notably `.` matches any character, `*` means "zero or more of previous", `^` matches start of line, `$` matches end of line). It is considerably more powerful than `FIND` but less capable than `grep`. For complex regex needs, use PowerShell's `Select-String` which uses full .NET regex.

### Example Usage
```cmd
REM Simple string search
findstr "error" *.log

REM Regex: find lines starting with a number
findstr /r "^[0-9]" data.txt

REM Recursive search, case-insensitive
findstr /s /i "password" C:\configs\*

REM Search for IP address pattern
findstr /r "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" network.log

REM Show only filenames that contain the string
findstr /m "TODO" *.bat

REM Search multiple strings (OR logic)
findstr "error warning critical" *.log

REM Search for exact phrase
findstr /c:"access denied" audit.log
```

### Related Commands
`FIND`, `FOR`, PowerShell `Select-String`

---

## FOR

### Command Name
`FOR` — Iterate over a set of files, strings, or command output

### Syntax
```
FOR %variable IN (set) DO command
FOR /D %variable IN (set) DO command          (directories only)
FOR /R [[drive:]path] %variable IN (set) DO command  (recursive)
FOR /L %variable IN (start,step,end) DO command      (number loop)
FOR /F ["options"] %variable IN (file/command/string) DO command  (parse)
```

### Description
**Simple:** Repeats a command for each item in a list — the equivalent of a for-each loop in programming.

**Technical:** `FOR` is one of the most powerful CMD constructs. `/F` (file/parse mode) is especially versatile — it can tokenise output from commands, parse delimited files (CSV, TSV), and extract specific fields. In batch files, variables use `%%variable`; in interactive CMD, use `%variable`. Delayed expansion (`setlocal enabledelayedexpansion`) is required for variables modified inside a FOR loop body.

### Example Usage
```cmd
REM Loop over a list
for %i in (apple banana cherry) do echo %i

REM Loop over files
for %f in (*.txt) do echo %f

REM Recursive file loop
for /r C:\logs %f in (*.log) do echo %f

REM Number loop (1 to 10, step 1)
for /l %i in (1,1,10) do echo %i

REM Parse command output (get just the process names)
for /f "tokens=1" %p in ('tasklist /nh') do echo %p

REM Parse a CSV file (skip header, get second field)
for /f "skip=1 tokens=2 delims=," %v in (data.csv) do echo %v

REM In a batch file (double percent signs)
for %%f in (*.txt) do (
    echo Processing: %%f
    copy "%%f" "backup\%%f"
)
```

### Common Mistakes
- Forgetting to double `%%` in batch files (single `%` is for interactive CMD)
- Not using `setlocal enabledelayedexpansion` when modifying variables inside a loop
- Using `%ERRORLEVEL%` inside a loop without delayed expansion

### Related Commands
`IF`, `GOTO`, `CALL`, `SET`, `SETLOCAL`

---

## FORMAT

### Command Name
`FORMAT` — Format a disk for use with Windows

### Syntax
```
FORMAT volume [/FS:filesystem] [/V:label] [/Q] [/L[:state]] [/A:size] [/C] [/I:state] [/X] [/P:passes]
```
| Switch | Meaning |
|---|---|
| `/FS:` | Filesystem: FAT, FAT32, exFAT, NTFS, ReFS |
| `/Q` | Quick format (skip bad sector scan) |
| `/V:` | Volume label |
| `/A:` | Cluster size |
| `/P:N` | Zero-fill sectors N times (secure wipe) |

### Description
**Simple:** Prepares a disk or partition for use by creating a new filesystem — **erases all data on the volume**.

**Technical:** `FORMAT` writes filesystem structures to a volume: boot sector, FAT tables or MFT (for NTFS), root directory, and volume metadata. `/Q` only clears the FAT/MFT without scanning for bad sectors. `/P:1` overwrites data sectors with zeros (basic secure erase). Requires the target volume to be unmounted or the user to confirm dismounting.

> ⚠️ **DESTRUCTIVE:** `FORMAT` erases all data on the target volume. Always double-check the drive letter before running.

### Example Usage
```cmd
REM Format a USB drive (D:) as FAT32
format D: /fs:fat32 /q /v:MYUSB

REM Format as NTFS with a label
format E: /fs:ntfs /v:DataDrive /q

REM Full format (checks bad sectors)
format D: /fs:ntfs

REM Secure format (zero-fill 1 pass)
format D: /fs:ntfs /p:1
```

### Common Mistakes
- Formatting the wrong drive letter — always verify with `diskpart list volume` first
- Using `/Q` on a new or suspect drive — always do a full format on new media

### Related Commands
`DISKPART`, `CONVERT`, `CHKDSK`, `FSUTIL`

---

## FSUTIL

### Command Name
`FSUTIL` — File System Utility — advanced filesystem operations

### Syntax
```
fsutil behavior query
fsutil behavior set
fsutil dirty query <volume>
fsutil fsinfo drives
fsutil fsinfo drivetype <volume>
fsutil fsinfo volumeinfo <volume>
fsutil volume diskfree <volume>
fsutil file createnew <filename> <length>
fsutil hardlink create <newname> <existingname>
fsutil reparsepoint query <filename>
```

### Description
**Simple:** A low-level utility for querying and setting filesystem properties — disk free space, volume info, and advanced NTFS features.

**Technical:** `FSUTIL` provides direct access to the filesystem driver IOCTLs. It can query and modify NTFS behaviors (like whether to update last-access timestamps), check if a volume is dirty (flagged for CHKDSK), query disk free space per volume, create sparse files, create hard links, and inspect reparse points (symlinks, junction points, mount points). Most subcommands require Administrator.

### Example Usage
```cmd
REM Check free space on C:
fsutil volume diskfree C:

REM List all drives
fsutil fsinfo drives

REM Check volume type
fsutil fsinfo drivetype C:

REM Check if volume is dirty (needs chkdsk)
fsutil dirty query C:

REM List NTFS volume info
fsutil fsinfo volumeinfo C:

REM Check NTFS behaviors
fsutil behavior query

REM Disable last-access time updates (improves SSD performance)
fsutil behavior set disablelastaccess 1

REM Create a hard link
fsutil hardlink create newlink.txt existingfile.txt
```

### Related Commands
`CHKDSK`, `COMPACT`, `CIPHER`, `DISKPART`

---

## FTP

### Command Name
`FTP` — File Transfer Protocol client

> ⚠️ **SECURITY WARNING:** FTP transmits credentials and data in **plaintext**. Use SFTP, FTPS, or SCP instead for any sensitive transfers. FTP is documented here for legacy/educational purposes only.

### Syntax
```
ftp [-v] [-d] [-i] [-n] [-g] [-s:filename] [-a] [-A] [-x:sendbuffer] [-r:recvbuffer] [-b:asyncbuffers] [-w:windowsize] [host]
```

### Description
**Simple:** Transfers files to and from FTP servers. Insecure — use modern alternatives.

**Technical:** `FTP` implements RFC 959 (File Transfer Protocol). It uses TCP port 21 for control and negotiates a data port for transfers. Because both the control channel and data channel are unencrypted, anyone on the network path can capture your username, password, and files using a packet sniffer. Modern alternatives: SFTP (SSH File Transfer Protocol, port 22), FTPS (FTP over SSL), or SCP.

### Example Usage
```cmd
REM Interactive FTP session
ftp ftp.example.com

REM Run FTP commands from a script file
ftp -s:ftp_script.txt ftp.example.com

REM FTP script file contents:
REM   open ftp.example.com
REM   user username password
REM   get remotefile.txt
REM   quit
```

### Related Commands
PowerShell `Invoke-WebRequest`, `BITSADMIN`, WinSCP (third-party SFTP/SCP client)

---

## FTYPE

### Command Name
`FTYPE` — Display or modify file type associations (program mappings)

### Syntax
```
FTYPE [filetype[=[opencommandstring]]]
```

### Description
**Simple:** Shows or sets which program opens a given file type — the second half of the file association system (`ASSOC` maps extensions to types; `FTYPE` maps types to programs).

**Technical:** `FTYPE` manages the `shell\open\command` registry values under `HKEY_CLASSES_ROOT\<filetype>`. When you double-click a file, Windows: (1) looks up the extension with `ASSOC` to get the file type, (2) looks up the file type with `FTYPE` to find the command, (3) executes the command with the file path substituted for `%1`. `%*` passes all parameters.

### Example Usage
```cmd
REM Show all file type associations
ftype | more

REM Show what opens text files
ftype txtfile

REM Show what opens batch files
ftype batfile

REM Set a new program to open a file type
ftype txtfile=notepad.exe %1
```

### Related Commands
`ASSOC`, `REG`, `START`

---

*Back to: [E.md](E.md) | Next: [G.md](G.md)*
