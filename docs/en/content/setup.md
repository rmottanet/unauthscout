# Setup and Troubleshooting

This document describes how to set up UnauthScout, verify its runtime dependencies,
and perform basic sanity testing. For comprehensive usage instructions and examples,
see the separate [Usage Guide](./usage).

## Purpose

This guide ensures you can successfully install UnauthScout and run a basic
reconnaissance operation. It focuses on **environment setup** and **initial
validation**, not operational workflows.

## Requirements

UnauthScout is intentionally lightweight and relies only on standard CLI tools
available on most Unix-like systems.

### Required dependencies

- **bash** (POSIX-compatible shell, version 4.0+)
- **curl** (7.0+) — HTTP client for API requests
- **jq** (1.6+) — JSON parsing and normalization

### Verify dependencies

You can manually verify the required tools:

```bash
bash --version | head -1
curl --version | head -1
jq --version
```

If any command is missing or reports an incompatible version, install or update it
using your system package manager.

### Platform-specific installation commands

| Platform | Command |
|----------|---------|
| Ubuntu/Debian | `sudo apt update && sudo apt install curl jq` |
| Fedora/RHEL | `sudo dnf install curl jq` |
| macOS (Homebrew) | `brew install curl jq` |
| Alpine Linux | `apk add curl jq` |

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
```

### 2. Make the binary executable

```bash
chmod +x bin/unauthscout
```

### 3. (Optional) Add to your PATH

For temporary session access:

```bash
export PATH="$PWD/bin:$PATH"
```

For permanent access, add the line to your shell profile (`~/.bashrc`, `~/.zshrc`,
etc.) or create a symbolic link:

```bash
sudo ln -s "$PWD/bin/unauthscout" /usr/local/bin/unauthscout
```

## Basic Sanity Check

Once installed, verify the tool works correctly with a simple unauthenticated
lookup of a known public figure:

```bash
./bin/unauthscout torvalds
```

**Expected successful behavior:**

* JSON output (either compact or formatted, depending on default mode)
* No authentication prompts or token requirements
* No stack traces, shell errors, or permission issues
* Clear platform identification in output

**Expected output characteristics:**

* Exit code `0`
* Output to stdout (not stderr)
* Structured JSON conforming to the unified schema
* User profile information for Linus Torvalds on GitHub

## Troubleshooting Initial Setup

### Missing dependency error

**Error**

```
[ERROR] Dependência não encontrada: jq. Por favor, instale-a para continuar.
```

**Cause**

One or more required tools are not installed or not in PATH.

**Resolution**

Install the missing dependency using your system package manager (see table above).

### Permission denied error

**Error**

```bash
./bin/unauthscout: Permission denied
```

**Cause**

The binary lacks execute permissions.

**Resolution**

```bash
chmod +x bin/unauthscout
```

### Command not found error

**Error**

```
unauthscout: command not found
```

**Cause**

The binary is not in your PATH.

**Resolution**

Either:
1. Use the full path: `./bin/unauthscout`
2. Add to PATH as described in the Installation section
3. Create a symbolic link to a directory in your PATH

### Network connectivity issues

**Error**

```
[ERROR] Failed to fetch GitHub user data
[ERROR] Failed to fetch GitLab user data
```

**Possible causes**

* No internet connection
* DNS resolution failure
* Corporate firewall blocking API endpoints

**Resolution**

* Verify network connectivity: `curl -s https://api.github.com`
* Test API endpoints directly:

```bash
curl -s "https://api.github.com/users/torvalds" | jq .login
curl -s "https://gitlab.com/api/v4/users?username=dzaporozhets" | jq .[0].username
```

## Verifying Version

After installation, verify you're running the expected version:

```bash
./bin/unauthscout --version
```

Expected output format: `UnauthScout vX.X.X`

## Expected Exit Behavior

* **Successful execution**: Exit code `0`
* **Fatal errors**: Non-zero exit code with descriptive error message to stderr
* **User errors** (e.g., missing username): Exit code `1` with help text

## Next Steps

Once you've successfully run the basic sanity check, proceed to the
[Usage Guide](./usage) for comprehensive instructions on:

* Platform-specific reconnaissance (`--github`, `--gitlab`)
* Repository enumeration (`--repos`)
* Intelligence summarization (`--summarize`)
* Output formatting options (`--raw`, `--pretty`)
* Advanced workflows and examples

## Summary

UnauthScout is designed to have minimal setup requirements and fail visibly when
requirements aren't met. A successful `./bin/unauthscout torvalds` test confirms
your environment is properly configured for all reconnaissance operations.
