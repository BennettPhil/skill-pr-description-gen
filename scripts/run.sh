#!/usr/bin/env bash
set -euo pipefail

# PR Description Generator
# Generates structured PR descriptions from git diffs

# --- Defaults (overridden by env vars, then CLI flags) ---
BASE="${PR_DESC_BASE:-main}"
HEAD=""
OUTPUT=""
FORMAT="${PR_DESC_FORMAT:-full}"
MAX_FILES="${PR_DESC_MAX_FILES:-0}"
NO_CHECKLIST=false
NO_TESTING=false
CONVENTIONAL="${PR_DESC_CONVENTIONAL:-false}"

# --- Parse CLI args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    --head) HEAD="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --format) FORMAT="$2"; shift 2 ;;
    --max-files) MAX_FILES="$2"; shift 2 ;;
    --no-checklist) NO_CHECKLIST=true; shift ;;
    --no-testing) NO_TESTING=true; shift ;;
    --conventional) CONVENTIONAL=true; shift ;;
    --help)
      echo "Usage: bash scripts/run.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --base <branch>     Base branch (default: main)"
      echo "  --head <branch>     Head branch (default: current branch)"
      echo "  --output <file>     Write to file instead of stdout"
      echo "  --format <fmt>      full|summary|checklist (default: full)"
      echo "  --max-files <n>     Limit files listed (default: 0 = unlimited)"
      echo "  --no-checklist      Omit review checklist"
      echo "  --no-testing        Omit testing notes"
      echo "  --conventional      Group by conventional commit type"
      echo "  --help              Show this help"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validate ---
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not a git repository" >&2
  exit 1
fi

if ! git rev-parse --verify "$BASE" &>/dev/null; then
  echo "Error: Base branch '$BASE' does not exist" >&2
  exit 2
fi

if [[ -z "$HEAD" ]]; then
  HEAD=$(git rev-parse --abbrev-ref HEAD)
fi

DIFF_STAT=$(git diff --stat "$BASE...$HEAD" 2>/dev/null)
if [[ -z "$DIFF_STAT" ]]; then
  echo "Error: No diff between '$BASE' and '$HEAD'" >&2
  exit 3
fi

# --- Gather data ---
STAT_SUMMARY=$(git diff --shortstat "$BASE...$HEAD")
DIFF_FILES=$(git diff --name-status "$BASE...$HEAD")
COMMITS=$(git log --oneline "$BASE...$HEAD")
COMMIT_COUNT=$(echo "$COMMITS" | wc -l | tr -d ' ')

# --- Build output ---
build_output() {
  # Summary
  if [[ "$FORMAT" != "checklist" ]]; then
    echo "## Summary"
    echo ""
    if [[ "$CONVENTIONAL" == "true" ]]; then
      # Group by conventional commit prefix
      echo "Changes across $COMMIT_COUNT commit(s):"
      echo ""
      for prefix in feat fix refactor chore docs test style perf ci build; do
        local matches
        matches=$(echo "$COMMITS" | grep -i "^[a-f0-9]* ${prefix}" || true)
        if [[ -n "$matches" ]]; then
          echo "**${prefix}**:"
          echo "$matches" | while IFS= read -r line; do
            echo "- ${line#* }"
          done
          echo ""
        fi
      done
      # Uncategorized
      local other
      other=$(echo "$COMMITS" | grep -ivE "^[a-f0-9]* (feat|fix|refactor|chore|docs|test|style|perf|ci|build)" || true)
      if [[ -n "$other" ]]; then
        echo "**other**:"
        echo "$other" | while IFS= read -r line; do
          echo "- ${line#* }"
        done
        echo ""
      fi
    else
      echo "$COMMITS" | head -1 | awk '{$1=""; print substr($0,2)}' | {
        read -r first_msg
        echo "$first_msg."
      }
      echo ""
    fi
    echo "**Stats**: $STAT_SUMMARY"
    echo ""
  fi

  # Changes list
  if [[ "$FORMAT" == "full" || "$FORMAT" == "summary" ]]; then
    echo "## Changes"
    echo ""

    local count=0
    local total
    total=$(echo "$DIFF_FILES" | wc -l | tr -d ' ')

    local added="" modified="" deleted=""
    while IFS=$'\t' read -r status filepath; do
      count=$((count + 1))
      if [[ "$MAX_FILES" -gt 0 && "$count" -gt "$MAX_FILES" ]]; then
        continue
      fi
      case "$status" in
        A*) added="${added}- \`${filepath}\`\n" ;;
        M*) modified="${modified}- \`${filepath}\`\n" ;;
        D*) deleted="${deleted}- \`${filepath}\`\n" ;;
        R*) modified="${modified}- \`${filepath}\` (renamed)\n" ;;
      esac
    done <<< "$DIFF_FILES"

    if [[ -n "$added" ]]; then
      echo "**Added**"
      echo -e "$added"
    fi
    if [[ -n "$modified" ]]; then
      echo "**Modified**"
      echo -e "$modified"
    fi
    if [[ -n "$deleted" ]]; then
      echo "**Deleted**"
      echo -e "$deleted"
    fi

    if [[ "$MAX_FILES" -gt 0 && "$total" -gt "$MAX_FILES" ]]; then
      local remaining=$((total - MAX_FILES))
      echo "... and $remaining more file(s)"
      echo ""
    fi
  fi

  # Testing notes
  if [[ "$FORMAT" == "full" && "$NO_TESTING" == "false" ]]; then
    echo "## Testing Notes"
    echo ""
    local has_tests=false has_config=false has_api=false
    if echo "$DIFF_FILES" | grep -qiE "test|spec"; then
      has_tests=true
    fi
    if echo "$DIFF_FILES" | grep -qiE "config|\.env|\.yaml|\.yml|\.toml"; then
      has_config=true
    fi
    if echo "$DIFF_FILES" | grep -qiE "api|route|endpoint|handler"; then
      has_api=true
    fi

    if $has_tests; then
      echo "- [ ] Updated tests cover the changes"
    else
      echo "- [ ] Add tests for new functionality"
    fi
    if $has_config; then
      echo "- [ ] Verify configuration in staging environment"
    fi
    if $has_api; then
      echo "- [ ] Test affected API endpoints"
    fi
    echo "- [ ] Run full test suite locally"
    echo ""
  fi

  # Review checklist
  if [[ "$FORMAT" == "full" || "$FORMAT" == "checklist" ]] && [[ "$NO_CHECKLIST" == "false" ]]; then
    echo "## Review Checklist"
    echo ""
    echo "- [ ] Code follows project conventions"
    echo "- [ ] Tests pass locally"
    echo "- [ ] No unintended file changes"
    echo "- [ ] Commit messages are clear"
    if [[ "$COMMIT_COUNT" -gt 10 ]]; then
      echo "- [ ] Consider squashing commits before merge"
    fi
    echo ""
  fi
}

# --- Output ---
if [[ -n "$OUTPUT" ]]; then
  build_output > "$OUTPUT"
  echo "PR description written to $OUTPUT"
else
  build_output
fi
