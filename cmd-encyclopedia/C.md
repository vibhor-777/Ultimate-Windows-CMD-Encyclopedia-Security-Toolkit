# CMD Encyclopedia — Commands Starting with C

---

## CD / CHDIR

### Command Name
`CD` / `CHDIR` — Change the current directory

### Syntax
```
CD [/D] [drive:][path]
CD [..]
CHDIR [/D] [drive:][path]
```
| Switch | Meaning |
|---|---|
| `/D` | Also change the current drive (not just directory) |
| `..` | Move up one directory level |

### Description
**Simple:** Changes which folder you are currently working in, like clicking into a folder in File Explorer.

**Technical:** `CD` modifies the current working directory tracked per process in the Windows process environment block. Without `/D`, it changes the directory on the current drive but does not switch drives. Each drive letter has its own "current directory" tracked separately by CMD. `CD` without arguments prints the current path.

### Example Usage
```cmd
REM Print current directory
cd

REM Go to a specific folder
cd C:\Windows\System32

REM Go up one level
cd ..

REM Go up two levels
cd ..\..

REM Switch to a different drive AND directory
cd /d D:\Projects

REM Go to user's home directory
cd %USERPROFILE%

REM Go to the desktop
cd %USERPROFILE%\Desktop
```

### Common Mistakes
- Forgetting `/D` when switching drives (`cd D:\path` won't switch drives without `/D`)
- Using `cd` in a script and expecting it to affect the parent process — it won't; `cd` only affects the current CMD session

### Related Commands
`DIR`, `PUSHD`, `POPD`, `MD`, `RD`

---

## CLS

### Command Name
`CLS` — Clear the console screen

### Syntax
```
CLS
```

### Description
**Simple:** Clears all text from the CMD window, giving you a clean screen.

**Technical:** `CLS` sends a VT100 escape sequence (or equivalent) to the console to clear the screen buffer and move the cursor to the top-left (home) position. In Windows CMD, it uses the `FillConsoleOutputCharacter` Win32 API call. It does not affect the command history (use `DOSKEY /LISTHISTORY` or the Up arrow to retrieve previous commands).

### Example Usage
```cmd
cls
```

### Related Commands
`COLOR`, `TITLE`, `PROMPT`

---

## COPY

### Command Name
`COPY` — Copy one or more files to another location

### Syntax
```
COPY [/D] [/V] [/N] [/Y | /-Y] [/Z] [/L] [/A | /B] source [/A | /B] [+ source ...] [destination [/A | /B]]
```
| Switch | Meaning |
|---|---|
| `/Y` | Suppress overwrite confirmation |
| `/-Y` | Prompt before overwrite |
| `/V` | Verify each new file is written correctly |
| `/Z` | Copy in restartable mode (network files) |
| `/A` | Treat as ASCII (text) file |
| `/B` | Treat as binary file |
| `/D` | Allow the destination to be a decrypted file |

### Description
**Simple:** Copies files from one place to another. Can also concatenate multiple files.

**Technical:** `COPY` is a CMD internal command (not an external `.exe`) that copies file data. Unlike `XCOPY` or `ROBOCOPY`, it does not preserve file timestamps, attributes, or ACLs by default. It supports file concatenation using the `+` operator (useful for combining text files or binary chunks). For reliable large-scale copies, `ROBOCOPY` is preferred.

### Example Usage
```cmd
REM Copy a single file
copy C:\source\file.txt D:\destination\

REM Copy and rename
copy file.txt backup.txt

REM Copy all .txt files
copy *.txt D:\backup\

REM Copy without overwrite prompt
copy /y source.txt dest.txt

REM Concatenate files (append file2 to file1, result in combined.txt)
copy /b file1.txt + file2.txt combined.txt

REM Duplicate a file in the same folder
copy report.doc report_backup.doc
```

### Common Mistakes
- Using `COPY` for folder trees — it doesn't recurse; use `XCOPY /E` or `ROBOCOPY`
- Expecting timestamps to be preserved — they are not; use `XCOPY /K` or `ROBOCOPY`
- Overwriting silently when `/Y` is set in the environment (`COPYCMD=/Y`)

### Related Commands
`XCOPY`, `ROBOCOPY`, `MOVE`, `DEL`

---

## CIPHER

### Command Name
`CIPHER` — Display or alter the encryption of folders and files (EFS)

### Syntax
```
CIPHER [/E | /D] [/S:directory] [/A] [/I] [/F] [/Q] [/H] [/K] [/U [/N]] [pathname [...]]
CIPHER /W:directory
CIPHER /R:efsfile [/SMARTCARD]
CIPHER /P
```
| Switch | Meaning |
|---|---|
| `/E` | Encrypt |
| `/D` | Decrypt |
| `/S` | Apply to all subfolders |
| `/W` | Wipe free space on a volume (secure delete aid) |
| `/R` | Generate an EFS recovery key |
| `/K` | Create new encryption key for current user |

### Description
**Simple:** Encrypts or decrypts files using Windows EFS (Encrypting File System), and can also securely overwrite free disk space.

**Technical:** EFS (Encrypting File System) is built into NTFS and encrypts files transparently at the filesystem level using a per-file symmetric key (AES-256 in modern Windows), which is itself encrypted with the user's public key (RSA). `CIPHER /W` overwrites free space to help prevent recovery of deleted files — it writes zeros, then ones, then random data in three passes over unallocated clusters. Note: EFS only works on NTFS volumes; FAT/exFAT are not supported.

### Example Usage
```cmd
REM Show encryption status of current directory
cipher

REM Encrypt a folder and all its contents
cipher /e /s:"C:\Sensitive Documents"

REM Decrypt a folder
cipher /d /s:"C:\Documents"

REM Securely wipe free space on C: (takes a long time)
cipher /w:C:\

REM Generate an EFS recovery agent certificate
cipher /r:recovery_cert
```

### Output Explanation
```
 Listing C:\Users\John\Documents\
 New files added to this directory will not be encrypted.

U Secret.txt      (E = encrypted, U = unencrypted)
E Financials.xlsx
```

### Common Mistakes
- EFS encryption is tied to your user account — if you lose your profile or certificate, encrypted files become inaccessible
- Always export your EFS certificate: `certmgr.msc` → Personal → Certificates → export
- `CIPHER /W` only wipes currently free space, not existing files

### Related Commands
`ATTRIB`, `ICACLS`, `COMPACT`, `BITLOCKER` (separate tool)

---

## CHKDSK

### Command Name
`CHKDSK` — Check disk for errors

### Syntax
```
CHKDSK [volume[[path]filename]] [/F] [/V] [/R] [/X] [/I] [/C] [/B] [/scan] [/perf] [/spotfix]
```
| Switch | Meaning |
|---|---|
| (none) | Read-only check — reports errors but does not fix |
| `/F` | Fix errors (schedules reboot if volume is in use) |
| `/R` | Locate bad sectors and recover readable info (implies /F) |
| `/V` | On FAT: list every file; on NTFS: display cleanup messages |
| `/X` | Force volume dismount before check |
| `/scan` | NTFS only: run online scan |

### Description
**Simple:** Checks your hard drive or SSD for file system errors and, optionally, repairs them.

**Technical:** `CHKDSK` uses the filesystem driver to traverse the directory tree and verify the integrity of: MFT (Master File Table) entries on NTFS, file and directory attribute records, security descriptors, allocation bitmaps, and bad cluster tracking. Without `/F`, it is entirely read-only. With `/F` on the system drive (C:), Windows schedules the check to run before the next boot when the volume is not mounted.

### Example Usage
```cmd
REM Read-only check of C: (safe, no changes)
chkdsk C:

REM Read-only check with verbose output
chkdsk C: /v

REM Full check with repair (will schedule reboot for C:)
chkdsk C: /f

REM Check for bad sectors (slow - reads every sector)
chkdsk C: /r

REM Online scan of NTFS volume (no dismount needed)
chkdsk C: /scan

REM Check another drive
chkdsk D: /f
```

### Common Mistakes
- Running `chkdsk /f` on C: without expecting a reboot — it schedules a pre-boot check
- Running `chkdsk /r` on large drives without expecting it to take hours
- Confusing CHKDSK errors with SMART errors — use `wmic diskdrive get status` for SMART

### Related Commands
`DISKPART`, `FSUTIL`, `SFC`, `DISM`, `DEFRAG`

---

## CMD

### Command Name
`CMD` — Start a new instance of the Windows Command Interpreter

### Syntax
```
CMD [/A | /U] [/Q] [/D] [/E:ON | /E:OFF] [/F:ON | /F:OFF] [/V:ON | /V:OFF] [[/S] [/C | /K] string]
```
| Switch | Meaning |
|---|---|
| `/C` | Execute string and terminate |
| `/K` | Execute string and remain open |
| `/S` | Strips first and last quote from string |
| `/Q` | Turn off echo |
| `/A` | ANSI output |
| `/U` | Unicode output |
| `/V:ON` | Enable delayed environment variable expansion |
| `/D` | Disable execution of AutoRun registry entries |
| `/E:ON` | Enable command extensions |

### Description
**Simple:** Launches a new CMD window or runs a command in a new CMD instance.

**Technical:** `cmd.exe` is the Windows command interpreter. Launching it with `/C` creates a child process that executes a command and exits — this is how `START`, `CALL`, and other scripts invoke external commands. `/V:ON` enables delayed expansion (uses `!var!` syntax for variables inside loops and IF blocks). `/D` prevents AutoRun registry keys from executing, which is useful for security-conscious scripting.

### Example Usage
```cmd
REM Open a new CMD window
cmd

REM Run a command and close
cmd /c dir C:\

REM Run a command and stay open
cmd /k "echo Hello && dir"

REM Launch with delayed expansion enabled
cmd /v:on /k echo Type !USERPROFILE! to test

REM Run a script in a clean CMD (no AutoRun)
cmd /d /c myscript.bat
```

### Related Commands
`START`, `CALL`, `POWERSHELL`

---

## COMP

### Command Name
`COMP` — Compare the contents of two files or sets of files byte-by-byte

### Syntax
```
COMP [data1] [data2] [/D] [/A] [/L] [/N=number] [/C] [/OFF[LINE]]
```

### Description
**Simple:** Compares two files and tells you if they are identical or where they differ.

**Technical:** `COMP` performs a byte-by-byte comparison of two files. It reports the first 10 differences with the offset and differing values. Unlike `FC`, which does a line-by-line comparison with context, `COMP` is purely binary/byte-level. For text file comparison with context lines, `FC` is more useful.

### Example Usage
```cmd
REM Compare two files
comp file1.txt file2.txt

REM Compare ignoring case differences
comp file1.txt file2.txt /c

REM Compare and show differences as characters
comp file1.txt file2.txt /a

REM Compare only first 100 lines
comp file1.txt file2.txt /n=100
```

### Related Commands
`FC`, `FINDSTR`

---

## COMPACT

### Command Name
`COMPACT` — Display or alter the compression of files on NTFS partitions

### Syntax
```
COMPACT [/C | /U] [/S[:dir]] [/A] [/I] [/F] [/Q] [/EXE[:algorithm]] [filename]
```

### Description
**Simple:** Compresses or decompresses files to save disk space on NTFS volumes.

**Technical:** NTFS compression is implemented at the filesystem driver level, compressing data transparently using a modified LZ77 algorithm. Compressed files appear normal to applications but take less space on disk. Compression is most effective for text files, logs, and rarely-accessed archives. Modern SSDs are fast enough that NTFS compression offers little performance benefit and may cause slight overhead. `COMPACT /EXE` (Windows 10+) uses superior compression algorithms (XPRESS4K, XPRESS8K, XPRESS16K, LZX) optimised for executable files.

### Example Usage
```cmd
REM Show compression status of current directory
compact

REM Compress a directory and all contents
compact /c /s:"C:\OldArchives"

REM Decompress
compact /u /s:"C:\OldArchives"

REM Show compression ratio
compact /s /q
```

### Related Commands
`CIPHER`, `ATTRIB`, `FSUTIL`

---

## CONVERT

### Command Name
`CONVERT` — Convert a FAT/FAT32 volume to NTFS

### Syntax
```
CONVERT volume /FS:NTFS [/V] [/CvtArea:filename] [/NoSecurity] [/X]
```

### Description
**Simple:** Converts a drive formatted as FAT or FAT32 to NTFS without deleting your files.

**Technical:** `CONVERT` performs a one-way, non-destructive filesystem conversion. It reads the existing FAT/FAT32 structures and migrates file data to an NTFS volume layout, creating the MFT, $Bitmap, $LogFile, and other NTFS metadata structures. The conversion cannot be reversed with `CONVERT` — converting NTFS back to FAT requires formatting (which erases data). Always back up data before converting. The system drive (C:) requires a reboot to convert.

### Example Usage
```cmd
REM Convert D: from FAT32 to NTFS
convert D: /fs:ntfs

REM Convert with verbose output
convert D: /fs:ntfs /v
```

### Common Mistakes
- Attempting to convert back to FAT — not possible without formatting
- Not backing up before conversion (rare, but conversion can fail on corrupted FAT volumes)

### Related Commands
`FORMAT`, `DISKPART`, `FSUTIL`, `CHKDSK`

---

*Back to: [B.md](B.md) | Next: [D.md](D.md)*
