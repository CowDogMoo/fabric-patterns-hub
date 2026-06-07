#!/usr/bin/env bash

# Test script for readme pattern
# This script demonstrates how to use the pattern and validates it works

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
OUTPUT_FILE="$SCRIPT_DIR/test-readme-output.md"

# Sample project info for testing
TEST_INPUT="Project: task-runner
Type: CLI Tool
Purpose: A fast, parallel task runner for monorepos
Language: Go
Features:
- Parallel task execution with dependency resolution
- YAML configuration with variable substitution
- Watch mode for development
- Rich terminal output with progress bars
Prerequisites: Go 1.21+, Git 2.30+
License: Apache 2.0"

echo "Testing readme pattern..."
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
echo "Running README generation on sample project info..."
echo ""

if echo "$TEST_INPUT" | fabric --pattern "$PATTERN_DIR" >"$OUTPUT_FILE" 2>&1; then
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
		"# "
		"## Installation"
		"## Quick Start"
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
		"task-runner"
		"Go"
		"parallel"
	)

	content_found=0
	for item in "${content[@]}"; do
		if grep -qi "$item" "$OUTPUT_FILE"; then
			echo "  Found: $item"
			((content_found++)) || true
		fi
	done

	echo ""

	if [ "$all_present" = true ] && [ "$content_found" -ge 2 ]; then
		echo "All expected sections present"
		echo "Found $content_found/3 expected content items"
		echo ""
		echo "Pattern test successful!"
		echo ""
		echo "To view the full output:"
		echo "  cat $OUTPUT_FILE"
		echo ""
		echo "To test with your own project info:"
		echo "  echo 'Project: name...' | fabric --pattern $PATTERN_DIR"
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
