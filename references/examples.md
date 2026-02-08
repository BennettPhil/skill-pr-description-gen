# Examples

## Example 1: Simple Feature Branch

```bash
$ bash scripts/run.sh --base main --head feature/add-search
```

Output:

```markdown
## Summary

Adds search functionality to the application with a new search endpoint and UI component.

**Stats**: 4 files changed, 127 insertions(+), 12 deletions(-)

## Changes

**Added**
- `src/components/SearchBar.tsx` -- New search bar UI component
- `src/api/search.ts` -- Search API endpoint handler

**Modified**
- `src/app.ts` -- Register search route
- `src/styles/main.css` -- Search bar styles

## Testing Notes

- [ ] Verify search returns expected results
- [ ] Test empty query handling
- [ ] Updated tests cover the changes

## Review Checklist

- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] No unintended file changes
- [ ] Commit messages are clear
```

## Example 2: Conventional Commits

```bash
$ bash scripts/run.sh --conventional
```

Groups changes by commit type: feat, fix, chore, docs, etc.

## Example 3: Large PR with File Limit

```bash
$ bash scripts/run.sh --max-files 5
```

Shows first 5 files, then "... and 23 more files".

## Example 4: Summary Only

```bash
$ bash scripts/run.sh --format summary
```

Outputs just the summary paragraph and diff stats.
