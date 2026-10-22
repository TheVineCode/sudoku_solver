#requires -Version 5.1

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:StageIndex = 0
$script:TotalStages = 10

function Pause-Wizard {
    param(
        [string]$Message = "Press Enter to continue"
    )

    [void](Read-Host "$Message")
}

function Start-Wizard {
    Clear-Host
    Write-Host ""
    Write-Host "  Learn and ship Sudoku" -ForegroundColor Cyan
    Write-Host "  $script:TotalStages stages" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  You drive the editor and GitHub. This wizard explains each step,"
    Write-Host "  waits for your changes, and runs safe checks. It never commits,"
    Write-Host "  pushes, merges, creates branches, or changes Git history." -ForegroundColor DarkGray
    Write-Host ""
    Pause-Wizard "Ready to start?"
}

function Start-Stage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Clear-Host
    $script:StageIndex++
    Write-Host ""
    Write-Host "  Stage $script:StageIndex/$script:TotalStages - $Title" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    Write-Host "  * $Text" -ForegroundColor Blue
}

function Write-Note {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    Write-Host "  $Text" -ForegroundColor DarkGray
}

function Write-WarningNote {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    Write-Host "  WARNING: $Text" -ForegroundColor Yellow
}

function Show-ManualCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    Write-Host "  PS> $Command" -ForegroundColor DarkCyan
}

function Show-ToolVersions {
    $node = Get-Command node -ErrorAction SilentlyContinue
    $npm = Get-Command npm -ErrorAction SilentlyContinue
    $git = Get-Command git -ErrorAction SilentlyContinue

    if ($null -ne $node) {
        Write-Host "  Node: $(& node --version)"
    }
    else {
        Write-WarningNote "Node.js was not found on PATH. Install it before continuing."
    }

    if ($null -ne $npm) {
        Write-Host "  npm:  $(& npm --version)"
    }
    else {
        Write-WarningNote "npm was not found on PATH. It normally comes with Node.js."
    }

    if ($null -ne $git) {
        Write-Host "  Git:  $(& git --version)"
        Write-Host ""
        Write-Host "  Current Git state:" -ForegroundColor DarkGray
        & git status --short --branch
    }
    else {
        Write-WarningNote "Git was not found on PATH."
    }
}

Start-Wizard

Start-Stage "Confirm the first product milestone"
Write-Host "The first milestone is an editor and validator, not the solving algorithm."
Write-Step "Write down the behavior you intend to keep: a new board is empty; values 1-9 can be entered; duplicate row, column, and block values are rejected; values can be cleared."
Write-Step "Decide whether entered puzzle clues will eventually be locked separately from user-entered values. Record that as a later decision if you are unsure."
Write-Note "The solver algorithm comes after the board model and validation rules are trustworthy."
Pause-Wizard "When your behavior notes are clear, press Enter"

Start-Stage "Prepare a feature branch manually"
Write-Host "This wizard will not create branches, commit, push, merge, or change Git settings."
Write-Step "Inspect the current state with: git status --short --branch"
Show-ManualCommand "git switch -c chore/test-foundation"
Write-Step "Keep the branch small and open a PR only after the local checks pass."
Pause-Wizard "After you have created the branch yourself, press Enter"

Start-Stage "Add the local test foundation"
Write-Host "Run these commands yourself from the repository root:"
Show-ManualCommand "npm init -y"
Show-ManualCommand "npm install --save-dev vitest"
Write-Step "Add scripts named test = vitest run and test:watch = vitest to package.json."
Write-Step "Add type = module to package.json so the testable Sudoku module can use imports and exports."
Write-Step "Run npm test once and confirm the test runner starts. With no test files, a no-tests failure is expected at this point."
Pause-Wizard "When package.json and the test command work, press Enter"

Start-Stage "Write the first failing test"
Write-Host "Create tests/sudoku.test.js and make the test describe behavior, not implementation details."
Write-Step "Write a test named something like: a new Sudoku board is a 9 by 9 empty board."
Write-Step "The test should construct the public Sudoku model and assert nine rows, nine cells per row, and only zero values."
Write-Step "Run npm test. The expected result is red because the exported Sudoku module does not exist yet."
Write-Note "A deliberate failure proves that the test can detect missing behavior. If it passes immediately, check that the test is actually being discovered."
Pause-Wizard "After you have seen the expected failing test, press Enter"

Start-Stage "Make the first slice green"
Write-Host "Create src/sudoku.js and move only the board model into it. Keep DOM rendering out of this file."
Write-Step "Export a Sudoku class that creates the empty 9 by 9 board in its constructor."
Write-Step "Import that class from the test and run npm test until the first test passes."
Write-Step "Do not add validation, rendering, or future solver code yet. The smallest green change is the goal."
Write-Step "After the test is green, refactor names or structure only if the behavior stays green."
Pause-Wizard "When the first slice is green and readable, press Enter"

