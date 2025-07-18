# Code Coverage System

This project includes a comprehensive code coverage system that validates test coverage during the pre-run phase of testing, ensuring quality test coverage before tests even execute.

## How It Works

The coverage system is implemented as a **pre-run hook** that initializes coverage instrumentation and immediately validates coverage requirements. This ensures that coverage issues are caught before any tests run.

### Coverage Requirements
- **Total Coverage**: 75% minimum (ONLY when 90% of code has tests)
- **Per-File Coverage**: 50% of file OR 100 lines minimum, whichever is LESS (ONLY for files that have tests or code execution)
- **Minimum Lines**: For files with tests, must cover 50% of file OR 100 lines, whichever is less
- **Test Coverage Threshold**: 90% of code must have tests before requiring 75% total coverage

### Key Features
- **Pre-run validation** - Coverage is checked before tests execute
- **Smart file detection** - Automatically converts CamelCase to snake_case for test matching
- **Files without tests are tracked** but not validated
- **Immediate failure** - Tests fail immediately if coverage requirements aren't met
- **Detailed reporting** - Shows comprehensive coverage breakdown
- **Flexible validation** - Only validates files with tests OR code execution
- **Scaled requirements** - For files with tests: 50% coverage OR 100 lines minimum, whichever is LESS

## Current Implementation

### Single Hook File: `pre_run_hook.gd`
The entire coverage system is implemented in a single file:
- **Initialization**: Creates coverage instance and instruments scripts
- **Validation**: Immediately checks coverage requirements
- **Reporting**: Shows detailed coverage breakdown
- **Failure Handling**: Fails tests immediately if requirements aren't met

### Configuration in `.gutconfig.json`
```json
{
  "pre_run_script": "res://tests/pre_run_hook.gd",
  "post_run_script": ""
}
```

## Coverage Targets

You can adjust the coverage requirements in `tests/pre_run_hook.gd`:

```gdscript
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage required (only when 90% of code has tests)
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage required (only for files with tests)
const MIN_LINES_COVERED := 100         # Minimum lines that must be covered (only in tested files)
const TEST_COVERAGE_THRESHOLD := 90.0  # Only require 75% total coverage when 90% of code has tests

# FOR FILES WITH TESTS: MUST COVER 50% OR 100 LINES MINIMUM, WHICHEVER IS LESS
# Examples:
#   - 80 line file: need 40 lines covered (50% of 80 = 40, which is less than 100)
#   - 300 line file: need 100 lines covered (100 is less than 50% of 300 = 150)
```

## What Happens During Test Runs

### 1. Pre-Run Phase
1. **Coverage Initialization**: Creates coverage instance using `addons/coverage/coverage.gd`
2. **Script Instrumentation**: Instruments all scripts in `res://scripts/`
3. **File Detection**: Automatically detects which files have corresponding test files
4. **Immediate Validation**: Checks coverage requirements before any tests run
5. **Failure Handling**: If coverage is insufficient, tests fail immediately with detailed error messages

### 2. Test Phase
- If coverage validation passes, tests proceed normally
- If coverage validation fails, tests never run and the process exits with failure

## File Detection Logic

The system automatically detects test files using smart naming conventions:

### CamelCase to Snake_Case Conversion
- `GameManager.gd` → looks for `test_game_manager.gd`
- `TowerManager.gd` → looks for `test_tower_manager.gd`
- `RivalHacker.gd` → looks for `test_rival_hacker.gd`

### Test File Locations
The system looks for test files in:
- `res://tests/unit/test_[snake_case_name].gd`
- `res://tests/integration/test_[snake_case_name].gd`

## Coverage Validation Rules

### Files That Are Validated
- **Files with tests**: Any file that has a corresponding test file
- **Files with code execution**: Any file that has coverage > 0% (code actually ran)

### Files That Are Ignored
- **Files without tests**: No corresponding test file found
- **Files with no execution**: No code ran during tests (0% coverage)

