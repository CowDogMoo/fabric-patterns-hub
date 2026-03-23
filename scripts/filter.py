#!/usr/bin/env python3
"""Shared post-processing filter for fabric pattern output.

Reads LLM output from stdin, cleans it up, and writes to stdout.

Usage:
    # Generic cleanup (strip fences, collapse blanks, remove preamble)
    echo "$output" | python3 scripts/filter.py

    # Section-based cleanup (merge duplicate sections, drop empty ones)
    echo "$output" | python3 scripts/filter.py --sections "Added,Changed,Removed"
    echo "$output" | python3 scripts/filter.py --sections "Key Changes,Added,Changed,Removed"

    # Max consecutive blank lines (default: 1)
    echo "$output" | python3 scripts/filter.py --max-blanks 2
"""

import argparse
import re
import sys


def strip_wrapping_fences(text: str) -> str:
    """Remove code fences that wrap the entire output, preserving internal ones."""
    lines = text.split("\n")
    # Only strip if the first line is a fence opener and the last is a closer
    if len(lines) >= 2 and re.match(r"^```\w*$", lines[0]) and lines[-1].strip() == "```":
        lines = lines[1:-1]
    return "\n".join(lines)


def strip_leading_trailing_blanks(text: str) -> str:
    """Remove leading and trailing blank lines."""
    lines = text.split("\n")
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return "\n".join(lines)


def remove_preamble(text: str) -> str:
    """Remove introductory 'Here is...' / 'Below is...' lines."""
    return re.sub(
        r"^(Here is|Here's|Below is) (the|an?) .*:?\s*$",
        "",
        text,
        flags=re.MULTILINE,
    )


def remove_placeholder_lines(text: str) -> str:
    """Remove lines with placeholder text.

    Handles:
    - 'No content', 'Nothing added', etc. (commit/pr patterns)
    - '[No CRITICAL findings]', '[None found]', '[No issues found]' (audit patterns)
    - '- None', '- No issues found' (list-style placeholders)
    """
    patterns = [
        # "No content", "Nothing was removed", etc.
        r"^\s*(No |Nothing )(content|features|code|changes|added|was added|"
        r"changed|was changed|removed|was removed).*$",
        # "[No CRITICAL findings]", "[None found]", "[No issues found]"
        r"^\s*\[No \w+ (issues|findings)\]\s*$",
        r"^\s*\[(None found|No issues found)\]\s*$",
        # "- None", "- No issues found"
        r"^\s*- (None|No issues found)\s*$",
    ]
    for pattern in patterns:
        text = re.sub(pattern, "", text, flags=re.MULTILINE | re.IGNORECASE)
    return text


def collapse_blank_lines(text: str, max_consecutive: int = 1) -> str:
    """Collapse runs of blank lines to at most max_consecutive."""
    lines = text.split("\n")
    result = []
    blank_count = 0
    for line in lines:
        if not line.strip():
            blank_count += 1
            if blank_count <= max_consecutive:
                result.append(line)
        else:
            blank_count = 0
            result.append(line)
    return "\n".join(result)


def ensure_blank_after_title(text: str) -> str:
    """Ensure exactly one blank line between the first line and the body."""
    lines = text.split("\n")
    if len(lines) < 2:
        return text
    title = lines[0]
    rest = lines[1:]
    # Strip leading blanks from rest
    while rest and not rest[0].strip():
        rest.pop(0)
    if rest:
        return title + "\n\n" + "\n".join(rest)
    return title


def drop_empty_heading_sections(text: str) -> str:
    """Remove markdown heading sections that have no content.

    A section is empty if it contains only blank lines or separators (---)
    before the next heading of equal or higher level, or end of text.
    """
    lines = text.split("\n")
    # Parse into (heading_level, heading_line, content_lines) groups
    sections: list[tuple[int, str, list[str]]] = []
    current_heading = ""
    current_level = 0
    current_content: list[str] = []

    for line in lines:
        heading_match = re.match(r"^(#{1,6})\s+", line)
        if heading_match:
            sections.append((current_level, current_heading, current_content))
            current_level = len(heading_match.group(1))
            current_heading = line
            current_content = []
        else:
            current_content.append(line)
    sections.append((current_level, current_heading, current_content))

    # Rebuild, skipping sections with no substantive content
    result_lines: list[str] = []
    for level, heading, content in sections:
        substantive = any(line.strip() and line.strip() != "---" for line in content)
        if level == 0:
            # Pre-heading content, always keep
            result_lines.extend(content)
        elif substantive:
            result_lines.append(heading)
            result_lines.extend(content)

    return "\n".join(result_lines)


