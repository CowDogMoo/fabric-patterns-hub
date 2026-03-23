#!/usr/bin/env bash

# Test script for grafana-dashboard-audit pattern
# This script demonstrates how to use the pattern and validates it works

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="$SCRIPT_DIR"
TEST_DASHBOARD="$SCRIPT_DIR/test-dashboard.json"
OUTPUT_REPORT="$SCRIPT_DIR/test-audit-report.md"

echo "🧪 Testing grafana-dashboard-audit pattern..."
echo ""

# Check if fabric is installed
if ! command -v fabric &>/dev/null; then
	echo "❌ Error: fabric is not installed"
	echo "   Install with: pip install fabric-ai"
	exit 1
fi

echo "✅ Fabric is installed"

# Check if test dashboard exists
if [ ! -f "$TEST_DASHBOARD" ]; then
	echo "❌ Error: Test dashboard not found at $TEST_DASHBOARD"
	exit 1
fi

echo "✅ Test dashboard found"

# Run the pattern
echo ""
echo "📊 Running audit on test dashboard..."
echo ""

if fabric --pattern "$PATTERN_DIR" <"$TEST_DASHBOARD" >"$OUTPUT_REPORT" 2>&1; then
	echo "✅ Pattern executed successfully"
	echo ""
	echo "📄 Report generated at: $OUTPUT_REPORT"
	echo ""

	# Show a preview of the report
	echo "📋 Report Preview:"
	echo "===================="
	head -n 30 "$OUTPUT_REPORT"
	echo ""
	echo "..."
	echo ""
	echo "===================="
	echo ""

	# Check if report contains expected sections
	echo "🔍 Validating report structure..."

	sections=(
		"# Grafana Dashboard Audit Report"
		"## 📊 Executive Summary"
		"## 🎯 Prioritized Remediation Roadmap"
	)

	all_present=true
	for section in "${sections[@]}"; do
		if grep -q "$section" "$OUTPUT_REPORT"; then
			echo "  ✅ Found: $section"
		else
			echo "  ❌ Missing: $section"
			all_present=false
		fi
	done

	echo ""

	if [ "$all_present" = true ]; then
		echo "✅ All expected sections present"
		echo ""
		echo "🎉 Pattern test successful!"
		echo ""
		echo "To view the full report:"
		echo "  cat $OUTPUT_REPORT"
		echo ""
		echo "To test with your own dashboard:"
		echo "  cat your-dashboard.json | fabric --pattern $PATTERN_DIR > your-audit.md"
		exit 0
	else
		echo "⚠️  Some sections missing - please review the output"
		exit 1
	fi
else
	echo "❌ Pattern execution failed"
	echo ""
	echo "Error output:"
	cat "$OUTPUT_REPORT"
	exit 1
fi
