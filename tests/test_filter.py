"""Tests for scripts/filter.py — the shared fabric pattern filter."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from filter import (
    collapse_blank_lines,
    drop_empty_heading_sections,
    ensure_blank_after_title,
    filter_text,
    merge_sections,
    normalize_section_spacing,
    remove_placeholder_lines,
    remove_preamble,
    strip_leading_trailing_blanks,
    strip_trailing_whitespace,
    strip_wrapping_fences,
)


class TestStripWrappingFences:
    def test_removes_markdown_fence(self):
        text = "```markdown\n# Hello\nWorld\n```"
        assert strip_wrapping_fences(text) == "# Hello\nWorld"

    def test_removes_python_fence(self):
        text = "```python\nprint('hi')\n```"
        assert strip_wrapping_fences(text) == "print('hi')"

    def test_removes_bare_fence(self):
        text = "```\nsome content\n```"
        assert strip_wrapping_fences(text) == "some content"

    def test_preserves_internal_fences(self):
        text = "# Review\n\n```go\nfunc main() {}\n```\n\nDone."
        assert strip_wrapping_fences(text) == text

    def test_no_fences(self):
        text = "just plain text\nno fences here"
        assert strip_wrapping_fences(text) == text

    def test_only_opening_fence(self):
        text = "```go\nfunc main() {}\nno closing fence"
        assert strip_wrapping_fences(text) == text

    def test_empty_input(self):
        assert strip_wrapping_fences("") == ""


class TestStripLeadingTrailingBlanks:
    def test_strips_leading(self):
        assert strip_leading_trailing_blanks("\n\nhello") == "hello"

    def test_strips_trailing(self):
        assert strip_leading_trailing_blanks("hello\n\n") == "hello"

    def test_strips_both(self):
        assert strip_leading_trailing_blanks("\n\nhello\n\n") == "hello"

    def test_preserves_internal(self):
        text = "hello\n\nworld"
        assert strip_leading_trailing_blanks(text) == text

    def test_empty_input(self):
        assert strip_leading_trailing_blanks("") == ""


class TestRemovePreamble:
    def test_removes_here_is(self):
        text = "Here is the review:\n# Review\nContent"
        result = remove_preamble(text)
        assert "Here is" not in result
        assert "# Review" in result

    def test_removes_heres(self):
        text = "Here's an analysis:\n# Analysis"
        result = remove_preamble(text)
        assert "Here's" not in result

    def test_removes_below_is(self):
        text = "Below is the output:\nContent"
        result = remove_preamble(text)
        assert "Below is" not in result

    def test_preserves_non_preamble(self):
        text = "Here is where things get interesting in the code."
        # This should NOT be removed — doesn't match "Here is the/an/a ..."
        result = remove_preamble(text)
        assert result == text

    def test_no_preamble(self):
        text = "# Review\nLooks good."
        assert remove_preamble(text) == text


class TestRemovePlaceholderLines:
    def test_no_content(self):
        result = remove_placeholder_lines("No content")
        assert result.strip() == ""

    def test_nothing_added(self):
        result = remove_placeholder_lines("Nothing was added")
        assert result.strip() == ""

    def test_no_changes(self):
        result = remove_placeholder_lines("No changes")
        assert result.strip() == ""

    def test_bracket_findings(self):
        result = remove_placeholder_lines("[No CRITICAL findings]")
        assert result.strip() == ""

    def test_bracket_issues(self):
        result = remove_placeholder_lines("[No HIGH issues]")
        assert result.strip() == ""

    def test_none_found(self):
        result = remove_placeholder_lines("[None found]")
        assert result.strip() == ""

    def test_no_issues_found(self):
        result = remove_placeholder_lines("[No issues found]")
        assert result.strip() == ""

    def test_dash_none(self):
        result = remove_placeholder_lines("- None")
        assert result.strip() == ""

    def test_dash_no_issues(self):
        result = remove_placeholder_lines("- No issues found")
        assert result.strip() == ""

    def test_preserves_real_content(self):
        text = "- SQL injection in handler.go"
        assert remove_placeholder_lines(text) == text

    def test_mixed_content(self):
        text = "- Real issue\n- None\n- Another issue"
        result = remove_placeholder_lines(text)
        assert "Real issue" in result
        assert "Another issue" in result
        lines = [line for line in result.split("\n") if line.strip()]
        assert len(lines) == 2


class TestCollapsBlankLines:
    def test_collapses_to_one(self):
        text = "a\n\n\n\nb"
        assert collapse_blank_lines(text, 1) == "a\n\nb"

    def test_collapses_to_two(self):
        text = "a\n\n\n\nb"
        assert collapse_blank_lines(text, 2) == "a\n\n\nb"

    def test_already_clean(self):
        text = "a\n\nb"
        assert collapse_blank_lines(text, 1) == text

    def test_no_blanks(self):
        text = "a\nb\nc"
        assert collapse_blank_lines(text, 1) == text


class TestEnsureBlankAfterTitle:
    def test_adds_blank_line(self):
        text = "title\nbody"
        assert ensure_blank_after_title(text) == "title\n\nbody"

    def test_collapses_multiple_blanks(self):
        text = "title\n\n\n\nbody"
        assert ensure_blank_after_title(text) == "title\n\nbody"

    def test_already_correct(self):
        text = "title\n\nbody"
        assert ensure_blank_after_title(text) == text

    def test_title_only(self):
        assert ensure_blank_after_title("just a title") == "just a title"


class TestDropEmptyHeadingSections:
    def test_drops_empty_section(self):
        text = "## CRITICAL\n\n## HIGH\n\n- Found an issue"
        result = drop_empty_heading_sections(text)
        assert "CRITICAL" not in result
        assert "HIGH" in result
        assert "Found an issue" in result

    def test_drops_section_with_only_separator(self):
        text = "## CRITICAL\n\n---\n\n## HIGH\n\n- Issue here"
        result = drop_empty_heading_sections(text)
        assert "CRITICAL" not in result
        assert "HIGH" in result

    def test_keeps_section_with_content(self):
        text = "## Summary\n\nTwo issues found."
        result = drop_empty_heading_sections(text)
        assert "Summary" in result
        assert "Two issues found" in result

    def test_preserves_pre_heading_content(self):
        text = "Intro text\n\n## Section\n\nContent"
        result = drop_empty_heading_sections(text)
        assert "Intro text" in result

    def test_multiple_empty_sections(self):
        text = "## A\n\n## B\n\n## C\n\nReal content"
        result = drop_empty_heading_sections(text)
        assert "A" not in result
        assert "B" not in result
        assert "C" in result
        assert "Real content" in result


class TestNormalizeSectionSpacing:
    def test_adds_blank_before_header(self):
        text = "content\n# Header"
        result = normalize_section_spacing(text)
        assert result == "content\n\n# Header"

    def test_adds_blank_before_separator(self):
        text = "content\n---"
        result = normalize_section_spacing(text)
        assert result == "content\n\n---"

    def test_no_double_blank(self):
        text = "content\n\n# Header"
        result = normalize_section_spacing(text)
        assert result == text

    def test_deduplicates_separators(self):
        text = "---\n---"
        result = normalize_section_spacing(text)
        assert result == "---"


class TestStripTrailingWhitespace:
    def test_strips_spaces(self):
        assert strip_trailing_whitespace("hello   ") == "hello"

    def test_strips_tabs(self):
        assert strip_trailing_whitespace("hello\t") == "hello"

    def test_multiline(self):
        text = "a  \nb \nc   "
        assert strip_trailing_whitespace(text) == "a\nb\nc"


class TestMergeSections:
    def test_merges_duplicate_added(self):
        text = "feat: add auth\n\n**Added:**\n- Login\n\n**Added:**\n- Signup"
        result = merge_sections(text, ["Added", "Changed", "Removed"])
        assert result.count("**Added:**") == 1
        assert "Login" in result
        assert "Signup" in result

    def test_drops_empty_sections(self):
        text = "fix: bug\n\n**Added:**\n\n**Changed:**\n- Fixed mutex\n\n**Removed:**\n"
        result = merge_sections(text, ["Added", "Changed", "Removed"])
        assert "**Added:**" not in result
        assert "**Removed:**" not in result
        assert "**Changed:**" in result
        assert "Fixed mutex" in result

    def test_preserves_section_order(self):
        text = "feat: update\n\n**Removed:**\n- Old code\n\n**Added:**\n- New code"
        result = merge_sections(text, ["Added", "Changed", "Removed"])
        added_pos = result.index("**Added:**")
        removed_pos = result.index("**Removed:**")
        assert added_pos < removed_pos

    def test_preserves_other_content(self):
        text = "feat: thing\n\nSome description here.\n\n**Added:**\n- Stuff"
        result = merge_sections(text, ["Added", "Changed", "Removed"])
        assert "Some description here." in result

    def test_key_changes_section(self):
        text = "feat: api\n\n**Key Changes:**\n- New endpoints\n\n**Added:**\n- GET /users"
        result = merge_sections(text, ["Key Changes", "Added", "Changed", "Removed"])
        assert "**Key Changes:**" in result
        assert "**Added:**" in result


class TestFilterTextIntegration:
    """End-to-end tests for the full filter pipeline."""

    def test_commit_filter(self):
        text = (
            "```\n"
            "feat: add user auth\n\n"
            "**Added:**\n- Login endpoint\n\n"
            "**Changed:**\nNo changes\n\n"
            "**Removed:**\nNothing was removed\n\n"
            "**Added:**\n- Signup endpoint\n"
            "```"
        )
        result = filter_text(text, section_names=["Added", "Changed", "Removed"], max_blanks=2)
        assert result.startswith("feat: add user auth")
        assert "**Added:**" in result
        assert result.count("**Added:**") == 1
        assert "Login endpoint" in result
        assert "Signup endpoint" in result
        assert "**Changed:**" not in result
        assert "**Removed:**" not in result
        assert "```" not in result

    def test_pr_filter(self):
        text = (
            "feat: new API\n\n"
            "**Key Changes:**\n- New endpoints\n\n"
            "**Added:**\n- GET /users\n\n"
            "**Changed:**\nNo changes\n\n"
            "**Removed:**\nNothing removed\n\n"
            "**Added:**\n- POST /users"
        )
        result = filter_text(
            text,
            section_names=["Key Changes", "Added", "Changed", "Removed"],
        )
        assert "**Key Changes:**" in result
        assert result.count("**Added:**") == 1
        assert "GET /users" in result
        assert "POST /users" in result
        assert "**Changed:**" not in result
        assert "**Removed:**" not in result

    def test_generic_filter_with_preamble(self):
        text = (
            "```markdown\n"
            "Here is the review:\n\n"
            "# Summary\n\n"
            "Code looks good.\n\n\n\n"
            "# Details\n\n"
            "Minor issues.\n"
            "```"
        )
        result = filter_text(text)
        assert "```" not in result
        assert "Here is" not in result
        assert "# Summary" in result
        assert "Code looks good." in result
        assert "# Details" in result

    def test_audit_filter_drops_empty_severity(self):
        text = (
            "# Security Audit\n\n"
            "## CRITICAL\n\n"
            "[No CRITICAL findings]\n\n"
            "## HIGH\n\n"
            "- SQL injection in handler.go\n\n"
            "## MEDIUM\n\n"
            "[None found]\n\n"
            "## LOW\n\n"
            "- None\n\n"
            "## Summary\n\n"
            "One high severity issue."
        )
        result = filter_text(text)
        assert "CRITICAL" not in result
        assert "MEDIUM" not in result
        assert "LOW" not in result
        assert "HIGH" in result
        assert "SQL injection" in result
        assert "Summary" in result
        assert "One high severity" in result

    def test_preserves_internal_code_blocks(self):
        text = (
            "# Review\n\n"
            "Bad code:\n\n"
            "```go\n"
            "func bad() {}\n"
            "```\n\n"
            "Good code:\n\n"
            "```go\n"
            "func good() {}\n"
            "```"
        )
        result = filter_text(text)
        assert "```go" in result
        assert "func bad()" in result
        assert "func good()" in result
        assert result.count("```go") == 2
        assert result.count("```") == 4  # 2 openers + 2 closers

    def test_empty_input(self):
        assert filter_text("") == ""

    def test_title_only(self):
        result = filter_text("feat: small fix", section_names=["Added", "Changed", "Removed"])
        assert result == "feat: small fix"

    def test_no_trailing_whitespace_in_output(self):
        text = "# Review   \n\nContent here   \n\nMore content  "
        result = filter_text(text)
        for line in result.split("\n"):
            assert line == line.rstrip(), f"Trailing whitespace in: {line!r}"
