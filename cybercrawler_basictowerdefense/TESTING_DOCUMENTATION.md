# CyberCrawler Testing Documentation

## Overview

This document provides a comprehensive guide to the testing system implemented for the CyberCrawler enhanced tower defense project. The testing framework uses GUT (Godot Unit Test) with advanced code coverage validation and automated CI/CD integration.

## Current Implementation Status

### ✅ COMPLETED SYSTEMS

#### 1. Test Framework Setup
- **GUT Framework**: Fully installed and configured
- **Coverage System**: Advanced code coverage with pre/post-run hooks
- **CI/CD Integration**: GitHub Actions workflow for automated testing
- **Test Structure**: Organized unit, integration, and system test directories

#### 2. Test Coverage (As of Latest Run - Updated July 2025)
- **Total Tests**: 494 tests across 32 test scripts
- **Test Success Rate**: 100% (494/494 passing)
- **Code Coverage**: 77.3% for files with tests (1701/2200 lines)
- **Files with Tests**: 21 out of 23 script files (91.3% coverage)
- **Total Coverage**: 62.1% across all code (1785/2875 lines)

#### 3. Coverage Requirements Met
- **Per-File Coverage**: All tested files meet 50% OR 100 lines minimum (whichever is LESS)
- **Total Coverage**: 75% requirement ACTIVE (91.3% of files have tests, above 90% threshold)
- **Validation**: Automated coverage validation prevents merging insufficiently tested code

## Test Structure

### Directory Organization
```
cybercrawler_basictowerdefense/
├── tests/
│   ├── unit/                    # ✅ 20 unit test files (429 tests)
│   │   ├── test_clickable.gd           # 13 tests - Clickable interface
│   │   ├── test_coverage_debug.gd      # 1 test - Coverage debugging
│   │   ├── test_currency_manager.gd    # 17 tests - Currency system
│   │   ├── test_debug_logger.gd        # 13 tests - Debug logging system
│   │   ├── test_enemy.gd               # 20 tests - Enemy behavior
│   │   ├── test_enemy_tower.gd         # 29 tests - Enemy tower logic
│   │   ├── test_freeze_mine.gd         # 21 tests - Freeze mine mechanics
│   │   ├── test_freeze_mine_manager.gd # 18 tests - Freeze mine management
│   │   ├── test_game_manager.gd        # 21 tests - Core game logic
│   │   ├── test_grid_layout.gd         # 22 tests - Grid path generation
│   │   ├── test_grid_manager.gd        # 21 tests - Grid management system
│   │   ├── test_powerful_tower.gd      # 15 tests - Powerful tower behavior
│   │   ├── test_priority_queue.gd      # 13 tests - Priority queue utility
│   │   ├── test_program_data_packet.gd # 29 tests - Program packet mechanics
│   │   ├── test_program_data_packet_manager.gd # 22 tests - Packet management
│   │   ├── test_projectile.gd          # 9 tests - Projectile behavior
│   │   ├── test_rival_hacker.gd        # 29 tests - Rival hacker AI
│   │   ├── test_targeting_util.gd      # 19 tests - Targeting algorithms
│   │   ├── test_tower.gd               # 26 tests - Base tower functionality
│   │   ├── test_tower_manager.gd       # 24 tests - Tower placement logic
│   │   └── test_wave_manager.gd        # 25 tests - Wave management
│   ├── integration/             # ✅ 11 integration test files (26 tests)
│   │   ├── test_combat_system_integration.gd # 6 tests - Combat system integration
│   │   ├── test_currency_flow.gd             # 5 tests - Currency flow integration
│   │   ├── test_enemy_movement.gd            # 6 tests - Enemy movement integration
│   │   ├── test_freeze_mine_integration.gd   # 5 tests - Freeze mine integration
│   │   ├── test_game_initialization.gd       # 5 tests - Game initialization
│   │   ├── test_grid_management_integration.gd # 6 tests - Grid management integration
│   │   ├── test_program_packet_integration.gd # 4 tests - Program packet integration
│   │   ├── test_rival_hacker_integration.gd  # 5 tests - Rival hacker integration
│   │   ├── test_tower_placement.gd           # 9 tests - Tower placement integration
│   │   └── test_wave_management.gd           # 4 tests - Wave management integration
│   ├── system/                  # ⏳ Empty (future system tests)
│   ├── pre_run_hook.gd          # ✅ Coverage initialization
│   └── post_run_hook.gd         # ✅ Coverage validation
├── .gutconfig.json              # ✅ GUT configuration
└── .github/workflows/tests.yml  # ✅ CI/CD workflow
```

### Test Categories

#### Unit Tests (455 tests)
- **Core Systems**: GameManager, WaveManager, TowerManager, GridManager
- **Game Entities**: Enemy, Tower, EnemyTower, PowerfulTower
- **Special Mechanics**: FreezeMine, ProgramDataPacket, RivalHacker
- **Utilities**: PriorityQueue, TargetingUtil, Clickable interface, DebugLogger
- **Managers**: CurrencyManager, FreezeMineManager, ProgramDataPacketManager

