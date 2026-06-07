# Fabric Pattern Creation Guide

A comprehensive guide to creating high-quality fabric patterns that match the
standards established in this repository.

## Table of Contents

1. [Introduction](#introduction)
2. [Pattern Architecture](#pattern-architecture)
3. [Core File: system.md](#core-file-systemmd)
4. [Knowledge Base Files](#knowledge-base-files)
5. [Filter Scripts](#filter-scripts)
6. [Test Scripts](#test-scripts)
7. [Pattern README](#pattern-readme)
8. [Quality Standards](#quality-standards)
9. [Non-Idiomatic Choices](#non-idiomatic-choices-vs-official-fabric)
10. [Pattern Maturity Levels](#pattern-maturity-levels)
11. [Templates](#templates)
12. [Checklist](#checklist-for-new-patterns)

---

## Introduction

### What is a Fabric Pattern?

A fabric pattern is a structured prompt designed to solve a specific problem
using AI. Patterns are the "fundamental units" of the
[Fabric](https://github.com/danielmiessler/fabric) framework - reusable,
composable components that can be chained together for complex workflows.

### Design Philosophy

From the official Fabric documentation:

> "We tend to use the System section of the prompt almost exclusively...
> extremely clear in our instructions, and using Markdown structure to
> emphasize what we want the AI to do, and in what order."

**Key principles:**

- **One pattern, one problem** - Each pattern solves exactly one task
- **Markdown for clarity** - Structure prompts for human and AI readability
- **System section focus** - Place instructions in system.md, not user.md
- **Composability** - Design patterns to chain with other patterns

### What Makes a High-Quality Pattern?

1. **Clear identity** - The AI knows exactly what role it plays
2. **Structured steps** - Processing workflow is explicit and numbered
3. **Specific output** - Format is defined with templates and examples
4. **Guardrails** - Constraints prevent common LLM mistakes
5. **User focus** - Output serves users, not implementation details

---

## Pattern Architecture

### Directory Structure

```
patterns/
└── <pattern-name>/
    ├── system.md           # Required: Core pattern prompt
    ├── filter.sh           # Optional: Post-process output
    ├── README.md           # Optional: Usage documentation
    ├── <name>-standards.md # Optional: Knowledge base
    └── test-pattern.sh     # Optional: Validation script
```

### File Overview

| File | Purpose | Required |
|------|---------|----------|
| `system.md` | Core pattern instructions | Yes |
| `filter.sh` | Clean LLM output | Recommended |
| `README.md` | Document usage and examples | Recommended |
| `*-standards.md` / `*-guide.md` | Domain knowledge reference | For complex patterns |
| `test-pattern.sh` | Validate pattern works | Recommended |
| `test-*.go` / `test-*.txt` | Sample test inputs | With test script |

### Naming Conventions

- **Pattern names**: lowercase, hyphen-separated (`go-security-audit`, `changelog`)
- **Knowledge bases**: `<topic>-standards.md` or `<topic>-guide.md`
- **Test files**: `test-<description>.<ext>`

---

## Core File: system.md

The `system.md` file is the heart of every pattern. It defines the AI's
identity, processing steps, and output format.

### Section Structure

| Section | Purpose | Required |
|---------|---------|----------|
| `# IDENTITY and PURPOSE` | Define AI role and task | Yes |
| `# KNOWLEDGE BASE` | Reference companion docs | No* |
| `# STEPS` | Numbered processing workflow | Yes |
| `# [DOMAIN] CATEGORIES` | Domain-specific reference tables | No |
| `# OUTPUT INSTRUCTIONS` | Formatting rules and constraints | Yes |
| `# OUTPUT FORMAT` | Template with examples | Yes |
| `# IMPORTANT CONSTRAINTS` | Explicit DO/DON'T rules | Recommended |
| `# INPUT` | Placeholder for user input | Yes |

\* Required when using companion knowledge base files

### Section Details

#### IDENTITY and PURPOSE

Define who the AI is and what problem it solves. Be specific about expertise
and scope.

**Good example** (from `go-security-audit/system.md`):

```markdown
# IDENTITY and PURPOSE

You are an expert Go security auditor specializing in identifying
vulnerabilities, security anti-patterns, and potential exploits in Go
codebases. Your purpose is to perform comprehensive security audits of Go code
and provide actionable remediation guidance.
```

**Bad example:**

```markdown
# IDENTITY and PURPOSE

You help with code.
```

#### KNOWLEDGE BASE

Reference companion documentation when the pattern requires deep domain
knowledge. Use **CRITICAL** markers to enforce application.

**Example** (from `changelog/system.md`):

```markdown
# KNOWLEDGE BASE

You have access to a comprehensive changelog standards reference in the same
directory as this pattern (`changelog-standards.md`). This document contains:

- Core principles (what changelogs are for, guiding principles)
- Changelog format (file structure, version headers)
- Change categories (Added, Changed, Deprecated, Removed, Fixed, Security)
- Writing guidelines (entry format, style, what to include)
- Version numbering (SemVer, pre-releases, breaking changes)

**CRITICAL**: Apply ALL relevant standards from the changelog-standards.md
document when generating changelogs. Use the full depth of knowledge in that
reference document.
```

#### STEPS

Numbered, actionable processing workflow. Each step should be clear and
verifiable.

**Example** (from `go-tests/system.md`):

```markdown
# STEPS

1. Analyze the provided Go code to identify all exported resources (functions,
   methods, types, constants, variables)
2. Determine which resources need testing (focus on functions and methods with
   logic)
3. Design straightforward test cases covering normal operation and key edge
   cases
4. Structure tests using table-driven testing pattern when appropriate
5. Ensure all comment lines stay within 80 character limit
6. Follow Go idioms and conventions strictly
```

#### OUTPUT INSTRUCTIONS

Rules for formatting and content. Use bullet points for clarity.

**Example** (from `commit/system.md`):

```markdown
# OUTPUT INSTRUCTIONS

- Output ONLY the commit message text with NO code blocks or markdown fences
- Do NOT wrap the output in ``` ```, backticks, or any other delimiters
- Start with a type from the list above and a colon, then a space
- Keep the summary line under 80 characters
- Use lowercase for the description after the type
- Don't end the summary with a period
- **CRITICAL**: Only include sections where there are actual changes
- **If nothing was added, DO NOT include the "Added:" section at all**
- **NEVER write placeholder text like "No content removed"**
- **Completely omit empty sections - do not mention them**
```

#### OUTPUT FORMAT

Provide a complete template showing exact output structure. Use code blocks
with language identifiers.

**Example** (from `changelog/system.md`):

````markdown
# OUTPUT FORMAT

## Standard Changelog

```markdown
## [Unreleased]

### Added

- Added new feature X for improved Y (#123)
- Added support for Z configuration

### Changed

- Changed default timeout from 30s to 60s

### Fixed

- Fixed crash when processing empty files (#456)
```

## Ansible/antsibull-changelog

```yaml
---
release_summary: "Brief 1-2 sentence overview of this release"
added:
  - "role_name - Added new feature X"
fixed:
  - "role_name - Fixed issue with W"
```
````

#### IMPORTANT CONSTRAINTS

Explicit rules about what the pattern should and should NOT do. These prevent
common LLM mistakes.

**Example** (from `go-security-audit/system.md`):

```markdown
# IMPORTANT CONSTRAINTS

- **DO NOT** generate placeholder findings or hypothetical vulnerabilities
- **DO NOT** include empty severity sections
- **DO NOT** provide generic security advice without code-specific context
- **ALWAYS** show vulnerable code snippets from the actual input
- **ALWAYS** provide concrete remediation steps with code examples
- **ALWAYS** reference the knowledge base for detailed explanations
- **VERIFY** that suggested tools and techniques are appropriate for Go version
```

#### INPUT

Simple placeholder section at the end. Describes what the user should provide.

**Example:**

```markdown
# INPUT

Go source code files, packages, or entire repositories for security analysis.
You may include:

- Individual Go source files (.go)
- Multiple files from a package
- Output from security tools (gosec, govulncheck)
- go.mod and go.sum for dependency analysis
```

---

## Knowledge Base Files

Knowledge base files provide deep domain expertise that would be too long to
include directly in `system.md`.

### When to Create a Knowledge Base

Create a companion `*-standards.md` or `*-guide.md` file when:

- The domain has extensive rules or specifications (Go documentation, security)
- Industry standards must be referenced (Keep a Changelog, Conventional Commits)
- Multiple examples and anti-patterns are needed
- The pattern output requires consistent adherence to complex rules

### Structure

Knowledge base files should include:

1. **Table of Contents** - For navigation
2. **Core Principles** - Philosophy and guidelines
3. **Detailed Specifications** - Rules with examples
4. **Anti-Patterns** - What NOT to do
5. **Quality Checklist** - Verification criteria
6. **References** - External documentation links

**Example structure** (from `changelog-standards.md`):

```markdown
# Changelog Standards

A comprehensive guide to writing and maintaining changelogs following the
Keep a Changelog specification...

## Table of Contents

1. [Core Principles](#core-principles)
2. [Changelog Format](#changelog-format)
3. [Change Categories](#change-categories)
4. [Writing Guidelines](#writing-guidelines)
5. [Version Numbering](#version-numbering)
6. [Quality Checklist](#quality-checklist)

---

## Core Principles

### What is a Changelog?

A changelog is a file containing a curated, chronologically ordered list of
notable changes for each version of a project.

### Guiding Principles

1. Changelogs are for **humans**, not machines
2. There should be an entry for **every version**
...
```

### Linking from system.md

Reference the knowledge base in the `# KNOWLEDGE BASE` section with a
**CRITICAL** marker:

```markdown
# KNOWLEDGE BASE

You have access to a comprehensive testing patterns reference in the same
directory as this pattern (`go-testing-patterns.md`). This document contains:

- Testing philosophy and core principles
- Table-driven test patterns
- Subtests and parallel testing
...

**CRITICAL**: Apply ALL relevant patterns from the go-testing-patterns.md
document when generating tests.
```

---

## Filter Scripts

Filter scripts (`filter.sh`) post-process LLM output to ensure clean,
consistent formatting.

### Purpose

LLMs often add unwanted elements:

- Markdown code fences wrapping the entire output
- Placeholder text for empty sections ("No changes removed")
- Introductory phrases ("Here is the changelog:")
- Excessive blank lines

Filter scripts remove these automatically.

### Common Operations

1. **Remove code block markers** - Strip ``` wrappers
2. **Remove placeholder text** - Delete "No content" / "Nothing removed"
3. **Remove empty sections** - Strip headers with no content
4. **Normalize spacing** - Max 2 consecutive blank lines
5. **Trim whitespace** - Clean trailing spaces

### Template

```bash
#!/usr/bin/env bash

# Filter script for <pattern-name> pattern
# Cleans up LLM output to ensure consistent formatting

set -euo pipefail

# Read all input
content=$(cat)

# Remove markdown code fences wrapping entire output
content=$(echo "$content" | sed -e '1{/^```markdown$/d;}' -e '${/^```$/d;}')

# Remove "Here is..." introductory phrases
content=$(echo "$content" | sed -E '/^(Here is|Here'\''s|Below is) .*:?$/d')

# Remove placeholder text for empty sections
content=$(echo "$content" | sed -E '/^\[No .* findings\]$/d')
content=$(echo "$content" | sed -E '/^- (No|None|Nothing) .*/d')

# Clean up excessive blank lines (max 2 consecutive)
content=$(echo "$content" | awk '
BEGIN { blank_count=0 }
/^[[:space:]]*$/ {
    blank_count++
    if (blank_count <= 2) print
    next
}
{
    blank_count=0
    print
}
')

# Trim trailing whitespace
content=$(echo "$content" | sed 's/[[:space:]]*$//')

# Ensure single final newline
echo "$content"
```

### Advanced: Section-Aware Filtering

For patterns with specific sections (like commit messages), use AWK for
stateful processing:

```bash
# Merge duplicate sections and remove empty ones
output=$(echo "$output" | awk '
BEGIN {
    added_buffer=""
    changed_buffer=""
    removed_buffer=""
    current_section=""
}

/^\*\*Added:\*\*/ { current_section="added"; next }
/^\*\*Changed:\*\*/ { current_section="changed"; next }
/^\*\*Removed:\*\*/ { current_section="removed"; next }

{
    if (current_section == "added") {
        added_buffer=added_buffer $0 "\n"
    } else if (current_section == "changed") {
        changed_buffer=changed_buffer $0 "\n"
    } else if (current_section == "removed") {
        removed_buffer=removed_buffer $0 "\n"
    } else {
        print
    }
}

END {
    if (added_buffer !~ /^[[:space:]]*$/) {
        print "**Added:**"
        printf "%s", added_buffer
    }
    if (changed_buffer !~ /^[[:space:]]*$/) {
        print "**Changed:**"
        printf "%s", changed_buffer
    }
    if (removed_buffer !~ /^[[:space:]]*$/) {
        print "**Removed:**"
        printf "%s", removed_buffer
    }
}
')
```

---

## Test Scripts

Test scripts (`test-pattern.sh`) validate that patterns work correctly.

### Purpose

- Verify fabric CLI is installed
- Run pattern with sample input
- Validate output structure
- Check for expected content
- Provide clear pass/fail feedback

### Template

```bash
#!/usr/bin/env bash

# Test script for <pattern-name> pattern
# Validates the pattern works correctly with sample input

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
TEST_INPUT="$SCRIPT_DIR/test-<input-file>"
OUTPUT_FILE="$SCRIPT_DIR/test-output.md"

echo "Testing <pattern-name> pattern..."
echo ""

# Check if fabric is installed
if ! command -v fabric &> /dev/null; then
    echo "Error: fabric is not installed"
    echo "   Install with: pip install fabric-ai"
    exit 1
fi

echo "Fabric is installed"

# Check if test files exist
if [ ! -f "$TEST_INPUT" ]; then
    echo "Error: Test input not found at $TEST_INPUT"
    exit 1
fi

echo "Test input found"

# Run the pattern
echo ""
echo "Running pattern on sample input..."
echo ""

if cat "$TEST_INPUT" | fabric --pattern "$PATTERN_DIR" > "$OUTPUT_FILE" 2>&1; then
    echo "Pattern executed successfully"
    echo ""

    # Show preview
    echo "Output Preview:"
    echo "===================="
    head -n 30 "$OUTPUT_FILE"
    echo "..."
    echo "===================="
    echo ""

    # Validate expected sections
    echo "Validating output structure..."

    sections=(
        "## Expected Section 1"
        "## Expected Section 2"
    )

    all_present=true
    for section in "${sections[@]}"; do
        if grep -q "$section" "$OUTPUT_FILE"; then
            echo "  Found: $section"
        else
            echo "  Missing: $section"
            all_present=false
        fi
    done

    echo ""

    if [ "$all_present" = true ]; then
        echo "All expected sections present"
        echo ""
        echo "Pattern test successful!"
        echo ""
        echo "To test with your own input:"
        echo "  cat your-file | fabric --pattern $PATTERN_DIR"
        exit 0
    else
        echo "Some checks failed - please review the output"
        exit 1
    fi
else
    echo "Pattern execution failed"
    cat "$OUTPUT_FILE"
    exit 1
fi
```

---

## Pattern README

Pattern-specific README files document usage and provide examples.

### When to Include

Include a README when:

- The pattern has non-obvious usage
- Multiple input formats are supported
- Examples would help users understand output
- Tips and best practices exist

### Sections

1. **Brief description** - One line explaining what the pattern does
2. **Usage** - Command examples
3. **Features** - Key capabilities
4. **Output format** - What users can expect
5. **Tips** - Best practices and gotchas

### Example

```markdown
# Go Tests Pattern

Generate simple, pragmatic table-driven tests for Go code.

## Usage

```bash
cat myfile.go | fabric --pattern go-tests
```

## Features

- Table-driven test generation
- Subtest support with t.Run
- Error case coverage
- 80-character comment line limits

## Output

The pattern generates:

- Complete test file with package declaration
- Test functions for exported functions/methods
- Test summary with coverage areas

## Tips

- Provide complete function signatures for better tests
- Include error-returning functions for comprehensive coverage
- Review generated tests before using in production

```

---

## Quality Standards

### Specificity

Name specific functions, files, and line numbers. Avoid vague language.

**Good:**
```

Fixed crash in ParseURL() when input contains empty scheme (parser.go:45)

```

**Bad:**
```

Fixed a bug in the parser

```

### Actionability

Provide working examples users can copy and run immediately.

**Good:**
```bash
# Install dependencies
go mod download

# Run tests
go test ./...
```

**Bad:**

```
Install the dependencies and run the tests.
```

### Empty Section Omission

Use **CRITICAL** markers to prevent placeholder text:

```markdown
- **CRITICAL**: Only include sections where there are actual changes
- **If nothing was added, DO NOT include the "Added:" section at all**
- **Completely omit empty sections - do not mention them**
```

### User Focus

Write for users consuming the output, not developers reading the code.

**Good:**

```
Added --verbose flag to enable detailed logging during sync operations
```

**Bad:**

```
Added verbose boolean parameter to SyncOptions struct
```

### Line Length

For code-generating patterns (Go, Python), enforce line limits:

```markdown
- Keep all comment lines under 80 characters
- Break long lines appropriately
```

---

## Non-Idiomatic Choices vs Official Fabric

This repository extends standard Fabric patterns with several additions not
found in the official repository. These are intentional enhancements for
complex, production-quality patterns.

| Feature | Standard Fabric | This Repository | Rationale |
|---------|-----------------|-----------------|-----------|
| Knowledge base files | Not used | `*-standards.md`, `*-guide.md` | Complex domains need extensive reference documentation |
| Filter scripts | Not used | `filter.sh` | Consistently clean LLM output artifacts |
| Test scripts | Not used | `test-pattern.sh` | Validate patterns work before deployment |
| Pattern READMEs | Rare | Encouraged | Document usage with examples |
| `# KNOWLEDGE BASE` section | Not standard | Used with CRITICAL marker | Reference companion documentation |
| `# IMPORTANT CONSTRAINTS` | Not standard | Recommended | Prevent common LLM mistakes explicitly |

### Why These Extensions?

**Knowledge bases** enable patterns that require deep domain expertise (security
auditing, documentation standards) without bloating the system.md file.

**Filter scripts** solve a real problem: LLMs frequently add unwanted markdown
wrappers, placeholder text, and introductory phrases. Post-processing ensures
clean, consistent output.

**Test scripts** catch regressions and validate patterns work with the current
fabric version. They serve as living documentation of expected behavior.

---

## Pattern Maturity Levels

### Minimal

System.md only. Suitable for simple patterns with straightforward output.

**Examples:** `commit`, `pr`

**Contents:**

```
pattern-name/
└── system.md
```

### Standard

Adds filter script and README. Recommended for most patterns.

**Examples:** `changelog`, `readme`

**Contents:**

```
pattern-name/
├── system.md
├── filter.sh
└── README.md
```

### Comprehensive

Full suite with knowledge base and testing. Required for complex domains.

**Examples:** `go-security-audit`, `go-tests`, `grafana-dashboard-audit`

**Contents:**

```
pattern-name/
├── system.md
├── filter.sh
├── README.md
├── <topic>-standards.md
├── test-pattern.sh
└── test-<input>.<ext>
```

---

## Templates

### system.md Template

```markdown
# IDENTITY and PURPOSE

You are an expert [ROLE] specializing in [SPECIFIC EXPERTISE]. Your purpose is
to [PRIMARY TASK] and provide [OUTPUT TYPE].

# KNOWLEDGE BASE

You have access to a comprehensive [TOPIC] reference in the same directory as
this pattern (`<topic>-standards.md`). This document contains:

- [Category 1]
- [Category 2]
- [Category 3]

**CRITICAL**: Apply ALL relevant standards from the <topic>-standards.md
document when [PERFORMING TASK].

# STEPS

1. [First step - analyze input]
2. [Second step - categorize/classify]
3. [Third step - generate output]
4. [Fourth step - validate/format]

# [DOMAIN] CATEGORIES

Reference the <topic>-standards.md for detailed guidelines. Brief overview:

| Category | Description |
|----------|-------------|
| **Category 1** | Brief description |
| **Category 2** | Brief description |

# OUTPUT INSTRUCTIONS

- [Formatting rule 1]
- [Formatting rule 2]
- **CRITICAL**: [Important constraint]
- [Additional rules]

# OUTPUT FORMAT

```[language]
[Template showing exact output structure]
```

# IMPORTANT CONSTRAINTS

- **DO NOT** [common mistake 1]
- **DO NOT** [common mistake 2]
- **ALWAYS** [required behavior 1]
- **ALWAYS** [required behavior 2]

# INPUT

[Description of what user should provide]:

```

### filter.sh Template

```bash
#!/usr/bin/env bash

# Filter script for <pattern-name> pattern
# Cleans up LLM output to ensure consistent formatting

set -euo pipefail

content=$(cat)

# Remove markdown code fences
content=$(echo "$content" | sed -e '1{/^```markdown$/d;}' -e '${/^```$/d;}')

# Remove introductory phrases
content=$(echo "$content" | sed -E '/^(Here is|Here'\''s|Below is) .*:?$/d')

# Remove placeholder text
content=$(echo "$content" | sed -E '/^\[No .* findings?\]$/d')

# Normalize blank lines (max 2)
content=$(echo "$content" | awk '
BEGIN { blank=0 }
/^$/ { blank++; if (blank <= 2) print; next }
{ blank=0; print }
')

# Trim trailing whitespace
content=$(echo "$content" | sed 's/[[:space:]]*$//')

echo "$content"
```

### test-pattern.sh Template

```bash
#!/usr/bin/env bash

# Test script for <pattern-name> pattern

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_INPUT="$SCRIPT_DIR/test-input.txt"
OUTPUT_FILE="$SCRIPT_DIR/test-output.md"

echo "Testing <pattern-name> pattern..."

# Check fabric installation
if ! command -v fabric &> /dev/null; then
    echo "Error: fabric not installed"
    exit 1
fi

# Check test input exists
if [ ! -f "$TEST_INPUT" ]; then
    echo "Error: Test input not found"
    exit 1
fi

# Run pattern
if cat "$TEST_INPUT" | fabric --pattern "$SCRIPT_DIR" > "$OUTPUT_FILE" 2>&1; then
    echo "Pattern executed successfully"

    # Validate output
    expected=("## Section 1" "## Section 2")
    for section in "${expected[@]}"; do
        if grep -q "$section" "$OUTPUT_FILE"; then
            echo "  Found: $section"
        else
            echo "  Missing: $section"
            exit 1
        fi
    done

    echo "All tests passed!"
else
    echo "Pattern failed"
    exit 1
fi
```

### Knowledge Base Template

```markdown
# [Topic] Standards

A comprehensive guide to [topic] following [specification/best practices].
This document serves as the knowledge base for the [pattern-name] pattern.

## Table of Contents

1. [Core Principles](#core-principles)
2. [Format](#format)
3. [Categories](#categories)
4. [Writing Guidelines](#writing-guidelines)
5. [Common Patterns](#common-patterns)
6. [Quality Checklist](#quality-checklist)

---

## Core Principles

### What is [Topic]?

[Definition and purpose]

### Guiding Principles

1. [Principle 1]
2. [Principle 2]
3. [Principle 3]

---

## Format

### Structure

[Describe the expected format with examples]

```[language]
[Format example]
```

---

## Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **Category 1** | [Description] | [Examples] |
| **Category 2** | [Description] | [Examples] |

---

## Writing Guidelines

### Good Examples

```[language]
[Good example with explanation]
```

### Bad Examples

```[language]
[Bad example with explanation of why it's wrong]
```

---

## Common Patterns

### Pattern 1

[Description and example]

### Pattern 2

[Description and example]

---

## Quality Checklist

- [ ] [Check 1]
- [ ] [Check 2]
- [ ] [Check 3]

---

## References

- [Reference 1](url)
- [Reference 2](url)

---

*Last updated: YYYY-MM-DD*

```

---

## Checklist for New Patterns

### Required

- [ ] `system.md` exists with all required sections
- [ ] Pattern name is lowercase, hyphen-separated
- [ ] `# IDENTITY and PURPOSE` clearly defines AI role and expertise
- [ ] `# STEPS` are numbered and actionable
- [ ] `# OUTPUT FORMAT` includes working template/example
- [ ] `# INPUT` section describes expected input

### Recommended

- [ ] `# IMPORTANT CONSTRAINTS` prevents common LLM mistakes
- [ ] `filter.sh` cleans output (code fences, placeholders)
- [ ] `README.md` documents usage with examples
- [ ] Pattern tested manually with sample input

### For Complex Patterns

- [ ] Knowledge base file for extensive domain rules
- [ ] `# KNOWLEDGE BASE` section references companion doc
- [ ] **CRITICAL** marker enforces knowledge base application
- [ ] `test-pattern.sh` validates pattern with sample input
- [ ] Test input files provided

### Quality Verification

- [ ] Output is specific (file paths, line numbers, function names)
- [ ] Examples are actionable (users can copy and run)
- [ ] Empty sections are omitted (not filled with placeholders)
- [ ] Content is user-focused (explains "what" and "why")
- [ ] Line limits enforced (80 chars for code comments)

---

## References

- [Fabric GitHub Repository](https://github.com/danielmiessler/Fabric)
- [Pattern System Documentation](https://deepwiki.com/danielmiessler/fabric/3-pattern-system)
- [Keep a Changelog](https://keepachangelog.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Go Doc Comments](https://go.dev/doc/comment)

---

*This guide is maintained as part of the
[Fabric Patterns Hub](https://github.com/CowDogMoo/fabric-patterns-hub)
repository.*
