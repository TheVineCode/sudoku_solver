#t!/usr/bin/env bash
#
# A guided learning path for building and shipping the Sudoku editor/validator.
# The solver itself is deliberately left as a later milestone.
#
# This wizard never commits, pushes, merges, creates branches, or changes GitHub
# settings. Those are deliberate actions for the project owner to perform.
#
# Everything above the "STAGES" marker is the wizard library: do not hand-edit
# it. Author the per-step stages below the marker.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Wizard library: delightful, consistent UX, identical across every wizard.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

# Author sets this at the top of the stages section.
TOTAL_STAGES=0

_STAGE_INDEX=0
ENV_FILE="${ENV_FILE:-.env}"
WRITTEN_ENV=()    # KEYs written to ENV_FILE this run
WRITTEN_SECRET=() # secret NAMEs set this run
SKIPPED=()        # things we couldn't do (e.g. gh missing)

# _clear wipes the terminal so only the current step is on screen. No-op when
# output isn't a terminal, so piped logs stay readable.
_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

# banner "Title" shows the opening frame: what this wizard does.
banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s stages%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
  printf '%s  You drive the browser; this wizard tells you exactly what to do and\n' "$DIM"
  printf '  captures the values you copy back. Stop any time with Ctrl-C and re-run\n'
  printf '  later, since it remembers values already saved.%s\n' "$RESET"
  pause "Ready to start?"
}

# stage "Name" clears the screen, then announces a stage and shows progress.
# Clearing keeps only the current step on screen.
stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Stage %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

# say "..." prints a plain instruction line.
say()  { printf '  %s\n' "$1"; }
# step "..." is a numbered-feeling action the human takes in the browser.
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

# open_url URL opens it in the human's browser, cross-platform incl. WSL.
open_url() {
  local url="$1"
  printf '  %s↗ opening%s %s\n' "$GREEN" "$RESET" "$url"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else warn "couldn't open a browser; visit it manually: $url"; fi
  } >/dev/null 2>&1 || warn "couldn't open a browser, so visit it manually: $url"
}

# pause "msg" waits for the human to confirm they've done the manual part.
pause() {
  printf '  %s%s%s ' "$DIM" "${1:-Press Enter to continue}" "$RESET"
  read -r _ || true
}

# confirm "question" is a y/N gate; returns success on yes.
confirm() {
  local reply=""
  printf '  %s? %s [y/N] ' "$YELLOW" "$1"
  read -r reply || true
  [[ "$reply" =~ ^[Yy] ]]
}

# _existing KEY: current value of KEY in ENV_FILE, if any.
_existing() {
  [[ -f "$ENV_FILE" ]] || return 1
  local line; line=$(grep -E "^${1}=" "$ENV_FILE" | tail -n1) || return 1
  printf '%s' "${line#*=}"
}

# ask KEY "Prompt" reads a value into $KEY. Offers the existing .env value as
# a default on re-runs (Enter keeps it). Visible input (non-secret).
ask() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter keeps current]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -r input || true
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# ask_secret KEY "Prompt" is like ask, but input is hidden.
ask_secret() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter keeps current]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -rs input || true
  printf '\n'
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

# write_env KEY VALUE upserts KEY=VALUE into ENV_FILE (creates it; replaces
# any existing line). Idempotent.
write_env() {
  local key="$1" value="$2" tmp
  touch "$ENV_FILE"
  tmp=$(mktemp)
  grep -vE "^${key}=" "$ENV_FILE" > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$ENV_FILE"
  WRITTEN_ENV+=("$key")
  printf '  %s✓ wrote%s %s → %s\n' "$GREEN" "$RESET" "$key" "$ENV_FILE"
}

# set_secret NAME VALUE sets a GitHub Actions repo secret via gh. Falls back
# to a warning (and records it) if gh is unavailable or unauthenticated.
set_secret() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if printf '%s' "$value" | gh secret set "$name" >/dev/null 2>&1; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ set%s GitHub secret %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub secret $name (set it manually: gh secret set $name)")
  warn "skipped GitHub secret $name: gh not ready; set it later"
}

