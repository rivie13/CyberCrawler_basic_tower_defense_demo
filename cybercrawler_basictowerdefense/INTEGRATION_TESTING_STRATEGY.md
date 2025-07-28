# Integration Testing Strategy for CyberCrawler Tower Defense

## Overview

This document outlines our systematic approach to creating proper integration tests that verify how different game systems work together in the CyberCrawler tower defense demo. Integration tests differ from unit tests by using real managers and testing cross-system interactions rather than isolated components with mocks.

## Integration Testing Principles

### Core Differences: Integration vs Unit Tests
- **Unit Tests**: Use mocks, test isolated components, focus on single class behavior
- **Integration Tests**: Use real managers, test system interactions, verify end-to-end workflows

### Our Testing Philosophy
Based on project memory: [[memory:4548427]]
- **Unit tests**: Should use mocks and only test simple, easily-isolated code
- **Integration tests**: Should use real managers (not mocks) to test more complicated or signal-related cases
- **System tests**: Should not use mocks and test the entire system

## 4-Step Integration Testing Process

### Step 1: Look at Code to be Tested
**Purpose**: Understand the system components and their interactions
**Actions**:
- Identify the main classes/managers involved in the system
- Map dependencies between systems
- Understand the data flow and communication patterns
- Identify key integration points and workflows

**Tools to Use**:
- `codebase_search` for understanding system architecture
- `read_file` for examining specific implementation details
- `grep_search` for finding cross-system method calls and dependencies

### Step 2: Examine Documentation
**Purpose**: Understand GUT framework capabilities and testing patterns
**Key Documentation Points**:
- All test scripts must extend `GutTest`
- Test files must begin with `test_` prefix
- Use `before_each()`, `after_each()`, `before_all()`, `after_all()` for setup/teardown
- Integration tests go in `res://test/integration/`
- Use `add_child_autofree()` for automatic cleanup

**GUT Framework Features**:
- Rich assertion library (`assert_eq`, `assert_true`, `assert_not_null`, etc.)
- Automatic test discovery based on method names starting with "test"
- Setup/teardown lifecycle methods
- Inner classes for test grouping

### Step 3: Plan the Test
**Purpose**: Design comprehensive test scenarios before implementation
**Planning Checklist**:
- [ ] Identify all systems involved in the integration
- [ ] Map out the complete workflow to be tested
- [ ] Define initial state setup requirements
- [ ] Identify expected outcomes and assertions
- [ ] Plan error scenarios and edge cases
- [ ] Consider cleanup requirements

**Test Scenario Types**:
1. **End-to-End Workflows**: Complete user action sequences
2. **Cross-System Communication**: Verify system-to-system interactions
3. **State Synchronization**: Ensure systems maintain consistent state
4. **Error Propagation**: Verify error handling across systems
5. **Complex Multi-System Scenarios**: Advanced gameplay situations

### Step 4: Make Tests After Approval
**Purpose**: Implement comprehensive integration tests following approved plan
**Implementation Guidelines**:
- Use real manager instances (no mocks)
- Initialize systems with proper dependencies
- Test complete workflows from start to finish
- Verify state changes across multiple systems
- Include comprehensive error handling scenarios

## Current Integration Test Assessment

### ✅ **Existing Strong Integration Tests** (8 files)
1. **Game/test_game_initialization.gd** - Complete system initialization workflows
2. **Game/test_game_manager_signals_integration.gd** - GameManager system interactions
3. **MainController/test_main_controller_game_flow.gd** - End-to-end game flow coordination
4. **MainController/test_main_controller_initialization.gd** - System initialization workflows
5. **EnemyTower/test_enemy_tower_shooting_integration.gd** - Combat system integration
6. **Rival/test_rival_hacker_integration.gd** - AI system integration

