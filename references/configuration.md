# Configuration

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PR_DESC_BASE` | `main` | Default base branch |
| `PR_DESC_FORMAT` | `full` | Default output format |
| `PR_DESC_CONVENTIONAL` | `false` | Enable conventional commit parsing |
| `PR_DESC_MAX_FILES` | `0` | Default max files to list |

## Precedence

Command-line flags take priority over environment variables:

```
CLI flags > Environment variables > Defaults
```

## Integration with gh CLI

Pipe output directly into `gh pr create`:

```bash
bash scripts/run.sh | gh pr create --title "My PR" --body-file -
```

Or save and use:

```bash
bash scripts/run.sh --output /tmp/pr-body.md
gh pr create --title "My PR" --body-file /tmp/pr-body.md
```
