# CMD Encyclopedia — Commands Starting with A

---

## ATTRIB

### Command Name
`ATTRIB` — Display or change file attributes

### Syntax
```
ATTRIB [+R|-R] [+A|-A] [+S|-S] [+H|-H] [+I|-I] [drive:][path][filename] [/S [/D]] [/L]
```

**Attribute flags:**
| Flag | Meaning |
|---|---|
| `+R` / `-R` | Set / Clear Read-only |
| `+A` / `-A` | Set / Clear Archive |
| `+S` / `-S` | Set / Clear System |
| `+H` / `-H` | Set / Clear Hidden |
| `+I` / `-I` | Set / Clear Not Content Indexed |
| `/S` | Process matching files in current folder and all subfolders |
| `/D` | Process folders too |

### Description
**Simple:** Shows or changes the special flags attached to files and folders (hidden, read-only, system, archive).

**Technical:** `ATTRIB` reads or modifies the attribute bytes stored in the file's directory entry in the filesystem (FAT32 or NTFS). On NTFS, this maps to the `$STANDARD_INFORMATION` attribute. Hiding a file with `+H` prevents it from appearing in Explorer (unless "Show hidden files" is enabled) and in `DIR` without the `/A` flag.

### Example Usage
```cmd
REM Show all file attributes in current directory
attrib

REM Show attributes recursively including hidden files
attrib /s /d

REM Hide a file
attrib +h secrets.txt

REM Unhide a file
attrib -h secrets.txt

REM Make a file read-only
attrib +r important.txt

REM Remove system and hidden flags (useful for recovering files)
attrib -s -h C:\boot.ini

REM Show all hidden+system files in Temp folder
attrib +h +s %TEMP%\*.* /s
```

### Output Explanation
```
A    SHR  C:\Windows\System32\hal.dll
```
- First column: attribute letters present (`A`=Archive, `S`=System, `H`=Hidden, `R`=Read-only)
- Second column: full file path

### Common Mistakes
- Forgetting `/S` when you need to recurse into subfolders
- Confusing ATTRIB (filesystem attributes) with ICACLS (NTFS permissions) — they are different systems
- Setting `+S +H` on the wrong files and making them invisible — use `attrib /s /d` to find them again

### Related Commands
`ICACLS`, `DIR /A`, `CIPHER`, `COMPACT`

---

## ARP

### Command Name
`ARP` — Display and modify the Address Resolution Protocol cache

### Syntax
```
ARP -a [inet_addr] [-N if_addr] [-v]
ARP -d inet_addr [if_addr]
ARP -s inet_addr eth_addr [if_addr]
```

| Switch | Meaning |
|---|---|
| `-a` | Display current ARP cache entries |
| `-d` | Delete an ARP cache entry |
| `-s` | Add a static ARP entry |
| `-N` | Display ARP entries for a specific network interface |
| `-v` | Verbose mode |

### Description
**Simple:** Shows the list of IP addresses that your computer has recently talked to and the MAC (hardware) addresses associated with them on your local network.

**Technical:** ARP (Address Resolution Protocol, RFC 826) resolves Layer-3 IP addresses to Layer-2 MAC addresses on Ethernet networks. When your machine needs to send a packet to an IP on the same subnet, it broadcasts an ARP request ("Who has 192.168.1.1?"). The reply is cached in the ARP table for a short TTL (typically 2 minutes on Windows). The `ARP` command lets you inspect and manipulate this cache. ARP poisoning/spoofing attacks exploit this cache — viewing it can reveal such attacks.

### Example Usage
```cmd
REM Show all ARP cache entries
arp -a

REM Show ARP entries for a specific interface
arp -a -N 192.168.1.10

REM Add a static ARP entry (requires admin)
arp -s 192.168.1.100 00-1A-2B-3C-4D-5E

REM Delete an ARP entry
arp -d 192.168.1.100
```

### Output Explanation
```
Interface: 192.168.1.50 --- 0x5
  Internet Address      Physical Address      Type
  192.168.1.1           00-1a-2b-3c-4d-5e     dynamic
  192.168.1.255         ff-ff-ff-ff-ff-ff     static
```
- **Internet Address:** IP address of the remote host
- **Physical Address:** MAC address (hardware address)
- **Type:** `dynamic` (learned via ARP) or `static` (manually set)

### Common Mistakes
- Mistaking the ARP cache for a complete list of network devices — it only shows recently communicated hosts
- ARP only works for local subnet communication; routed traffic shows only the gateway MAC
- `-d` requires Administrator rights

### Related Commands
`IPCONFIG`, `NETSTAT`, `PING`, `ROUTE`, `NETSH`

---

## AT (Deprecated)

### Command Name
`AT` — Schedule commands to run at a specific time (**DEPRECATED**)

### Deprecation Notice
> ⚠️ **AT is deprecated as of Windows 8 / Server 2012.** It is still present but may be removed in a future Windows version. Use `SCHTASKS` instead.

