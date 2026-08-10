# Branch Pattern

Generate clean, idiomatic git branch names from natural language descriptions,
issue tickets, or git diffs and status summaries.

## Usage

### Basic Usage

```bash
echo "fix login timeout on slow connections" | fabric -p branch
```

### With Post-Processing Filter

To ensure clean output without markdown wrappers or trailing whitespace:

```bash
echo "fix login timeout on slow connections" | fabric -p branch | ./patterns/branch/filter.sh
```

### Direct Branch Checkout

Generate a branch name and check it out immediately:

```bash
# Create and switch to new branch from description
git checkout -b "$(echo "fix auth token expiry issue AUTH-456" | fabric -p branch | ./patterns/branch/filter.sh)"
```

### From Git Diff or Status

Infer a branch name from unstaged/staged changes:

```bash
git diff | fabric -p branch | ./patterns/branch/filter.sh
```

### Shell Function Integration

You can integrate this pattern into your shell environment (e.g. `~/.zshrc` or `~/.bashrc`):

```bash
# fabric_branch() generates an idiomatic branch name and checks it out
fabric_branch() {
    local input="$*"
    if [ -z "$input" ]; then
        input=$(git diff HEAD 2>/dev/null)
        if [ -z "$input" ]; then
            input=$(git status --short 2>/dev/null)
        fi
    fi

    if [ -z "$input" ]; then
        echo "error: no description provided and no git changes found" >&2
        return 1
    fi

    local branch_name
    branch_name=$(echo "$input" | fabric -p branch | ./patterns/branch/filter.sh)

    if [ -z "$branch_name" ]; then
        echo "error: failed to generate branch name" >&2
        return 1
    fi

    echo "✓ Checking out branch: $branch_name"
    git checkout -b "$branch_name"
}
```

## Features

- Follows standard git branch naming conventions
- Supports standardized category prefixes (`feature/`, `bugfix/`, `hotfix/`, etc.)
- Automatically detects and includes ticket/issue identifiers
- Formats in lowercase kebab-case
- Adheres to git reference safety rules (no illegal ref characters)
- Single-line output suitable for scripting and shell automation

## Branch Prefix Reference

| Prefix | Description | Example |
|---|---|---|
| `feature/` | New features, enhancements, capabilities | `feature/oauth-provider` |
| `bugfix/` | Bug fixes and defect remediation | `bugfix/login-session-timeout` |
| `hotfix/` | Urgent production fixes and security patches | `hotfix/cve-2026-patch` |
| `refactor/` | Code restructuring without behavior changes | `refactor/db-client-cleanup` |
| `docs/` | Documentation additions or updates | `docs/update-api-guide` |
| `chore/` | Tooling, dependencies, CI/CD maintenance | `chore/bump-dependencies` |
| `test/` | Adding or updating tests | `test/auth-integration-tests` |
| `perf/` | Performance optimizations | `perf/cache-query-results` |
| `release/` | Release preparation and version cuts | `release/v1.2.0` |

## Output Format

```
<prefix>/<optional-ticket-><kebab-case-slug>
```

Example:

```
feature/123-dark-mode-toggle
```

## Examples

### Example 1: Bug Fix with Ticket Number

```bash
# Input:
echo "Fix null pointer crash during token validation for ticket AUTH-789" | fabric -p branch

# Output:
bugfix/auth-789-token-validation-crash
```

### Example 2: New Feature Description

```bash
# Input:
echo "Implement export to CSV and Excel for reporting dashboard" | fabric -p branch

# Output:
feature/reporting-export-csv-excel
```

### Example 3: Documentation Update

```bash
# Input:
echo "Update deployment instructions and architecture diagram in README" | fabric -p branch

# Output:
docs/update-deployment-architecture
```

### Example 4: Dependency Maintenance / Chore

```bash
# Input:
echo "Upgrade Go toolchain to 1.24 and update golangci-lint config" | fabric -p branch

# Output:
chore/upgrade-go-1-24-lint
```

## Tips

- Include ticket numbers or issue keys in descriptions for automatic inclusion in branch names
- Be descriptive about the primary outcome of the change
- When running from `git diff`, staged changes provide the cleanest signal
