#!/usr/bin/env bash

# Test script for go-doc-comments pattern
# This script demonstrates how to use the pattern and validates it works

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
TEST_INPUT="$SCRIPT_DIR/test-undocumented.go"
OUTPUT_FILE="$SCRIPT_DIR/test-documentation-output.md"

echo "Testing go-doc-comments pattern..."
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
echo "Running documentation generation on test code..."
echo ""

if fabric --pattern "$PATTERN_DIR" <"$TEST_INPUT" >"$OUTPUT_FILE" 2>&1; then
	echo "Pattern executed successfully"
	echo ""
	echo "Output generated at: $OUTPUT_FILE"
	echo ""

	# Show a preview of the output
	echo "Output Preview:"
	echo "===================="
	head -n 50 "$OUTPUT_FILE"
	echo ""
	echo "..."
	echo ""
	echo "===================="
	echo ""

	# Check if output contains expected sections
	echo "Validating output structure..."

	sections=(
		"## Documented Code"
		"## Documentation Summary"
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

	# Check for documentation content
	echo ""
	echo "Checking for expected documentation patterns..."

	patterns=(
		"// Package"
		"// Cache"
		"// NewCache"
		"// Set"
		"// Get"
	)

	patterns_found=0
	for pattern in "${patterns[@]}"; do
		if grep -q "$pattern" "$OUTPUT_FILE"; then
			echo "  Found: $pattern"
			((patterns_found++)) || true
		fi
	done

	echo ""

	if [ "$all_present" = true ] && [ "$patterns_found" -ge 3 ]; then
		echo "All expected sections present"
		echo "Found $patterns_found/5 expected documentation patterns"
		echo ""
		echo "Pattern test successful!"
		echo ""
		echo "To view the full output:"
		echo "  cat $OUTPUT_FILE"
		echo ""
		echo "To test with your own code:"
		echo "  cat yourfile.go | fabric --pattern $PATTERN_DIR"
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
