# CMD Encyclopedia — Commands Starting with I

---

## ICACLS

### Command Name
`ICACLS` — Display or modify discretionary access control lists (DACLs) on files and folders

### Syntax
```
icacls name [/grant[:r] User:perm] [/deny User:perm] [/remove[:g|:d] User] [/inheritance:e|d|r] [/setowner User] [/findsid Sid] [/verify] [/reset] [/save aclfile [/t]] [/restore aclfile] [/setintegritylevel level] [/t] [/c] [/l] [/q]
```

**Permission abbreviations:**
| Perm | Meaning |
|---|---|
| `F` | Full control |
| `M` | Modify |
| `RX` | Read and execute |
| `R` | Read only |
| `W` | Write only |
| `D` | Delete |
| `(OI)` | Object inherit |
| `(CI)` | Container inherit |

### Description
**Simple:** Views and changes who has permission to access files and folders — the Windows ACL editor from the command line.

**Technical:** `ICACLS` replaces the older `CACLS` command. It interfaces with the Windows security descriptor stored in each NTFS file's `$SECURITY_DESCRIPTOR` attribute. An DACL (Discretionary Access Control List) contains ACEs (Access Control Entries), each specifying a SID (Security Identifier), access mask, and inheritance flags. `ICACLS` can save and restore entire ACL sets, making it ideal for backup/restore of permissions and bulk permission changes.

### Example Usage
```cmd
REM View permissions on a folder
icacls "C:\MyFolder"

REM View permissions recursively
icacls "C:\MyFolder" /t

REM Grant user read+execute
icacls "C:\MyFolder" /grant DOMAIN\john:(RX)

REM Grant administrator full control recursively
icacls "C:\MyFolder" /grant Administrators:(OI)(CI)F /t

REM Remove a user's permissions
icacls "C:\MyFolder" /remove DOMAIN\john

REM Reset permissions to inherited (remove explicit entries)
icacls "C:\MyFolder" /reset /t

REM Save permissions to a file
icacls "C:\MyFolder" /save permissions.acl /t

REM Restore permissions from file
icacls "C:\MyFolder" /restore permissions.acl

REM Take ownership (use with TAKEOWN first)
takeown /f "C:\MyFolder" /r /d y
icacls "C:\MyFolder" /grant %USERNAME%:F /t

REM Check who has access to a file
icacls "C:\secret.txt"
```

### Output Explanation
```
C:\MyFolder BUILTIN\Administrators:(OI)(CI)(F)
            NT AUTHORITY\SYSTEM:(OI)(CI)(F)
            BUILTIN\Users:(OI)(CI)(RX)
            CREATOR OWNER:(OI)(CI)(IO)(F)
```
- `(OI)` — Object Inherit (applies to files in the folder)
- `(CI)` — Container Inherit (applies to subfolders)
- `(IO)` — Inherit Only (does not apply to the folder itself)
- `(F)` — Full Control
- `(RX)` — Read and Execute

### Common Mistakes
- Forgetting `/t` for recursive operations
- Removing the SYSTEM account's permissions — this can break Windows functionality
- Using `ICACLS` to fix permissions on system directories without first understanding what the original permissions should be

### Related Commands
`ATTRIB`, `TAKEOWN`, `WHOAMI /PRIV`, `CIPHER`

---

## IF

### Command Name
`IF` — Conditional statement in batch scripts

### Syntax
```
IF [NOT] ERRORLEVEL number command
IF [NOT] string1==string2 command
IF [NOT] EXIST filename command
IF [/I] string1 compare-op string2 command
```

**Comparison operators:**
| Op | Meaning |
|---|---|
| `EQU` | Equal |
| `NEQ` | Not equal |
| `LSS` | Less than |
| `LEQ` | Less than or equal |
| `GTR` | Greater than |
| `GEQ` | Greater than or equal |

### Description
**Simple:** The conditional statement for batch scripts — runs a command only if a condition is true.