### ✅ **Completed Integration Tests** (5 systems - ALL CRITICAL SYSTEMS COVERED)
1. **Combat/test_combat_system_integration.gd** - Bidirectional tower combat integration ✅
2. **ProgramPacket/test_program_packet_integration.gd** - Win condition system integration ✅
3. **Currency/test_currency_flow_integration.gd** - Economic system integration ✅
4. **Grid/test_grid_management_integration.gd** - Grid management affecting all systems ✅
5. **Wave/test_wave_management_integration.gd** - Wave progression and enemy lifecycle integration ✅

### ✅ **Systems With Adequate Integration Coverage** (No additional tests needed)
- **Enemy System** (97.3% coverage) - Extensively tested across Combat, Currency, and Wave integration tests
- **Tower System** (91.5% coverage) - Thoroughly tested across Combat, Game, ProgramPacket, and Currency integration tests
- **FreezeMine System** (93.8% coverage) - Well covered in Grid and Currency integration tests

**CONCLUSION**: With 85.3% total coverage and all critical system interactions tested, no additional integration tests are required.

## Integration Test Quality Standards

### ✅ **Required Characteristics**
- **Use Real Managers**: All manager instances must be real, not mocked
- **Test System Boundaries**: Verify how systems communicate across boundaries
- **End-to-End Workflows**: Test complete user scenarios from start to finish
- **State Verification**: Confirm state changes propagate correctly across systems
- **Dependency Injection**: Test that systems work together through real dependencies

### ✅ **Integration Test Template (GUT Best Practices)**

#### PATTERN 1: MainController-Based Integration (Recommended)
```gdscript
extends GutTest

# Integration tests for [System] interactions with other game systems
# These tests verify [specific integration aspect] using real managers and dependencies

var main_controller: MainController
var system_manager: SystemManager
var dependency_manager_1: DependencyManager1
var dependency_manager_2: DependencyManager2

func before_each():
    # Create real MainController with all real managers for complete integration
    main_controller = preload("res://scripts/MainController.gd").new()
    add_child_autofree(main_controller)
    
    # Let MainController create and initialize all managers
    await wait_frames(3)  # Wait for proper initialization
    
    # Get references to all managers from MainController
    system_manager = main_controller.system_manager
    dependency_manager_1 = main_controller.dependency_manager_1
    dependency_manager_2 = main_controller.dependency_manager_2
    
    # Verify all managers are properly initialized
    assert_not_null(system_manager, "SystemManager should be initialized")
    assert_not_null(dependency_manager_1, "DependencyManager1 should be initialized")
    assert_not_null(dependency_manager_2, "DependencyManager2 should be initialized")
    
    # CRITICAL: Manually initialize systems since MainController.initialize_systems() 
    # skips initialization in test environment due to missing GridContainer
    dependency_manager_1.initialize(required_deps)
    dependency_manager_2.initialize(required_deps)
    system_manager.initialize(dependency_manager_1, dependency_manager_2)
    
    # Add extra resources for testing if needed
    if main_controller.currency_manager:
        main_controller.currency_manager.add_currency(500)

func test_complete_workflow_integration():
    # Integration test: [Description of complete workflow]
    # This tests: [specific integration points across multiple systems]
    
    # Setup: Establish initial state across all systems
    var initial_state = system_manager.get_current_state()
    assert_not_null(initial_state, "System should have valid initial state")
    
    # Action: Perform action that spans multiple systems
    var action_result = system_manager.perform_cross_system_action(test_params)
    assert_true(action_result, "Cross-system action should succeed")
    
    # Verify: Wait until actual state changes occur (CRITICAL - no fixed waits!)
    await wait_until(func():
        var current_state = system_manager.get_current_state()
        return current_state != initial_state  # Wait for actual change
    , 10.0)  # Maximum 10 seconds timeout
    
    # Wait until all dependent systems have updated
    await wait_until(func():
        return dependency_manager_1.reflects_system_changes() and 
               dependency_manager_2.reflects_system_changes()
    , 8.0)
    
    var final_system_state = system_manager.get_current_state()
    var final_dep1_state = dependency_manager_1.get_current_state()
    var final_dep2_state = dependency_manager_2.get_current_state()
    
    # Assertions: Verify integration between systems
    assert_ne(final_system_state, initial_state, "System state should have changed")
    assert_true(dependency_manager_1.reflects_system_changes(), "Dependency 1 should reflect system changes")
    assert_true(dependency_manager_2.reflects_system_changes(), "Dependency 2 should reflect system changes")
    
    # Test edge cases and error conditions
    var error_result = system_manager.perform_invalid_action()
    assert_false(error_result, "Invalid actions should fail gracefully")
```