### Validation Requirements
- **Per-file**: 50% of file OR 100 lines minimum, whichever is LESS (for validated files only)
- **Total coverage**: 75% required only when 90% of code has tests
- **Examples**:
  - 80-line file: needs 40 lines covered (50% of 80 = 40, less than 100)
  - 300-line file: needs 100 lines covered (100 is less than 50% of 300 = 150)
  - 200-line file: needs 100 lines covered (50% of 200 = 100, same as minimum)

## Example Output

### Coverage Validation Passes
```
🔥 PRE-RUN HOOK IS RUNNING! 🔥
=== Initializing Code Coverage ===
✓ Coverage instrumentation complete
✓ Monitoring coverage for: res://scripts/
✓ Coverage targets: 75.0% total, 50.0% per file

=== IMMEDIATE COVERAGE VALIDATION ===
--- Test Coverage Analysis ---
Files with tests: 3
Files without tests: 8 (IGNORED)

--- Coverage Results (VALIDATED FILES) ---
Coverage in validated files: 78.5% (156/198 lines)

📁 Files Being Validated (✅=meets coverage, 📝=has tests, ❌=fails):
  ✅ 📝 GameManager.gd (85/100 lines, 85.0%, need 50 lines - 50% of 100)
  ✅ 📝 TowerManager.gd (45/60 lines, 75.0%, need 30 lines - 50% of 60)
  ✅ 📝 Enemy.gd (26/38 lines, 68.4%, need 19 lines - 50% of 38)

--- All Files Coverage Breakdown ---
📊 Files with Coverage (3 files):
  ✅ 85.0% GameManager.gd (85/100 lines)
  ✅ 75.0% TowerManager.gd (45/60 lines)
  ✅ 68.4% Enemy.gd (26/38 lines)

📊 Files with No Coverage (8 files):
  ❌ 0.0% WaveManager.gd (45 lines)
  ❌ 0.0% CurrencyManager.gd (32 lines)
  ❌ 0.0% GridManager.gd (67 lines)

✅ COVERAGE VALIDATION PASSED!
✅ All files with tests meet coverage requirements!
=== Coverage Validation Complete ===
```

### Coverage Validation Fails
```
🔥 PRE-RUN HOOK IS RUNNING! 🔥
=== Initializing Code Coverage ===
✓ Coverage instrumentation complete
✓ Monitoring coverage for: res://scripts/
✓ Coverage targets: 75.0% total, 50.0% per file

=== IMMEDIATE COVERAGE VALIDATION ===
--- Test Coverage Analysis ---
Files with tests: 3
Files without tests: 8 (IGNORED)

--- Coverage Results (VALIDATED FILES) ---
Coverage in validated files: 35.2% (67/290 lines)

📁 Files Being Validated (✅=meets coverage, 📝=has tests, ❌=fails):
  ❌ 📝 GameManager.gd (25/100 lines, 25.0%, need 50 lines - 50% of 100)
  ❌ 📝 TowerManager.gd (15/60 lines, 25.0%, need 30 lines - 50% of 60)
  ❌ 📝 RivalHacker.gd (40/300 lines, 13.3%, need 100 lines - min 100 < 50% of 300)
  ✅ 📝 Enemy.gd (27/30 lines, 90.0%, need 15 lines - 50% of 30)

--- All Files Coverage Breakdown ---
📊 Files with Coverage (4 files):
  ❌ 25.0% GameManager.gd (25/100 lines)
  ❌ 25.0% TowerManager.gd (15/60 lines)
  ❌ 13.3% RivalHacker.gd (40/300 lines)
  ✅ 90.0% Enemy.gd (27/30 lines)

❌ COVERAGE VALIDATION FAILED!
  - Files with insufficient coverage: GameManager.gd (25/100 lines, need 25 more) - insufficient coverage, TowerManager.gd (15/60 lines, need 15 more) - insufficient coverage, RivalHacker.gd (40/300 lines, need 60 more) - insufficient coverage

🚫 COVERAGE VALIDATION FAILED: Coverage requirements not met: Files with insufficient coverage: GameManager.gd (25/100 lines, need 25 more) - insufficient coverage, TowerManager.gd (15/60 lines, need 15 more) - insufficient coverage, RivalHacker.gd (40/300 lines, need 60 more) - insufficient coverage
❌ Tests will be FAILED due to insufficient coverage!
🔥 FORCING IMMEDIATE EXIT WITH CODE 1
```

