#!/usr/bin/env bash

# Test script for go-cobra pattern
# Runs the pattern against test-cli-issues.go and validates output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILE="$SCRIPT_DIR/test-cli-issues.go"

echo "Testing go-cobra pattern..."
echo "==========================="

# Check if fabric is available
if ! command -v fabric &>/dev/null; then
	echo "Error: fabric is not installed or not in PATH"
	echo "Install with: pip install fabric-ai"
	exit 1
fi

# Run the pattern
echo "Running pattern against test-cli-issues.go..."
OUTPUT=$(fabric --pattern go-cobra <"$TEST_FILE" 2>&1) || true

# Apply filter if it exists
if [ -f "$SCRIPT_DIR/filter.sh" ]; then
	OUTPUT=$(echo "$OUTPUT" | "$SCRIPT_DIR/filter.sh")
fi

echo ""
echo "Pattern Output:"
echo "---------------"
echo "$OUTPUT"
echo ""

# Validate output contains expected sections
echo "Validating output structure..."

CHECKS_PASSED=0
CHECKS_FAILED=0

check_section() {
	local section="$1"
	if echo "$OUTPUT" | grep -q "$section"; then
		echo "  [PASS] Found: $section"
		((CHECKS_PASSED++))
	else
		echo "  [FAIL] Missing: $section"
		((CHECKS_FAILED++))
	fi
}

# Check for expected sections
check_section "## Summary"
check_section "## Critical Issues"
check_section "## Improvements"
check_section "## Positive Observations"
check_section "## Recommendations"

# Check for expected issue detection
echo ""
echo "Checking issue detection..."

check_issue() {
	local issue="$1"
	if echo "$OUTPUT" | grep -qi "$issue"; then
		echo "  [PASS] Detected: $issue"
		((CHECKS_PASSED++))
	else
		echo "  [WARN] Not detected: $issue"
		# Don't fail for issue detection - LLM output can vary
	fi
}

# These issues should be detected
check_issue "RunE"
check_issue "Viper"
check_issue "flag"
check_issue "error"

echo ""
echo "Results:"
echo "--------"
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"

if [ "$CHECKS_FAILED" -gt 0 ]; then
	echo ""
	echo "Some structural checks failed. Review the output above."
	exit 1
else
	echo ""
	echo "All structural checks passed!"
	exit 0
fi
