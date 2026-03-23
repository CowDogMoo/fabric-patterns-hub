#!/usr/bin/env bash

# Test script for python-tests pattern
# Validates the pattern works correctly with sample input

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_INPUT="$SCRIPT_DIR/test-code.py"
TEST_OUTPUT="$SCRIPT_DIR/test-generated-tests.py"

echo "Python Tests Pattern Validation"
echo "================================"

# Check if fabric is installed
if ! command -v fabric &>/dev/null; then
	echo "ERROR: fabric is not installed or not in PATH"
	echo "Please install fabric first: https://github.com/danielmiessler/fabric"
	exit 1
fi

echo "[OK] fabric is installed"

# Check if test input exists
if [[ ! -f "$TEST_INPUT" ]]; then
	echo "ERROR: Test input file not found: $TEST_INPUT"
	exit 1
fi

echo "[OK] Test input file exists"

# Run the pattern
echo ""
echo "Running pattern against test-code.py..."
echo ""

fabric --pattern python-tests <"$TEST_INPUT" >"$TEST_OUTPUT" 2>&1

# Check if output was generated
if [[ ! -s "$TEST_OUTPUT" ]]; then
	echo "ERROR: No output generated"
	exit 1
fi

echo "[OK] Output generated"

# Validate expected content
echo ""
echo "Validating output content..."

# Check for pytest import
if grep -q "import pytest" "$TEST_OUTPUT"; then
	echo "[OK] Contains pytest import"
else
	echo "WARNING: Missing pytest import"
fi

# Check for test class
if grep -q "class Test" "$TEST_OUTPUT"; then
	echo "[OK] Contains test class"
else
	echo "WARNING: Missing test class"
fi

# Check for test functions
if grep -q "def test_" "$TEST_OUTPUT"; then
	echo "[OK] Contains test functions"
else
	echo "ERROR: No test functions found"
	exit 1
fi

# Check for fixtures
if grep -q "@pytest.fixture" "$TEST_OUTPUT"; then
	echo "[OK] Contains fixtures"
else
	echo "INFO: No fixtures found (may be acceptable)"
fi

# Check for parametrized tests
if grep -q "@pytest.mark.parametrize" "$TEST_OUTPUT"; then
	echo "[OK] Contains parametrized tests"
else
	echo "INFO: No parametrized tests found (may be acceptable)"
fi

# Check for exception testing
if grep -q "pytest.raises" "$TEST_OUTPUT"; then
	echo "[OK] Contains exception tests"
else
	echo "WARNING: No exception tests found"
fi

# Check for Calculator tests
if grep -q "Calculator" "$TEST_OUTPUT"; then
	echo "[OK] Tests Calculator class"
else
	echo "WARNING: Calculator class tests not found"
fi

# Check for standalone function tests
if grep -q "test_average\|test_maximum\|test_minimum\|test_is_even\|test_is_prime" "$TEST_OUTPUT"; then
	echo "[OK] Tests standalone functions"
else
	echo "WARNING: Standalone function tests not found"
fi

echo ""
echo "================================"
echo "Validation Complete"
echo ""
echo "Generated test file: $TEST_OUTPUT"
echo ""
echo "Preview (first 50 lines):"
echo "--------------------------------"
head -50 "$TEST_OUTPUT"
echo ""
echo "--------------------------------"
echo ""
echo "To run the generated tests:"
echo "  cd $SCRIPT_DIR"
echo "  pytest $TEST_OUTPUT -v"
