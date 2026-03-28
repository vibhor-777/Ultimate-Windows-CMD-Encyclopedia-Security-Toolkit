# CMD Encyclopedia — Commands Starting with V

---

## VER

### Command Name
`VER` — Display the Windows version

### Syntax
```
VER
```

### Description
**Simple:** Displays the version number of Windows currently running.

**Technical:** `VER` is a CMD internal command that reads the OS version from the Windows kernel (`NtCurrentTeb()->ProcessEnvironmentBlock->OSMajorVersion`, etc.) and formats it as a string. The version string format changed significantly between Windows versions:
- Windows XP: `Microsoft Windows XP [Version 5.1.2600]`
- Windows 7: `Microsoft Windows [Version 6.1.7601]`
- Windows 10: `Microsoft Windows [Version 10.0.19044]`
- Windows 11: `Microsoft Windows [Version 10.0.22621]`

Note: Windows 11 still reports version `10.0.x` — use the build number to distinguish from Windows 10.

**Version mapping:**
| Windows Version | Version Number |
|---|---|
| XP | 5.1 |
| Vista | 6.0 |
| 7 | 6.1 |
| 8 | 6.2 |
| 8.1 | 6.3 |
| 10 | 10.0 (builds < 22000) |
| 11 | 10.0 (builds >= 22000) |
| Server 2019 | 10.0.17763 |
| Server 2022 | 10.0.20348 |

### Example Usage
```cmd
REM Display Windows version
ver

REM Use in a script for version checking
for /f "tokens=*" %v in ('ver') do set WIN_VER=%v
echo %WIN_VER%

REM Check if running Windows 10+
ver | findstr /i "10\."
if %ERRORLEVEL% equ 0 echo Windows 10 or later

REM More detail
systeminfo | findstr /i "OS Version"
winver
```

### Output Explanation
```
Microsoft Windows [Version 10.0.22631.2861]
```
- `10.0` — Major.Minor version
- `22631` — Build number (this identifies Windows 11 23H2)
- `2861` — Revision/Update number

### Related Commands
`SYSTEMINFO`, `WMIC os get`, `WINVER`

---

## VERIFY

### Command Name
`VERIFY` — Control whether CMD verifies that files are written correctly to disk

### Syntax
```
VERIFY [ON | OFF]
```

### Description
**Simple:** An old command that tells CMD whether to verify disk write operations. In modern Windows, this has no practical effect.

**Technical:** In the DOS era, `VERIFY ON` caused the OS to re-read each disk sector after writing to confirm the write was successful. In modern Windows, disk write verification is handled at lower levels by the filesystem driver, disk driver, and hardware (write-back caching with cache verification). `VERIFY ON` in modern CMD performs no additional checking — it simply sets an internal flag. It is retained for backward compatibility with legacy batch scripts.

### Example Usage
```cmd
REM Check current verify status
verify

REM Enable verification (legacy, no practical effect in modern Windows)
verify on

REM Disable verification
verify off
```

### Output
```
VERIFY is off
```

### Related Commands
`COPY /V` (actually verifies file copies), `CHKDSK`

---

## VOL

### Command Name
`VOL` — Display the volume label and serial number of a disk

### Syntax
```
VOL [drive:]
```

### Description
**Simple:** Shows the name (label) and serial number assigned to a disk drive.

**Technical:** `VOL` reads the volume boot record metadata to retrieve the volume label (stored in the NTFS `$Volume` metadata file or the FAT volume boot sector) and the serial number (a random 32-bit number assigned at format time). The volume serial number is different from the disk serial number (manufacturer assigned, readable via `WMIC diskdrive get serialnumber`). Volume serial numbers change when you format a volume; they do not change when you rename the label.

### Example Usage
```cmd
REM Show label and serial number of current drive
vol

REM Show for a specific drive
vol C:
vol D:

REM Use in a script
for /f "skip=1 tokens=*" %v in ('vol C:') do echo Volume info: %v
```

### Output Explanation
```
 Volume in drive C is Windows
 Volume Serial Number is ABCD-1234
```
- **Volume label:** "Windows" (the name you see in File Explorer)
- **Serial number:** `ABCD-1234` (hexadecimal, formatted as XXXX-XXXX)

### Related Commands
`LABEL`, `FORMAT`, `DISKPART`, `FSUTIL`

---

*Back to: [U.md](U.md) | Next: [W.md](W.md)*
