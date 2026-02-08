# API Reference

## Command

```
bash scripts/run.sh [OPTIONS]
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--base <branch>` | `main` | Base branch to compare against |
| `--head <branch>` | Current branch | Head branch with changes |
| `--output <file>` | stdout | Write output to a file instead of stdout |
| `--format <fmt>` | `full` | Output format: `full`, `summary`, `checklist` |
| `--max-files <n>` | `0` (unlimited) | Limit number of files shown in changes list |
| `--no-checklist` | false | Omit the review checklist section |
| `--no-testing` | false | Omit the testing notes section |
| `--conventional` | false | Parse conventional commit prefixes (feat, fix, etc.) |
| `--help` | - | Show usage information |

## Output Sections

When `--format full` (default), the output contains these markdown sections:

### 1. Summary
A brief paragraph describing the overall change based on commit messages and diff statistics.

### 2. Changes
A categorized list of modified files grouped by directory or change type:
- **Added**: New files
- **Modified**: Changed files with brief description
- **Deleted**: Removed files

### 3. Testing Notes
Suggested testing steps based on the types of files changed:
- If tests were modified: "Updated tests cover the changes"
- If config changed: "Verify configuration in staging environment"
- If API routes changed: "Test affected API endpoints"

### 4. Review Checklist
A markdown checklist for reviewers:
- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] No unintended file changes
- [ ] Commit messages are clear

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Not a git repository |
| 2 | Base branch does not exist |
| 3 | No diff between branches |
