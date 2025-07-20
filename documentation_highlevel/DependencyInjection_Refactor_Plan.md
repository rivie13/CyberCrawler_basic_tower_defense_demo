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
| **GridManager**        | ❌ No          | -               | ✅ Yes          | HIGH     | Core system, needs interface |
| **TowerManager**       | ❌ No          | -               | ✅ Yes          | HIGH     | Core system, needs interface |
| **WaveManager**        | ❌ No          | -               | ✅ Yes          | HIGH     | Core system, needs interface |
| **GameManager**        | ❌ No          | -               | ✅ Yes          | MEDIUM   | Game state, needs interface |
| **RivalHackerManager** | ❌ No          | -               | ✅ Yes          | HIGH     | Complex AI, needs interface |
| **ProgramDataPacketManager** | ❌ No | -               | ✅ Yes          | MEDIUM   | Specialized, needs interface |
| **MainController**     | ❌ No          | -               | ✅ Yes          | HIGH     | Orchestrator, needs DI refactor |

### Dependency Injection Analysis

#### ✅ **Good Practices Found:**
- **Initialize() methods:** Most managers use `initialize()` for dependency injection
- **Signal-based communication:** Good use of signals between systems
- **Separation of concerns:** Clear boundaries between different managers
- **CurrencyManager refactored:** ✅ Successfully implemented interface pattern
- **FreezeMineManager refactored:** ✅ Successfully implemented generic mine interface pattern

#### ❌ **Issues Found:**
- **Direct instantiation in MainController:** All managers created with `.new()` in `setup_managers()`
- **No interface contracts:** Most managers depend on concrete classes, not abstractions
- **Hard coupling:** Systems directly reference each other's concrete types
- **Test difficulties:** Cannot easily mock dependencies for unit testing

### Specific Refactoring Needs

#### **HIGH PRIORITY - Core Systems:**
1. **GridManager** → `GridManagerInterface`
   - Used by: TowerManager, WaveManager, RivalHackerManager, ProgramDataPacketManager
   - Key methods: `is_valid_grid_position()`, `is_grid_occupied()`, `grid_to_world()`, `world_to_grid()`

2. **TowerManager** → `TowerManagerInterface`
   - Used by: RivalHackerManager, GameManager, MainController
   - Key methods: `get_towers()`, `attempt_tower_placement()`, `get_total_power_level()`

3. **WaveManager** → `WaveManagerInterface`
   - Used by: GameManager, ProgramDataPacketManager, MainController
   - Key methods: `get_enemies()`, `start_wave()`, `get_current_wave()`

4. **RivalHackerManager** → `RivalHackerManagerInterface`
   - Used by: MainController, FreezeMine
   - Key methods: `get_enemy_towers()`, `get_rival_hackers()`, `activate()`

#### **MEDIUM PRIORITY - Supporting Systems:**
5. **GameManager** → `GameManagerInterface`
   - Used by: GridManager, ProgramDataPacketManager, MainController
   - Key methods: `is_game_over()`, `trigger_game_over()`, `trigger_game_won()`

6. **ProgramDataPacketManager** → `ProgramDataPacketManagerInterface`
   - Used by: MainController, RivalHackerManager
   - Key methods: `get_program_data_packet()`, `can_player_release_packet()`

### MainController Refactoring Plan

**Current Issues:**
```gdscript
# Current - Direct instantiation
func setup_managers():
    grid_manager = GridManager.new()
    wave_manager = WaveManager.new()
    # ... etc
```

**Target - Dependency Injection:**
```gdscript
# Target - Accept interfaces
func setup_managers(grid_mgr: GridManagerInterface, wave_mgr: WaveManagerInterface, ...):
    grid_manager = grid_mgr
    wave_manager = wave_mgr
    # ... etc
```

### Testing Impact

**Current Test Issues:**
- Cannot mock GridManager methods (causes linter errors)
- Cannot isolate systems for unit testing
- Tests depend on real implementations

**After Refactoring:**
- Can create `MockGridManager` that implements `GridManagerInterface`
- Can test each system in isolation
- Full control over test scenarios

---

## 11. Action Items

- [x] **CurrencyManager refactored** - ✅ COMPLETED
- [x] **FreezeMineManager refactored** - ✅ COMPLETED
- [ ] Complete the audit table above for your codebase.
- [ ] For each "Needs Refactor?", create an interface and update usages.
- [ ] Update all tests to use mocks/fakes.
- [ ] Document the new dependency injection pattern in your project docs.

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