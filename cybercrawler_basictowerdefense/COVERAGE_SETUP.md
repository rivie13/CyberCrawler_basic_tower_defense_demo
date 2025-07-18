# Code Coverage Validation System

This project includes a **smart** code coverage validation system that only validates files that actually have tests, ensuring tests are actually covering the code before allowing them to pass.

## How It Works

### Smart Coverage Requirements
- **Total Coverage**: 75% minimum (ONLY when 90% of code has tests)
- **Per-File Coverage**: 50% minimum (ONLY for files that have tests)
- **Minimum Lines**: 100 lines must be covered (ONLY in tested files)
- **Test Coverage Threshold**: 90% of code must have tests before requiring 75% total coverage

### Key Features
- **Files without tests are IGNORED** in validation
- **75% total coverage requirement is WAIVED** until 90% of code has tests
- **Only validates files that actually have corresponding test files**
- **Detailed failure reporting** shows exactly which files failed and why
- **Comprehensive GUT run summary** always shows coverage details (even when tests pass)
- **Single file coverage failures** will cause test failures if a file has tests but doesn't meet 50% coverage

### Coverage Hooks

#### 1. `coverage_hook_combined.gd` (Default - WITH Smart Validation)
- **Pre-run**: Initializes coverage instrumentation
- **Post-run**: Smart validation that only checks files with tests
- **GUT Summary**: Always shows comprehensive coverage information
- **Usage**: Set in `.gutconfig.json` (currently active)

#### 2. `coverage_hook_simple.gd` (Simple - NO Validation)
- **Pre-run**: Initializes coverage instrumentation  
- **Post-run**: Displays comprehensive coverage report only (no validation)
- **GUT Summary**: Always shows comprehensive coverage information
- **Usage**: Change `.gutconfig.json` to use this instead

## Configuration

### Enable Smart Coverage Validation (Current)
```json
{
  "pre_run_script": "res://tests/coverage_hook_combined.gd",
  "post_run_script": "res://tests/coverage_hook_combined.gd"
}
```

### Disable Coverage Validation (Simple Mode)
```json
{
  "pre_run_script": "res://tests/coverage_hook_simple.gd", 
  "post_run_script": "res://tests/coverage_hook_simple.gd"
}
```

### Disable Coverage Entirely
Remove the `pre_run_script` and `post_run_script` lines from `.gutconfig.json`

## Coverage Targets

You can adjust the coverage requirements in `coverage_hook_combined.gd`:

```gdscript
const COVERAGE_TARGET_TOTAL := 75.0    # 75% total coverage required (only when 90% of code has tests)
const COVERAGE_TARGET_FILE := 50.0     # 50% per-file coverage required (only for files with tests)
const MIN_LINES_COVERED := 100         # Minimum lines that must be covered (only in tested files)
const TEST_COVERAGE_THRESHOLD := 90.0  # Only require 75% total coverage when 90% of code has tests
```

## What Happens When Coverage is Insufficient

1. **Tests will FAIL** even if all individual tests pass
2. **Detailed error messages** show what coverage requirements weren't met
3. **File-by-file breakdown** shows which tested files need more coverage
4. **Files without tests are listed** but not counted in validation
5. **Test run exits with failure code** (useful for CI/CD)

## GUT Run Summary Information

**Both hooks now provide comprehensive coverage information in the GUT run summary:**

### Always Shown (Even When Tests Pass):
- **Overall Coverage**: Total percentage and line counts
- **Test Coverage**: Percentage of code that has tests
- **Files with Tests**: Individual file coverage with ✅/❌ indicators
- **Files without Tests**: List of files ignored in validation
- **Validation Status**: Pass/fail with detailed reasons

### Example GUT Summary Output:

```
=== CODE COVERAGE SUMMARY ===
📊 Overall Coverage: 45.2% (67/148 lines)
📋 Test Coverage: 40.0% of code has tests (8/20 files)

📁 Files with Tests (Coverage):
  ✅ TowerManager.gd (75.0%)
  ❌ Enemy.gd (12.5%)
  ✅ GameManager.gd (85.2%)

🚫 Files without Tests (ignored in validation):
  - WaveManager.gd
  - CurrencyManager.gd
  - GridManager.gd
  - RivalHacker.gd

✅ COVERAGE VALIDATION PASSED!
ℹ️ Total coverage requirement waived (need 90.0% test coverage for 75.0% total requirement)
```

## Example Output

### Coverage Passes
```
✅ COVERAGE VALIDATION PASSED!
📊 Coverage: 78.5% (1250/1590 lines)
📋 Test coverage: 85.2% of code has tests

=== CODE COVERAGE SUMMARY ===
📊 Overall Coverage: 78.5% (1250/1590 lines)
📋 Test Coverage: 85.2% of code has tests (17/20 files)

📁 Files with Tests (Coverage):
  ✅ TowerManager.gd (85.0%)
  ✅ Enemy.gd (75.0%)
  ✅ GameManager.gd (90.0%)

🚫 Files without Tests (ignored in validation):
  - WaveManager.gd
  - CurrencyManager.gd
  - GridManager.gd

✅ COVERAGE VALIDATION PASSED!
```

