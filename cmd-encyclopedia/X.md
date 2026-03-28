# CMD Encyclopedia — Commands Starting with X

---

## XCOPY

### Command Name
`XCOPY` — Extended copy — copy files and directory trees

### Syntax
```
XCOPY source [destination] [/A | /M] [/D[:date]] [/P] [/S [/E]] [/V] [/W] [/C] [/I] [/Q] [/F] [/L] [/G] [/H] [/R] [/T] [/U] [/K] [/N] [/O] [/X] [/Y | /-Y] [/Z] [/B] [/J] [/EXCLUDE:file1[+file2][+file3]...]
```

**Key switches:**
| Switch | Meaning |
|---|---|
| `/S` | Copy subdirectories (excluding empty) |
| `/E` | Copy subdirectories including empty ones |
| `/H` | Copy hidden and system files |
| `/K` | Copy file attributes (preserve read-only, etc.) |
| `/O` | Copy file ownership and ACL info |
| `/G` | Copy encrypted files to unencrypted destination |
| `/Y` | Suppress overwrite confirmation |
| `/C` | Continue even if errors occur |
| `/I` | Assume destination is a directory if it doesn't exist |
| `/D` | Copy files changed on or after specified date |
| `/M` | Copy only files with the Archive attribute set (for incremental backup) |
| `/L` | List files that would be copied (dry run) |
| `/Z` | Copy in restartable mode |
| `/EXCLUDE:file` | Exclude files listed in a text file |

### Description
**Simple:** A more powerful version of `COPY` that can copy entire directory trees, preserve attributes, and handle errors more gracefully.

**Technical:** `XCOPY` is an external command (`xcopy.exe` in `System32`) that extends `COPY` with directory recursion, attribute filtering, date filtering, and error tolerance. It preserves file timestamps by default (unlike `COPY`). For very robust copying (especially over networks), `ROBOCOPY` is preferred — it has better retry logic, multi-threading, and mirror/sync capabilities. However, `XCOPY` is simpler for basic recursive copies and has been available since DOS days.

**Important exit codes:**
| Code | Meaning |
|---|---|
| 0 | Files copied successfully |
| 1 | No files found to copy |
| 2 | User pressed Ctrl+C |
| 4 | Initialization error |
| 5 | Disk write error |

### Example Usage
```cmd
REM Copy a directory tree (subdirectories, no empty ones)
xcopy C:\Source D:\Dest /s

REM Copy complete tree including empty directories
xcopy C:\Source D:\Dest /e /i

REM Copy including hidden and system files, preserve attributes
xcopy C:\Source D:\Dest /e /h /k

REM Copy with permission/ownership info
xcopy C:\Source D:\Dest /e /o

REM Copy only files changed since a date
xcopy C:\Source D:\Dest /d:01/01/2024

REM Dry run (list files that would be copied)
xcopy C:\Source D:\Dest /l

REM Copy over network with restartable mode
xcopy C:\Source \\server\dest /e /z /c

REM Copy excluding certain files (create exclusion list first)
echo *.tmp > exclude.txt
echo *.log >> exclude.txt
xcopy C:\Source D:\Dest /e /exclude:exclude.txt

REM Backup: copy only files with Archive bit set
xcopy C:\Source D:\Backup /m /e /y

REM Force destination as directory (avoids "file or directory?" prompt)
xcopy C:\Source D:\Dest /e /i
```

### Common Mistakes
- Being prompted "File or Directory?" for new destinations — always use `/I` flag or pre-create the destination directory
- Forgetting `/E` when you need to copy empty subdirectories
- Not using `/K` — without it, file attributes (like read-only) are not preserved
- Using `XCOPY` for large/complex copies — `ROBOCOPY` is more reliable for those

### XCOPY vs ROBOCOPY vs COPY

| Feature | COPY | XCOPY | ROBOCOPY |
|---|---|---|---|
| Recurse directories | No | Yes (`/S`, `/E`) | Yes (`/E`) |
| Preserve timestamps | No | Yes | Yes |
| Preserve ACLs | No | Yes (`/O`) | Yes (`/COPYALL`) |
| Retry on failure | No | No | Yes (`/R`, `/W`) |
| Multi-threaded | No | No | Yes (`/MT`) |
| Mirror/sync | No | No | Yes (`/MIR`) |
| Logging | No | No | Yes (`/LOG`) |

### Related Commands
`COPY`, `ROBOCOPY`, `MOVE`, `ICACLS`

---

*Back to: [W.md](W.md) | Next: [Y.md](Y.md)*
