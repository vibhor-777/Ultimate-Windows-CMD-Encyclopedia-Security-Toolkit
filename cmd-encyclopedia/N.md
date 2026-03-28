# CMD Encyclopedia — Commands Starting with N

---

## NET

### Command Name
`NET` — Network services command suite

### Syntax Overview
```
net user [username [password | *] [options]] [/domain]
net localgroup [groupname [/add | /delete] [username]] [/domain]
net share [sharename [=drive:path [/users:N | /unlimited] [/remark:"text"]]]
net use [drive: [\\computer\share [password | *]] [/user:[domain\]username]]
net start [servicename]
net stop [servicename]
net view [\\computer | /domain[:domainname]]
net accounts [/domain]
net statistics [workstation | server]
net session [\\computer] [/delete]
net time [\\computer] [/set]
```

### Description
**Simple:** A multi-purpose networking tool for managing users, groups, shared folders, services, and network connections.

**Technical:** `NET` is a comprehensive command with many subcommands, each interfacing with different Windows services via the LAN Manager API (`netapi32.dll`). It predates Windows NT and has been the primary administrative tool for decades. In domain environments, the `/domain` flag redirects operations to the domain controller.

---

### NET USER

**Manage local user accounts:**

```cmd
REM List all local users
net user

REM Show details about a specific user
net user john.smith

REM Create a new user (requires admin)
net user newuser P@ssw0rd123 /add

REM Delete a user
net user olduser /delete

REM Change a password
net user john.smith NewP@ssword

REM Disable an account
net user john.smith /active:no

REM Set password never expires
net user john.smith /passwordchg:yes /expires:never

REM Domain operations
net user john.smith /domain
```

---

### NET LOCALGROUP

**Manage local groups:**

```cmd
REM List all local groups
net localgroup

REM Show group members
net localgroup Administrators

REM Add user to group
net localgroup Administrators john.smith /add

REM Remove user from group
net localgroup Administrators john.smith /delete

REM Create a new group
net localgroup "Help Desk" /add /comment:"Help Desk Team"
```

---

### NET SHARE

**Manage shared folders:**

```cmd
REM List all shares
net share

REM Create a share
net share MyShare=C:\ShareFolder /remark:"Shared folder"

REM Set user limit
net share MyShare /users:10

REM Delete a share
net share MyShare /delete
```

---

### NET USE

**Connect to network shares:**

```cmd
REM Connect to a network share
net use Z: \\server\share

REM Connect with credentials
net use Z: \\server\share /user:DOMAIN\username P@ssword

REM List current connections
net use

REM Disconnect
net use Z: /delete

REM Disconnect all
net use * /delete
```

---

### NET START / STOP

**Manage services:**

```cmd
REM List running services
net start

REM Start a service
net start "Windows Update"

REM Stop a service
net stop "Print Spooler"
```

### Related Commands
`NETSH`, `NETSTAT`, `SC`, `NSLOOKUP`, `IPCONFIG`

---

## NETSH

### Command Name
`NETSH` — Network Shell — configure and monitor network settings

### Syntax
```
netsh [context] [subcommand] [parameters]
```

**Key contexts:**
| Context | Purpose |
|---|---|
| `interface ip` | IP address configuration |
| `advfirewall` | Windows Firewall management |
| `wlan` | Wireless LAN management |
| `http` | HTTP server settings |
| `trace` | Network packet tracing |
| `netio` | Network I/O settings |

### Description
**Simple:** A powerful command-line tool for configuring almost every aspect of Windows networking — IP addresses, firewall rules, WiFi profiles, and much more.

**Technical:** `NETSH` is an interactive shell that hosts contexts loaded as DLL plugins (e.g., `ifmon.dll` for interface context, `hnetmon.dll` for firewall). Each context exposes a set of commands via a registration interface. `NETSH` can also export/import all network configuration as a script file, enabling configuration backup and deployment.

### Example Usage
```cmd
REM Show firewall status for all profiles
netsh advfirewall show allprofiles

REM Turn on firewall for all profiles
netsh advfirewall set allprofiles state on

REM Show all IP interface configuration
netsh interface ip show config

REM Set a static IP address
netsh interface ip set address "Ethernet" static 192.168.1.100 255.255.255.0 192.168.1.1

REM Set back to DHCP
netsh interface ip set address "Ethernet" dhcp

REM Show wireless profiles
netsh wlan show profiles

REM Show wireless password (requires admin)
netsh wlan show profile name="MyWiFi" key=clear

REM Export all network config
netsh -c interface dump > network_config.txt

REM Reset TCP/IP stack
netsh int ip reset resetlog.txt

REM Reset Winsock
netsh winsock reset

REM Add a firewall rule
netsh advfirewall firewall add rule name="Allow Port 8080" protocol=TCP dir=in localport=8080 action=allow

REM Show all firewall rules
netsh advfirewall firewall show rule name=all
```

