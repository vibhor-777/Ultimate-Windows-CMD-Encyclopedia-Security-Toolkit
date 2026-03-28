# Networking Commands — Category Guide

A comprehensive guide to networking diagnostics and configuration from the Windows Command Prompt.

---

## Overview

Windows CMD has a robust set of networking tools built in. From checking your IP address to tracing network paths and examining active connections, this guide covers everything needed for network diagnostics.

---

## 1. IP Configuration

### View Current Network Configuration

```cmd
REM Quick view of IP addresses
ipconfig

REM Full configuration including MAC address, DHCP details, DNS
ipconfig /all

REM View only a specific adapter
ipconfig /all | findstr /a /n "."
```

**Output includes:**
- IPv4 and IPv6 addresses
- Subnet mask
- Default gateway
- DHCP server
- DNS servers
- MAC address (Physical Address)
- Lease times

### Change IP Configuration

```cmd
REM Set static IP
netsh interface ip set address "Ethernet" static 192.168.1.100 255.255.255.0 192.168.1.1

REM Switch back to DHCP
netsh interface ip set address "Ethernet" dhcp

REM Set static DNS
netsh interface ip set dns "Ethernet" static 8.8.8.8

REM Add secondary DNS
netsh interface ip add dns "Ethernet" 8.8.4.4 index=2

REM Switch DNS to automatic
netsh interface ip set dns "Ethernet" dhcp
```

### Release and Renew DHCP

```cmd
REM Release DHCP lease (loses IP address)
ipconfig /release

REM Renew DHCP lease (gets new IP from server)
ipconfig /renew

REM Release/renew specific adapter
ipconfig /release "Wi-Fi"
ipconfig /renew "Wi-Fi"
```

**Command:** `IPCONFIG` — See [I.md](../I.md) | `NETSH` — See [N.md](../N.md)

---

## 2. Connectivity Testing

### Basic Ping

```cmd
REM Test if a host is reachable
ping google.com

REM Ping your gateway
ping 192.168.1.1

REM Ping Google's DNS
ping 8.8.8.8

REM Continuous ping (Ctrl+C to stop)
ping -t 8.8.8.8

REM Ping 10 times
ping -n 10 google.com

REM Use in a script
ping -n 1 -w 1000 192.168.1.1 > nul
if %ERRORLEVEL% equ 0 (
    echo Gateway is reachable
) else (
    echo Gateway is NOT reachable
)
```

### Advanced Ping

```cmd
REM Test MTU (set packet size, don't fragment)
ping -f -l 1472 192.168.1.1

REM Force IPv4
ping -4 google.com

REM Force IPv6
ping -6 google.com

REM Resolve hostname
ping -a 8.8.8.8
```

**Command:** `PING` — See [P.md](../P.md)

---

## 3. DNS Lookup

### Basic Lookups

```cmd
REM Look up a domain name
nslookup google.com

REM Look up using a specific DNS server
nslookup google.com 8.8.8.8

REM Reverse lookup (IP to hostname)
nslookup 8.8.8.8
```

### Advanced DNS Queries

```cmd
REM Look up mail servers (MX records)
nslookup -type=MX company.com

REM Look up name servers (NS records)
nslookup -type=NS company.com

REM Look up text records (SPF, DKIM)
nslookup -type=TXT company.com

REM Interactive mode
nslookup
> set type=A
> microsoft.com
> set type=MX
> microsoft.com
> exit
```

### DNS Cache Management

```cmd
REM View cached DNS entries
ipconfig /displaydns

REM Flush (clear) DNS cache
ipconfig /flushdns

REM Re-register hostname with DNS
ipconfig /registerdns
```

**Command:** `NSLOOKUP` — See [N.md](../N.md)

---

## 4. Network Statistics and Connections

### Active Connections

```cmd
REM Show all connections and listening ports
netstat -a

REM Show with process IDs
netstat -ano

REM Show only listening ports
netstat -an | find "LISTENING"

REM Show only established connections
netstat -an | find "ESTABLISHED"

REM Show with process names (requires admin)
netstat -b

REM Find what's listening on a specific port
netstat -ano | find ":8080"
```

### Cross-reference PIDs with processes

```cmd
REM Find the process name for a PID from netstat
netstat -ano | find "LISTENING"
REM Note the PID, then:
tasklist | find "1234"

REM One-liner: get process using port 80
for /f "tokens=5" %p in ('netstat -ano ^| find ":80 "') do tasklist /fi "pid eq %p"
```

### Network Statistics

```cmd
REM Show per-protocol statistics
netstat -s

REM Show Ethernet statistics
netstat -e

REM Show routing table
netstat -r

REM Auto-refresh every 5 seconds
netstat -ano 5
```

**Command:** `NETSTAT` — See [N.md](../N.md)

---

## 5. Route Tracing

### TRACERT (Basic Route Tracing)

```cmd
REM Trace route to destination
tracert google.com

REM Faster (skip DNS resolution)
tracert -d 8.8.8.8

REM Limit hops
tracert -h 10 google.com
```

### PATHPING (Route + Packet Loss Statistics)

```cmd
REM Full path analysis with packet loss
pathping google.com

REM Skip DNS resolution
pathping -n 8.8.8.8

REM Use pathping to find the problem hop
pathping -q 100 8.8.8.8
```

