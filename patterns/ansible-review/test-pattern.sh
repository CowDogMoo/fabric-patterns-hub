#!/usr/bin/env bash

# Test script for ansible-review pattern
# Tests the pattern with good and bad playbook examples

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_NAME="ansible-review"
PATTERN_INSTALLED_BY_US=false

# Cleanup function to remove pattern if we installed it
cleanup() {
	if [ "$PATTERN_INSTALLED_BY_US" = true ]; then
		echo
		echo -e "${YELLOW}Cleaning up: Removing temporarily installed pattern${NC}"
		rm -f ~/.config/fabric/patterns/"$PATTERN_NAME"
		echo -e "${GREEN}✓ Pattern removed${NC}"
	fi
}

# Set trap to cleanup on exit (normal or error)
trap cleanup EXIT

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing ansible-review Pattern${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check if fabric is installed
if ! command -v fabric &>/dev/null; then
	echo -e "${RED}Error: fabric is not installed${NC}"
	echo "Please install fabric: https://github.com/danielmiessler/fabric"
	exit 1
fi

echo -e "${GREEN}✓ fabric is installed${NC}"

# Check if pattern exists in fabric
if ! fabric -l | grep -q "$PATTERN_NAME"; then
	echo -e "${YELLOW}Warning: Pattern not found in fabric patterns directory${NC}"
	echo "Installing pattern temporarily to ~/.config/fabric/patterns/$PATTERN_NAME"
	mkdir -p ~/.config/fabric/patterns
	ln -sf "$SCRIPT_DIR" ~/.config/fabric/patterns/
	PATTERN_INSTALLED_BY_US=true
	echo -e "${GREEN}✓ Pattern installed (will be removed after tests)${NC}"
else
	echo -e "${GREEN}✓ Pattern found in fabric${NC}"
fi

echo

# Test 1: Bad playbook (should find many issues)
echo -e "${BLUE}Test 1: Analyzing playbook with anti-patterns${NC}"
echo "============================================"
echo

if [ -f "$SCRIPT_DIR/test-bad-playbook.yml" ]; then
	echo -e "${YELLOW}Running review on test-bad-playbook.yml...${NC}"
	OUTPUT=$(fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-bad-playbook.yml" 2>&1 || true)

	# Check for expected issues in output
	FOUND_ISSUES=0

	if echo "$OUTPUT" | grep -iq "FQCN\|Fully Qualified"; then
		echo -e "${GREEN}✓ Detected FQCN issues${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect FQCN issues${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "password\|secret\|credential\|hardcoded"; then
		echo -e "${GREEN}✓ Detected security/credential issues${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect security issues${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "idempoten\|changed_when\|creates"; then
		echo -e "${GREEN}✓ Detected idempotency issues${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect idempotency issues${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "name\|naming\|unnamed"; then
		echo -e "${GREEN}✓ Detected naming issues${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect naming issues${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "state: latest\|latest"; then
		echo -e "${GREEN}✓ Detected state:latest anti-pattern${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect state:latest issue${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "mode\|0755\|quoted"; then
		echo -e "${GREEN}✓ Detected mode quoting issues${NC}"
		((FOUND_ISSUES++)) || true
	else
		echo -e "${RED}✗ Failed to detect mode quoting issues${NC}"
	fi

	echo
	echo -e "${BLUE}Found $FOUND_ISSUES issue categories in test-bad-playbook.yml${NC}"

	if [ $FOUND_ISSUES -ge 4 ]; then
		echo -e "${GREEN}✓ Test 1 PASSED: Pattern detected multiple issue types${NC}"
	else
		echo -e "${YELLOW}⚠ Test 1 WARNING: Pattern detected fewer issues than expected${NC}"
	fi

	# Save full report
	fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-bad-playbook.yml" >"$SCRIPT_DIR/test-bad-report.md" 2>&1 || true
	echo -e "${GREEN}Full report saved to: test-bad-report.md${NC}"
else
	echo -e "${RED}✗ test-bad-playbook.yml not found${NC}"
fi

echo
echo

# Test 2: Good playbook (should have minimal issues)
echo -e "${BLUE}Test 2: Analyzing well-structured playbook${NC}"
echo "============================================"
echo

if [ -f "$SCRIPT_DIR/test-good-playbook.yml" ]; then
	echo -e "${YELLOW}Running review on test-good-playbook.yml...${NC}"
	OUTPUT=$(fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-good-playbook.yml" 2>&1 || true)

	# Check that good code gets fewer critical findings
	CRITICAL_COUNT=$(echo "$OUTPUT" | grep -c "CRITICAL" || true)

	if [ "$CRITICAL_COUNT" -le 2 ]; then
		echo -e "${GREEN}✓ Test 2 PASSED: Good playbook has minimal/no critical findings ($CRITICAL_COUNT)${NC}"
	else
		echo -e "${YELLOW}⚠ Test 2 WARNING: Good playbook has $CRITICAL_COUNT critical findings${NC}"
	fi

	# Check for positive observations
	if echo "$OUTPUT" | grep -iq "Positive Observations\|good practice\|well"; then
		echo -e "${GREEN}✓ Pattern identified positive practices${NC}"
	else
		echo -e "${YELLOW}⚠ Pattern may not have identified positive practices${NC}"
	fi

	# Save full report
	fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-good-playbook.yml" >"$SCRIPT_DIR/test-good-report.md" 2>&1 || true
	echo -e "${GREEN}Full report saved to: test-good-report.md${NC}"
else
	echo -e "${RED}✗ test-good-playbook.yml not found${NC}"
fi

echo
echo

# Test 3: Filter script
echo -e "${BLUE}Test 3: Testing filter script${NC}"
echo "============================================"
echo

if [ -f "$SCRIPT_DIR/filter.sh" ]; then
	# Test that filter is executable
	if [ -x "$SCRIPT_DIR/filter.sh" ]; then
		echo -e "${GREEN}✓ filter.sh is executable${NC}"
	else
		echo -e "${RED}✗ filter.sh is not executable${NC}"
		chmod +x "$SCRIPT_DIR/filter.sh"
		echo -e "${YELLOW}Made filter.sh executable${NC}"
	fi

	# Test filter functionality
	TEST_INPUT='```markdown
# Ansible Review Report

## Critical Issues

[No CRITICAL issues]

## Improvements

### Use FQCN for all modules

**Severity:** MEDIUM
```'

	FILTERED_OUTPUT=$(echo "$TEST_INPUT" | "$SCRIPT_DIR/filter.sh")

	if echo "$FILTERED_OUTPUT" | grep -q "\[No CRITICAL issues\]"; then
		echo -e "${RED}✗ Filter failed to remove placeholder text${NC}"
	else
		echo -e "${GREEN}✓ Filter removes placeholder text${NC}"
	fi

	if echo "$FILTERED_OUTPUT" | grep -q "^# Ansible Review Report"; then
		echo -e "${GREEN}✓ Filter preserves markdown headers${NC}"
	else
		echo -e "${RED}✗ Filter failed to preserve markdown headers${NC}"
	fi

	if echo "$FILTERED_OUTPUT" | grep -q "### Use FQCN"; then
		echo -e "${GREEN}✓ Filter preserves actual content${NC}"
	else
		echo -e "${RED}✗ Filter failed to preserve actual content${NC}"
	fi
else
	echo -e "${RED}✗ filter.sh not found${NC}"
fi

echo
echo

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo
echo "Pattern: $PATTERN_NAME"
echo "Location: $SCRIPT_DIR"
echo
echo "Test Reports Generated:"
echo "  - test-bad-report.md"
echo "  - test-good-report.md"
echo
echo -e "${GREEN}Testing complete!${NC}"
echo
echo "To manually test the pattern:"
echo "  cat test-bad-playbook.yml | fabric -p $PATTERN_NAME"
echo
