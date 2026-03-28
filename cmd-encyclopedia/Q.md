# CMD Encyclopedia — Commands Starting with Q

---

## QUERY

### Command Name
`QUERY` — Display information about sessions, processes, or users

### Syntax
```
query session [sessionname | username | sessionid] [/server:servername] [/mode] [/flow] [/connect] [/counter] [/v]
query process [* | processid | username | sessionname | programname] [/server:servername] [/id | /a]
query user [username | sessionid] [/server:servername]
query termserver [servername] [/domain:domain] [/address] [/continue]
```

### Description
**Simple:** Shows information about currently logged-on users, active sessions, and running processes on the local or a remote terminal server.

**Technical:** `QUERY` interfaces with the Remote Desktop Services (Terminal Services) API to enumerate logon sessions, processes within sessions, and connected users. It is particularly useful in multi-user environments (Terminal Servers, RDS collections) and for scripting logon/logoff management.

---

### QUERY SESSION

**Display information about sessions:**

```cmd
REM Show all sessions on local machine
query session

REM Show sessions on a remote server
query session /server:RDSERVER01

REM Show verbose session info
query session /v
```

**Output:**
```
 SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEVICE
 services                                    0  Disc
 console           John Smith               1  Active
 rdp-tcp#4         Jane Doe                 2  Active
```
- **SESSIONNAME:** Name of the session
- **USERNAME:** Logged-in user
- **ID:** Session ID (used with LOGOFF and other commands)
- **STATE:** Active, Disconnected, Listen, Idle

---

### QUERY PROCESS

**Display processes in sessions:**

```cmd
REM Show all processes
query process *

REM Show processes for a specific user
query process /server:RDSERVER01 username

REM Show all processes with session information
query process * /a
```

---

### QUERY USER

**Display logged-on users:**

```cmd
REM Show all logged-on users
query user

REM Show users on remote server
query user /server:RDSERVER01
```

**Output:**
```
 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
 john.smith            console             1  Active       none   1/15/2024 8:00 AM
 jane.doe              rdp-tcp#4           2  Active       0:05   1/15/2024 9:30 AM
```

### Common Mistakes
- Confusing session ID with process ID — session IDs are used with LOGOFF/RESET, not TASKKILL
- Expecting `QUERY USER` to show domain-wide logged-on users — it only shows users on the specified server

### Related Commands
`LOGOFF`, `MSG`, `QWINSTA`, `TASKLIST`, `NET SESSION`

---

## QWINSTA

### Command Name
`QWINSTA` — Query Windows Station — display session information

### Syntax
```
qwinsta [sessionname | username | sessionid] [/server:servername] [/mode] [/flow] [/connect] [/counter]
```

### Description
**Simple:** Displays information about Remote Desktop / Terminal Services sessions — effectively an alias for `QUERY SESSION`.

**Technical:** `QWINSTA` (Query WINdows STAtion) is functionally identical to `QUERY SESSION`. Both commands call the same underlying Terminal Services API (`WTSEnumerateSessions`). The name `QWINSTA` comes from the Windows Station concept in the Win32 subsystem — a Windows Station is a security boundary containing one or more desktops and a clipboard. The associated command `RWINSTA` (Reset WINdows STAtion) resets a session, equivalent to `RESET SESSION`.

### Example Usage
```cmd
REM Show all sessions
qwinsta

REM Show sessions on remote server
qwinsta /server:RDSERVER01

REM Find a specific user's session
qwinsta john.smith

REM Show with counter information
qwinsta /counter
```

### Output
Same as `QUERY SESSION`:
```
 SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEVICE
 services                                    0  Disc
 console           Administrator            1  Active  wdcon
 rdp-tcp                                65536  Listen  rdpwd
```

### Related Commands
`QUERY SESSION`, `QUERY USER`, `LOGOFF`, `MSG`, `RESET SESSION`

---

*Back to: [P.md](P.md) | Next: [R.md](R.md)*