### Related Commands
`IPCONFIG`, `NETSTAT`, `ROUTE`, `PING`, `NET`

---

## NETSTAT

### Command Name
`NETSTAT` — Display network connections, statistics, and protocol information

### Syntax
```
netstat [-a] [-b] [-e] [-f] [-n] [-o] [-p proto] [-r] [-s] [-t] [-x] [-y] [interval]
```
| Switch | Meaning |
|---|---|
| `-a` | Show all connections and listening ports |
| `-n` | Show addresses numerically (no DNS resolution) |
| `-o` | Show owning process ID |
| `-b` | Show executable for each connection (requires admin) |
| `-e` | Show Ethernet statistics |
| `-r` | Show routing table |
| `-s` | Show per-protocol statistics |
| `-p proto` | Show connections for specific protocol (TCP, UDP, etc.) |
| `interval` | Refresh every N seconds |

### Description
**Simple:** Shows all current network connections and listening ports, plus which processes are using them.

**Technical:** `NETSTAT` queries the TCP/IP stack via the IP Helper API to enumerate socket connection state machines. The `-o` flag adds Process ID (PID) which can be cross-referenced with `TASKLIST` to identify which program owns each connection. `-b` does this automatically but requires Administrator. States: LISTENING (accepting connections), ESTABLISHED (connected), TIME_WAIT (closing), CLOSE_WAIT (remote closed), SYN_SENT (connecting), etc.

### Example Usage
```cmd
REM Show all connections and listening ports
netstat -a

REM Show with PIDs (for identifying processes)
netstat -ano

REM Show only listening ports
netstat -an | find "LISTENING"

REM Show established connections only
netstat -an | find "ESTABLISHED"

REM Show with executable names (requires admin)
netstat -b

REM Show routing table
netstat -r

REM Show statistics
netstat -s

REM Auto-refresh every 5 seconds
netstat -ano 5

REM Find what is listening on port 8080
netstat -ano | find ":8080"
```

### Output Explanation
```
Active Connections
Proto  Local Address          Foreign Address        State           PID
TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       4
TCP    192.168.1.100:52341    74.125.24.100:443      ESTABLISHED     1234
UDP    0.0.0.0:53             *:*                                    876
```

### Related Commands
`IPCONFIG`, `PING`, `NETSH`, `ROUTE`, `TASKLIST`

---

## NSLOOKUP

### Command Name
`NSLOOKUP` — Query Internet name servers (DNS lookup)

### Syntax
```
nslookup [hostname] [dns-server]
nslookup -type=record hostname [dns-server]
nslookup -debug hostname
```
Interactive mode:
```
nslookup
> set type=MX
> google.com
> exit
```

### Description
**Simple:** Looks up a domain name's IP address (or other DNS records) — useful for diagnosing DNS problems.

**Technical:** `NSLOOKUP` sends DNS queries directly to a DNS server and displays the raw responses. Unlike `PING` (which uses the OS resolver cache), `NSLOOKUP` bypasses the cache and goes directly to DNS. Supports querying different record types: A (IPv4), AAAA (IPv6), MX (mail), NS (name servers), TXT (text/SPF), CNAME (aliases), PTR (reverse lookup), SOA (authority). Invaluable for diagnosing: DNS propagation delays, mail server configuration, SPF/DKIM records, and split-horizon DNS.

### Example Usage
```cmd
REM Basic lookup
nslookup google.com

REM Lookup using a specific DNS server (e.g., Google's)
nslookup google.com 8.8.8.8

REM Reverse lookup (IP to hostname)
nslookup 8.8.8.8

REM Look up MX records (mail servers)
nslookup -type=MX company.com

REM Look up name servers
nslookup -type=NS company.com

REM Look up TXT records (SPF, DKIM)
nslookup -type=TXT company.com

REM Interactive mode for multiple queries
nslookup
> set type=A
> microsoft.com
> set type=MX
> microsoft.com
> exit
```

### Output Explanation
```
Server:  dns1.company.com
Address:  192.168.1.1

Non-authoritative answer:
Name:    google.com
Addresses:  2607:f8b0:4004:c1b::64
          142.250.80.46
```
- **Server/Address:** The DNS server that answered the query
- **Non-authoritative answer:** The DNS server got the answer from its cache, not directly from the authoritative server
- **Name:** The resolved hostname
- **Addresses:** IP addresses returned

### Related Commands
`IPCONFIG /flushdns`, `PING`, `TRACERT`, `PATHPING`

---

*Back to: [M.md](M.md) | Next: [O.md](O.md)*
