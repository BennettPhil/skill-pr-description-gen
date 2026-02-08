# Usage Guide

## Basic Usage

Run from the root of any git repository:

```bash
bash scripts/run.sh
```

This compares the current branch against `main` and prints a structured PR description to stdout.

## Comparing Specific Branches

```bash
bash scripts/run.sh --base develop --head feature/auth-refactor
```

## Saving Output to a File

```bash
bash scripts/run.sh --output pr-body.md
```

The file can then be used with `gh pr create --body-file pr-body.md`.

## Using Conventional Commits

If your project uses conventional commits (e.g., `feat:`, `fix:`, `chore:`), enable grouping:

```bash
bash scripts/run.sh --conventional
```

This groups the changes by commit type in the summary section.

## Summary-Only Output

For a quick overview without the checklist or testing sections:

```bash
bash scripts/run.sh --format summary
```

## Checklist-Only Output

To get just the review checklist:

```bash
bash scripts/run.sh --format checklist
```

## Limiting File List

For large PRs, limit the number of files shown:

```bash
bash scripts/run.sh --max-files 20
```

Files beyond the limit are summarized as "... and N more files".
