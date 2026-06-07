# Grafana Dashboard Audit Pattern

A comprehensive fabric pattern for auditing Grafana dashboard JSON files against industry best practices. This pattern analyzes dashboards for design quality, accessibility, performance, observability methodology adherence, and provides actionable recommendations.

## Pattern Structure

This pattern includes:

- **`system.md`** - The audit framework and prompt engineering for LLM
- **`best-practices.md`** - Comprehensive reference document with detailed criteria (source of truth)
- **`filter.sh`** - Post-processing to clean up output formatting
- **`README.md`** - This documentation
- **`test-dashboard.json`** - Sample dashboard for testing
- **`test-pattern.sh`** - Automated testing script

The pattern is designed with **separation of concerns**: the `best-practices.md` contains the comprehensive knowledge base (what to look for), while `system.md` contains the audit framework (how to analyze and report). This eliminates duplication and makes the pattern easier to maintain and extend.

## Purpose

This pattern helps you:

- **Audit dashboard quality** against established best practices
- **Identify issues** across multiple categories (design, accessibility, performance, etc.)
- **Generate reports** with severity-based findings and remediation roadmaps
- **Assess maturity** and provide path to improvement
- **Maintain consistency** across dashboard portfolios
- **Support CI/CD** integration for dashboard quality gates

## Features

- ✅ Comprehensive analysis across 10 key categories
- ✅ Severity-based findings (Critical, High, Medium, Low, Info)
- ✅ Observability methodology detection (USE, RED, Golden Signals)
- ✅ Accessibility evaluation (colorblind-friendly, contrast, labels)
- ✅ Performance assessment (panel count, query efficiency, refresh rates)
- ✅ Maturity scoring and improvement roadmap
- ✅ Single or batch dashboard analysis
- ✅ Detailed technical breakdown with panel/query analysis
- ✅ Actionable recommendations with specific next steps

## Audit Categories

1. **Purpose and Documentation** - Clear naming, descriptions, audience identification
2. **Observability Methodology** - USE/RED/Golden Signals alignment
3. **Visual Design and Accessibility** - Colors, hierarchy, readability
4. **Data Presentation** - Axes, aggregations, visualization types
5. **Performance and Scalability** - Panel count, refresh rates, query efficiency
6. **Variables and Reusability** - Template variables, datasource flexibility
7. **Navigation and Organization** - Layout, grouping, drill-downs
8. **Naming and Tagging** - Conventions, ownership, discoverability
9. **Query Quality** - Well-formed queries, appropriate aggregations
10. **Accessibility** - Contrast, fonts, labels, alternative indicators

## Installation

This pattern is part of the fabric-patterns-hub. Ensure you have fabric installed:

```bash
# Install fabric if you haven't already
pip install fabric-ai

# Add this patterns repository to fabric
fabric --add-pattern-source /path/to/fabric-patterns-hub/patterns
```

Or use it directly by pointing to the pattern directory:

```bash
fabric --pattern /path/to/fabric-patterns-hub/patterns/grafana-dashboard-audit
```

## Usage

### Single Dashboard Audit

Audit a single dashboard JSON file:

```bash
cat dashboard.json | fabric --pattern grafana-dashboard-audit > audit-report.md
```

### Multiple Dashboard Audit

Audit multiple dashboards and generate individual reports:

```bash
# Audit all dashboards in a directory
for dashboard in dashboards/*.json; do
  cat "$dashboard" | fabric --pattern grafana-dashboard-audit > "reports/$(basename "$dashboard" .json)-audit.md"
done
```

### Batch Analysis with Comparison

Audit multiple dashboards in a single analysis (includes comparative summary):

```bash
# Combine multiple dashboards into one input
cat dashboards/*.json | fabric --pattern grafana-dashboard-audit > combined-audit-report.md
```

### Export from Grafana API

Fetch and audit dashboards directly from Grafana:

```bash
# Export dashboard by UID
curl -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  "https://your-grafana.com/api/dashboards/uid/dashboard-uid" \
  | jq '.dashboard' \
  | fabric --pattern grafana-dashboard-audit > audit-report.md
```

### Audit All Dashboards in a Folder

