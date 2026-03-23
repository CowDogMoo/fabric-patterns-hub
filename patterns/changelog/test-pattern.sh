#!/usr/bin/env bash

# Test script for changelog pattern
# This script demonstrates how to use the pattern and validates it works

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
TEST_INPUT="$SCRIPT_DIR/test-commits.txt"
OUTPUT_FILE="$SCRIPT_DIR/test-changelog-output.md"

echo "Testing changelog pattern..."
echo ""

# Check if fabric is installed
if ! command -v fabric &>/dev/null; then
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
echo "Running changelog generation on sample commits..."
echo ""

if fabric --pattern "$PATTERN_DIR" <"$TEST_INPUT" >"$OUTPUT_FILE" 2>&1; then
	echo "Pattern executed successfully"
	echo ""
	echo "Output generated at: $OUTPUT_FILE"
	echo ""

	# Show a preview of the output
	echo "Output Preview:"
	echo "===================="
	head -n 40 "$OUTPUT_FILE"
	echo ""
	echo "..."
	echo ""
	echo "===================="
	echo ""

	# Check if output contains expected sections
	echo "Validating output structure..."

	sections=(
		"### Added"
		"### Fixed"
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

	# Check for expected content
	echo ""
	echo "Checking for expected content..."

	content=(
		"export"
		"YAML"
		"crash"
		"security\|Security"
	)

	content_found=0
	for item in "${content[@]}"; do
		if grep -qiE "$item" "$OUTPUT_FILE"; then
			echo "  Found: $item"
			((content_found++)) || true
		fi
	done

	echo ""

	if [ "$all_present" = true ] && [ "$content_found" -ge 2 ]; then
		echo "All expected sections present"
		echo "Found $content_found/4 expected content items"
		echo ""
		echo "Pattern test successful!"
		echo ""
		echo "To view the full output:"
		echo "  cat $OUTPUT_FILE"
		echo ""
		echo "To test with your own commits:"
		echo "  git log --oneline | fabric --pattern $PATTERN_DIR"
		exit 0
	else
		echo "Some checks failed - please review the output"
		exit 1
	fi
else
	echo "Pattern execution failed"
	echo ""
	echo "Error output:"
	cat "$OUTPUT_FILE"
	exit 1
fi