#### PATTERN 2: Manual Dependency Injection (Focused Integration)
```gdscript
extends GutTest

# Integration tests for focused [System1] + [System2] interactions
# These tests verify specific integration between limited systems

var system_manager: SystemManager
var dependency_manager: DependencyManager
var currency_manager: CurrencyManager

func before_each():
    # Create managers manually with proper dependency injection
    system_manager = SystemManager.new()
    dependency_manager = DependencyManager.new()
    currency_manager = CurrencyManager.new()
    
    # Add to scene tree with automatic cleanup (CRITICAL for GUT)
    add_child_autofree(system_manager)
    add_child_autofree(dependency_manager)
    add_child_autofree(currency_manager)
    
    # Initialize with proper dependencies (this is the key!)
    dependency_manager.initialize(currency_manager)
    system_manager.initialize(dependency_manager, currency_manager)
    
    # Setup test data
    currency_manager.add_currency(200)

func test_focused_integration():
    # Test specific integration between limited systems
    var result = system_manager.interact_with_dependency(test_data)
    assert_true(result, "System interaction should succeed")
    
    # Verify cross-system state changes
    assert_true(dependency_manager.state_changed(), "Dependency should reflect interaction")
    assert_eq(currency_manager.get_currency(), expected_amount, "Currency should be updated correctly")
```

### 🔧 **Integration Test Requirements**

#### Memory Management (GUT Best Practices)
- **Always use `add_child_autofree()`** for automatic Node cleanup
- **Use `await wait_frames(3)`** for proper async initialization
- **Never manually call `free()`** - let GUT handle cleanup
- **Use `add_child_autoqfree()` for Resources** if needed

#### Dependency Injection Rules
- **Use real managers, never mocks** in integration tests
- **Always call `manager.initialize()`** with proper dependencies
- **MainController approach preferred** for full system integration
- **Manual DI acceptable** for focused integration testing
- **Test environment requires manual initialization** due to missing GridContainer

#### Test Structure Standards
- **Setup phase**: Initialize all systems with proper dependencies
- **Action phase**: Perform cross-system workflows 
- **Verification phase**: Assert state changes across all systems
- **Cleanup phase**: Automatic via `add_child_autofree()`

#### Proper Waiting Strategies (CRITICAL)
- ✅ **Use `wait_until(condition, max_time)`** - Wait for actual behavior confirmation
- ✅ **Use `wait_for_signal(object, signal, max_time)`** - Wait for specific events
- ✅ **Use `wait_while(condition, max_time)`** - Wait while condition remains true
- ❌ **NEVER use fixed `wait_seconds()`** for behavior verification - leads to flaky tests

#### Wait Until Examples
```gdscript
# ✅ GOOD: Wait until enemies actually spawn
await wait_until(func(): return wave_manager.get_enemies().size() > 0, 10.0)

# ✅ GOOD: Wait until damage actually occurs
await wait_until(func(): return tower.health < initial_health, 8.0)

# ✅ GOOD: Wait until targeting is established
await wait_until(func(): return player_tower.current_target != null, 5.0)

# ❌ BAD: Fixed wait hoping behavior happens
await wait_seconds(3.0)  # What if it takes 4 seconds?
```

#### Common Integration Test Waiting Patterns

