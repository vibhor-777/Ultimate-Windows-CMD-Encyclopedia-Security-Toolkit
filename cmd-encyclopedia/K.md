# CMD Encyclopedia — Commands Starting with K

---

## KLIST

### Command Name
`KLIST` — Display and manage Kerberos tickets

### Syntax
```
klist [tickets] [tgt] [purge] [sessions] [kcd_cache] [get servicename] [add_bind] [query_bind] [-lh logonhandle] [-li logonid]
```
| Subcommand | Meaning |
|---|---|
| `tickets` | Display all cached Kerberos service tickets (default) |
| `tgt` | Display the Ticket Granting Ticket (TGT) |
| `purge` | Delete all cached Kerberos tickets |
| `sessions` | Display all current logon sessions |
| `get` | Request a service ticket for a specific SPN |

### Description
**Simple:** Shows the Kerberos authentication tickets your computer currently holds — used for troubleshooting authentication problems in Active Directory environments.

**Technical:** `KLIST` interfaces with the Windows Security Support Provider Interface (SSPI) and the Kerberos SSP (`kerberos.dll`) to enumerate the Kerberos ticket cache. In Kerberos authentication (used by Active Directory), a client first obtains a Ticket Granting Ticket (TGT) from the KDC (Key Distribution Center / Domain Controller), then exchanges it for Service Tickets to access specific resources (file servers, web apps, etc.). `KLIST` is essential for diagnosing:
- "Clock skew" errors (client and DC time are >5 minutes apart)
- Expired tickets causing re-authentication failures
- Kerberos delegation issues
- Pass-the-Ticket attack detection

Requires Windows 7 / Server 2008 R2 or later. On older systems, use `KERBTRAY` (GUI) from the Resource Kit.

### Example Usage
```cmd
REM Display all cached Kerberos tickets
klist

REM Display only the TGT
klist tgt

REM Show all logon sessions with tickets
klist sessions

REM Purge all cached tickets (forces re-authentication)
klist purge

REM Request a specific service ticket
klist get host/server01.company.com

REM Display tickets for a specific logon ID
klist -li 0x3e7
```

### Output Explanation
```
Credentials cache: API:...

Current LogonId is 0:0x12345

Cached Tickets: (3)

#0>     Client: JohnSmith @ COMPANY.LOCAL
        Server: krbtgt/COMPANY.LOCAL @ COMPANY.LOCAL
        KerbTicket Encryption Type: AES-256-CTS-HMAC-SHA1-96
        Ticket Flags 0x40e10000 -> forwardable renewable initial pre_authent name_canonicalize
        Start Time: 1/15/2024 8:00:00 (local)
        End Time:   1/15/2024 18:00:00 (local)
        Renew Time: 1/22/2024 8:00:00 (local)
        Session Key Type: AES-256-CTS-HMAC-SHA1-96

#1>     Client: JohnSmith @ COMPANY.LOCAL
        Server: cifs/fileserver01.company.com @ COMPANY.LOCAL
        ...
```

**Key fields:**
- **Client:** The user the ticket belongs to
- **Server:** The service the ticket grants access to (`krbtgt` = TGT; `cifs` = SMB file share; `host` = general services)
- **Start/End Time:** Ticket validity window
- **Renew Time:** Latest the ticket can be renewed without a full re-authentication
- **Ticket Flags:** Kerberos properties (forwardable, renewable, etc.)

### Common Mistakes
- Running `klist purge` when troubleshooting and then being unable to access network resources until re-authenticating
- Ignoring `End Time` — an expired ticket explains "Access Denied" on a previously working resource
- Confusing Kerberos clock skew (requires NTP sync) with password expiry

### Troubleshooting with KLIST
```cmd
REM Step 1: Check if TGT is present and not expired
klist tgt

REM Step 2: Check for the service ticket you need
klist | findstr /i "cifs"

REM Step 3: If expired or missing, purge and re-auth
klist purge
net use \\fileserver01 /user:DOMAIN\username

REM Step 4: Verify new tickets were obtained
klist
```

### Related Commands
`NET USE`, `NLTEST`, `NETDOM`, PowerShell `Get-KerberosTicketCache`

---

*Back to: [J.md](J.md) | Next: [L.md](L.md)*