### Total Coverage Requirement Waived
```
--- Test Coverage Analysis ---
Files with tests: 2
Files without tests: 10 (IGNORED)

ℹ️ Total coverage requirement waived (only 16.7% of files have tests, need 90.0%)

✅ COVERAGE VALIDATION PASSED!
✅ All files with tests meet coverage requirements!
```

## Excluded Paths

The following paths are excluded from coverage analysis:
- `res://addons/*` - GUT and coverage addons
- `res://tests/*` - Test scripts themselves
- `res://scenes/*` - Scene files
- `res://tools/*` - Utility tools

## Configuration Options

### Enable Coverage Validation (Current)
```json
{
  "pre_run_script": "res://tests/pre_run_hook.gd",
  "post_run_script": ""
}
```

### Disable Coverage Validation
```json
{
  "pre_run_script": "",
  "post_run_script": ""
}
```

## Running Tests

### In Godot Editor
1. Open the GUT panel
2. Run tests normally
3. Coverage validation happens automatically in the pre-run phase

### Command Line
```bash
# Run with coverage validation
godot --headless --script addons/gut/gut_cmdln.gd -gprint_to_console -gexit

# Run specific test directory
godot --headless --script addons/gut/gut_cmdln.gd -gdir=tests/unit -gprint_to_console -gexit
```

## Troubleshooting

### "Coverage instance is still null"
- Check that the coverage addon is properly installed in `addons/coverage/`
- Verify that the pre-run hook path is correct in `.gutconfig.json`
- Ensure the coverage addon is enabled in project settings

### Tests failing immediately due to coverage
- Check which files are failing coverage requirements
- Write more tests to cover the failing code
- Lower coverage targets temporarily if needed
- Remove the pre-run script to disable coverage validation

### Files not being detected as having tests
- Verify test files follow the naming convention: `test_[snake_case_name].gd`
- Check that test files are in `res://tests/unit/` or `res://tests/integration/`
- Ensure the CamelCase to snake_case conversion is working correctly

### Coverage showing 0% for all files
- Check that scripts are in the `res://scripts/` directory
- Verify tests are actually executing code from the scripts
- Ensure coverage instrumentation is working properly

## Technical Details

### How Coverage Works
1. **Pre-run Hook**: `tests/pre_run_hook.gd` extends `GutHookScript`
2. **Coverage Addon**: Uses `addons/coverage/coverage.gd` for instrumentation
3. **Script Instrumentation**: Automatically instruments all scripts in `res://scripts/`
4. **File Matching**: Smart CamelCase to snake_case conversion for test detection
5. **Immediate Validation**: Checks requirements before tests run
6. **Force Exit**: Uses `get_tree().quit(1)` to ensure proper failure propagation

### Key Classes
- **GutHookScript**: Base class for GUT hooks
- **Coverage**: Main coverage instrumentation class
- **ScriptCoverage**: Individual file coverage tracking

## Benefits of This Approach

1. **Immediate Feedback**: Coverage issues are caught before tests run
2. **No False Positives**: Only validates files that actually have tests
3. **Gradual Adoption**: You can add tests incrementally
4. **Clear Reporting**: Detailed breakdown of what needs testing
5. **Realistic Requirements**: Coverage targets scale with test coverage
6. **Automatic Detection**: Smart file matching reduces configuration
7. **Fail Fast**: Issues are caught early in the testing process 



USE THIS COMMAND
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/unit/ -gexit


USE THE ABOVE COMMAND IT WORKS!!!!!!!!!!!!!!!