```bash
# Get all dashboards in a folder and audit them
FOLDER_UID="your-folder-uid"

# List all dashboards in the folder
curl -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  "https://your-grafana.com/api/search?folderIds=${FOLDER_UID}&type=dash-db" \
  | jq -r '.[].uid' \
  | while read uid; do
    echo "Auditing dashboard: $uid"
    curl -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
      "https://your-grafana.com/api/dashboards/uid/$uid" \
      | jq '.dashboard' \
      | fabric --pattern grafana-dashboard-audit > "reports/${uid}-audit.md"
  done
```

### CI/CD Integration

Use in your CI pipeline to enforce dashboard quality:

```bash
#!/bin/bash
# .github/workflows/dashboard-quality-check.sh

REPORT=$(cat dashboard.json | fabric --pattern grafana-dashboard-audit)

# Extract critical/high issue count
CRITICAL_COUNT=$(echo "$REPORT" | grep -c "^## 🔴 Critical Issues")
HIGH_COUNT=$(echo "$REPORT" | grep -c "^## 🟠 High Priority Issues")

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "❌ Dashboard has critical issues!"
  echo "$REPORT"
  exit 1
fi

if [ "$HIGH_COUNT" -gt 5 ]; then
  echo "⚠️  Dashboard has more than 5 high priority issues"
  echo "$REPORT"
  exit 1
fi

echo "✅ Dashboard quality check passed"
```

## Output Format

The pattern generates a comprehensive markdown report with:

### Executive Summary

- Dashboard metadata (title, UID, panel count, variables)
- Maturity score (0-100)
- Methodology detection
- Overall assessment

### Findings by Severity

- 🔴 Critical Issues - Must fix (broken functionality, misleading data)
- 🟠 High Priority - Should fix (usability, accessibility, performance)
- 🟡 Medium Priority - Important (best practices, consistency)
- 🟢 Low Priority - Nice to have (minor improvements)
- ℹ️ Informational - Suggestions (optimization, enhancements)

### Strengths

- Positive aspects already implemented
- Best practices in use

### Maturity Assessment

- Current level (Low/Medium/High)
- Characteristics of current level
- Path to next level

### Prioritized Remediation Roadmap

- Phase 1: Critical Fixes (Do First)
- Phase 2: High Impact Improvements (Do Next)
- Phase 3: Quality Enhancements (Do When Time Permits)
- Phase 4: Optimization (Nice to Have)

### Detailed Technical Analysis

- Panel-by-panel breakdown
- Variable analysis
- Query performance insights

## Example Output

```markdown
# Grafana Dashboard Audit Report

**Dashboard:** Production API Monitoring
**UID:** prod-api-mon
**Audit Date:** 2026-01-10
**Maturity Score:** 68/100

---

## 📊 Executive Summary

This dashboard provides good coverage of API metrics but lacks
documentation and has accessibility concerns. The RED methodology
is partially implemented but inconsistent across panels.

**Key Metrics:**
- Total Panels: 24
- Total Variables: 3
- Datasources Used: Prometheus, Loki
- Estimated Methodology: RED (Partial)

**Overall Assessment:** Medium maturity dashboard with solid foundations
but requiring improvements in accessibility and documentation.

---

## 🔴 Critical Issues (1)

### Missing Error Tracking in Key Panels
**Severity:** CRITICAL
**Category:** Observability Methodology
**Impact:** Cannot detect or track API errors effectively

**Finding:**
The dashboard claims to follow RED methodology but 3 out of 5
service panels lack error rate metrics. This prevents proper
monitoring of service health.

**Recommendation:**
Add error rate queries to panels for services: auth-api,
payment-api, and notification-api. Use queries like:
`rate(http_requests_total{job="api", status=~"5.."}[5m])`

...
```

## Best Practices

### When to Use This Pattern

✅ **Good use cases:**

- Pre-deployment dashboard quality checks
- Regular dashboard audits (quarterly/monthly)
- Onboarding new dashboards to production
- Establishing baseline quality standards
- Identifying tech debt in dashboard portfolios
- Training teams on dashboard best practices

❌ **Not ideal for:**

- Real-time dashboard debugging (use Grafana UI)
- Complex dashboard transformations (use agent instead)
- Interactive remediation (use agent instead)

### Using Audit Reports with Agents

The output of this pattern is designed to be consumed by a Grafana agent:

1. **Generate audit report** with this pattern
2. **Feed report to agent** as context for remediation
3. **Agent uses MCP tools** to implement fixes
4. **Re-audit** to verify improvements

Example workflow:

