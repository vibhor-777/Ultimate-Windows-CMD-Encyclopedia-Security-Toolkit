# Disk Operations Commands — Category Guide

A comprehensive guide to disk management from the Windows Command Prompt.

---

## Overview

Effective disk management is critical for maintaining system health, performance, and data integrity. This guide covers checking disk health, partitioning, formatting, cleanup, and advanced disk operations.

---

## 1. Checking Disk Space

### Quick Space Overview

```cmd
REM Check free space on a specific volume
fsutil volume diskfree C:

REM Check all drives via WMIC
wmic logicaldisk get deviceid,size,freespace,filesystem,volumename

REM Human-readable format via PowerShell
powershell -command "Get-PSDrive -PSProvider FileSystem | Select Name, Used, Free"
```

### Disk Space Script

```bat
@echo off
echo === DISK SPACE REPORT ===
echo.
wmic logicaldisk where drivetype=3 get deviceid,size,freespace,volumename /format:list
echo.
REM Convert bytes to GB using PowerShell
powershell -command "Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, @{N='Size(GB)';E={[math]::Round($_.Size/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.FreeSpace/1GB,2)}}, @{N='Free(%)';E={[math]::Round($_.FreeSpace/$_.Size*100,1)}} | Format-Table -AutoSize"
```

---

## 2. Checking Disk Health

### CHKDSK (File System Check)

```cmd
REM Read-only check (no repairs, safe to run anytime)
chkdsk C:

REM Read-only with verbose output
chkdsk C: /v

REM Full repair check (schedules reboot for system volume)
chkdsk C: /f

REM Online NTFS scan (no dismount needed, Windows 8+)
chkdsk C: /scan

REM Check with bad sector scan (very slow, reads every sector)
chkdsk C: /r
```

> ⚠️ **Important:** Run `chkdsk C:` (no flags) first for a read-only check. Only add `/f` or `/r` when you need to repair errors and understand it may require a reboot.

### SMART Status (Hardware Health)

```cmd
REM Check SMART status via WMIC
wmic diskdrive get status,model,serialnumber,size

REM Expected output for healthy drive: Status=OK
```

### Combining Health Checks

```bat
@echo off
echo === DISK HEALTH REPORT ===
echo.
echo [Physical Disk SMART Status]
wmic diskdrive get status,model,size,serialnumber
echo.
echo [Volume Filesystem Status]
for /f "skip=1 tokens=1" %%d in ('wmic logicaldisk where drivetype=3 get deviceid') do (
    echo Checking %%d...
    chkdsk %%d
)
```

**Command:** `CHKDSK` — See [C.md](../C.md) | `FSUTIL` — See [F.md](../F.md)

---

## 3. Partitioning with DISKPART

### View Disks and Volumes

```cmd
REM Launch diskpart
diskpart

REM At DISKPART> prompt:
list disk
list volume
list partition
```

### Detailed Disk Information

```
DISKPART> list disk
DISKPART> select disk 0
DISKPART> detail disk
DISKPART> list partition
DISKPART> select partition 1
DISKPART> detail partition
DISKPART> exit
```

### Common DISKPART Tasks (Use with Extreme Care)

```
REM View volumes only (read-only, safe)
DISKPART> list volume
DISKPART> exit

REM Assign a drive letter to a volume without one
DISKPART> list volume
DISKPART> select volume 3
DISKPART> assign letter=E

REM Change an existing drive letter
DISKPART> select volume 3
DISKPART> remove letter=E
DISKPART> assign letter=F

REM Mark a partition as active (for bootable drives)
DISKPART> select disk 0
DISKPART> select partition 1
DISKPART> active

REM Extend a volume (requires unallocated space after the volume)
DISKPART> select volume 3
DISKPART> extend
```

### DISKPART Script Mode

```bat
@echo off
REM Create a DISKPART script file (list only - safe)
echo list disk > diskpart_info.txt
echo list volume >> diskpart_info.txt
echo exit >> diskpart_info.txt

diskpart /s diskpart_info.txt
del diskpart_info.txt
```

**Command:** `DISKPART` — See [D.md](../D.md)

---

## 4. Formatting

> ⚠️ **FORMAT PERMANENTLY ERASES ALL DATA on the target volume. Triple-check your drive letter before running.**

```cmd
REM Quick format as NTFS (most common)
format D: /fs:ntfs /q /v:DataDrive

REM Quick format as FAT32 (for USB drives, compatibility)
format D: /fs:fat32 /q /v:USB

REM Quick format as exFAT (for large USB drives)
format D: /fs:exfat /q /v:USBDRIVE

REM Full format (checks for bad sectors, takes longer)
format D: /fs:ntfs /v:DataDrive

REM Secure format (zero-fill 1 pass)
format D: /fs:ntfs /p:1
```

**Filesystem selection guide:**
| Filesystem | Best For | Max File Size | Max Volume |
|---|---|---|---|
| FAT32 | USB drives, compatibility | 4 GB | 32 GB |
| exFAT | Large USB drives, flash | 16 EB | 128 PB |
| NTFS | Internal drives, servers | 256 TB | 256 TB |
| ReFS | Server resilience | 35 PB | 35 PB |

**Command:** `FORMAT` — See [F.md](../F.md)

---

## 5. Converting Filesystems

```cmd
REM Convert FAT/FAT32 to NTFS (non-destructive, one-way)
convert D: /fs:ntfs

REM Convert with verbose output
convert D: /fs:ntfs /v
```

> **Note:** NTFS → FAT is not possible without formatting (which erases data).

**Command:** `CONVERT` — See [C.md](../C.md)