### Syntax (Historical Reference)
```
AT [\\computername] [[id] [/DELETE] | /DELETE [/YES]]
AT [\\computername] time [/INTERACTIVE] [/EVERY:date[,...] | /NEXT:date[,...]] command
```

### Description
**Simple:** The old way to schedule programs to run at a specific time. Replaced by Task Scheduler and the `SCHTASKS` command.

**Technical:** `AT` was a simple command-line scheduler that stored jobs in the Service Control Manager. It ran jobs under the SYSTEM account and had very limited scheduling options compared to the modern Task Scheduler engine. Microsoft replaced it with `SCHTASKS` which interfaces with the full Windows Task Scheduler infrastructure.

### Modern Replacement
```cmd
REM AT equivalent using SCHTASKS
AT 14:00 /every:M,T,W,Th,F myprogram.exe

REM Modern SCHTASKS equivalent
schtasks /create /tn "MyTask" /tr "myprogram.exe" /sc weekly /d MON,TUE,WED,THU,FRI /st 14:00
```

### Related Commands
`SCHTASKS`, Task Scheduler GUI (`taskschd.msc`)

---

## ASSOC

### Command Name
`ASSOC` — Display or modify file extension associations

### Syntax
```
ASSOC [.ext[=[fileType]]]
```

| Usage | Effect |
|---|---|
| `ASSOC` | List all current associations |
| `ASSOC .ext` | Show what file type `.ext` is associated with |
| `ASSOC .ext=filetype` | Set the association |
| `ASSOC .ext=` | Remove the association |

### Description
**Simple:** Shows which program type is linked to a file extension — the first step in determining what program opens a file.

**Technical:** `ASSOC` manages the file extension → file type mapping stored in `HKEY_CLASSES_ROOT` (which merges `HKEY_LOCAL_MACHINE\SOFTWARE\Classes` and `HKEY_CURRENT_USER\Software\Classes`). The file type name returned by `ASSOC` is then looked up with `FTYPE` to find the actual executable that opens files of that type. Together, `ASSOC` + `FTYPE` define the shell open verb.

### Example Usage
```cmd
REM Show all file associations
assoc | more

REM Show what .txt is associated with
assoc .txt

REM Show what .bat is associated with
assoc .bat

REM Associate .log files with text files
assoc .log=txtfile

REM Remove an association
assoc .xyz=
```

### Output Explanation
```
.txt=txtfile
```
- `.txt` is the extension
- `txtfile` is the file type name (look this up with `ftype txtfile` to find the actual program)

### Common Mistakes
- Confusing `ASSOC` (extension → type mapping) with `FTYPE` (type → program mapping)
- Modifying associations for system-critical extensions (`.exe`, `.bat`, `.dll`) can break Windows
- Changes require Administrator rights and affect all users on the system

### Related Commands
`FTYPE`, `REG`, `START`

---

## AUDITPOL

### Command Name
`AUDITPOL` — Display and configure the Windows Audit Policy

### Syntax
```
auditpol /get /category:*
auditpol /get /subcategory:"subcategory name"
auditpol /set /subcategory:"subcategory name" /success:enable /failure:enable
auditpol /list /category
auditpol /backup /file:auditpolicy.csv
auditpol /restore /file:auditpolicy.csv
```

### Description
**Simple:** Shows and configures what security events Windows records in the Security Event Log. For example, whether failed login attempts are logged.

**Technical:** `AUDITPOL` interfaces with the Local Security Authority (LSA) to configure per-subcategory audit policy settings. These settings determine which events are written to the Windows Security Event Log (Event ID ranges: logon events 4624/4625, object access 4656+, policy changes 4719+, etc.). Proper audit policy configuration is a core component of security monitoring and compliance (PCI-DSS, HIPAA, CIS Benchmarks). Requires SeSecurityPrivilege (Administrator).

### Example Usage
```cmd
REM Show all current audit policy settings
auditpol /get /category:*

REM Show just logon/logoff auditing
auditpol /get /subcategory:"Logon"

REM List all available categories
auditpol /list /category

REM Enable auditing of logon success and failure
auditpol /set /subcategory:"Logon" /success:enable /failure:enable

REM Backup current audit policy
auditpol /backup /file:audit_policy_backup.csv

REM Restore audit policy from backup
auditpol /restore /file:audit_policy_backup.csv
```

### Output Explanation
```
System audit policy
Category/Subcategory                      Setting
Logon/Logoff
  Logon                                   Success and Failure
  Logoff                                  Success
  Account Lockout                         Failure
```
- **Category:** High-level grouping
- **Subcategory:** Specific event type
- **Setting:** `No Auditing`, `Success`, `Failure`, or `Success and Failure`

### Common Mistakes
- Not enabling failure auditing for Logon — this means failed password attempts are not logged
- Enabling too many subcategories generates enormous event logs that become impractical to review
- Forgetting that Group Policy can override local audit policy settings

### Related Commands
`GPRESULT`, `GPUPDATE`, `WEVTUTIL`, `EVENTCREATE`

---

*Back to: [Encyclopedia Index](../README.md) | Next: [B.md](B.md)*