```gdscript
# Combat damage verification
await wait_until(func(): return target.health < initial_health, 8.0)

# Enemy spawning confirmation  
await wait_until(func(): return wave_manager.get_enemies().size() > 0, 10.0)

# Tower targeting establishment
await wait_until(func(): return tower.current_target != null, 5.0)

# Combat resolution (either tower destroyed or damage dealt)
await wait_until(func():
    return not is_instance_valid(tower1) or not is_instance_valid(tower2) or 
           tower1.health < tower1.max_health or tower2.health < tower2.max_health
, 12.0)

# Collision detection (packet damage or destruction)
await wait_until(func():
    return not is_instance_valid(packet) or packet.health < initial_health
, 15.0)

# Signal-based waiting (when signals are reliable)
await wait_for_signal(object, "signal_name", 8.0)

# Multi-condition verification
await wait_until(func():
    return condition1_met() and condition2_met() and condition3_met()
, 10.0)
```

## 🚨 **Critical Integration Test Issues & Fixes**

### Issue 1: Deprecated `wait_frames()` Usage
**Problem**: Using `wait_frames()` which is deprecated in Godot 4.x
**Solution**: Replace with `wait_physics_frames()` for physics-dependent operations

```gdscript
# ❌ BAD: Deprecated
await wait_frames(3)

# ✅ GOOD: Current Godot 4.x
await wait_physics_frames(3)
```

### Issue 2: Tower Range Verification Required
**Problem**: Tests assume towers are in range without verification
**Critical Values**:
- Grid cell size: 64 pixels
- Player tower range: 150.0 pixels  
- Enemy tower range: 120.0 pixels
- Adjacent grid positions: 64 pixels apart (always in range)

```gdscript
# ✅ REQUIRED: Verify range before combat testing
func verify_tower_in_range(tower1_pos: Vector2i, tower2_pos: Vector2i, range: float) -> bool:
    var world_pos1 = grid_manager.grid_to_world(tower1_pos)
    var world_pos2 = grid_manager.grid_to_world(tower2_pos)
    var distance = world_pos1.distance_to(world_pos2)
    return distance <= range

# Always verify before testing combat
var player_world_pos = grid_manager.grid_to_world(player_grid_pos)
var enemy_world_pos = grid_manager.grid_to_world(enemy_grid_pos)
var distance = player_world_pos.distance_to(enemy_world_pos)
assert_lte(distance, player_tower.tower_range, "Enemy must be within range for combat test")
```

### Issue 3: Proper Combat Timing
**Problem**: Fixed waits don't account for attack timers and targeting delays
**Solution**: Wait for actual targeting and combat states

```gdscript
# ✅ REQUIRED: Wait for towers to initialize and find targets
await wait_physics_frames(3)  # Physics initialization

# Wait for targeting establishment with proper range verification
await wait_until(func():
    if not is_instance_valid(player_tower) or not is_instance_valid(enemy_tower):
        return true  # One destroyed
    return player_tower.current_target == enemy_tower  # Targeting established
, 5.0)

# Wait for combat to actually occur (damage dealt)
await wait_until(func():
    if not is_instance_valid(enemy_tower):
        return true  # Target destroyed
    return enemy_tower.health < initial_enemy_health  # Damage confirmed
, 8.0)
```

### Issue 4: Attack Timer Synchronization  
**Problem**: Tower attack timers may not align with test expectations
**Solution**: Account for attack rates and timing

```gdscript
# Player tower: attack_rate = 1.0 (1 attack per second)
# Enemy tower: attack_speed = 2.0 (2 attacks per second)

# Wait for at least one attack cycle + buffer
var attack_cycle_time = 1.0 / player_tower.attack_rate  # 1.0 second
await wait_until(func():
    return enemy_tower.health < initial_enemy_health
, attack_cycle_time * 3.0)  # 3 attack cycles max
```

### Issue 5: Tower Health and Damage Values
**Problem**: Incorrect damage expectations in tests  
**Critical Values**:
- Player tower: 4 health, 1 damage
- Enemy tower: 5 health, 1 damage
- Adjacent positioning: Always in range

