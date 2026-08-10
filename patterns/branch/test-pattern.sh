#!/usr/bin/env bash

# Test script for branch pattern
# Validates the branch pattern against sample descriptions and diffs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
OUTPUT_FILE="$SCRIPT_DIR/test-branch-output.txt"

# Sample test inputs
TEST_INPUT="Fix null pointer exception in authentication token validator for issue AUTH-456"

echo "Testing branch pattern..."
echo ""

# Check if fabric is installed
if ! command -v fabric &>/dev/null; then
	echo "Error: fabric is not installed"
	echo "   Install with: pip install fabric-ai"
	exit 1
fi

echo "Fabric is installed"

# Run the pattern
echo ""
echo "Running branch name generation on sample input..."
echo "Input: $TEST_INPUT"
echo ""

if echo "$TEST_INPUT" | fabric --pattern "$PATTERN_DIR" | "$SCRIPT_DIR/filter.sh" >"$OUTPUT_FILE" 2>&1; then
	echo "Pattern executed successfully"
	echo ""
	echo "Generated Branch Name:"
	echo "===================="
	cat "$OUTPUT_FILE"
	echo ""
	echo "===================="
	echo ""

	# Validate output is a valid branch name format
	echo "Validating branch name format..."
	branch_name=$(tr -d '[:space:]' <"$OUTPUT_FILE")

	# Dots are allowed for release version branches (e.g. release/v2.4.0)
	if [[ "$branch_name" =~ ^(feature|bugfix|hotfix|refactor|docs|chore|test|perf|release)/[a-z0-9-]+(\.[a-z0-9-]+)*$ ]]; then
		echo "  ✓ Valid prefix and kebab-case slug: $branch_name"
		echo ""
		echo "Pattern test successful!"
		echo ""
		echo "To test with your own description:"
		echo "  echo 'your description' | fabric --pattern $PATTERN_DIR | $SCRIPT_DIR/filter.sh"
		exit 0
	else
		echo "  ✗ Output format does not match standard branch pattern: $branch_name"
		exit 1
	fi
else
	echo "Pattern execution failed"
	echo ""
	echo "Error output:"
	cat "$OUTPUT_FILE"
	exit 1
fi
