# Setup and Troubleshooting

This document describes how to set up UnauthScout, its runtime dependencies,
and how to troubleshoot common errors during execution.

## Requirements

UnauthScout is intentionally lightweight and relies only on standard CLI tools.

### Required dependencies

- **bash** (POSIX-compatible)
- **curl** — HTTP client for API requests
- **jq** — JSON parsing and normalization

### Verify dependencies

You can manually verify the required tools:

```bash
bash --version
curl --version
jq --version
````

If any command is missing, install it using your system package manager.

## Installation

```bash
git clone https://github.com/rmottanet/unauthscout.git
cd unauthscout
chmod +x bin/unauthscout
```

Optionally add the binary to your PATH:

```bash
export PATH="$PWD/bin:$PATH"
```

## Basic Sanity Check

Run a simple unauthenticated lookup:

```bash
unauthscout torvalds
```

Expected behavior:

* JSON output
* No authentication prompts
* No stack traces or shell errors

## Common Errors and Troubleshooting

### Missing dependency

**Error**

```
[ERROR] Missing required command: jq
```

**Cause**

* One or more required tools are not installed or not in PATH.

**Resolution**
Install the missing dependency, for example:

```bash
sudo apt install jq
```

### Network or API failure

**Error**

```
[ERROR] Failed to fetch GitHub user data
```

or

```
[ERROR] Failed to fetch GitLab user data
```

**Possible causes**

* Network connectivity issues
* Temporary API outage
* Rate limiting by the provider

**Resolution**

* Verify network access
* Retry the request
* Use `--raw` to inspect partial responses if available

### Parsing failure

**Error**

```
[ERROR] Failed to parse API response
```

**Cause**

* API response format changed
* Unexpected empty or malformed JSON
* Tooling mismatch (`jq` version)

**Resolution**

* Re-run the command with `--raw`
* Compare raw output with the documented API mapping
* Validate schema alignment

### No results returned (GitLab)

**Behavior**

* Empty output or parsing error

**Cause**

* The GitLab `/users?username=` endpoint returns an empty array
* Username does not exist or is ambiguous

**Resolution**

* Verify the username manually
* Inspect raw output using `--raw`

## Debugging with Raw Mode

UnauthScout provides a `--raw` flag to bypass normalization:

```bash
unauthscout <username> --raw
unauthscout <username> --raw -gh
```

Use raw mode to:

* Inspect newly exposed fields
* Validate API behavior
* Aid schema evolution

Raw mode is intended for **analysis and development**, not automation.

## Expected Exit Behavior

* Successful execution returns exit code `0`
* Fatal errors terminate execution with a non-zero exit code
* All errors are printed to stderr with a clear message

## Notes on Rate Limiting

UnauthScout does not attempt to bypass rate limits.

* GitHub unauthenticated requests are rate-limited
* GitLab unauthenticated requests may also be throttled

For sustained usage, consider:

* Spacing requests
* Adding authenticated support in a future version

## Summary

UnauthScout is designed to fail fast and visibly.

If something breaks:

1. Check dependencies
2. Re-run with `--raw`
3. Compare raw output against the API mapping docs
4. Update schemas and parsers accordingly
