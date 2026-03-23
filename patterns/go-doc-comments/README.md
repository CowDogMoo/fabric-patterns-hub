# Go Doc Comments Pattern

A comprehensive fabric pattern for generating and improving Go documentation comments following official Go standards. This pattern analyzes Go code and produces documentation that adheres to the "Go Doc Comments" specification.

## Pattern Structure

This pattern includes:

- **`system.md`** - The documentation framework and prompt engineering for LLM
- **`go-documentation-standards.md`** - Comprehensive reference document with standards (source of truth)
- **`filter.sh`** - Post-processing to clean up output formatting
- **`README.md`** - This documentation
- **`test-undocumented.go`** - Sample code without documentation for testing
- **`test-pattern.sh`** - Automated testing script

The pattern is designed with **separation of concerns**: the `go-documentation-standards.md` contains the knowledge base (documentation rules), while `system.md` contains the execution framework (how to analyze and generate).

## Purpose

This pattern helps you:

- **Generate documentation** for undocumented Go code
- **Improve existing documentation** to meet standards
- **Learn Go doc conventions** through examples
- **Maintain consistency** across codebases
- **Support CI/CD** integration for documentation quality

## Features

- Complete documentation for all exported declarations
- Modern Go 1.19+ doc comment features (headings, links, lists)
- 80-character line length compliance
- Proper godoc syntax
- Documentation for concurrency safety, errors, and cleanup
- Summary of documentation changes

## Documentation Categories

1. **Package Comments** - "Package [name]" format
2. **Function Comments** - Start with function name
3. **Type Comments** - "A [Type] represents..."
4. **Constant/Variable Comments** - Purpose and usage
5. **Method Comments** - Start with method name
6. **Concurrency Safety** - Thread safety documentation
7. **Error Documentation** - Error conditions
8. **Cleanup Requirements** - Resource release needs

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
fabric --pattern /path/to/fabric-patterns-hub/patterns/go-doc-comments
```

## Usage

### Document a Single File

```bash
cat myfile.go | fabric --pattern go-doc-comments > myfile_documented.go
```

### Document from Clipboard

```bash
pbpaste | fabric --pattern go-doc-comments | pbcopy
```

### Document All Files in a Package

```bash
for file in *.go; do
  echo "Documenting $file..."
  cat "$file" | fabric --pattern go-doc-comments > "${file%.go}_documented.go"
done
```

### Integration with go generate

Add to your Go file:

```go
//go:generate sh -c "cat $GOFILE | fabric --pattern go-doc-comments > $GOFILE.tmp && mv $GOFILE.tmp $GOFILE"
```

### CI/CD Documentation Check

```bash
#!/bin/bash
# Check for missing documentation

for file in $(find . -name "*.go" -not -path "./vendor/*"); do
  undocumented=$(grep -c "^func\|^type\|^var\|^const" "$file" || true)
  documented=$(grep -c "^//" "$file" || true)

  if [ "$undocumented" -gt "$documented" ]; then
    echo "Warning: $file may have undocumented exports"
    cat "$file" | fabric --pattern go-doc-comments
  fi
done
```

## Output Format

### Documented Code

Complete Go code with all documentation comments added or improved.

### Documentation Summary

- Count of new doc comments added
- Count of existing comments improved
- Key changes made

### Notes

Important documentation decisions and suggestions for further improvement.

## Example

### Before

```go
package user

type User struct {
    ID   int
    Name string
}

func NewUser(name string) *User {
    return &User{Name: name}
}

func (u *User) Validate() error {
    if u.Name == "" {
        return errors.New("name required")
    }
    return nil
}
```

### After

```go
// Package user provides user management functionality including
// creation, validation, and storage operations.
package user

// User represents a user in the system with a unique identifier
// and display name.
type User struct {
    ID   int    // Unique identifier assigned on creation
    Name string // Display name of the user
}

// NewUser creates a new User with the given name.
// The ID is assigned when the user is persisted.
func NewUser(name string) *User {
    return &User{Name: name}
}

// Validate checks that the user has all required fields populated.
// It returns an error if the Name field is empty.
func (u *User) Validate() error {
    if u.Name == "" {
        return errors.New("name required")
    }
    return nil
}
```

## Best Practices

### When to Use This Pattern

**Good use cases:**

- Adding documentation to legacy code
- Ensuring consistent documentation style
- Learning Go documentation conventions
- Preparing code for open source release

**Not ideal for:**

- Highly domain-specific documentation (provide context)
- Complex API documentation (may need manual refinement)

### Tips for Best Results

1. **Provide complete files** - Context helps generate better docs
2. **Include existing comments** - Pattern can improve them
3. **Review output** - May need domain-specific refinement
4. **Run gofmt** - Ensure formatting is correct

## Customization

### Extending Standards

Edit `go-documentation-standards.md` to add organization-specific requirements:

```markdown
## Company-Specific Standards

### API Documentation

All public API functions must include:
- Example usage in a code block
- Error conditions with specific error types
- Performance characteristics for hot paths
```

### Adjusting Output Format

Edit the `# OUTPUT FORMAT` section in `system.md` to customize the output structure.

## Troubleshooting

### Issue: Documentation too verbose

**Solution:** The pattern aims for completeness. Edit for conciseness after generation.

### Issue: Missing package documentation

**Solution:** Ensure the package clause is included in the input.

### Issue: Incorrect function descriptions

**Solution:** Provide more context or manually refine domain-specific documentation.

## Related Patterns

- **go-refactor** - Refactor Go code (includes doc improvements)
- **go-review** - Review Go code (checks documentation quality)
- **go-tests** - Generate tests (may need documentation)

## References

### Pattern Documentation

- **`go-documentation-standards.md`** - Comprehensive documentation standards

### External Resources

- [Go Doc Comments Specification](https://go.dev/doc/comment)
- [Effective Go - Commentary](https://go.dev/doc/effective_go#commentary)
- [Go Blog - Godoc](https://go.dev/blog/godoc)

## Contributing

Contributions welcome! Submit PRs for new documentation patterns or improvements.

## License

Part of fabric-patterns-hub, follows parent repository license.

---

**Version:** 1.0.0
**Last Updated:** 2026-01-10
**Maintainer:** fabric-patterns-hub contributors