**Technical:** `IF` is a CMD internal command providing three types of tests: numeric ERRORLEVEL comparison, string equality (case-sensitive unless `/I`), and file existence. The extended comparison operators (EQU, NEQ, LSS, etc.) only work with CMD extensions enabled (default). `IF` can be combined with `ELSE` and parentheses for multi-line blocks. Note: `IF %ERRORLEVEL% EQU 0` differs subtly from `IF NOT ERRORLEVEL 1` — the latter is true if ERRORLEVEL < 1, which handles the case where a command doesn't set ERRORLEVEL at all.

### Example Usage
```bat
@echo off

REM Check if a file exists
if exist "config.txt" (
    echo Config file found
) else (
    echo Config file missing!
    exit /b 1
)

REM Check ERRORLEVEL after a command
ping -n 1 google.com > nul
if %ERRORLEVEL% equ 0 (
    echo Internet is reachable
) else (
    echo Internet is NOT reachable
)

REM String comparison
set /p NAME=Enter name:
if /i "%NAME%"=="admin" (
    echo Welcome, administrator!
)

REM Numeric comparison
set COUNT=5
if %COUNT% gtr 3 echo Count is greater than 3

REM Check if NOT exists
if not exist "output" mkdir output
```

### Common Mistakes
- Not quoting strings: `if %VAR%==value` fails if VAR is empty (use `if "%VAR%"=="value"`)
- Using `==` for numeric comparison — use EQU/GTR/LSS etc.
- Misunderstanding ERRORLEVEL: `IF ERRORLEVEL N` means "if errorlevel is N OR GREATER"

### Related Commands
`GOTO`, `FOR`, `SET`, `ERRORLEVEL`, `CALL`

---

## IPCONFIG

### Command Name
`IPCONFIG` — Display and manage IP network configuration

### Syntax
```
ipconfig [/all] [/release [adapter]] [/renew [adapter]] [/flushdns] [/registerdns] [/displaydns] [/showclassid adapter] [/setclassid adapter [classid]] [/allcompartments]
```
| Switch | Meaning |
|---|---|
| `/all` | Show full configuration for all adapters |
| `/release` | Release DHCP lease (lose IP address) |
| `/renew` | Renew DHCP lease (request new IP address) |
| `/flushdns` | Clear DNS resolver cache |
| `/displaydns` | Show DNS resolver cache entries |
| `/registerdns` | Re-register hostname with DNS |

### Description
**Simple:** Shows your computer's network settings — IP address, subnet mask, gateway, and DNS servers.

**Technical:** `IPCONFIG` queries the Windows IP Helper API (`iphlpapi.dll`) to retrieve network adapter configuration from the TCP/IP stack. `/all` exposes additional details: MAC address (Physical Address), DHCP server, lease times, DNS suffix, and whether the adapter is DHCP-enabled. `flushdns` clears the Windows DNS resolver cache (separate from the browser cache), which resolves "wrong site" issues after DNS changes. The DNS cache content can be viewed with `/displaydns`.

### Example Usage
```cmd
REM Quick view of IP addresses
ipconfig

REM Full network configuration
ipconfig /all

REM Flush DNS cache (fixes DNS resolution issues)
ipconfig /flushdns

REM View current DNS cache
ipconfig /displaydns

REM Release and renew DHCP (gets new IP)
ipconfig /release
ipconfig /renew

REM Release specific adapter
ipconfig /release "Wi-Fi"

REM Renew specific adapter
ipconfig /renew "Ethernet"
```

### Output Explanation
```
Ethernet adapter Ethernet:
   Connection-specific DNS Suffix  . : company.local
   Description . . . . . . . . . . . : Intel(R) Ethernet Connection
   Physical Address. . . . . . . . . : 00-1A-2B-3C-4D-5E
   DHCP Enabled. . . . . . . . . . . : Yes
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.1.1
   DNS Servers . . . . . . . . . . . : 192.168.1.1
```

### Common Mistakes
- Running `ipconfig /release` without planning to renew — you will lose network access
- Confusing "flushing DNS" with clearing the browser cache (they are different caches)
- Expecting `ipconfig /renew` to fix all network problems — it only helps with DHCP issues

### Related Commands
`PING`, `NETSTAT`, `NETSH`, `ARP`, `ROUTE`, `NSLOOKUP`

---

*Back to: [H.md](H.md) | Next: [J.md](J.md)*