```bash
# Step 1: Generate audit
cat dashboard.json | fabric --pattern grafana-dashboard-audit > audit.md

# Step 2: Use with agent (conceptual - agent integration coming)
# The agent reads audit.md and uses Grafana MCP tools to fix issues

# Step 3: Verify improvements
cat updated-dashboard.json | fabric --pattern grafana-dashboard-audit > audit-after.md

# Step 4: Compare
diff audit.md audit-after.md
```

## Customization

This pattern is designed to be easily customizable for your organization's specific needs.

### Extending Best Practices Criteria

To add or modify audit criteria, edit the `best-practices.md` file:

1. **Add new sections** for organization-specific requirements
2. **Modify existing criteria** to match your standards
3. **Add examples** from your dashboard ecosystem

The pattern automatically incorporates any changes you make to `best-practices.md`.

Example additions:

```markdown
## Company-Specific Standards

### Required Labels
All production dashboards must include:
- `team` tag identifying the owning team
- `environment` tag (prod, staging, dev)
- `slo` tag if dashboard tracks SLO metrics

### Approved Datasources
Only the following datasource types are permitted:
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)
...
```

### Adjusting Severity Levels

To customize severity levels and scoring, modify the `system.md` file:

```markdown
# SEVERITY LEVELS (Custom for our org)

- **CRITICAL**: <your definition>
- **HIGH**: <your definition>
- **MEDIUM**: <your definition>
...

# MATURITY SCORING (Custom for our org)

Calculate a 0-100 score based on:
- **Critical issues**: -25 points each (more strict)
- **High issues**: -15 points each
...
```

### Changing Output Format

To modify the report structure, edit the `# OUTPUT FORMAT` section in `system.md`. You can:

- Add new report sections
- Reorder existing sections
- Change emoji indicators
- Adjust table formats

## Examples

### Example 1: Simple Service Dashboard

Input: A basic service dashboard with 8 panels showing request rate, errors, and latency.

Expected output: Likely medium maturity score with recommendations for:

- Adding documentation
- Implementing template variables
- Including drill-down links
- Adding sparklines to stat panels

### Example 2: Complex Application Dashboard

Input: A comprehensive application dashboard with 35 panels, multiple variables, and mixed methodologies.

Expected output: Potential high priority issues:

- Too many panels (recommend splitting)
- Performance concerns with refresh rate
- Accessibility issues with color choices
- Inconsistent methodology application

### Example 3: Infrastructure Dashboard

Input: A USE method infrastructure dashboard with proper organization.

Expected output: Likely high maturity score with recommendations for:

- Minor accessibility improvements
- Additional documentation
- Optimization suggestions

## Troubleshooting

### Issue: Pattern doesn't detect methodology

**Solution:** The pattern looks for specific metric patterns (rate, errors, duration for RED; utilization, saturation, errors for USE). If your metrics have custom names, the detection may not work. The pattern will still audit other aspects.

### Issue: Report is too verbose

**Solution:** Use the filter script or post-process with grep to focus on specific severity levels:

```bash
cat dashboard.json | fabric --pattern grafana-dashboard-audit | grep -A 10 "^## 🔴"
```

### Issue: JSON parsing errors

**Solution:** Ensure your dashboard JSON is valid:

```bash
cat dashboard.json | jq . > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

## Related Patterns

- **grafana-dashboard-create** - Generate dashboards from requirements (coming soon)
- **grafana-dashboard-optimize** - Optimize dashboard performance (coming soon)
- **grafana-query-builder** - Build PromQL/LogQL queries (coming soon)

## References

### Pattern Documentation

- **`best-practices.md`** - Comprehensive best practices reference included with this pattern (source of truth for audit criteria)

### External Resources

This pattern is based on industry best practices from:

- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/best-practices/)
- [RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- [USE Method](http://www.brendangregg.com/usemethod.html)
- [Four Golden Signals (Google SRE)](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Grafana Dashboarding Best Practices Course](https://learn.grafana.com/dashboarding-best-practices)

All of these resources have been synthesized and organized in the `best-practices.md` reference document.

## Contributing

Contributions are welcome! If you have ideas for improving the audit criteria or adding new checks, please submit a PR or open an issue.

## License

This pattern is part of the fabric-patterns-hub and follows the same license as the parent repository.

---

**Version:** 1.0.0
**Last Updated:** 2026-01-10
**Maintainer:** fabric-patterns-hub contributors