### Coverage Fails
```
❌ COVERAGE VALIDATION FAILED!
  - Files with tests below 50.0% coverage: TowerManager.gd (12.5%), Enemy.gd (0.0%)
  - Only 67 lines covered in tested files, minimum required: 100

=== CODE COVERAGE SUMMARY ===
📊 Overall Coverage: 45.2% (67/148 lines)
📋 Test Coverage: 40.0% of code has tests (8/20 files)

📁 Files with Tests (Coverage):
  ❌ TowerManager.gd (12.5%)
  ❌ Enemy.gd (0.0%)
  ✅ GameManager.gd (85.2%)

🚫 Files without Tests (ignored in validation):
  - WaveManager.gd
  - CurrencyManager.gd
  - GridManager.gd
  - RivalHacker.gd

❌ COVERAGE VALIDATION FAILED!
  - Files with tests below 50.0% coverage: TowerManager.gd (12.5%), Enemy.gd (0.0%)
  - Only 67 lines covered in tested files, minimum required: 100

🚫 TESTS FAILED: Coverage requirements not met
```

### Total Coverage Requirement Waived
```
ℹ️ Total coverage requirement waived (only 45.2% of code has tests, need 90.0%)
✅ COVERAGE VALIDATION PASSED!
📊 Coverage: 45.2% (67/148 lines)
📋 Test coverage: 45.2% of code has tests

=== CODE COVERAGE SUMMARY ===
📊 Overall Coverage: 45.2% (67/148 lines)
📋 Test Coverage: 45.2% of code has tests (9/20 files)

📁 Files with Tests (Coverage):
  ✅ TowerManager.gd (75.0%)
  ✅ Enemy.gd (60.0%)
  ✅ GameManager.gd (85.2%)

🚫 Files without Tests (ignored in validation):
  - WaveManager.gd
  - CurrencyManager.gd
  - GridManager.gd
  - RivalHacker.gd

✅ COVERAGE VALIDATION PASSED!
ℹ️ Total coverage requirement waived (need 90.0% test coverage for 75.0% total requirement)
```

## How Files Are Detected

The system automatically detects which files have tests by looking for:
- `res://tests/unit/test_[filename].gd`
- `res://tests/integration/test_[filename].gd`

For example:
- `res://scripts/TowerManager.gd` → looks for `res://tests/unit/test_TowerManager.gd` or `res://tests/integration/test_TowerManager.gd`
- If test file exists → file is validated
- If no test file exists → file is ignored in validation

## Excluded Paths

The following paths are excluded from coverage analysis:
- `res://addons/*` - GUT and coverage addons
- `res://tests/*` - Test scripts themselves
- `res://scenes/*` - Scene files
- `res://tools/*` - Utility tools

## Running Tests

### In Godot Editor
1. Open the GUT panel
2. Run tests normally
3. Check the GUT run summary for comprehensive coverage information

### Command Line
```bash
# Run with coverage validation
godot --headless --script addons/gut/gut_cmdln.gd -gprint_to_console -gexit

# Run specific test directory
godot --headless --script addons/gut/gut_cmdln.gd -gdir=tests/unit -gprint_to_console -gexit
```

## Troubleshooting

### "No coverage instance found"
- Make sure the coverage hook is properly set in `.gutconfig.json`
- Check that the hook script path is correct

### Tests failing due to coverage
- Write more tests to cover uncovered code in tested files
- Lower coverage targets temporarily if needed
- Use `coverage_hook_simple.gd` to disable validation

### Files without tests being validated
- The system should automatically ignore files without tests
- Check that test files follow the naming convention: `test_[filename].gd`
- Verify test files are in `res://tests/unit/` or `res://tests/integration/`

### Coverage showing 0%
- Check that scripts are in the `res://scripts/` directory
- Verify excluded paths aren't too broad
- Ensure coverage instrumentation is running

### Single file coverage failures
- If a file has tests but doesn't meet 50% coverage, tests will fail
- This ensures that when you write tests for a file, they actually cover the code
- Add more test cases to improve coverage for that specific file

## Benefits of Smart Validation

1. **No false failures** from files without tests
2. **Gradual adoption** - you can add tests incrementally
3. **Clear feedback** on what needs testing
4. **Realistic requirements** that scale with your test coverage
5. **Detailed reporting** shows exactly what's missing
6. **Always visible coverage** in GUT run summary
7. **Single file validation** ensures test quality when tests exist 