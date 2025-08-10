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

Patterns are stored under `custom-patterns/<pattern-name>/system.md`.

Example:

- **Commit message generation**: `custom-patterns/commit/system.md`
- **Pull request description generation**: `custom-patterns/pr/system.md`

1. Use in Fabric

Point your Fabric CLI or config to the `system.md` file you want to use.

Example:

```yaml
patterns:
  commit:
    system: ./custom-patterns/commit/system.md
  pr:
    system: ./custom-patterns/pr/system.md
```

---

## 📂 Available Patterns

### 📚 Pattern Categories

- **[commit/](custom-patterns/commit/)** – Generate clear, Conventional
  Commits-compliant messages from `git diff`
- **[pr/](custom-patterns/pr/)** – Draft concise, informative pull request
  descriptions from changes

Each pattern directory contains:

- **`system.md`** — Core Fabric prompt instructions

---

## ✍️ Usage Examples

### Commit Pattern

```bash
fabric run --system ./custom-patterns/commit/system.md --input ./my-diff.txt
```

### Pull Request Pattern

```bash
fabric run --system ./custom-patterns/pr/system.md --input ./my-diff.txt
```

---

## 🤝 Contributing

We welcome new patterns and improvements!
To contribute:

1. Fork the repository
1. Create a new pattern under `custom-patterns/<pattern-name>/`
1. Add at least:

   - `system.md` (required)
   - `examples/` folder with sample inputs/outputs _(optional but encouraged)_

1. Submit a pull request

---

## 📜 License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
