---
name: pr-description-gen
description: Generates structured PR descriptions from git diffs with summary, changes, testing notes, and review checklist.
version: 0.1.0
license: Apache-2.0
---

# PR Description Generator

Analyzes the diff between two git branches and produces a structured pull request description including a summary, categorized changes list, testing notes, and a review checklist.

## Quick Start

```bash
# Generate PR description for current branch vs main
bash scripts/run.sh

# Compare specific branches
bash scripts/run.sh --base main --head feature/my-branch

# Output as markdown file
bash scripts/run.sh --output pr-description.md
```

## Reference Index

- [references/api.md](references/api.md) -- All flags, arguments, and output formats
- [references/usage-guide.md](references/usage-guide.md) -- Step-by-step walkthroughs
- [references/configuration.md](references/configuration.md) -- Config options and environment variables
- [references/examples.md](references/examples.md) -- Copy-paste-ready examples

## Implementation

The core logic lives in `scripts/run.sh`. It uses `git diff` and `git log` to analyze changes, then formats output into structured markdown sections.
