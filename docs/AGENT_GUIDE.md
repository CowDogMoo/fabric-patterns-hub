# Pattern vs Agent vs Skill Guide

Use this guide to decide between a Fabric pattern, an agent workflow, and a
harness skill.

Agent implementations live in
[cowdogmoo/squad](https://github.com/CowDogMoo/squad). When this guide
classifies a workflow as agent-preferred, that is where to find or contribute
the agent definition.

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
- See [cowdogmoo/squad](https://github.com/CowDogMoo/squad) for the agent catalog.

### Use a SKILL when

- A built-in harness capability already covers the task (`/verify`,
  `/code-review`, `/security-review`, `/init`, etc.).
- The work is a focused side-task you want to run inside the current
  conversation rather than handed off to an autonomous agent.
- You want guided/interactive behavior with access to the current session's
  context and files.
- The scope is narrower than an agent: one capability, one outcome, no
  long-running iteration loop.

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
- go-doc-comments
- python-doc-comments

### Pattern-preferred

- branch
- commit
- pr
- changelog
- readme

### Depends

- grafana-dashboard-audit: audit = pattern; remediation = agent

## Tips

- If you find yourself needing to inspect other files, switch to an agent.
- If you want fixes applied or validated, use an agent.
- If you only need a single output artifact (e.g., commit message), use a pattern.
- If a slash command already does the job, use the skill instead of writing a
  one-off pattern or agent.
