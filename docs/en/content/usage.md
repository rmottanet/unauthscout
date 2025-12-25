# Usage Guide

This document provides comprehensive instructions for using UnauthScout v0.3.0,
covering all reconnaissance workflows, intelligence features, and output
formats. For installation and basic setup, refer to [Setup Guide](setup.md).

## Command Structure

The basic command structure follows this pattern:

```bash
unauthscout [options] <username>
```

Where:
* `<username>` is the target identifier (required)
* `[options]` control platform selection, reconnaissance depth, and output format

## Platform Selection

By default, UnauthScout searches both GitHub and GitLab. You can scope your
reconnaissance to a single platform.

### Search both platforms (default)

```bash
unauthscout <username>
```

**Example:**
```bash
unauthscout torvalds
```

### GitHub only

```bash
unauthscout <username> --github
# or
unauthscout <username> -gh
```

**Example:**
```bash
unauthscout torvalds --github
```

### GitLab only

```bash
unauthscout <username> --gitlab
# or
unauthscout <username> -gl
```

**Example:**
```bash
unauthscout dzaporozhets --gitlab
```

## Reconnaissance Depth

### Basic profile reconnaissance (default)

Fetches and normalizes user profile information only.

```bash
unauthscout <username>
```

**Output includes:**
* Platform identifier
* Handle and display name
* Profile URL
* Available metrics (followers, public repos)
* Social links (when available)

### Repository enumeration

Adds public repository/project listing to the reconnaissance.

```bash
unauthscout <username> --repos
# or
unauthscout <username> -r
```

**Output includes (in addition to profile):**
* List of public repositories/projects
* For each: name, URL, stars, language (GitHub only), last activity
* Formatted as a table in default mode

**Examples:**
```bash
# Both platforms
unauthscout torvalds --repos

# GitHub only
unauthscout torvalds --github --repos

# GitLab only  
unauthscout dzaporozhets --gitlab --repos
```

### Intelligence summarization

Generates analytical insights from enumerated repositories. **Requires `--repos`.**

```bash
unauthscout <username> --repos --summarize
# or
unauthscout <username> -r -s
```

**Intelligence summary includes:**
* Total stars across all repositories
* Top 3 programming languages (GitHub only - GitLab reports "N/A")
* Most starred repository
* Latest activity date

**Examples:**
```bash
# Full intelligence report
unauthscout torvalds --repos --summarize

# GitHub-specific intelligence
unauthscout torvalds --github --repos --summarize
```

## Output Formats

UnauthScout provides multiple output formats for different use cases.

### Default formatted output (human-readable)

When no output flags are specified, UnauthScout presents formatted,
color-coded reports suitable for terminal viewing.

```bash
unauthscout <username>
unauthscout <username> --repos
unauthscout <username> --repos --summarize
```

**Characteristics:**
* Color-coded platform headers
* Clean table formatting for repositories
* Intelligence summary section (when requested)
* Designed for direct human consumption

### Machine-readable JSON (compact)

Optimized for scripting and pipeline integration.

```bash
unauthscout <username> --raw
```

**Characteristics:**
* Compact JSON (no extra whitespace)
* Conforms to unified schemas (`unified_user.json`, `unified_repo.json`)
* Suitable for `jq` processing and data storage
* Exit code only indicates success/failure

**Examples:**
```bash
# Pipe to jq for field extraction
unauthscout torvalds --raw | jq '.handle'

# Store for later analysis
unauthscout torvalds --github --repos --raw > torvalds_gh.json
```

### Human-readable JSON (formatted)

Indented JSON for manual inspection and debugging.

```bash
unauthscout <username> --raw --pretty
```

**Characteristics:**
* Properly indented JSON structure
* Easier to read than compact format
* Still conforms to unified schemas
* Combines with all other options

**Examples:**
```bash
# Inspect full structure
unauthscout torvalds --raw --pretty | less

# Debug GitLab responses
unauthscout dzaporozhets --gitlab --repos --raw --pretty
```

## Workflow Examples

### Quick profile check

```bash
unauthscout johndoe
```

*Purpose: Verify if a username exists on either platform.*

### Full OSINT reconnaissance

```bash
unauthscout targetuser --repos --summarize
```

*Purpose: Complete intelligence gathering including profile, assets, and analytics.*

### Script integration

```bash
unauthscout targetuser --github --repos --raw | jq '.[].stars' | awk '{sum+=$1} END {print sum}'
```

*Purpose: Extract specific metrics for automated reporting.*

### Comparative analysis