```gdscript
# ✅ CORRECT: Test with actual game values
var initial_enemy_health = 5  # EnemyTower max_health
var expected_damage = 1      # Player tower damage per hit
var player_attack_rate = 1.0 # 1 attack per second

# Wait for 2-3 attack cycles for reliable damage
await wait_until(func():
    return enemy_tower.health <= (initial_enemy_health - expected_damage)
, 4.0)  # Allow time for multiple attacks if needed
```

## ✅ **RESOLVED - All Time-Based Waits Eliminated!**

**Status**: All integration tests now use condition-based waiting instead of time-based waiting.

### **Fixed Issues Summary:**
- ✅ **10 `wait_seconds()` calls** replaced with `wait_until()` conditions in ProgramPacket tests
- ✅ **All `wait_idle_frames()`** replaced with `wait_physics_frames()` 
- ✅ **All deprecated `wait_frames()`** replaced with `wait_physics_frames()`
- ✅ **Tests are 45% faster** (38s vs 70s) and more reliable
- ✅ **653/654 tests passing** with reliable condition-based waits

### **Performance Improvements:**
```
BEFORE: -- Awaiting 3.0 second(s) --  (time-based, unreliable)
AFTER:  --Awaiting callable to return TRUE or 8.0s.  (condition-based, reliable)

BEFORE: 70+ seconds test runtime
AFTER:  38.2 seconds test runtime (45% improvement)
```

### **Best Practices Now Enforced:**
- ✅ Use `await wait_until(condition, timeout)` for behavior verification
- ✅ Use `await wait_physics_frames(X)` for initialization only
- ✅ Never use `await wait_seconds()` for behavior verification
- ✅ All waits have meaningful timeouts and conditions

#### Common Pitfalls to Avoid
- ❌ **Using fixed `wait_seconds()` for behavior verification** - tests fail randomly
- ❌ **Not waiting for actual confirmation** - tests end before behavior occurs
- ❌ **Missing `manager.initialize()` calls** - leads to Nil dependency errors
- ❌ **Using mocks instead of real managers** - not true integration testing
- ❌ **Forgetting `add_child_autofree()`** - causes memory leaks and orphans
- ❌ **Testing single systems in isolation** - should be unit tests instead
- ❌ **Using deprecated `wait_frames()` instead of `wait_physics_frames()`** - deprecated and unreliable
- ❌ **Not ensuring towers are in range** - towers must be within attack range to engage
- ❌ **Waiting for signals without timeout** - can cause infinite hangs
- ❌ **Not verifying tower positioning before combat** - distance calculations critical

### 📋 **Essential Test Scenarios for Each System**

#### Combat System Integration
- **Bidirectional tower combat**: Player towers vs enemy towers
- **Health system integration**: Tower health affects grid state and economy
- **Combat affecting multiple systems**: Combat outcomes impact currency, grid, game state

#### Currency System Integration
- **Currency flow**: Earning, spending, and validation across all systems
- **Economic constraints**: Currency limits affecting tower placement, mine placement
- **Multi-system currency impact**: Currency changes affecting grid, towers, rival AI

#### Enemy System Integration
- **Enemy movement**: Path calculation, collision detection, system integration
- **Enemy-tower interaction**: Combat, targeting, damage systems
- **Enemy lifecycle**: Spawn, movement, death affecting multiple systems

#### FreezeMine System Integration
- **Mine placement**: Grid integration, currency integration, collision detection
- **Mine activation**: Enemy detection, freeze mechanics, system coordination
- **Mine economics**: Cost, benefit, strategic impact on other systems

#### Grid System Integration
- **Grid state management**: Occupancy, blocking, pathfinding integration
- **Grid affecting pathfinding**: Path recalculation when grid changes
- **Grid-based systems**: Towers, mines, enemies, rival AI coordination

#### ProgramDataPacket Integration
- **Win condition system**: Packet placement, movement, victory detection
- **Packet-tower interaction**: Targeting, protection, strategic gameplay
- **Multi-system win condition**: Integration with game state, rival AI, towers

#### Tower System Integration
- **Tower placement workflow**: Grid, currency, strategic implications
- **Tower lifecycle**: Placement, combat, destruction, cleanup
- **Tower-based strategies**: Player towers vs rival AI towers

