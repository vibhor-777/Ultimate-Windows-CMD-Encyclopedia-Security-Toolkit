# CMD Encyclopedia — Commands Starting with J

---

## Overview

There are no major built-in Windows CMD commands that start with the letter **J**. This is one of the gaps in the CMD command alphabet.

---

## Minor / Third-Party References

### JETPACK (Obsolete)
`JETPACK` was a utility included with older versions of Windows DHCP/WINS servers to compact Jet database files used by those services. It is not present in modern Windows versions.

```cmd
REM Historical syntax (Windows Server 2003 and earlier)
REM jetpack dhcp.mdb tmp.mdb
```

**Modern replacement:** Microsoft SQL Server Compact or built-in service compaction is handled automatically.

---

## What to Use Instead

For tasks that might seem "J"-related:

| Task | Command to Use |
|---|---|
| Job scheduling | `SCHTASKS` (see S.md) |
| Junction points (folder links) | `MKLINK /J` (see M.md category reference) |
| Joining a domain | `NETDOM JOIN` or System Properties GUI |

---

## Junction Points (MKLINK)

While not starting with J, **junction points** are commonly referred to by their "J" connection type:

```cmd
REM Create a directory junction (similar to symlink for folders)
mklink /j C:\NewLink C:\ExistingFolder

REM View junction points in a directory
dir /al

REM View reparse points (junctions and symlinks)
fsutil reparsepoint query C:\NewLink
```

**Junction points** are NTFS reparse points that redirect directory access to another location on the same volume. Unlike symbolic links, junctions do not require Administrator on Windows Vista+ (though creating them still requires elevation in most configurations).

---

## PowerShell Alternatives for "J" Tasks

```powershell
# Get scheduled jobs (PowerShell-specific)
Get-ScheduledJob

# Create a new NTFS junction
New-Item -ItemType Junction -Path "C:\NewLink" -Value "C:\ExistingFolder"

# Join a domain
Add-Computer -DomainName "company.local" -Credential (Get-Credential)
```

---

*Back to: [I.md](I.md) | Next: [K.md](K.md)*
