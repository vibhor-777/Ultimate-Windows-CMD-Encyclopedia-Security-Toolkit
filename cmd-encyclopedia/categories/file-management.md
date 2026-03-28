# File Management Commands — Category Guide

A comprehensive guide to managing files and folders from the Windows Command Prompt.

---

## Overview

File management is one of the most common tasks performed in CMD. This guide groups file management commands by task, so you can quickly find what you need.

---

## 1. Creating Files and Folders

### Creating Directories

```cmd
REM Create a single directory
md Reports

REM Create nested directories (creates all missing intermediate folders)
md C:\Projects\2024\Q1\Reports

REM Create multiple directories in one line
md Logs && md Output && md Temp

REM Create a directory only if it doesn't exist
if not exist "C:\MyLogs\" md "C:\MyLogs"
```

**Command:** `MD` / `MKDIR` — See [M.md](../M.md)

### Creating Files

```cmd
REM Create an empty file
type nul > newfile.txt
copy nul newfile.txt

REM Create a file with content
echo This is my file > myfile.txt

REM Create a file with multiple lines
(
    echo Line 1
    echo Line 2
    echo Line 3
) > multiline.txt

REM Append to an existing file
echo New line >> existing.txt

REM Create a timestamped log file
set LOG=log_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt
echo Log started %DATE% %TIME% > %LOG%
```

**Commands:** `ECHO`, `TYPE`, `COPY NUL`

---

## 2. Deleting Files and Folders

### Deleting Files

```cmd
REM Delete a specific file
del report.txt

REM Delete with confirmation prompt (safer)
del /p important.doc

REM Delete all files of a type
del *.tmp

REM Delete recursively (all .log files in all subdirectories)
del /s /q *.log

REM Force delete read-only files
del /f protected.txt

REM Delete hidden files
del /a:h hiddenfile.txt
```

> ⚠️ Files deleted with `DEL` from CMD do NOT go to the Recycle Bin.

**Command:** `DEL` / `ERASE` — See [D.md](../D.md)

### Deleting Directories

```cmd
REM Remove an empty directory
rd emptydir

REM Remove a directory and all its contents (with confirmation)
rd /s OldFolder

REM Remove without any confirmation (be very careful)
rd /s /q TempFiles
```

**Command:** `RD` / `RMDIR` — See [R.md](../R.md)

---

## 3. Copying Files

### Basic Copy

```cmd
REM Copy a file to another location
copy source.txt D:\Backup\

REM Copy and rename
copy original.txt backup_copy.txt

REM Copy all files of a type
copy *.txt D:\TextBackup\

REM Suppress overwrite confirmation
copy /y source.txt dest.txt

REM Verify the copy is correct
copy /v source.txt dest.txt
```

**Command:** `COPY` — See [C.md](../C.md)

### Copy Directory Trees

```cmd
REM Copy entire directory tree (excluding empty folders)
xcopy C:\Source D:\Dest /s /i

REM Copy entire tree including empty folders, preserve attributes
xcopy C:\Source D:\Dest /e /h /k /i

REM Robust copy with retry (best for networks)
robocopy C:\Source D:\Dest /e

REM Mirror (keep destination identical to source)
robocopy C:\Source D:\Dest /mir

REM Copy preserving all metadata (timestamps, ACLs, owner)
robocopy C:\Source D:\Dest /e /copyall

REM Copy with logging
robocopy C:\Source D:\Dest /e /log:copy_log.txt
```

**Commands:** `XCOPY` — See [X.md](../X.md) | `ROBOCOPY` — See [R.md](../R.md)

---

## 4. Moving Files

```cmd
REM Move a file to another folder
move report.txt C:\Archive\

REM Move and rename
move oldname.txt newname.txt

REM Move all files of a type
move *.log C:\Logs\Archive\

REM Suppress overwrite confirmation
move /y file.txt dest\file.txt
```

**Command:** `MOVE` — See [M.md](../M.md)

---

## 5. Renaming Files and Folders

```cmd
REM Rename a file
ren oldname.txt newname.txt

REM Rename multiple files (change extension)
ren *.log *.bak

REM Rename a folder
ren "Old Folder Name" "New Folder Name"

REM Rename with a prefix (using FOR loop)
for %f in (*.txt) do ren "%f" "2024_%f"
```

**Command:** `REN` / `RENAME` — See [R.md](../R.md)

---

## 6. Searching for Files

### By Name

```cmd
REM Find files by name in current directory
dir report.txt

REM Find all .txt files recursively
dir /s /b *.txt

REM Find files matching a pattern
dir /s /b *report*

REM Find all files in a directory tree
for /r C:\Users %f in (*.docx) do echo %f
```