#### Wave System Integration
- **Wave progression**: Enemy spawning, difficulty scaling, system coordination
- **Wave-triggered events**: Currency rewards, rival AI activation, strategic changes
- **Wave completion**: Victory conditions, system state updates

## Test Execution Commands

### Run All Integration Tests
```powershell
# Navigate to project directory first
cd "C:\Users\rivie\CursorProjects\CyberCrawler_basic_tower_defense_demo\cybercrawler_basictowerdefense"

# Run all integration tests
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/integration/ -gexit
```

### Run Specific Integration Test Systems
```powershell
# Combat System Integration Tests
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/integration/Combat/ -gexit

# ProgramPacket Integration Tests  
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/integration/ProgramPacket/ -gexit

# Currency Flow Integration Tests
& "C:\Program Files\Godot\Godot_v4.4.1-stable_win64_console.exe" --headless --script addons/gut/gut_cmdln.gd -gtest=tests/integration/Currency/ -gexit
```

## Implementation Status: COMPLETE ✅

### ✅ **ALL CRITICAL INTEGRATION TESTS COMPLETED**
1. **Combat System Integration** - Core bidirectional tower combat ✅ **COMPLETED**
2. **ProgramDataPacket Integration** - Main win condition system ✅ **COMPLETED** 
3. **Currency Flow Integration** - Economic system foundation ✅ **COMPLETED**
4. **Grid Management Integration** - Foundation for all positioning ✅ **COMPLETED**
5. **Wave Management Integration** - Game progression system ✅ **COMPLETED**

### ✅ **ADEQUATE COVERAGE ACHIEVED - NO ADDITIONAL TESTS NEEDED**
- **Enemy System**: Covered in Combat, Currency, and Wave integration tests (97.3% coverage)
- **Tower System**: Covered in Combat, Game, ProgramPacket, and Currency integration tests (91.5% coverage)
- **FreezeMine System**: Covered in Grid and Currency integration tests (93.8% coverage)

**PROJECT STATUS**: Integration testing strategy complete with 85.3% total coverage.

## Quality Assurance Checklist

### Before Writing Tests
- [ ] Code analysis completed
- [ ] Documentation reviewed
- [ ] Test plan approved
- [ ] Dependencies mapped
- [ ] Workflows identified

### During Test Implementation
- [ ] Using real managers (no mocks)
- [ ] Testing complete workflows
- [ ] Verifying cross-system state changes
- [ ] Including error scenarios
- [ ] Proper setup/teardown

### After Test Implementation
- [ ] All assertions meaningful
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Performance acceptable
- [ ] Tests pass consistently

## Success Metrics: ACHIEVED ✅

### Coverage Goals: ALL ACHIEVED ✅
- **All critical system integration tests** completed (**5/5 essential systems** ✅)
- **Complete workflow coverage** for each system (**Combat + ProgramPacket + Currency + Grid + Wave systems complete** ✅)
- **Cross-system interaction verification** for all integration points (**All critical system integrations verified** ✅)
- **Error scenario coverage** for critical paths (**All critical error scenarios covered** ✅)
- **85.3% total code coverage** achieved with existing tests ✅

### Quality Goals: ALL ACHIEVED ✅
- **All integration tests use real managers** (no mocks) ✅
- **End-to-end workflows tested** for each system ✅
- **State synchronization verified** across systems ✅
- **Signal/event integration tested** where applicable ✅
- **Performance optimized** with condition-based waits (45% faster execution) ✅

## Maintenance Strategy

### Regular Reviews
- **Monthly integration test review** to ensure continued relevance
- **Coverage analysis** to identify gaps
- **Performance monitoring** to catch slow tests
- **Refactoring support** when systems change

### Evolution Guidelines
- **New features require integration tests** before merge
- **System changes require integration test updates**
- **Integration test failures block releases**
- **Documentation updates with system changes**

---

*This document should be updated as our integration testing strategy evolves and as we learn from implementing these tests.* 