**When to use which:**
- `TRACERT` — Quick route check; see if a specific hop is unreachable
- `PATHPING` — Intermittent issues; measures packet loss at each hop over time

**Commands:** `TRACERT` — See [T.md](../T.md) | `PATHPING` — See [P.md](../P.md)

---

## 6. ARP (Address Resolution Protocol)

```cmd
REM View ARP cache (local subnet MAC mappings)
arp -a

REM View for a specific interface
arp -a -N 192.168.1.10

REM Add a static ARP entry
arp -s 192.168.1.100 00-1A-2B-3C-4D-5E

REM Delete an ARP entry
arp -d 192.168.1.100
```

**Command:** `ARP` — See [A.md](../A.md)

---

## 7. Routing Table

```cmd
REM Display full routing table
route print

REM Display IPv4 routes only
route print -4

REM Add a temporary route
route add 10.0.0.0 mask 255.255.255.0 192.168.1.1

REM Add a persistent route (survives reboot)
route add -p 10.0.0.0 mask 255.255.255.0 192.168.1.1

REM Delete a route
route delete 10.0.0.0
```

**Command:** `ROUTE` — See [R.md](../R.md)

---

## 8. Network Adapter Management (NETSH)

### View Adapter Information

```cmd
REM Show all interfaces
netsh interface show interface

REM Show IP configuration
netsh interface ip show config

REM Show all addresses
netsh interface ip show addresses
```

### Windows Firewall

```cmd
REM Show firewall status
netsh advfirewall show allprofiles

REM Enable firewall
netsh advfirewall set allprofiles state on

REM Disable firewall (not recommended)
netsh advfirewall set allprofiles state off

REM Add inbound rule
netsh advfirewall firewall add rule name="Allow Port 8080" protocol=TCP dir=in localport=8080 action=allow

REM Show all rules
netsh advfirewall firewall show rule name=all

REM Delete a rule
netsh advfirewall firewall delete rule name="Allow Port 8080"
```

### Wireless Networks

```cmd
REM List saved Wi-Fi profiles
netsh wlan show profiles

REM Show Wi-Fi password for a saved network
netsh wlan show profile name="MyNetwork" key=clear

REM List available networks
netsh wlan show networks

REM Export a Wi-Fi profile
netsh wlan export profile name="MyNetwork" folder=C:\WiFiBackup

REM Connect to a network
netsh wlan connect name="MyNetwork"

REM Disconnect
netsh wlan disconnect
```

### Network Reset

```cmd
REM Reset TCP/IP stack (fixes many connectivity issues)
netsh int ip reset resetlog.txt

REM Reset Winsock (fixes socket-layer issues)
netsh winsock reset

REM Flush DNS
ipconfig /flushdns

REM After running resets, restart the computer
```

**Command:** `NETSH` — See [N.md](../N.md)

---

## 9. Network Share Management

```cmd
REM List all shares on this machine
net share

REM Connect to a network share
net use Z: \\server\share

REM Connect with credentials
net use Z: \\server\share /user:DOMAIN\username Password123

REM Show current connections
net use

REM Disconnect
net use Z: /delete

REM List all accessible computers in workgroup/domain
net view
net view /domain

REM View shares on a specific computer
net view \\server
```

**Command:** `NET` — See [N.md](../N.md)

---

## 10. Comprehensive Network Diagnostic Workflow

When troubleshooting a network issue, work through these steps in order:

```cmd
REM Step 1: Check your IP configuration
ipconfig /all

REM Step 2: Test loopback (is TCP/IP stack working?)
ping 127.0.0.1

REM Step 3: Test your gateway (is your local network working?)
ping 192.168.1.1

REM Step 4: Test internet connectivity (IP, not DNS)
ping 8.8.8.8

REM Step 5: Test DNS resolution
nslookup google.com

REM Step 6: Full connectivity test
ping google.com

REM Step 7: Trace route if still failing
tracert 8.8.8.8

REM Step 8: Check for unusual connections
netstat -ano

REM Step 9: Check routing table
route print
```

---

## 11. Quick Reference: Networking Commands

| Task | Command | Notes |
|---|---|---|
| View IP address | `ipconfig` | Full info: `ipconfig /all` |
| Test connectivity | `ping hostname` | |
| DNS lookup | `nslookup domain` | |
| Trace route | `tracert hostname` | |
| Route + loss stats | `pathping hostname` | |
| View connections | `netstat -ano` | With PIDs |
| View listening ports | `netstat -an \| find "LISTENING"` | |
| ARP table | `arp -a` | |
| Routing table | `route print` | |
| Firewall status | `netsh advfirewall show allprofiles` | |
| Set static IP | `netsh interface ip set address...` | |
| DNS cache | `ipconfig /displaydns` | |
| Flush DNS cache | `ipconfig /flushdns` | |
| Map network drive | `net use Z: \\server\share` | |
| WiFi profiles | `netsh wlan show profiles` | |
| Reset TCP/IP | `netsh int ip reset` + reboot | |

---

*Related guides:*
- [system-info.md](system-info.md) — System information including network info
- [user-management.md](user-management.md) — User accounts for network auth
- [disk-operations.md](disk-operations.md) — Network storage