---

## 6. Disk Cleanup and Optimization

### Clean Up Temporary Files

```cmd
REM Delete all files in user TEMP folder
del /q /f /s "%TEMP%\*.*"

REM Delete all files in Windows TEMP folder (requires admin)
del /q /f /s "%SystemRoot%\Temp\*.*"

REM Run Windows Disk Cleanup (requires prior configuration)
cleanmgr /sagerun:1

REM Pre-configure cleanup categories (run once, then use above)
cleanmgr /sageset:1
```

### Windows Component Store Cleanup

```cmd
REM Analyze component store size
dism /online /cleanup-image /analyzecomponentstore

REM Clean up superseded components
dism /online /cleanup-image /startcomponentcleanup

REM Clean up with rebase (more aggressive)
dism /online /cleanup-image /startcomponentcleanup /resetbase
```

### Defragmentation

```cmd
REM Check fragmentation level (read-only)
defrag C: /a

REM Analyze and report
defrag C: /a /v

REM Defragment a volume
defrag C: /v

REM Defragment all volumes
defrag /c

REM Optimize SSD (trim, not traditional defrag)
defrag C: /o

REM Retrim SSD
defrag C: /retrim
```

> **Note:** Windows 10/11 automatically schedules optimisation (defrag for HDDs, TRIM for SSDs). Manual defragmentation is rarely needed.

---

## 7. NTFS Compression

```cmd
REM Check compression status
compact

REM Compress a folder and all its contents
compact /c /s:"C:\OldArchives"

REM Decompress a folder
compact /u /s:"C:\OldArchives"

REM Show compression statistics
compact /s /q

REM Windows 10+ executable compression (LZX algorithm)
compact /exe:lzx C:\Program Files\Application\*.exe
```

**Command:** `COMPACT` — See [C.md](../C.md)

---

## 8. Advanced FSUTIL Operations

```cmd
REM Check if a volume is dirty (flagged for chkdsk)
fsutil dirty query C:

REM Get volume information
fsutil fsinfo volumeinfo C:

REM List all drives
fsutil fsinfo drives

REM Check volume type (NTFS, FAT, etc.)
fsutil fsinfo drivetype C:

REM Disable last-access time updates (performance improvement for high-file-count volumes)
fsutil behavior set disablelastaccess 1

REM Re-enable last-access time updates
fsutil behavior set disablelastaccess 0

REM Create a sparse file
fsutil file createnew sparsefile.bin 1073741824

REM Create a hard link
fsutil hardlink create linkfile.txt originalfile.txt
```

**Command:** `FSUTIL` — See [F.md](../F.md)

---

## 9. DISM for Image and System Health

```cmd
REM Check Windows image health (read-only)
dism /online /cleanup-image /checkhealth

REM Scan for corruption
dism /online /cleanup-image /scanhealth

REM Repair corruption from Windows Update
dism /online /cleanup-image /restorehealth

REM Repair using local source (Windows install media)
dism /online /cleanup-image /restorehealth /source:D:\sources\install.wim /limitaccess

REM Export repair source from WIM
dism /export-image /sourceimagefile:D:\sources\install.wim /sourceindex:1 /destinationimagefile:C:\repair\install.wim
```

**Command:** `DISM` — See [D.md](../D.md)

---

## 10. Volume Labels and Drive Info

```cmd
REM Show volume label and serial number
vol C:

REM Change volume label
label C: Windows

REM Change via diskpart
diskpart
> select volume 0
> label DataDrive
> exit
```

**Command:** `VOL` — See [V.md](../V.md) | `LABEL` — See [L.md](../L.md)

---

## 11. Complete Disk Operations Workflow

### For a New Drive

```cmd
REM 1. Open diskpart and identify the disk
diskpart
> list disk
> select disk 1        REM (be sure this is the right disk!)
> clean               REM WARNING: erases all data
> create partition primary
> format fs=ntfs label=NewDrive quick
> assign letter=E
> exit
```

### For Existing Drive Maintenance

```cmd
REM 1. Check space
wmic logicaldisk get deviceid,freespace,size

REM 2. Check filesystem health (read-only)
chkdsk C:

REM 3. Check physical health
wmic diskdrive get status,model

REM 4. Clean up temp files
del /q /f /s "%TEMP%\*.*"

REM 5. Optimize
defrag C: /o /v
```

---

## 12. Quick Reference: Disk Operations Commands

| Task | Command | Notes |
|---|---|---|
| Check free space | `fsutil volume diskfree C:` | |
| Drive details | `wmic logicaldisk get deviceid,size,freespace` | |
| File system health | `chkdsk C:` | Read-only; add `/f` to repair |
| Physical health | `wmic diskdrive get status,model` | SMART check |
| Partition management | `diskpart` | Interactive; be careful |
| Format a volume | `format D: /fs:ntfs /q` | ⚠️ Erases everything |
| Convert to NTFS | `convert D: /fs:ntfs` | Non-destructive, one-way |
| NTFS compression | `compact /c /s:"path"` | |
| Defrag HDD | `defrag C: /v` | |
| Optimize SSD | `defrag C: /o` | |
| Clean temp files | `del /q /f /s "%TEMP%\*.*"` | |
| DISM health check | `dism /online /cleanup-image /scanhealth` | |
| Repair image | `dism /online /cleanup-image /restorehealth` | |
| Volume label | `vol C:` / `label C: Name` | |

---

*Related guides:*
- [file-management.md](file-management.md) — File operations on disks
- [system-info.md](system-info.md) — Hardware information
- [networking.md](networking.md) — Network storage
