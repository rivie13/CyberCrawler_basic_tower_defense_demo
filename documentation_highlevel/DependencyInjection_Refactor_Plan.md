# CyberCrawler Dependency Injection & Interface-Driven Refactor Plan

## 1. Why Dependency Injection?

- **Testability:** Easily inject mocks/fakes for unit tests.
- **Loose Coupling:** Classes depend on abstractions, not concrete implementations.
- **Flexibility:** Swap out systems (e.g., AI, grid, currency) without rewriting core logic.
- **Maintainability:** Isolate changes and reduce ripple effects across the codebase.

---

## 2. General Approach

### a. Define Interfaces for All Major Systems
- Use `class_name` in GDScript to define interfaces (abstract base classes).
- Example: `GridManagerInterface`, `TowerManagerInterface`, `CurrencyManagerInterface`, etc.

### b. Make Concrete Classes Implement Interfaces
- All system managers (e.g., `GridManager`, `TowerManager`) should extend their respective interfaces.

### c. Inject Dependencies
- Pass dependencies via `initialize()` methods or exported properties, **never** instantiate them directly inside the class.
- Example:
  ```gdscript
  var grid_manager: GridManagerInterface
  func initialize(_grid_manager: GridManagerInterface, ...):
      grid_manager = _grid_manager
  ```

### d. Use Mocks in Tests
- Create mock classes that implement the interfaces for use in unit tests.
- Example:
  ```gdscript
  class MockGridManager:
      extends GridManagerInterface
      func is_valid_grid_position(pos): return true
      # ...etc
  ```

---

## 3. Current State Analysis

### a. What's Already Good
- Some interfaces exist in `scripts/Interfaces/`.
- Some managers already use `initialize()` for dependency injection.

### b. What Needs Refactoring
- **Direct Instantiations:** Any place where a manager or system is created with `.new()` inside another class should be refactored to accept it as a parameter.
- **Hard NodePath Lookups:** Replace `get_node("...")` with dependency injection where possible.
- **Signal Connections:** Prefer connecting signals in the parent or via dependency injection, not in the child's `_ready()` unless the dependency is injected.
- **Static Typing:** Use interface types for properties/parameters, not concrete classes.
- **Test Doubles:** Ensure all tests use mocks/fakes, not real implementations, for dependencies.

---

## 4. Refactoring Checklist

### a. For Each Major System:
- [ ] Create an interface in `scripts/Interfaces/` if not present.
- [ ] Make the real implementation extend the interface.
- [ ] Update all usages to accept the interface, not the concrete class.
- [ ] Remove all `.new()` calls for dependencies inside classes.
- [ ] Update `initialize()` methods to require all dependencies.
- [ ] Update scene instantiation to inject dependencies at runtime.