Start-Stage "Grow validation with red-green-refactor"
Write-Host "Add one behavior and one test at a time. Keep Sudoku rules independent from the DOM."
Write-Step "Add a public setValue operation that accepts a row, column, and value and reports whether the change was accepted."
Write-Step "Test a valid value, then test that a duplicate in the same row is rejected without mutating the cell."
Write-Step "Repeat for a column and a 3 by 3 block, using worked board examples as independent expected results."
Write-Step "Add a clearValue operation and test that clearing an entered cell restores zero."
Write-Step "After the tests pass, remove unused parameters and extract shared uniqueness logic only when duplication is real."
Write-Step "Run npm test after every small slice. Do not write the entire test suite before implementing the behavior."
Pause-Wizard "When the model rules are covered and green, press Enter"

Start-Stage "Reconnect the browser safely"
Write-Host "Now connect the tested model to the browser without moving DOM concerns back into the model."
Write-Step "Create a browser entry point that imports the model, renders it, and owns event listeners."
Write-Step "Select cells only when the click target is a game block; background clicks must not create NaN row or column state."
Write-Step "Use keydown rather than keypress, accept 1-9, and support Backspace or Delete through clearValue."
Write-Step "Keep the selected cell in one explicit state value rather than relying on document.querySelector('.active')."
Write-Step "Add jsdom-based tests only for important UI seams: selecting a cell, entering a value, rejecting a duplicate, and clearing a value."
Write-Step "Run npm test and manually open index.html to verify the browser behavior."
Pause-Wizard "When the tested UI behavior works, press Enter"

Start-Stage "Make the board usable on small screens"
Write-Host "Fix layout after behavior is stable, so styling changes do not hide logic failures."
Write-Step "Use a square board constrained by both viewport width and height instead of width alone."
Write-Step "Use repeat(9, 1fr), aspect-ratio, and a font size that can shrink with the board."
Write-Step "Check a desktop viewport, a portrait phone viewport, and a landscape phone viewport."
Write-Step "Make the selected cell keyboard-accessible or provide an equivalent accessible input path."
Write-Step "Record any remaining visual issue as a separate follow-up instead of mixing it into a rules PR."
Pause-Wizard "When the board remains usable in all three viewport shapes, press Enter"

Start-Stage "Add formatting and linting"
Write-Host "Use automation to catch consistency and common JavaScript mistakes."
Show-ManualCommand "npm install --save-dev prettier eslint"
Write-Step "Add a Prettier configuration and scripts named format and format:check."
Write-Step "Add an ESLint configuration appropriate for browser JavaScript modules and scripts named lint and lint:fix."
Write-Step "Add a check script that runs format:check, lint, and test in sequence."
Show-ManualCommand "npm run check"
Write-Step "Fix the code rather than disabling a rule without understanding it."
Pause-Wizard "When npm run check is green, press Enter"

Start-Stage "Add continuous integration manually"
Write-Host "Create .github/workflows/quality.yml with a job that runs on pushes and pull requests."
Write-Step "Use the repository's Node version, run npm ci, then run npm run check."
Write-Step "Run npm run check locally first; GitHub Actions should repeat the same authoritative checks."
Write-Step "Open the Actions tab after pushing a future branch and confirm the workflow runs for the pull request."
Write-Note "The wizard does not create or push the workflow. You create and review those changes yourself."
Pause-Wizard "When the workflow file exists and is locally valid, press Enter"

Start-Stage "Create the first PR and protect the workflow"
Write-Host "Perform the GitHub actions yourself; this wizard only reminds you of the review sequence."
Write-Step "Review git diff and git diff --check before staging anything."
Write-Step "Create your commit, push your branch, and open a pull request manually."
Write-Step "In the PR, explain the behavior added, tests added, and checks run."
Write-Step "Review the diff as if you were a teammate: look for missing tests, accidental scope, and unclear names."
Write-Step "After the workflow is reliable, configure branch protection so the quality check is required before merging."
Write-Step "Merge only after the checks pass, then delete the branch and start the next small feature branch manually."
Pause-Wizard "When you understand the PR loop, press Enter"

Start-Stage "Plan the actual solver as a new milestone"
Write-Host "Do not add the solving algorithm until the editor and validator are dependable."
Write-Step "Choose the solver contract: given a valid puzzle, return a solved board, no solution, or multiple-solution status."
Write-Step "Write worked examples and failing tests for the solver before choosing backtracking or another algorithm."
Write-Step "Keep solving separate from rendering so it can be tested with plain JavaScript values."
Write-Step "Add performance or puzzle-validity tests only after correctness tests are green."
Write-Note "A future solver PR should be independent from the initial test-foundation PR whenever possible."
Pause-Wizard "When the next milestone is written down, press Enter"

Clear-Host
Write-Host ""
Write-Host "  Wizard complete" -ForegroundColor Green
Write-Host "  You now have a staged path from the current browser prototype to a tested editor, CI, PR workflow, and future solver."
Write-Host "  No Git write operation was performed by this script." -ForegroundColor DarkGray
Write-Host ""
