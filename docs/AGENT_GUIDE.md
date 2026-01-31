# Agent vs Pattern Guide

Use this guide to decide when to run a Fabric pattern versus when to reach for an
agent workflow.

## Quick Rubric

### Use a PATTERN when
- The input is self-contained (single file or text blob).
- The output is pure text and does not require repo changes.
- No tool runs are needed (tests, formatters, linters, scanners).
- The task does not benefit from exploring related files or context.

### Use an AGENT when
- The best result depends on repo context (multiple files, configs, conventions).
- The task should run tools (tests, linters, formatters, security scanners).
- The task modifies files or applies fixes.
- Iteration/feedback loops matter (run -> fix -> re-run).

## Pattern Classification in This Repo

### Agent-preferred
- go-refactor
- python-refactor
- go-tests
- python-tests
- go-security-audit
- go-review
- python-review
- ansible-review
- go-cobra
- go-taskfile

### Pattern-preferred
- commit
- pr
- changelog
- readme
- go-doc-comments
- python-doc-comments

### Depends
- grafana-dashboard-audit: audit = pattern; remediation = agent

## Tips

- If you find yourself needing to inspect other files, switch to an agent.
- If you want fixes applied or validated, use an agent.
- If you only need a single output artifact (e.g., commit message), use a pattern.
