# 🧵 Fabric Patterns Hub

Fabric Patterns Hub is a collection of custom [Fabric](https://github.com/danielmiessler/Fabric)
patterns for enhancing workflows, improving consistency, and enabling
collaboration. Patterns can be used as-is or adapted for your own Fabric setup.

---

## 🚀 Getting Started

1. Clone the Repository

```bash
gh repo clone CowDogMoo/fabric-patterns-hub
cd fabric-patterns-hub
```

1. Locate a Pattern

Patterns are stored under `patterns/<pattern-name>/system.md`.

Example:

- **Commit message generation**: `patterns/commit/system.md`
- **Pull request description generation**: `patterns/pr/system.md`

1. Use in Fabric

Point your Fabric CLI or config to the `system.md` file you want to use.

1. Decide Pattern vs Agent

See [docs/AGENT_GUIDE.md](docs/AGENT_GUIDE.md) for when to use a pattern vs an agent.

Example:

```yaml
patterns:
  commit:
    system: ./patterns/commit/system.md
  pr:
    system: ./patterns/pr/system.md
  readme:
    system: ./patterns/readme/system.md
```

---

## 📂 Available Patterns

### 📚 Pattern Categories

#### General Patterns

- **[changelog/](patterns/changelog/)** – Generate structured changelog
  fragments for Ansible collections using antsibull-changelog format
- **[commit/](patterns/commit/)** – Generate clear, Conventional
  Commits-compliant messages from `git diff`
- **[pr/](patterns/pr/)** – Draft concise, informative pull request
  descriptions from changes
- **[readme/](patterns/readme/)** – Generate comprehensive, well-structured
  README documentation for GitHub repositories following best practices

#### Go-Specific Patterns

- **[go-tests/](patterns/go-tests/)** – Generate simple, pragmatic table-driven
  tests for Go code following Go idioms and best practices
- **[go-doc-comments/](patterns/go-doc-comments/)** – Generate or improve Go
  documentation comments following official Go Doc Comments specification
- **[go-review/](patterns/go-review/)** – Review Go code for idiomatic patterns,
  best practices, and adherence to Go community conventions (2025)
- **[go-refactor/](patterns/go-refactor/)** – Refactor Go code to be more
  idiomatic and maintainable while preserving functionality

Each pattern directory contains:

- **`system.md`** — Core Fabric prompt instructions

---

## ✍️ Usage Examples

### Changelog Pattern

```bash
fabric run --system ./patterns/changelog/system.md --input ./git-log.txt
```

### Commit Pattern

```bash
fabric run --system ./patterns/commit/system.md --input ./my-diff.txt
```

### Pull Request Pattern

```bash
fabric run --system ./patterns/pr/system.md --input ./my-diff.txt
```

### README Pattern

```bash
fabric run --system ./patterns/readme/system.md --input ./project-info.txt
```

### Go Tests Pattern

```bash
fabric run --system ./patterns/go-tests/system.md --input ./my-go-file.go
```

### Go Doc Comments Pattern

```bash
fabric run --system ./patterns/go-doc-comments/system.md --input ./my-go-file.go
```

### Go Review Pattern

```bash
fabric run --system ./patterns/go-review/system.md --input ./my-go-file.go
```

### Go Refactor Pattern

```bash
fabric run --system ./patterns/go-refactor/system.md --input ./my-go-file.go
```

---

## 🤝 Contributing

We welcome new patterns and improvements!
To contribute:

1. Fork the repository
1. Read the **[Pattern Creation Guide](docs/PATTERN_GUIDE.md)** for quality standards
1. Create a new pattern under `patterns/<pattern-name>/`
1. Add at least:

   - `system.md` (required)
   - `filter.sh` for output cleanup _(recommended)_
   - `README.md` with usage examples _(recommended)_
   - `examples/` folder with sample inputs/outputs _(optional but encouraged)_

1. Submit a pull request

See [docs/PATTERN_GUIDE.md](docs/PATTERN_GUIDE.md) for comprehensive guidance on
creating high-quality patterns, including templates and checklists.

---

## 📜 License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
