#!/usr/bin/env bash

# Test script for go-security-audit pattern
# Tests the pattern with vulnerable and secure code examples

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_NAME="go-security-audit"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Testing go-security-audit Pattern${NC}"
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
	echo "Installing pattern to ~/.config/fabric/patterns/$PATTERN_NAME"
	mkdir -p ~/.config/fabric/patterns
	ln -sf "$SCRIPT_DIR" ~/.config/fabric/patterns/
	echo -e "${GREEN}✓ Pattern installed${NC}"
else
	echo -e "${GREEN}✓ Pattern found in fabric${NC}"
fi

echo

# Test 1: Vulnerable code
echo -e "${BLUE}Test 1: Analyzing vulnerable code${NC}"
echo "============================================"
echo

if [ -f "$SCRIPT_DIR/test-vulnerable.go" ]; then
	echo -e "${YELLOW}Running audit on test-vulnerable.go...${NC}"
	OUTPUT=$(fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-vulnerable.go" 2>&1 || true)

	# Check for expected vulnerability types in output
	FOUND_ISSUES=0

	if echo "$OUTPUT" | grep -iq "SQL Injection\|sql injection"; then
		echo -e "${GREEN}✓ Detected SQL Injection${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect SQL Injection${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "Command Injection\|command injection"; then
		echo -e "${GREEN}✓ Detected Command Injection${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect Command Injection${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "Path Traversal\|path traversal"; then
		echo -e "${GREEN}✓ Detected Path Traversal${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect Path Traversal${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "XSS\|Cross-Site Scripting\|text/template"; then
		echo -e "${GREEN}✓ Detected XSS vulnerability${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect XSS vulnerability${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "hardcoded\|credentials"; then
		echo -e "${GREEN}✓ Detected hardcoded credentials${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect hardcoded credentials${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "MD5\|weak.*hash\|weak.*crypto"; then
		echo -e "${GREEN}✓ Detected weak cryptography${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect weak cryptography${NC}"
	fi

	if echo "$OUTPUT" | grep -iq "race.*condition\|data race\|math/rand"; then
		echo -e "${GREEN}✓ Detected race condition or insecure random${NC}"
		((FOUND_ISSUES++))
	else
		echo -e "${RED}✗ Failed to detect race condition or insecure random${NC}"
	fi

	echo
	echo -e "${BLUE}Found $FOUND_ISSUES vulnerability types in test-vulnerable.go${NC}"

	if [ $FOUND_ISSUES -ge 5 ]; then
		echo -e "${GREEN}✓ Test 1 PASSED: Pattern detected multiple vulnerability types${NC}"
	else
		echo -e "${YELLOW}⚠ Test 1 WARNING: Pattern detected fewer vulnerabilities than expected${NC}"
	fi

	# Save full report
	fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-vulnerable.go" >"$SCRIPT_DIR/test-vulnerable-report.md" 2>&1 || true
	echo -e "${GREEN}Full report saved to: test-vulnerable-report.md${NC}"
else
	echo -e "${RED}✗ test-vulnerable.go not found${NC}"
fi

echo
echo

# Test 2: Secure code
echo -e "${BLUE}Test 2: Analyzing secure code${NC}"
echo "============================================"
echo

if [ -f "$SCRIPT_DIR/test-secure.go" ]; then
	echo -e "${YELLOW}Running audit on test-secure.go...${NC}"
	OUTPUT=$(fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-secure.go" 2>&1 || true)

	# Check that secure code gets fewer critical findings
	CRITICAL_COUNT=$(echo "$OUTPUT" | grep -c "CRITICAL" || true)

	if [ "$CRITICAL_COUNT" -le 2 ]; then
		echo -e "${GREEN}✓ Test 2 PASSED: Secure code has minimal/no critical findings ($CRITICAL_COUNT)${NC}"
	else
		echo -e "${YELLOW}⚠ Test 2 WARNING: Secure code has $CRITICAL_COUNT critical findings${NC}"
	fi

	# Save full report
	fabric -p "$PATTERN_NAME" <"$SCRIPT_DIR/test-secure.go" >"$SCRIPT_DIR/test-secure-report.md" 2>&1 || true
	echo -e "${GREEN}Full report saved to: test-secure-report.md${NC}"
else
	echo -e "${RED}✗ test-secure.go not found${NC}"
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
# Test Report

## CRITICAL Severity Findings

[None found]

## HIGH Severity Findings

### SQL Injection
```'

	FILTERED_OUTPUT=$(echo "$TEST_INPUT" | "$SCRIPT_DIR/filter.sh")

	if echo "$FILTERED_OUTPUT" | grep -q "\[None found\]"; then
		echo -e "${RED}✗ Filter failed to remove placeholder text${NC}"
	else
		echo -e "${GREEN}✓ Filter removes placeholder text${NC}"
	fi

	if echo "$FILTERED_OUTPUT" | grep -q "^# Test Report"; then
		echo -e "${GREEN}✓ Filter preserves markdown headers${NC}"
	else
		echo -e "${RED}✗ Filter failed to preserve markdown headers${NC}"
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
echo "  - test-vulnerable-report.md"
echo "  - test-secure-report.md"
echo
echo -e "${GREEN}Testing complete!${NC}"
echo
echo "To manually test the pattern:"
echo "  cat test-vulnerable.go | fabric -p $PATTERN_NAME"
echo
