# Changelog Pattern

A comprehensive fabric pattern for generating structured changelog entries from git commit history. This pattern transforms commit messages into user-focused changelog entries following the Keep a Changelog format.

## Pattern Structure

This pattern includes:

- **`system.md`** - The changelog generation framework and prompt engineering for LLM
- **`changelog-standards.md`** - Comprehensive reference document with changelog standards (source of truth)
- **`filter.sh`** - Post-processing to clean up output formatting
- **`README.md`** - This documentation
- **`test-commits.txt`** - Sample commit messages for testing
- **`test-pattern.sh`** - Automated testing script

The pattern is designed with **separation of concerns**: the `changelog-standards.md` contains the knowledge base (changelog conventions), while `system.md` contains the execution framework (how to generate entries).

## Purpose

This pattern helps you:

- **Generate changelog entries** from git commits
- **Categorize changes** properly (Added, Changed, Fixed, etc.)
- **Write user-focused** descriptions
- **Maintain consistency** across releases
- **Support multiple formats** (Keep a Changelog, antsibull-changelog)

## Features

- Keep a Changelog format support
- Ansible/antsibull-changelog YAML support
- Standard category grouping
- User-focused entry writing
- Reference linking (issues, PRs, CVEs)
- Semantic versioning alignment

## Changelog Categories

| Category | Description |
|----------|-------------|
| **Added** | New features, capabilities, or functionality |
| **Changed** | Changes to existing functionality |
| **Deprecated** | Features marked for removal |
| **Removed** | Removed features |
| **Fixed** | Bug fixes |
| **Security** | Security vulnerability fixes |

## Installation

This pattern is part of the fabric-patterns-hub. Ensure you have fabric installed:

```bash
# Install fabric if you haven't already
pip install fabric-ai

# Add this patterns repository to fabric
fabric --add-pattern-source /path/to/fabric-patterns-hub/patterns
```

Or use it directly:

```bash
fabric --pattern /path/to/fabric-patterns-hub/patterns/changelog
```

## Usage

### Generate from Git Log

```bash
# Get commits since last tag
git log v1.0.0..HEAD --oneline | fabric --pattern changelog
```

### Generate for Specific Range

```bash
# Commits between two versions
git log v1.0.0..v1.1.0 --pretty=format:"%s" | fabric --pattern changelog
```

### Generate for Current Sprint

```bash
# Last 2 weeks of commits
git log --since="2 weeks ago" --oneline | fabric --pattern changelog
```

### Ansible/antsibull-changelog Format

```bash
# For Ansible collections
git log v1.0.0..HEAD --oneline | fabric --pattern changelog \
  --instruction "Use antsibull-changelog YAML format"
```

### CI/CD Integration

```bash
#!/bin/bash
# Generate changelog for release

LAST_TAG=$(git describe --tags --abbrev=0)
git log ${LAST_TAG}..HEAD --pretty=format:"%s" | \
  fabric --pattern changelog > CHANGELOG_FRAGMENT.md
```

## Output Format

### Standard Format (Keep a Changelog)

```markdown
## [Unreleased]

### Added

- Added new export command for data export (#234)
- Added support for YAML configuration files

### Changed

- Changed default timeout from 30s to 60s

### Fixed

- Fixed crash when processing empty files (#245)
```

### Ansible Format (antsibull-changelog)

```yaml
---
release_summary: "This release adds export functionality and fixes critical bugs"
added:
  - "export_module - Added new export command"
  - "config_role - Added YAML configuration support"
changed:
  - "core - Changed default timeout to 60s"
fixed:
  - "parser_module - Fixed crash on empty files"
```

## Example

### Input (Git Commits)

```
feat: add export command for CSV data
fix: resolve crash when processing empty files
chore: update CI configuration
feat: support YAML configuration files
fix: correct timeout calculation
docs: update README with examples
refactor: clean up error handling
```

### Output

```markdown
## [Unreleased]

### Added

- Added export command for CSV data export
- Added support for YAML configuration files

### Fixed

- Fixed crash when processing empty files
- Fixed incorrect timeout calculation
```

Note: Internal changes (chore, docs, refactor) are omitted as they're not user-facing.

## Best Practices

### When to Use This Pattern

**Good use cases:**

- Generating release notes from commits
- Creating changelog fragments for PRs
- Maintaining consistent changelog format
- Automating release documentation

**Not ideal for:**

- Generating full release announcements (need more context)
- Initial changelog setup (create structure manually)

### Tips for Best Results

1. **Use conventional commits** - Structured commit messages yield better results
2. **Include issue numbers** - Pattern will preserve references
3. **Separate user changes** - Internal changes are filtered out
4. **Review output** - May need minor adjustments for clarity

## Customization

### Extending Standards

Edit `changelog-standards.md` to add organization-specific requirements:

```markdown
## Company Standards

### Required References

All entries must include:
- JIRA ticket number in format [PROJ-123]
- GitHub PR number
```

### Adjusting Output Format

Edit the `# OUTPUT FORMAT` section in `system.md` to customize the changelog structure.

## Troubleshooting

### Issue: Too many entries

**Solution:** Filter commits before passing to pattern:

```bash
git log --grep="feat\|fix" --oneline | fabric --pattern changelog
```

### Issue: Missing context

**Solution:** Include more commit details:

```bash
git log --pretty=format:"%s%n%b" | fabric --pattern changelog
```

### Issue: Wrong category

**Solution:** Use conventional commit prefixes (feat:, fix:, etc.) for better categorization.

## Related Patterns

- **commit** - Generate commit messages
- **pr** - Generate PR descriptions
- **readme** - Generate README documentation

## References

### Pattern Documentation

- **`changelog-standards.md`** - Comprehensive changelog standards reference

### External Resources

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [antsibull-changelog](https://github.com/ansible-community/antsibull-changelog)

## Contributing

Contributions welcome! Submit PRs for new changelog formats or improvements.

## License

Part of fabric-patterns-hub, follows parent repository license.

---

**Version:** 1.0.0
**Last Updated:** 2026-01-10
**Maintainer:** fabric-patterns-hub contributors