#### Integration Tests (39 tests)
- **Cross-System Testing**: Tower placement, currency flow, combat system
- **Signal Propagation**: System communication validation
- **Game Scenarios**: Early/mid-game placement testing
- **Mechanic Integration**: Freeze mine, program packet, rival hacker integration

#### System Tests (0 tests)
- **Future Implementation**: End-to-end game scenarios
- **Performance Testing**: Frame rate and memory usage validation

## How to Run Tests

### Command Line (Recommended)
```bash
# Navigate to project directory
cd "C:\Users\rivie\CursorProjects\CyberCrawler_basic_tower_defense_demo\cybercrawler_basictowerdefense"

# Run all unit tests
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/unit/ -gexit

# Run all tests (unit + integration)
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gexit
```

### Godot Editor
1. Open project in Godot Editor
2. Install GUT plugin from AssetLib if not already installed
3. Enable GUT plugin in Project Settings > Plugins
4. Use GUT panel at bottom of editor
5. Set test directories: `tests/unit`, `tests/integration`, `tests/system`
6. Click "Run All" or run specific tests

### CI/CD Pipeline
- **Automatic**: Tests run on every push/PR via GitHub Actions
- **Manual**: Can be triggered manually in GitHub repository
- **Results**: Available in GitHub Actions tab and as artifacts

## Code Coverage System

### Coverage Requirements
- **Per-File Coverage**: If it has a test, then 50% of file OR 100 lines minimum, whichever is LESS
- **Total Coverage**: 75% across ALL files required when 90% of files have tests
- **Validation**: Automated validation prevents merging insufficiently tested code

### Coverage Validation Process
1. **Pre-Run Hook**: Initializes coverage instrumentation
2. **Test Execution**: Collects coverage data during test runs
3. **Post-Run Hook**: Validates coverage requirements and fails tests if insufficient


## Test Implementation Details

### Test Patterns Used
- **before_each()**: Fresh setup for each test
- **add_child_autofree()**: Automatic cleanup of test objects
- **watch_signals()**: Signal emission testing
- **Mock Objects**: Isolated testing of individual components
- **Edge Case Testing**: Boundary conditions and error scenarios

### Key Test Features
- **Isolation**: Each test runs independently
- **Comprehensive Coverage**: Tests both success and failure paths
- **Real Integration**: Tests actual system interactions
- **Performance**: Fast execution (0.792s for 455 tests)
- **Reliability**: 100% pass rate with proper error handling

### Test Quality Metrics
- **Test Count**: 494 tests across 32 scripts
- **Assert Count**: 1708 assertions
- **Execution Time**: 0.847 seconds
- **Success Rate**: 100% (494/494 passing)
- **Coverage**: 77.3% for tested files

## Testing Strategy VERY IMPORTANT MUST FOLLOW THIS PLAN
- **Read the Files**: Make sure to read the file to be tested and dependencies it has to understand what you need to do
- **Read the Docs**: Make sure to read the GUT documentation to understand any limitations there may be to what we need to test
- **Create a plan**: Create a plan of how to write the tests properly
- **Write the Tests**: Actually write the tests, but only after you have done the previous steps!!!
  - AND ONLY DO ONE AT A TIME TEST IT AFTER TO MAKE SURE IT WORKS BEFORE JUST MOVING ON TO DO ANOTHER TEST!!!

## Testing Plan

### Phase 1: Core Systems ✅ COMPLETED
- [x] GameManager - Core game logic and state management
- [x] WaveManager - Enemy spawning and wave progression
- [x] TowerManager - Tower placement and management
- [x] CurrencyManager - Economic system and purchasing
- [x] GridManager - Grid management and pathfinding

### Phase 2: Game Entities ✅ COMPLETED
- [x] Enemy - Enemy behavior and pathfinding
- [x] Tower - Base tower functionality
- [x] EnemyTower - Enemy tower mechanics
- [x] PowerfulTower - Enhanced tower behavior
- [x] ProgramDataPacket - Core win condition mechanic

### Phase 3: Special Mechanics ✅ COMPLETED
- [x] FreezeMine - Special weapon system
- [x] RivalHacker - AI opponent behavior
- [x] Projectile - Combat mechanics
- [x] TargetingUtil - AI targeting algorithms

### Phase 4: Integration Testing ✅ COMPLETED
- [x] Tower Placement Integration - Cross-system workflow testing
- [x] Currency Flow Integration - Economic system integration
- [x] Combat System Integration - Combat mechanics integration
- [x] Freeze Mine Integration - Special weapon integration
- [x] Program Packet Integration - Win condition integration
- [x] Rival Hacker Integration - AI opponent integration
- [x] Enemy Movement Integration - Movement system integration
- [x] Grid Management Integration - Grid system integration
- [x] Wave Management Integration - Wave system integration
- [x] Game Initialization Integration - System startup integration