### b. For All Tests:
- [ ] Create mock classes for each interface.
- [ ] Inject mocks into the class under test.
- [ ] Remove any attempts to override methods on Godot built-ins (see [GUT docs](https://gut.readthedocs.io/en/v9.4.0/_sources/Double-Strategy.md.txt)).

---

## 5. Example: Refactoring RivalHackerManager

**Before:**
```gdscript
var grid_manager: GridManager
func initialize(grid_mgr: GridManager, ...):
    grid_manager = grid_mgr
```

**After:**
```gdscript
var grid_manager: GridManagerInterface
func initialize(grid_mgr: GridManagerInterface, ...):
    grid_manager = grid_mgr
```

**In Test:**
```gdscript
class MockGridManager:
    extends GridManagerInterface
    func is_valid_grid_position(pos): return true
    # etc.

var mock_grid_manager = MockGridManager.new()
rival_hacker_manager.initialize(mock_grid_manager, ...)
```

---

## 6. Scene Organization & OOP Best Practices

- **Loose Coupling:** Avoid hard dependencies between scenes/scripts. Use signals, interfaces, and dependency injection.
- **Single Responsibility:** Each class/scene should do one thing well.
- **No Direct NodePath Lookups:** Use dependency injection or groups for dynamic lookups.
- **Signal-Driven Communication:** Use signals for event-driven behavior, not for direct control.

---

## 7. What to Audit in Your Codebase

- [ ] **All manager classes:** Are dependencies injected, or are they created internally?
- [ ] **All usages of `.new()`:** Are you creating dependencies, or should they be injected?
- [ ] **All signal connections:** Are they made in the right place (parent or via DI)?
- [ ] **All tests:** Are you using mocks/fakes, or real implementations?
- [ ] **All interface usage:** Are you using interface types for properties/parameters?

---

## 8. Next Steps

1. **Inventory all major systems** (Grid, Tower, Currency, Wave, Enemy, Rival, etc.).
2. **List which have interfaces and which need them.**
3. **Plan the refactor:**  
   - Update interfaces and implementations.
   - Refactor constructors/initializers.
   - Update all usages and tests.
4. **Document the new architecture** in your project's docs for future contributors.

---

## 9. References

- [Godot Best Practices: Scene Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
- [Godot Interfaces](https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_interfaces.html)
- [GUT Doubles & Testing](https://gut.readthedocs.io/en/v9.4.0/_sources/Double-Strategy.md.txt)

---

## 10. Codebase Audit Results

### Current Interface Status

| System/Manager         | Has Interface? | Interface Type | Needs Refactor? | Priority | Notes |
|------------------------|:--------------:|:---------------:|:---------------:|:--------:|-------|
| **Clickable**          | ✅ Yes         | Utility Class   | ❌ No           | -        | Static utility, well-designed |
| **TargetingUtil**      | ✅ Yes         | Utility Class   | ❌ No           | -        | Static utility, well-designed |
| **CurrencyManager**    | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to CurrencyManagerInterface |
| **FreezeMineManager**  | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to MineManagerInterface (generic) |
| **TowerManager**       | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to TowerManagerInterface |
| **GridManager**        | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ GridManagerInterface created and implemented |
| **WaveManager**        | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to WaveManagerInterface |
| **GameManager**        | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to GameManagerInterface |
| **RivalHackerManager** | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to RivalHackerManagerInterface |
| **ProgramDataPacketManager** | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to ProgramDataPacketManagerInterface |
| **MainController**     | ✅ Yes         | Interface       | ✅ COMPLETED    | -        | ✅ Refactored to use dependency injection |

### Dependency Injection Analysis

#### ✅ **Good Practices Found:**
- **Initialize() methods:** Most managers use `initialize()` for dependency injection
- **Signal-based communication:** Good use of signals between systems
- **Separation of concerns:** Clear boundaries between different managers
- **CurrencyManager refactored:** ✅ Successfully implemented interface pattern
- **FreezeMineManager refactored:** ✅ Successfully implemented generic mine interface pattern
- **TowerManager refactored:** ✅ Successfully implemented interface pattern
- **GridManagerInterface implemented:** ✅ Interface created and implemented in actual GridManager
- **WaveManager refactored:** ✅ Successfully implemented interface pattern
- **RivalHackerManager refactored:** ✅ Successfully implemented interface pattern
- **ProgramDataPacketManager refactored:** ✅ Successfully implemented interface pattern

#### ❌ **Issues Found:**
- **Direct instantiation in MainController:** All managers created with `.new()` in `setup_managers()`
- **GameManager refactored:** ✅ Successfully implemented interface pattern
- **MainController refactored:** ✅ Successfully implemented dependency injection pattern
- **Test coverage at 74.4%:** Slightly below target of 75%

### Specific Refactoring Needs

#### **HIGH PRIORITY - Core Systems:**
1. **All Core Systems** → ✅ COMPLETED
   - **Status:** ✅ All major systems now use dependency injection

#### **COMPLETED SYSTEMS:**
- ✅ **GridManager** → `GridManagerInterface` ✅ COMPLETED
- ✅ **TowerManager** → `TowerManagerInterface` ✅ COMPLETED  
- ✅ **WaveManager** → `WaveManagerInterface` ✅ COMPLETED
- ✅ **RivalHackerManager** → `RivalHackerManagerInterface` ✅ COMPLETED
- ✅ **ProgramDataPacketManager** → `ProgramDataPacketManagerInterface` ✅ COMPLETED
- ✅ **CurrencyManager** → `CurrencyManagerInterface` ✅ COMPLETED
- ✅ **FreezeMineManager** → `MineManagerInterface` ✅ COMPLETED
- ✅ **GameManager** → `GameManagerInterface` ✅ COMPLETED
- ✅ **MainController** → Dependency Injection ✅ COMPLETED

### MainController Refactoring Plan

**Current Issues:**
```gdscript
# Current - Direct instantiation
func setup_managers():
    grid_manager = GridManager.new()
    wave_manager = WaveManager.new() as WaveManagerInterface
    tower_manager = TowerManager.new()
    # ... etc
```

**Target - Dependency Injection:**
```gdscript
# Target - Accept interfaces
func initialize(grid_mgr: GridManagerInterface, wave_mgr: WaveManagerInterface, 
                tower_mgr: TowerManagerInterface, currency_mgr: CurrencyManagerInterface,
                game_mgr: GameManagerInterface, rival_mgr: RivalHackerManagerInterface,
                packet_mgr: ProgramDataPacketManagerInterface, mine_mgr: MineManagerInterface):
    grid_manager = grid_mgr
    wave_manager = wave_mgr
    tower_manager = tower_mgr
    # ... etc
```

### Testing Impact

**Current Test Status:**
- ✅ All interface tests passing
- ✅ Mock implementations working correctly
- ✅ Systems can be tested in isolation
- ❌ Test coverage at 74.4% (target: 75%)
- ❌ One failing test in WaveManager (path-related)

**After Refactoring:**
- Can create `MockGameManager` that implements `GameManagerInterface`
- Can test MainController with all mocked dependencies
- Full control over test scenarios
- Better test coverage potential

---

## 11. Action Items

- [x] **CurrencyManager refactored** - ✅ COMPLETED
- [x] **FreezeMineManager refactored** - ✅ COMPLETED
- [x] **TowerManager refactored** - ✅ COMPLETED
- [x] **GridManagerInterface created and implemented** - ✅ COMPLETED
- [x] **ProgramDataPacketManager refactored** - ✅ COMPLETED
- [x] **WaveManager refactored** - ✅ COMPLETED
- [x] **RivalHackerManager refactored** - ✅ COMPLETED
- [x] **GameManager refactored** - ✅ COMPLETED
- [x] **MainController refactored** - ✅ COMPLETED
- [ ] **Fix failing WaveManager test** - 🚧 MEDIUM PRIORITY
- [ ] **Improve test coverage to 75%** - 🚧 MEDIUM PRIORITY
- [ ] **Update scene instantiation to inject dependencies** - 🚧 LOW PRIORITY

---

## 12. Completed Refactors

### ✅ CurrencyManager Refactor (COMPLETED)
- **Interface Created:** `CurrencyManagerInterface` in `scripts/Interfaces/CurrencyManagerInterface.gd`
- **Implementation Updated:** `CurrencyManager` now extends `CurrencyManagerInterface`
- **Dependencies Updated:** All managers now accept `CurrencyManagerInterface` instead of concrete class
- **Tests Updated:** All tests pass with interface pattern
- **Benefits Achieved:** 
  - Loose coupling between currency system and other managers
  - Easy to mock for testing
  - Clear contract for currency management functionality

### ✅ FreezeMineManager Refactor (COMPLETED)
- **Generic Interface Created:** `MineManagerInterface` in `scripts/Interfaces/MineManagerInterface.gd`
- **Base Class Created:** `Mine` in `scripts/Interfaces/Mine.gd` for all mine types
- **Implementation Updated:** `FreezeMineManager` now extends `MineManagerInterface`
- **FreezeMine Updated:** Now extends generic `Mine` class
- **Dependencies Updated:** MainController now accepts `MineManagerInterface`
- **Tests Updated:** All tests pass with generic interface pattern
- **Benefits Achieved:**
  - **Open/Closed Principle:** Easy to add new mine types (explosive, EMP, etc.)
  - **Generic design:** One interface handles all mine types
  - **Loose coupling:** Mine system decoupled from specific implementations
  - **Future-proof:** Can easily add `ExplosiveMine`, `EMPMine`, etc. without changing interface

### ✅ TowerManager Refactor (COMPLETED)
- **Interface Created:** `TowerManagerInterface` in `scripts/Interfaces/TowerManagerInterface.gd`
- **Implementation Updated:** `TowerManager` now extends `TowerManagerInterface`
- **Dependencies Updated:** 
  - `RivalHackerManager` now accepts `TowerManagerInterface` instead of concrete class
  - `GameManager` now accepts `TowerManagerInterface` instead of generic `Node`
  - `MainController` now accepts `TowerManagerInterface` instead of concrete class
- **Tests Updated:** 
  - `MockTowerManager` in `test_targeting_util.gd` now implements `TowerManagerInterface`
  - All tests pass with interface pattern
- **Benefits Achieved:**
  - **Loose coupling:** Tower management system decoupled from specific implementations
  - **Easy mocking:** Can create mock tower managers for testing other systems
  - **Clear contract:** Interface defines all tower management functionality
  - **Strategic flexibility:** AI systems can work with any tower manager implementation

### ✅ GridManagerInterface Implementation (COMPLETED)
- **Interface Testing:** Created comprehensive test suite for `GridManagerInterface` in `tests/unit/Interfaces/test_grid_manager_interface.gd`
- **Implementation Updated:** `GridManager` now extends `GridManagerInterface`
- **Mock Implementation:** Used existing `MockGridManager` from `tests/unit/Mocks/MockGridManager.gd` that properly implements the interface
- **Test Coverage:** All interface methods tested including path management, grid occupation, coordinate conversion, and blocking
- **Fixed Risky Test:** Resolved `test_path_positions` risky test by ensuring proper mock implementation and assertions
- **Benefits Achieved:**
  - **Interface validation:** Ensures GridManagerInterface contract is properly defined and testable
  - **Mock reliability:** Confirms MockGridManager works correctly for dependency injection testing
  - **Test quality:** All tests now have proper assertions and pass consistently
  - **Foundation ready:** GridManagerInterface is fully implemented and tested

### ✅ ProgramDataPacketManager Refactor (COMPLETED)
- **Interface Created:** `ProgramDataPacketManagerInterface` in `scripts/Interfaces/ProgramDataPacketManagerInterface.gd`
- **Implementation Updated:** `ProgramDataPacketManager` now extends `ProgramDataPacketManagerInterface`
- **Dependencies Updated:** 
  - `MainController` now accepts `ProgramDataPacketManagerInterface` instead of concrete class
  - All tests updated to use interface type
- **Mock Created:** `MockProgramDataPacketManager` in `tests/unit/Mocks/MockProgramDataPacketManager.gd` for testing other systems
- **Benefits Achieved:**
  - **Loose coupling:** Program data packet system decoupled from specific implementations
  - **Easy mocking:** Can create mock packet managers for testing other systems
  - **Clear contract:** Interface defines all packet management functionality
  - **Strategic flexibility:** AI systems can work with any packet manager implementation

### ✅ WaveManager Refactor (COMPLETED)
- **Interface Created:** `WaveManagerInterface` in `scripts/Interfaces/WaveManagerInterface.gd`
- **Implementation Updated:** `WaveManager` now extends `WaveManagerInterface`
- **Dependencies Updated:** 
  - `MainController` now accepts `WaveManagerInterface` instead of concrete class
  - `ProgramDataPacketManager` now accepts `WaveManagerInterface` instead of generic `Node`
  - All tests updated to use interface type
- **Mock Created:** `MockWaveManager` in `tests/unit/Mocks/MockWaveManager.gd` for testing other systems
- **Benefits Achieved:**
  - **Loose coupling:** Wave management system decoupled from specific implementations
  - **Easy mocking:** Can create mock wave managers for testing other systems
  - **Clear contract:** Interface defines all wave management functionality
  - **Strategic flexibility:** AI systems can work with any wave manager implementation

### ✅ RivalHackerManager Refactor (COMPLETED)
- **Interface Created:** `RivalHackerManagerInterface` in `scripts/Interfaces/RivalHackerManagerInterface.gd`
- **Implementation Updated:** `RivalHackerManager` now extends `RivalHackerManagerInterface`
- **Dependencies Updated:** 
  - `MainController` now accepts `RivalHackerManagerInterface` instead of concrete class
  - All tests updated to use interface type
- **Mock Created:** `MockRivalHackerManager` in `tests/unit/Mocks/MockRivalHackerManager.gd` for testing other systems
- **Benefits Achieved:**
  - **Loose coupling:** Rival hacker AI system decoupled from specific implementations
  - **Easy mocking:** Can create mock rival hacker managers for testing other systems
  - **Clear contract:** Interface defines all rival hacker AI functionality
  - **Strategic flexibility:** Game systems can work with any rival hacker AI implementation

### ✅ GameManager Refactor (COMPLETED)
- **Interface Created:** `GameManagerInterface` in `scripts/Interfaces/GameManagerInterface.gd`
- **Implementation Updated:** `GameManager` now extends `GameManagerInterface`
- **Dependencies Updated:** 
  - `GridManager` now accepts `GameManagerInterface` instead of concrete class
  - `ProgramDataPacketManager` now accepts `GameManagerInterface` instead of generic `Node`
  - `MainController` now accepts `GameManagerInterface` instead of concrete class
  - All tests updated to use interface type
- **Mock Created:** `MockGameManager` in `tests/unit/Mocks/MockGameManager.gd` for testing other systems
- **Interface Testing:** Created comprehensive test suite for `GameManagerInterface` in `tests/unit/Interfaces/test_game_manager_interface.gd`
- **Benefits Achieved:**
  - **Loose coupling:** Game state management system decoupled from specific implementations
  - **Easy mocking:** Can create mock game managers for testing other systems
  - **Clear contract:** Interface defines all game state management functionality
  - **Strategic flexibility:** Game systems can work with any game manager implementation
  - **Complete DI refactor:** All major systems now use interfaces for dependency injection

### ✅ MainController Refactor (COMPLETED)
- **Dependency Injection Implemented:** `initialize()` method accepts all managers as parameters
- **Backwards Compatibility Maintained:** Still works without injected dependencies via `setup_managers()`
- **Signal Connections Preserved:** All signal connections work with both real and mocked dependencies
- **Mock Created:** `MockMainController` in `tests/unit/Mocks/MockMainController.gd` for testing other systems
- **Testing Updated:** Created comprehensive test suite for dependency injection in `tests/unit/MainController/test_main_controller_dependency_injection.gd`
- **Benefits Achieved:**
  - **Loose coupling:** MainController no longer creates its own dependencies
  - **Easy testing:** Can inject mocked dependencies for isolated testing
  - **Flexible architecture:** Can swap out any manager implementation without changing MainController
  - **Clear separation:** Dependencies are explicitly declared and injected
  - **Production ready:** Maintains backwards compatibility for existing scene usage

---

## 13. Next Steps - IMMEDIATE PRIORITIES

### ✅ **COMPLETED: MainController Refactor**
1. **✅ Constructor approach changed:** Now accepts all managers as parameters via `initialize()`
2. **✅ Backwards compatibility maintained:** Still works without injected dependencies
3. **✅ Tests updated:** MainController tests use mocked dependencies
4. **✅ Loose coupling achieved:** No direct `.new()` calls for dependencies in production code

### 🚧 **MEDIUM: Fix Test Issues**
1. **Make sure tests use mocks!!!!** must go through and make sure all tests use mocks. no exceptions.
2. make sure tests are comprehensive
3. follow coverage rules
4. exclude appropriate files from coverage (interface files)



### 🚧 **LOW: Scene Integration**
1. **Update scene files:** Modify how MainController is instantiated to inject dependencies
2. **Document new patterns:** Update project documentation for future contributors 