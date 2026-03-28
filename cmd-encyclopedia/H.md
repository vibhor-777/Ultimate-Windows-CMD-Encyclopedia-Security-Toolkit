# CMD Encyclopedia — Commands Starting with H

---

## HELP

### Command Name
`HELP` — Display help information for CMD commands

### Syntax
```
HELP [command]
```

### Description
**Simple:** Lists all available CMD commands with brief descriptions, or shows detailed help for a specific command.

**Technical:** `HELP` without arguments enumerates all internal CMD commands and external utilities that have help entries registered. For most commands, `command /?` provides more comprehensive help than `HELP command`. The `/?` switch is processed by the command itself and often provides full syntax documentation.

### Example Usage
```cmd
REM List all commands
help

REM Help for a specific command
help dir
help netstat

REM Alternative (often more detailed)
dir /?
netstat /?
ping /?
```

### Output Explanation
```
For more information on a specific command, type HELP command-name
ASSOC          Displays or modifies file extension associations.
ATTRIB         Displays or changes file attributes.
BREAK          Sets or clears extended CTRL+C checking.
...
```

### Related Commands
Every CMD command supports `/?`

---

## HOSTNAME

### Command Name
`HOSTNAME` — Display the name of the current computer

### Syntax
```
hostname
```

### Description
**Simple:** Prints the computer's network name (hostname) — useful in scripts that need to know which machine they are running on.

**Technical:** `HOSTNAME` calls `GetComputerName()` (or `GetComputerNameEx()`) Win32 API and prints the result. The hostname is stored in `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName` and in the TCP/IP stack configuration. It is also available as the `%COMPUTERNAME%` environment variable.

### Example Usage
```cmd
REM Display hostname
hostname

REM Use in a script with environment variable (equivalent)
echo %COMPUTERNAME%

REM Use in a log filename
set LOG=audit_%COMPUTERNAME%_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.txt
echo Audit log for %COMPUTERNAME% > %LOG%
```

### Output Explanation
```
WORKSTATION-01
```
Simply prints the computer's hostname on a single line.

### Common Mistakes
- Confusing `HOSTNAME` with the fully qualified domain name (FQDN) — `hostname` returns just the short name; use `nslookup %COMPUTERNAME%` or PowerShell `[System.Net.Dns]::GetHostEntry('')` for the FQDN

### Related Commands
`IPCONFIG`, `NETSH`, `SYSTEMINFO`, `WHOAMI`

---

*Back to: [G.md](G.md) | Next: [I.md](I.md)*
