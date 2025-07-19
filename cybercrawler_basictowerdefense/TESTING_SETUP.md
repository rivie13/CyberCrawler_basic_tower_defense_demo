# GUT Testing Setup Guide

## Overview
This guide will help you set up GUT (Godot Unit Test) framework for the CyberCrawler project to prevent regression bugs and ensure feature reliability.

## Step 1: Install GUT through Godot Asset Library

1. Open Godot editor with your CyberCrawler project
2. Click on "AssetLib" tab at the top of the screen
3. Search for "GUT - Godot Unit Testing" or "GUT - Godot Unit Testing (Godot 4)"
4. Click "Download" and then "Install"
5. When prompted, install to the default location (addons/gut)

## Step 2: Enable GUT Plugin

1. Go to Project → Project Settings
2. Click on the "Plugins" tab
3. Find "Gut" in the list
4. Check the "Enable" checkbox
5. You should see a new "GUT" panel appear at the bottom of the editor

## Step 3: Configure Test Directories

1. In the GUT panel, scroll down to "Test Directories"
2. Set the following directories:
   - tests/unit (for unit tests)
   - tests/integration (for integration tests)
   - tests/system (for system tests)

## Step 4: Test Structure

### Directory Structure
```
cybercrawler_basictowerdefense/
├── tests/
│   ├── unit/
│   │   ├── test_game_manager.gd
│   │   ├── test_tower_manager.gd
│   │   ├── test_currency_manager.gd
│   │   └── test_wave_manager.gd
│   ├── integration/
│   │   ├── test_tower_placement.gd
│   │   ├── test_wave_progression.gd
│   │   └── test_game_flow.gd
│   └── system/
│       ├── test_full_game_scenarios.gd
│       └── test_performance.gd
├── addons/
│   └── gut/
└── scripts/
```

### Test File Naming Convention
- Test files must begin with `test_`
- Test methods must begin with `test_`
- All test scripts must extend `GutTest`

## Step 5: Writing Your First Test

Create a simple test file to verify the setup:

```gdscript
# tests/unit/test_example.gd
extends GutTest

func test_passes():
    # This test should pass
    assert_eq(1, 1, "One should equal one")

func test_game_manager_exists():
    # Test that we can reference our GameManager
    var game_manager = GameManager.new()
    assert_not_null(game_manager, "GameManager should be instantiable")
```

## Step 6: Running Tests

1. In the GUT panel, click "Run All" to run all tests
2. Or click specific test files/methods to run individual tests
3. Results will appear in the GUT panel

## Benefits of This Setup

1. **Regression Prevention**: Tests catch when changes break existing functionality
2. **Confidence**: You can refactor knowing tests will catch issues
3. **Documentation**: Tests serve as living documentation of expected behavior
4. **Debugging**: Tests help isolate issues to specific components

## Next Steps

After setup, we'll create comprehensive tests for:
- GameManager (health, victory conditions, timers)
- TowerManager (placement, validation, tower types)
- CurrencyManager (spending, earning, validation)
- WaveManager (enemy spawning, wave progression)
- Integration tests for gameplay flows

## Tips

- Run tests frequently during development
- Write tests for bug fixes to prevent regressions
- Use descriptive test names that explain what's being tested
- Test edge cases and error conditions
- Mock dependencies to isolate units under test 


USE THIS COMMAND
first:
cd C:\Users\rivie\CursorProjects\CyberCrawler_basic_tower_defense_demo\cybercrawler_basictowerdefense

second:
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/unit/ -gexit


USE THE ABOVE COMMAND IT WORKS!!!!!!!!!!!!!!!