### Phase 5: System Testing ⏳ PLANNED
- [ ] End-to-End Game Scenarios
- [ ] Performance Benchmarking
- [ ] Memory Usage Testing
- [ ] Stress Testing

### Phase 6: Remaining Coverage ⏳ PLANNED
- [ ] MainController.gd (270 lines) - Main game controller
- [ ] RivalAlertSystem.gd (222 lines) - AI alert system
- [ ] RivalHackerManager.gd (453 lines) - AI management

## Benefits Achieved

### 🛡️ Regression Prevention
- **Automated Testing**: 455 tests catch breaking changes
- **Coverage Validation**: Prevents merging insufficiently tested code
- **CI/CD Integration**: Tests run on every commit automatically

### 🐛 Bug Prevention
- **Comprehensive Coverage**: 83.2% coverage of tested files
- **Edge Case Testing**: Boundary conditions and error scenarios
- **Integration Testing**: Cross-system interaction validation

### 📚 Living Documentation
- **Behavior Specification**: Tests document expected behavior
- **Usage Examples**: Tests show how to use classes
- **API Contract**: Tests enforce interface consistency

### 🔄 Development Workflow
- **Fast Feedback**: 0.792s execution time for 455 tests
- **Confidence**: 100% pass rate enables safe refactoring
- **Quality Gates**: Automated validation prevents quality regression

## IMPORTANT: Coverage and Test Execution Guidance

### GUT Coverage and Test Validation: Editor vs Command Line

**Code coverage and coverage validation will NOT work reliably when running GUT from the Godot editor.**

- The Godot editor (and the GUT plugin) may preload scripts before the pre-run hook runs, which prevents the coverage system from instrumenting scripts. This results in 0% coverage for most or all files, even if tests pass.
- This is a known limitation of Godot and GUT. See the [GUT documentation](https://gut.readthedocs.io/en/v9.4.0/Quick-Start.html) for more details. (I can't find it myself yet, looking for it but seems to be legit)

**To get accurate coverage and enforce coverage requirements, ALWAYS run tests from the command line:**

```powershell
cd "C:\Users\rivie\CursorProjects\CyberCrawler_basic_tower_defense_demo\cybercrawler_basictowerdefense";
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/unit/ -gexit
```

- This ensures the pre-run hook instruments all scripts before any are loaded, so coverage is tracked correctly.
- The CI pipeline is configured to use this command for all automated test and coverage validation.

### Running Tests in the Editor
- You can run tests in the Godot editor for quick feedback, but **ignore the coverage results** shown in the editor.
- Use the command line for any test runs where coverage or coverage validation matters (e.g., before PRs, for CI, for release readiness).

---

## Test Directory Structure (Updated)

Tests are now organized into subdirectories by system/feature for clarity and maintainability. This applies to both unit and integration tests.

```
cybercrawler_basictowerdefense/
  tests/
    unit/
      Enemy/
        test_enemy.gd
      Tower/
        test_tower.gd
        test_tower_manager.gd
        ...
      ...
    integration/
      Combat/
        test_combat_system_integration.gd
      Currency/
        test_currency_flow.gd
      ...
```

- **All test discovery and coverage validation scripts have been updated to support this structure.**
- You can add new test files in the appropriate subdirectory for the system or feature being tested.

---

## CI and Coverage Validation

- The CI workflow runs all tests and coverage validation from the command line, ensuring accurate results and enforcing coverage requirements.
- If coverage or tests fail, CI will fail the build.
- Do not rely on coverage results from the Godot editor or GUT panel for PRs or releases.

---

## Troubleshooting: Coverage Issues

- **If you see 0% coverage for all files in the editor, but correct coverage from the command line, this is expected.**
- If you see coverage issues from the command line, check that:
  - You are running the correct command (see above).
  - No scripts are being loaded before the pre-run hook (avoid autoloads that reference scripts under test).
  - The test directory structure matches the organization described above.

---

## Summary of Recent Refactoring

- **Tests are now organized into subdirectories by system/feature.**
- **Coverage hooks and validation scripts have been updated to support recursive test discovery.**
- **CI is configured to use the command line for all test and coverage validation.**
- **Coverage is only accurate when running from the command line.**

---

## Success Metrics

### Current Achievements
- **Test Coverage**: 494 tests with 100% pass rate
- **Code Coverage**: 77.3% for tested files
- **Execution Speed**: 0.847s for 494 tests
- **Quality**: 1708 assertions across all tests
- **Reliability**: Zero test failures in latest run

### Quality Indicators
- **Regression Prevention**: Automated testing catches breaking changes
- **Development Confidence**: Safe refactoring with comprehensive tests
- **Code Quality**: High coverage indicates well-tested code
- **Maintainability**: Living documentation through tests

---

**Status**: Comprehensive testing system fully operational
**Last Updated**: July 2025 - Based on latest test run results
**Next Actions**: Implement system tests and complete remaining file coverage 