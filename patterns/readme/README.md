# README Pattern

A comprehensive fabric pattern for generating high-quality README documentation for software projects. This pattern creates clear, comprehensive READMEs that answer the three fundamental questions: What is this? Why should I care? How do I use it?

## Pattern Structure

This pattern includes:

- **`system.md`** - The README generation framework and prompt engineering for LLM
- **`readme-standards.md`** - Comprehensive reference document with README standards (source of truth)
- **`filter.sh`** - Post-processing to clean up output formatting
- **`README.md`** - This documentation
- **`examples/`** - Sample READMEs for different project types
- **`test-pattern.sh`** - Automated testing script

The pattern is designed with **separation of concerns**: the `readme-standards.md` contains the knowledge base (README best practices), while `system.md` contains the execution framework (how to generate READMEs).

## Purpose

This pattern helps you:

- **Generate READMEs** for new projects
- **Improve existing documentation** to meet standards
- **Learn README best practices** through templates
- **Maintain consistency** across project documentation
- **Answer the three questions** - What, why, how

## Features

- Progressive disclosure structure
- Working code examples
- Project type variations (CLI, library, web app)
- Complete section templates
- Badge recommendations
- Quality checklist

## README Categories

1. **Project Title** - Clear, descriptive name
2. **One-line Description** - What it does and who it's for
3. **Overview** - 2-3 sentences expanding on the description
4. **Features** - Key capabilities and benefits
5. **Installation** - Prerequisites and step-by-step instructions
6. **Quick Start** - Working example users can run immediately
7. **Usage** - Detailed usage examples
8. **Configuration** - Environment variables and config options
9. **Contributing** - How to contribute
10. **License** - License information

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
fabric --pattern /path/to/fabric-patterns-hub/patterns/readme
```

## Usage

### Generate README from Project Info

Provide project information as input:

```bash
echo "Project: my-cli-tool
Type: CLI
Purpose: A command-line tool for managing Docker containers
Features: Container listing, logs viewing, shell access
Language: Go
License: MIT" | fabric --pattern readme > README.md
```

### Generate README from Existing Code

Point to your codebase:

```bash
cat package.json main.go | fabric --pattern readme > README.md
```

### Generate README from Clipboard

```bash
pbpaste | fabric --pattern readme | pbcopy
```

### Generate for Different Project Types

```bash
# For a library
echo "Type: Library
Name: my-lib
Purpose: HTTP client with retry support
Language: Python" | fabric --pattern readme

# For a web app
echo "Type: Web Application
Name: my-app
Purpose: Task management dashboard
Stack: React, Node.js, PostgreSQL" | fabric --pattern readme
```

## Output Format

The pattern generates a complete README with:

- Project title and one-line description
- Overview paragraph
- Feature list
- Installation instructions with prerequisites
- Quick Start with working examples
- Detailed usage section
- Configuration documentation
- Contributing guidelines
- License information

## Example Output

```markdown
# my-cli-tool

A command-line tool for managing Docker containers with intuitive commands.

## Overview

my-cli-tool simplifies Docker container management by providing easy-to-remember
commands for common operations. It's designed for developers who want to quickly
interact with containers without remembering complex Docker CLI syntax.

## Features

- **Container Listing** - View all containers with status and resource usage
- **Log Viewing** - Stream container logs with filtering support
- **Shell Access** - Quick shell access to running containers

## Installation

### Prerequisites

- Go 1.21 or higher
- Docker Engine 24.0+

### Quick Install

\`\`\`bash
go install github.com/user/my-cli-tool@latest
\`\`\`

### Verification

\`\`\`bash
my-cli-tool --version
# Expected: my-cli-tool v1.0.0
\`\`\`

## Quick Start

\`\`\`bash
# List all containers
my-cli-tool list

# View logs
my-cli-tool logs my-container

# Open shell
my-cli-tool shell my-container
\`\`\`

## License

MIT License
```

## Best Practices

### When to Use This Pattern

**Good use cases:**

- Creating README for new projects
- Improving existing README documentation
- Generating consistent documentation across repos
- Learning README best practices

**Not ideal for:**

- API documentation (use dedicated tools)
- Full documentation sites (use static site generators)

### Tips for Best Results

1. **Provide complete information** - More context yields better READMEs
2. **Specify project type** - CLI, library, web app, etc.
3. **Include key features** - Help the pattern understand capabilities
4. **Mention dependencies** - For accurate prerequisites

## Customization

### Extending Standards

Edit `readme-standards.md` to add organization-specific requirements:

```markdown
## Company Standards

### Required Sections

All project READMEs must include:
- Security contact information
- Support escalation path
- Related internal documentation links
```

### Adjusting Output Format

Edit the `# OUTPUT FORMAT` section in `system.md` to customize the README structure.

## Troubleshooting

### Issue: README is too generic

**Solution:** Provide more specific project information including features, use cases, and target audience.

### Issue: Missing sections

**Solution:** Ensure all relevant project information is included in the input.

### Issue: Wrong project type assumptions

**Solution:** Explicitly specify the project type (CLI, library, web app, etc.)

## Related Patterns

- **go-doc-comments** - Generate Go documentation
- **go-review** - Review code documentation

## References

### Pattern Documentation

- **`readme-standards.md`** - Comprehensive README standards reference
- **`examples/`** - Sample READMEs for different project types

### External Resources

- [Make a README](https://www.makeareadme.com/)
- [Awesome README](https://github.com/matiassingers/awesome-readme)
- [Standard Readme](https://github.com/RichardLitt/standard-readme)

## Contributing

Contributions welcome! Submit PRs for new README templates or improvements.

## License

Part of fabric-patterns-hub, follows parent repository license.

---

**Version:** 1.0.0
**Last Updated:** 2026-01-10
**Maintainer:** fabric-patterns-hub contributors
