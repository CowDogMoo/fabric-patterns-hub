#!/usr/bin/env bash

# Filter script for go-taskfile pattern
# Cleans up LLM output to ensure consistent formatting

set -euo pipefail

content=$(cat)

# Remove markdown code fences wrapping entire output
content=$(echo "$content" | sed -e '1{/^```markdown$/d;}' -e '${/^```$/d;}')

# Remove introductory phrases
content=$(echo "$content" | sed -E '/^(Here is|Here'"'"'s|Below is) .*:?$/d')

# Remove placeholder text
content=$(echo "$content" | sed -E '/^\[No .* findings?\]$/d')
content=$(echo "$content" | sed -E '/^- (No|None|Nothing) .*/d')

# Normalize blank lines (max 2)
content=$(echo "$content" | awk '
BEGIN { blank=0 }
/^[[:space:]]*$/ { blank++; if (blank <= 2) print; next }
{ blank=0; print }
')

# Trim trailing whitespace
content=$(echo "$content" | sed 's/[[:space:]]*$//')

echo "$content"