def normalize_section_spacing(text: str) -> str:
    """Ensure one blank line before markdown headers and HR separators."""
    lines = text.split("\n")
    result = []
    for i, line in enumerate(lines):
        is_header = line.startswith("#")
        is_separator = line.strip() == "---"
        # Skip duplicate separators
        if is_separator and result:
            prev_non_blank = next((ln for ln in reversed(result) if ln.strip()), None)
            if prev_non_blank == "---":
                continue
        if i > 0 and (is_header or is_separator):
            # Add blank line before if previous line isn't already blank
            if result and result[-1].strip():
                result.append("")
        result.append(line)
    return "\n".join(result)


def strip_trailing_whitespace(text: str) -> str:
    """Remove trailing whitespace from each line."""
    return "\n".join(line.rstrip() for line in text.split("\n"))


def merge_sections(text: str, section_names: list[str]) -> str:
    """Parse bold section headers, merge duplicates, drop empty sections.

    Handles sections like **Added:**, **Changed:**, **Removed:**, **Key Changes:**
    """
    lines = text.split("\n")

    # Build header patterns
    header_pattern = re.compile(
        r"^\*\*(" + "|".join(re.escape(s) for s in section_names) + r"):\*\*\s*$"
    )

    title = ""
    sections: dict[str, list[str]] = {name: [] for name in section_names}
    other_lines: list[str] = []
    current_section: str | None = None
    title_found = False

    for line in lines:
        # First non-empty line is the title
        if not title_found:
            if line.strip():
                title = line
                title_found = True
            continue

        # Check for section header
        match = header_pattern.match(line)
        if match:
            current_section = match.group(1)
            continue

        # Accumulate into the right bucket
        if current_section:
            sections[current_section].append(line)
        else:
            other_lines.append(line)

    # Build output
    parts = [title]

    # Non-section content (between title and first section)
    other_text = "\n".join(other_lines).strip()
    if other_text:
        parts.append("")
        parts.append(other_text)

    # Sections with content
    for name in section_names:
        content = "\n".join(sections[name]).strip()
        if content:
            parts.append("")
            parts.append(f"**{name}:**")
            parts.append(content)

    return "\n".join(parts)


def filter_text(
    text: str,
    section_names: list[str] | None = None,
    max_blanks: int = 1,
) -> str:
    """Apply all filter steps to the input text."""
    text = strip_wrapping_fences(text)
    text = strip_leading_trailing_blanks(text)
    text = remove_preamble(text)
    text = remove_placeholder_lines(text)

    if section_names:
        text = merge_sections(text, section_names)
        text = ensure_blank_after_title(text)
    else:
        text = drop_empty_heading_sections(text)
        text = normalize_section_spacing(text)

    text = collapse_blank_lines(text, max_blanks)
    text = strip_leading_trailing_blanks(text)
    text = strip_trailing_whitespace(text)
    return text


def main():
    parser = argparse.ArgumentParser(description="Post-process fabric pattern output")
    parser.add_argument(
        "--sections",
        help="Comma-separated bold section names to merge/filter (e.g. 'Added,Changed,Removed')",
    )
    parser.add_argument(
        "--max-blanks",
        type=int,
        default=1,
        help="Maximum consecutive blank lines (default: 1)",
    )
    args = parser.parse_args()

    section_names = None
    if args.sections:
        section_names = [s.strip() for s in args.sections.split(",")]

    text = sys.stdin.read()
    result = filter_text(text, section_names=section_names, max_blanks=args.max_blanks)
    print(result)


if __name__ == "__main__":
    main()