### By Content

```cmd
REM Search file contents for a string
findstr "error" *.log

REM Case-insensitive, recursive search
findstr /s /i "password" C:\Configs\*

REM Search for a regex pattern (IP addresses)
findstr /r "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" network.log

REM Simple filter (literal string, no regex)
find "ERROR" logfile.txt
```

**Commands:** `DIR` — See [D.md](../D.md) | `FIND` — See [F.md](../F.md) | `FINDSTR` — See [F.md](../F.md)

---

## 7. File Permissions and Attributes

### File Attributes (Basic Flags)

```cmd
REM Show attributes of all files
attrib

REM Show all files including hidden
attrib /s /d

REM Make a file read-only
attrib +r important.txt

REM Hide a file
attrib +h secretfile.txt

REM Unhide files
attrib -h -s *.* /s

REM Set archive attribute (mark for backup)
attrib +a *.txt
```

**Command:** `ATTRIB` — See [A.md](../A.md)

### NTFS Permissions (ACLs)

```cmd
REM View file permissions
icacls "C:\MyFolder"

REM Grant user read+execute
icacls "C:\MyFolder" /grant DOMAIN\john:(RX)

REM Grant admin full control recursively
icacls "C:\MyFolder" /grant Administrators:(OI)(CI)F /t

REM Remove a user's access
icacls "C:\MyFolder" /remove DOMAIN\john

REM Reset to inherited permissions
icacls "C:\MyFolder" /reset /t

REM Save permissions to file
icacls "C:\MyFolder" /save acl_backup.txt /t

REM Restore permissions
icacls "C:\MyFolder" /restore acl_backup.txt
```

**Command:** `ICACLS` — See [I.md](../I.md)

### Encryption (EFS)

```cmd
REM Encrypt a folder
cipher /e /s:"C:\SensitiveData"

REM Decrypt
cipher /d /s:"C:\SensitiveData"

REM Check encryption status
cipher

REM Securely wipe free space
cipher /w:C:\
```

**Command:** `CIPHER` — See [C.md](../C.md)

---

## 8. Disk Operations

### Check Disk Space

```cmd
REM Show disk space for all drives
fsutil volume diskfree C:
wmic logicaldisk get deviceid,size,freespace,filesystem

REM Show space for a specific drive
for /f "tokens=*" %d in ('wmic logicaldisk get deviceid /value ^| findstr "DeviceID"') do echo %d
```

### Check Disk Health

```cmd
REM Read-only disk check (no repairs)
chkdsk C:

REM Full check with repairs (schedules reboot for C:)
chkdsk C: /f

REM Online NTFS scan (no dismount)
chkdsk C: /scan
```

**Command:** `CHKDSK` — See [C.md](../C.md)

### File Comparison

```cmd
REM Compare two files
fc file1.txt file2.txt

REM Binary comparison
fc /b program_v1.exe program_v2.exe

REM Case-insensitive text compare
fc /c config1.ini config2.ini
```

**Command:** `FC` — See [F.md](../F.md)

---

## 9. Viewing File Contents

```cmd
REM Display file contents
type readme.txt

REM Display with paging
type largefile.txt | more

REM Display directory tree
tree /f

REM Display directory tree (ASCII mode, redirectable)
tree /f /a > structure.txt
```

**Commands:** `TYPE` — See [T.md](../T.md) | `TREE` — See [T.md](../T.md) | `MORE` — See [M.md](../M.md)

---

## 10. Quick Reference: File Management Commands

| Task | Command | Notes |
|---|---|---|
| Create directory | `md dirname` | Creates intermediate dirs automatically |
| Delete file | `del /p filename` | `/p` prompts for confirmation |
| Delete directory tree | `rd /s dirname` | Prompts; `/q` to suppress |
| Copy file | `copy src dest` | No recursion |
| Copy tree (basic) | `xcopy src dest /e /i` | |
| Copy tree (robust) | `robocopy src dest /e` | Preferred for production |
| Move file | `move src dest` | |
| Rename | `ren old new` | |
| Search for file | `dir /s /b *pattern*` | |
| Search file content | `findstr /s /i "text" *.ext` | |
| View permissions | `icacls path` | |
| Change permissions | `icacls path /grant User:(perm)` | |
| View/change attributes | `attrib` | |
| Compare files | `fc file1 file2` | |
| Check disk | `chkdsk C:` | Read-only without `/f` |
| View file | `type filename` | |
| View with pages | `more filename` | |

---

*Related guides:*
- [disk-operations.md](disk-operations.md) — Advanced disk management
- [networking.md](networking.md) — Network file access
- [user-management.md](user-management.md) — File permission users
