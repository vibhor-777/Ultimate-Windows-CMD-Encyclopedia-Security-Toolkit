# Contributing to the Ultimate Windows CMD Encyclopedia & Security Toolkit

Thank you for your interest in contributing! This project welcomes contributions of all kinds — new encyclopedia entries, improved scripts, bug fixes, and documentation improvements.

---

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How to Report Bugs](#how-to-report-bugs)
- [How to Suggest Features](#how-to-suggest-features)
- [How to Submit Pull Requests](#how-to-submit-pull-requests)
- [Coding Standards for .bat Files](#coding-standards-for-bat-files)
- [Documentation Standards](#documentation-standards)
- [Testing Scripts Before PR](#testing-scripts-before-pr)

---

## Code of Conduct

This project is an **educational resource**. All contributors are expected to:

1. **Be respectful** — Treat all community members with dignity.
2. **Be constructive** — Focus on improving the project, not criticising individuals.
3. **Stay on topic** — Contributions should align with the educational and safety focus of this project.
4. **No malicious content** — Scripts that perform unauthorized access, exploitation, or system damage will not be accepted. Ever.
5. **Give credit** — If your contribution is based on another's work, cite the source.

Violations of these standards may result in your contribution being rejected and/or being blocked from the project.

---

## How to Report Bugs

Found an error in documentation or a bug in a script? Please report it!

### Via GitHub Issues

1. Go to the [Issues tab](https://github.com/vibhor-777/Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit/issues)
2. Click **"New Issue"**
3. Use this template:

```
**Type:** Bug

**File affected:** (e.g., scripts/maintenance/disk_check.bat)

**Windows version:** (e.g., Windows 11 22H2)

**Describe the bug:**
A clear description of what the bug is.

**To reproduce:**
Steps to reproduce the behaviour.

**Expected behaviour:**
What you expected to happen.

**Actual behaviour:**
What actually happened.

**Error message (if any):**
Paste any error messages here.
```

---

## How to Suggest Features

Have an idea for a new command entry, script, or feature?

### Via GitHub Issues

1. Go to the [Issues tab](https://github.com/vibhor-777/Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit/issues)
2. Click **"New Issue"**
3. Use this template:

```
**Type:** Feature Request

**Category:** (Encyclopedia entry / New script / Documentation / Other)

**Description:**
A clear description of the feature you'd like to see.

**Why is this useful?**
Explain the use case and who would benefit.

**Example:**
If applicable, show an example of what the feature would look like.

**Safety considerations:**
If it's a script, explain why it is safe and educational.
```

---

## How to Submit Pull Requests

### Before You Start

1. **Check existing issues** — Your idea may already be tracked
2. **Fork the repository** — Work on your own fork, not directly on the main branch
3. **Create a feature branch** — Never work directly on `main`

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### Making Changes

1. Make your changes following the [coding standards](#coding-standards-for-bat-files) below
2. Test all changes (see [Testing](#testing-scripts-before-pr))
3. Update relevant documentation if needed

### Submitting

1. Commit your changes with clear messages:
   ```bash
   git add .
   git commit -m "Add encyclopedia entry for NETSH command"
   git commit -m "Fix: disk_check.bat CHKDSK path handling on non-C drives"
   ```

2. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

3. Open a Pull Request on GitHub:
   - Title: Clear, concise description of the change
   - Description: What changed, why, and how to test it
   - Link any related issues with `Closes #123`

### PR Review Process

- Maintainers will review within a few days
- Be prepared to make requested changes
- Keep the PR focused — one feature/fix per PR is preferred

---

## Coding Standards for .bat Files

All `.bat` files in this project **must** follow these standards:

### 1. File Header (Required)

Every `.bat` file must start with this comment block:

```bat
@echo off
REM ============================================================
REM  filename.bat
REM  Part of: Ultimate Windows CMD Encyclopedia & Security Toolkit
REM  Purpose: (Brief description)
REM  Author:  your-github-username
REM  Version: 1.0
REM  Usage:   (How to run, e.g., "Run as Administrator")
REM  SAFETY:  (Describe safety considerations - is it read-only?)
REM  Output:  (Where output goes, e.g., "Screen + log in Logs\")
REM ============================================================
```

### 2. Comments (Required)

- Every **section** of code must have a section header comment
- Complex logic must have an explanation comment
- Do NOT comment every single line — only where clarification helps

```bat
REM Good: Section header
REM ============================================================
REM  SECTION 2: Check Running Services
REM ============================================================

REM Good: Explaining non-obvious logic
REM Skip=1 to skip the header row from WMIC output
for /f "skip=1 tokens=1" %%s in ('wmic service ...') do ...

REM Bad: Unnecessary comment
echo Hello  REM prints Hello
```

### 3. Safety Requirements (Mandatory)

- **No destructive commands without confirmation:** Any command that deletes, formats, or modifies data must be preceded by a `SET /P confirm` prompt
- **No registry deletions:** `REG DELETE` is not allowed
- **No `FORMAT` commands:** Unless writing a documentation-only demo with no actual execution
- **No `NET USER ... /DELETE`** — user deletion is not permitted in scripts
- **Use read-only alternatives** — prefer `REG QUERY` over `REG ADD`, `SC QUERY` over `SC STOP`

### 4. Logging (Required)

All scripts must create a log file:

```bat
REM Log directory setup
set "LOGDIR=%SCRIPTDIR%..\..\Logs"
if not exist "%LOGDIR%\" mkdir "%LOGDIR%"

REM Timestamped log filename
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set RAWDATE=%%i
set LOGDATE=%RAWDATE:~0,4%-%RAWDATE:~4,2%-%RAWDATE:~6,2%_%RAWDATE:~8,2%-%RAWDATE:~10,2%
set "LOGFILE=%LOGDIR%\scriptname_%LOGDATE%.txt"
```

### 5. Error Handling

- Use `2>nul` to suppress expected errors (like missing files)
- Check `%ERRORLEVEL%` after critical operations
- Always provide meaningful messages when something fails

```bat
ping -n 1 8.8.8.8 > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FAIL] Cannot reach internet.
) else (
    echo [PASS] Internet reachable.
)
```

### 6. User Input Validation

- Always validate `SET /P` input before using it
- Never execute user-supplied input directly
- Validate choices against known-good values only

```bat
set /p CHOICE=Enter 1, 2, or 3:
if "%CHOICE%"=="1" goto :Option1
if "%CHOICE%"=="2" goto :Option2
if "%CHOICE%"=="3" goto :Option3
REM Invalid input handled:
echo Invalid choice. Please enter 1, 2, or 3.
```

### 7. Formatting

- Use 4-space indentation (or tabs, but be consistent)
- Use `SETLOCAL ENABLEDELAYEDEXPANSION` at the top when using `!variables!` in loops
- End all scripts with `ENDLOCAL`
- Line length: keep lines under 120 characters where possible

---

## Documentation Standards

### Encyclopedia Entries

Each command entry in `cmd-encyclopedia/` must follow this format:

```markdown
## COMMANDNAME

### Command Name
`COMMANDNAME` — Brief one-line description

### Syntax
```
commandname [switches] [parameters]
```

| Switch | Meaning |
|---|---|
| `/switch` | What it does |

### Description
**Simple:** One paragraph for beginners.
**Technical:** Detailed paragraph for advanced users.

### Example Usage
```cmd
REM Explain what this does
commandname /switch value
```

### Output Explanation
Explain what the output means.

### Common Mistakes
- Bullet list of common mistakes

### Related Commands
`RELATED`, `COMMANDS`
```

### Category Guides

Files in `cmd-encyclopedia/categories/` should:
- Start with a brief overview paragraph
- Group commands logically by task/use case
- Include working example code for every task
- Include a Quick Reference table at the end
- Link to relevant alphabet entries

### General Documentation

- Use proper Markdown formatting
- Include a table of contents for files > 500 lines
- Use code blocks for all command examples
- Mark destructive commands with `⚠️` warnings

---

## Testing Scripts Before PR

**All scripts must be tested on Windows before submitting.**

### Testing Checklist

Before submitting a `.bat` script PR, verify:

- [ ] Script runs without errors on Windows 10 or Windows 11
- [ ] `@echo off` is the first line
- [ ] Header comment block is present and complete
- [ ] Script creates the `Logs\` directory if it doesn't exist
- [ ] Script creates a timestamped log file
- [ ] All `SET /P` inputs are validated
- [ ] No destructive operations execute without explicit user confirmation
- [ ] Script handles the case where it's NOT run as Administrator gracefully
- [ ] `ENDLOCAL` is called at the end
- [ ] No hardcoded paths specific to your machine (use environment variables)

### Testing Environment

Test on at least one of:
- Windows 10 (any build)
- Windows 11 (any build)
- Windows Server 2019 or 2022 (for server-oriented scripts)

### Testing Read-Only Scripts

For read-only scripts (security scans, audits):
1. Run on a **non-production** machine first
2. Verify the log file is created with expected content
3. Verify no system changes were made (check before/after with a separate tool)

### Testing Scripts with Destructive Actions

For scripts with destructive actions (like temp file cleanup):
1. Test the **confirmation mechanism first** — verify it cancels correctly when you say "NO"
2. Test on a non-critical system
3. Verify only the intended files/locations are affected

---

## Questions?

If you have questions about contributing, open an [Issue](https://github.com/vibhor-777/Ultimate-Windows-CMD-Encyclopedia-Security-Toolkit/issues) with the tag `question`.

Thank you for helping make this resource better for everyone! 🎉
