#!/bin/bash
# Post-processing filter for PR pattern output
# Removes empty sections, placeholder text, and code block markers

# Read input from stdin
input=$(cat)

# Strip leading blank lines (fixes GitHub showing generic PR title)
input=$(echo "$input" | sed '/./,$!d')

# Remove code block markers (backticks)
output="${input//\`\`\`/}"

# Remove empty sections with placeholder text
output=$(echo "$output" | sed -E '/\*\*Added:\*\*/,/^$/{ /No (content|features|code|changes)/d; /Nothing (added|was added)/d; }')
output=$(echo "$output" | sed -E '/\*\*Changed:\*\*/,/^$/{ /No (content|features|code|changes)/d; /Nothing (changed|was changed)/d; }')
output=$(echo "$output" | sed -E '/\*\*Removed:\*\*/,/^$/{ /No (content|features|code|changes)/d; /Nothing (removed|was removed)/d; }')

# Remove section headers that have no content following them and merge duplicate sections
output=$(echo "$output" | awk '
BEGIN {
    first_line=1
    key_changes_buffer=""
    added_buffer=""
    changed_buffer=""
    removed_buffer=""
    other_content=""
    current_section=""
    in_key_changes=0
    first_section=1
}

# Keep the title line (first non-empty line)
NR==1 || (first_line && NF>0) {
    if (first_line) {
        print $0
        first_line=0
    }
    next
}

# Detect section headers and accumulate content
/^\*\*Key Changes:\*\*/ {
    current_section="key_changes"
    in_key_changes=1
    next
}

/^\*\*Added:\*\*/ {
    current_section="added"
    in_key_changes=0
    next
}

/^\*\*Changed:\*\*/ {
    current_section="changed"
    in_key_changes=0
    next
}

/^\*\*Removed:\*\*/ {
    current_section="removed"
    in_key_changes=0
    next
}

# Collect content for current section
{
    if (current_section == "key_changes") {
        key_changes_buffer=key_changes_buffer $0 "\n"
    } else if (current_section == "added") {
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
    # Print any non-section content first (after title)
    if (other_content !~ /^[[:space:]]*$/) {
        printf "%s", other_content
    }

    # Print Key Changes section if it has content
    if (key_changes_buffer !~ /^[[:space:]]*$/) {
        # Ensure blank line before first section
        if (first_section) {
            print ""
            first_section=0
        }
        print "**Key Changes:**"
        printf "%s", key_changes_buffer
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

echo "$output"