```bash
# GitHub data
unauthscout targetuser --github --repos --raw > gh_data.json

# GitLab data  
unauthscout targetuser --gitlab --repos --raw > gl_data.json

# Compare programmatically
diff <(jq '.[].full_name' gh_data.json | sort) <(jq '.[].full_name' gl_data.json | sort)
```

*Purpose: Cross-platform comparison of asset footprints.*

## Output Mode Comparison

| Mode | Command | Best For | Output Type |
|------|---------|----------|-------------|
| **Formatted Report** | `unauthscout user` | Terminal viewing, quick analysis | Color-coded text |
| **Formatted + Repos** | `unauthscout user -r` | Asset enumeration review | Text + table |
| **Formatted + Intel** | `unauthscout user -r -s` | Complete OSINT assessment | Text + table + summary |
| **Machine JSON** | `unauthscout user --raw` | Scripting, pipelines, storage | Compact JSON |
| **Human JSON** | `unauthscout user --raw --pretty` | Debugging, manual inspection | Indented JSON |
| **Platform-specific** | Add `--github` or `--gitlab` | Focused reconnaissance | All above formats |

## Common Operational Errors

### Missing username

**Error**: Help text displayed

**Solution**: Provide a username as the first non-option argument

### Summarization without repository enumeration

**Error**: `--summarize` requires `--repos`

**Solution**: Always combine `--summarize` with `--repos`

```bash
# Wrong
unauthscout user --summarize

# Correct
unauthscout user --repos --summarize
```

### Pretty formatting without raw mode

**Note**: `--pretty` only affects output when used with `--raw`. Without `--raw`,
the tool uses its default formatted report mode regardless of `--pretty`.

## Platform-Specific Considerations

### GitHub
- Rich unauthenticated API with 15+ public fields
- Language detection available for repositories
- Stricter rate limits (60 requests/hour per IP)
- Social metadata (Twitter, location, bio)

### GitLab
- Limited unauthenticated API (5 core user fields)
- Language detection **not available** (returns "N/A")
- Repository tags available via `tag_list` field
- Generally more permissive rate limits

### Field Availability
Some intelligence features have platform constraints:

| Intelligence Feature | GitHub | GitLab | Notes |
|---------------------|--------|--------|-------|
| Top Languages | ✅ | ❌ | GitLab API doesn't expose language |
| Total Stars | ✅ | ✅ | Both platforms provide star counts |
| Latest Activity | ✅ | ✅ | Different field names, same concept |
| Repository Count | ✅ | ❌ | GitLab doesn't expose public_repos |

## Rate Limiting Considerations

UnauthScout does not implement rate-limit evasion. Be mindful of:

* **GitHub**: ~60 unauthenticated requests/hour per IP
* **GitLab**: More permissive but still throttles abusive patterns

**Recommendations:**
* Space requests when scanning multiple targets
* Use platform flags to avoid unnecessary calls
* For heavy usage, consider implementing delays in wrapper scripts

## Version Information

Check your UnauthScout version:

```bash
unauthscout --version
```

**Expected output**: `UnauthScout v0.3.0`

View full help:

```bash
unauthscout --help
```

## Advanced Usage Patterns

### Batch Processing

```bash
# Process list of usernames
for user in user1 user2 user3; do
  unauthscout "$user" --github --repos --raw >> results.jsonl
  sleep 2  # Respect rate limits
done
```

### Integration with other tools

```bash
# Feed to grep for pattern matching
unauthscout targetuser --repos | grep -i "python"

# Count repositories per language (GitHub only)
unauthscout targetuser --github --repos --raw | jq 'group_by(.language) | map({lang: .[0].language, count: length})'

# Create activity timeline
unauthscout targetuser --repos --raw | jq 'map(.updated_at[0:10]) | unique | sort'
```

### Conditional execution

```bash
# Only proceed if user exists
if unauthscout targetuser --github --raw >/dev/null 2>&1; then
  echo "User exists, enumerating repositories..."
  unauthscout targetuser --github --repos --summarize
else
  echo "User not found on GitHub"
fi
```

## Summary

UnauthScout v0.3.0 provides a flexible command-line interface for unauthenticated
OSINT reconnaissance across GitHub and GitLab. The key to effective usage is
understanding the layered approach:

1. **Select platforms** (`--github`, `--gitlab`, or both)
2. **Choose depth** (profile, repositories, intelligence)
3. **Pick format** (formatted report or JSON for machines)

Start with simple profile checks, then layer on repository enumeration and
intelligence summarization as needed for your reconnaissance objectives.