# set_var NAME VALUE sets a GitHub Actions repo variable (non-secret).
set_var() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if gh variable set "$name" --body "$value" >/dev/null 2>&1; then
      printf '  %s✓ set%s GitHub variable %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub variable $name")
  warn "skipped GitHub variable $name, gh not ready; set it later"
}

# finish clears, then shows a closing summary of everything configured.
finish() {
  _clear
  printf '\n%s%s  ✓ Setup complete%s\n' "$BOLD" "$GREEN" "$RESET"
  (( ${#WRITTEN_ENV[@]} ))    && note "wrote ${#WRITTEN_ENV[@]} value(s) to $ENV_FILE: ${WRITTEN_ENV[*]}"
  (( ${#WRITTEN_SECRET[@]} )) && note "set ${#WRITTEN_SECRET[@]} GitHub secret(s): ${WRITTEN_SECRET[*]}"
  if (( ${#SKIPPED[@]} )); then
    printf '\n'; warn "still to do by hand:"
    for s in "${SKIPPED[@]}"; do note "  - $s"; done
  fi
  printf '\n'
}

# ──────────────────────────────────────────────────────────────────────────
# STAGES: the learning path. These stages explain changes; they do not make
# code or Git changes on your behalf.
# ──────────────────────────────────────────────────────────────────────────

TOTAL_STAGES=10

banner "Learn and ship Sudoku"

stage "Confirm the first product milestone"
say "The first milestone is an editor and validator, not the solving algorithm."
step "Write down the behavior you intend to keep: a new board is empty; values 1-9 can be entered; duplicate row, column, and block values are rejected; values can be cleared."
step "Decide whether entered puzzle clues will eventually be locked separately from user-entered values. Record that as a later decision if you are unsure."
note "The solver algorithm comes after the board model and validation rules are trustworthy."
pause "When your behavior notes are clear, press Enter"

stage "Prepare a feature branch manually"
say "This wizard will not create branches, commit, push, merge, or change Git settings."
step "Inspect the current state with: git status --short --branch"
step "Create your own branch for the test foundation, for example: git switch -c chore/test-foundation"
step "Keep the branch small and open a PR only after the local checks pass."
pause "After you have created the branch yourself, press Enter"

stage "Add the local test foundation"
say "Run these commands yourself from the repository root:"
step "npm init -y"
step "npm install --save-dev vitest"
step "Add scripts named test = vitest run and test:watch = vitest to package.json."
step "Add type = module to package.json so the testable Sudoku module can use imports and exports."
step "Commit nothing yet. Run npm test once and confirm the test runner starts, even if it reports that no tests exist."
pause "When package.json and the test command work, press Enter"

stage "Write the first failing test"
say "Create tests/sudoku.test.js and make the test describe behavior, not implementation details."
step "Write a test named something like: a new Sudoku board is a 9 by 9 empty board."
step "The test should construct the public Sudoku model and assert nine rows, nine cells per row, and only zero values."
step "Run npm test. The expected result is red because the exported Sudoku module does not exist yet."
note "A deliberate failure proves that the test can detect missing behavior. If it passes immediately, check that the test is actually being discovered."
pause "After you have seen the expected failing test, press Enter"

stage "Make the first slice green"
say "Create src/sudoku.js and move only the board model into it. Keep DOM rendering out of this file."
step "Export a Sudoku class that creates the empty 9 by 9 board in its constructor."
step "Import that class from the test and run npm test until the first test passes."
step "Do not add validation, rendering, or future solver code yet. The smallest green change is the goal."
step "After the test is green, refactor names or structure only if the behavior stays green."
pause "When the first slice is green and readable, press Enter"

stage "Grow validation with red-green-refactor"
say "Add one behavior and one test at a time. Keep Sudoku rules independent from the DOM."
step "Add a public setValue operation that accepts a row, column, and value and reports whether the change was accepted."
step "Test a valid value, then test that a duplicate in the same row is rejected without mutating the cell."
step "Repeat for a column and a 3 by 3 block, using worked board examples as independent expected results."
step "Add a clearValue operation and test that clearing an entered cell restores zero."
step "After the tests pass, remove unused parameters and extract shared uniqueness logic only when duplication is real."
step "Run npm test after every small slice. Do not write the entire test suite before implementing the behavior."
pause "When the model rules are covered and green, press Enter"

stage "Reconnect the browser safely"
say "Now connect the tested model to the browser without moving DOM concerns back into the model."
step "Create a browser entry point that imports the model, renders it, and owns event listeners."
step "Select cells only when the click target is a game block; background clicks must not create NaN row or column state."
step "Use keydown rather than keypress, accept 1-9, and support Backspace or Delete through clearValue."
step "Keep the selected cell in one explicit state value rather than relying on document.querySelector('.active')."
step "Add jsdom-based tests only for important UI seams: selecting a cell, entering a value, rejecting a duplicate, and clearing a value."
step "Run npm test and manually open index.html to verify the browser behavior."
pause "When the tested UI behavior works, press Enter"

stage "Make the board usable on small screens"
say "Fix layout after behavior is stable, so styling changes do not hide logic failures."
step "Use a square board constrained by both viewport width and height instead of width alone."
step "Use repeat(9, 1fr), aspect-ratio, and a font size that can shrink with the board."
step "Check a desktop viewport, a portrait phone viewport, and a landscape phone viewport."
step "Make the selected cell keyboard-accessible or provide an equivalent accessible input path."
step "Record any remaining visual issue as a separate follow-up instead of mixing it into a rules PR."
pause "When the board remains usable in all three viewport shapes, press Enter"

stage "Add formatting and linting"
say "Use automation to catch consistency and common JavaScript mistakes."
step "Run: npm install --save-dev prettier eslint"
step "Add a Prettier configuration and scripts named format and format:check."
step "Add an ESLint configuration appropriate for browser JavaScript modules and scripts named lint and lint:fix."
step "Add a check script that runs format:check, lint, and test in sequence."
step "Run npm run check before opening a PR. Fix the code rather than disabling a rule without understanding it."
pause "When npm run check is green, press Enter"

stage "Add continuous integration manually"
say "Create .github/workflows/quality.yml with a job that runs on pushes and pull requests."
step "Use the repository's Node version, run npm ci, then run npm run check."
step "Run the workflow locally first with npm run check; GitHub Actions should repeat the same authoritative checks."
step "Open the Actions tab after pushing a future branch and confirm the workflow runs for the pull request."
note "The wizard does not create or push the workflow. You create and review those changes yourself."
pause "When the workflow file exists and is locally valid, press Enter"

stage "Create the first PR and protect the workflow"
say "Perform the GitHub actions yourself; this wizard only reminds you of the review sequence."
step "Review git diff and git diff --check before staging anything."
step "Create your commit, push your branch, and open a pull request manually."
step "In the PR, explain the behavior added, tests added, and checks run."
step "Review the diff as if you were a teammate: look for missing tests, accidental scope, and unclear names."
step "After the workflow is reliable, configure branch protection so the quality check is required before merging."
step "Merge only after the checks pass, then delete the branch and start the next small feature branch manually."
pause "When you understand the PR loop, press Enter"

stage "Plan the actual solver as a new milestone"
say "Do not add the solving algorithm until the editor and validator are dependable."
step "Choose the solver contract: given a valid puzzle, return a solved board, no solution, or multiple-solution status."
step "Write worked examples and failing tests for the solver before choosing backtracking or another algorithm."
step "Keep solving separate from rendering so it can be tested with plain JavaScript values."
step "Add performance or puzzle-validity tests only after correctness tests are green."
note "A future solver PR should be independent from the initial test-foundation PR whenever possible."
pause "When the next milestone is written down, press Enter"

finish
