#!/bin/bash
# Post-processing filter for commit pattern output
# Removes empty sections, placeholder text, and code block markers

# Read input from stdin
input=$(cat)

# Strip leading blank lines (fixes GitHub showing "Commit {sha} pushed by {user}")
input=$(echo "$input" | sed '/./,$!d')

# Remove code block markers (backticks)
output="${input//\`\`\`/}"

# Remove empty sections with placeholder text (case-insensitive)
output=$(echo "$output" | sed -E '/\*\*Added:\*\*/,/^$/{ /[Nn]o (content|features|code|changes)/d; /[Nn]othing (added|was added)/d; }')
output=$(echo "$output" | sed -E '/\*\*Changed:\*\*/,/^$/{ /[Nn]o (content|features|code|changes)/d; /[Nn]othing (changed|was changed)/d; }')
output=$(echo "$output" | sed -E '/\*\*Removed:\*\*/,/^$/{ /[Nn]o (content|features|code|changes)/d; /[Nn]othing (removed|was removed)/d; }')

# Remove section headers that have no content following them and merge duplicate sections
output=$(echo "$output" | awk '
BEGIN {
    first_line=1
    added_buffer=""
    changed_buffer=""
    removed_buffer=""
    other_content=""
    current_section=""
    first_section=1
}

# Keep the summary line (first non-empty line)
NR==1 || (first_line && NF>0) {
    if (first_line) {
        print $0
        first_line=0
    }
    next
}

# Detect section headers and accumulate content
/^\*\*Added:\*\*/ {
    current_section="added"
    next
}

/^\*\*Changed:\*\*/ {
    current_section="changed"
    next
}

/^\*\*Removed:\*\*/ {
    current_section="removed"
    next
}

# Collect content for current section
{
    if (current_section == "added") {
        added_buffer=added_buffer $0 "\n"
    } else if (current_section == "changed") {
        changed_buffer=changed_buffer $0 "\n"
    } else if (current_section == "removed") {
        removed_buffer=removed_buffer $0 "\n"
    } else {
        other_content=other_content $0 "\n"
    }
}

END {
    # Print any non-section content first
    if (other_content !~ /^[[:space:]]*$/) {
        printf "%s", other_content
    }

    # Print Added section if it has content
    if (added_buffer !~ /^[[:space:]]*$/) {
        # Ensure blank line before first section
        if (first_section) {
            print ""
            first_section=0
        }
        print "**Added:**"
        printf "%s", added_buffer
    }

    # Print Changed section if it has content
    if (changed_buffer !~ /^[[:space:]]*$/) {
        # Ensure blank line before first section
        if (first_section) {
            print ""
            first_section=0
        }
        print "**Changed:**"
        printf "%s", changed_buffer
    }

    # Print Removed section if it has content
    if (removed_buffer !~ /^[[:space:]]*$/) {
        # Ensure blank line before first section
        if (first_section) {
            print ""
            first_section=0
        }
        print "**Removed:**"
        printf "%s", removed_buffer
    }
}
')

# Clean up excessive blank lines (max 2 consecutive)
output=$(echo "$output" | awk '
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
output=$(echo "$output" | sed 's/[[:space:]]*$//')

echo "$output"
