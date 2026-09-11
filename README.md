# 🧵 Git Text Patterns

Three prompt-and-filter pairs that turn a git diff into text: a branch name, a
commit message, or a pull request title and body.

Each pattern is a system prompt plus a deterministic output filter. The prompt
is model-agnostic; the filter is what makes the output safe to pipe straight
into `git commit -F -` or `gh pr create` without a human reading it first.

---

## 🚀 Getting Started

```bash
gh repo clone CowDogMoo/git-text-patterns
cd git-text-patterns
```

Patterns live at `patterns/<name>/`, each containing:

| File | Purpose |
|------|---------|
| `system.md` | The system prompt |
| `filter.sh` | Deterministic post-processing (required — see below) |
| `README.md` | Usage and worked examples |

---

## 📂 Available Patterns

| Pattern | Input | Output |
|---------|-------|--------|
| **[branch/](patterns/branch/)** | a description, or a diff | one git branch name |
| **[commit/](patterns/commit/)** | `git diff --staged` | a Conventional Commits message |
| **[pr/](patterns/pr/)** | `git diff <base>...HEAD` | a PR title line + body |

All three take their input on **stdin** and emit text on **stdout**. None of
them reads your working directory or writes a file.

---

## 🔧 Why the filter exists

A raw model response is not safe to commit. `scripts/filter.py` is the shared
post-processor that strips code fences, removes echoed prompt boilerplate,
drops "Here is your commit message" preambles, collapses blank runs, strips
AI-assistant attribution footers, and aborts on an upstream API error rather
than committing the error text.

Each pattern parameterizes it:

```bash
# commit
filter.py --sections "Added,Changed,Removed" --max-blanks 2

# pr
filter.py --sections "Key Changes,Added,Changed,Removed" --no-blank-after-title

# branch — reduce to the last line that is a plausible git ref
filter.py | grep -E '^[A-Za-z0-9][A-Za-z0-9._/-]*$' | tail -n 1
```

`PR_REQUIRED_HEADINGS` is read from the environment by the `pr` filter to keep
a repository's mandatory template headings intact.

---

## ✍️ Usage

These patterns are driven by the `squad_gen` helper in
[l50/dotfiles](https://github.com/l50/dotfiles) (`git.sh`), which runs squad's
pure-text transform on the `claude-code` provider and pipes the result through
the pattern's filter:

```bash
git ds | squad_gen commit          # commit message
git diff main...HEAD | squad_gen pr # PR title + body
squad_branch fix auth token expiry  # branch name, checked out
```

Directly, without the helper:

```bash
git diff --staged \
  | squad run --provider claude-code --system "$(cat patterns/commit/system.md)" \
  | ./patterns/commit/filter.sh
```

---

## 🧭 Pattern or agent?

These patterns are **stdin→stdout transforms** whose input a pipe already
produces. That is the whole test.

If a job needs to read a repository to do its work — generate a README, write a
changelog from history, audit dashboards — it belongs in
[squad-agents](https://github.com/cowdogmoo/squad-agents) as an agent, with its
standards document as a skill. Making a human paste the context an agent could
gather itself is the anti-pattern.

See [docs/AGENT_GUIDE.md](docs/AGENT_GUIDE.md) for the full decision guide.

---

## 🧪 Tests

```bash
task test          # pytest over scripts/filter.py
task               # pre-commit + tests
```

---

## 🤝 Contributing

1. Fork the repository
1. Read the **[Pattern Creation Guide](docs/PATTERN_GUIDE.md)**
1. Create `patterns/<name>/` with `system.md` and `filter.sh`
1. Add tests to `tests/test_filter.py` for any new filter behavior
1. Submit a pull request

A new pattern belongs here only if its input arrives on stdin and its output is
text. Otherwise open it as an agent in squad-agents.

---

## 📜 License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.
