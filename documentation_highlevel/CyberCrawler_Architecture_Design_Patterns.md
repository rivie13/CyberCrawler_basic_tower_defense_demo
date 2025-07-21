# CyberCrawler TD Architecture & Design Patterns

## Overview

This document outlines the architectural patterns and design principles being used in CyberCrawler's **Tower Defense (TD) portion** of the vertical slice development. The current approach combines **Dependency Injection (DI)** with **Manager-based Orchestration** to create a modular, testable, and scalable codebase that can evolve from the TD prototype into a full-featured tower defense system that will eventually integrate with the stealth action and hub systems in the complete game.

**Important Scope Clarification:**
- This repository contains **ONLY the tower defense portion** of CyberCrawler
- The 2.5D stealth action portion has not been started yet (will be separate project)
- The hub/safehouse system has not been started yet (will be separate project)
- The vertical slice will eventually connect: **Stealth Action → Network Breach → Jack In → Tower Defense**
- This document focuses on the TD architecture and how it will integrate with the stealth action system

---

## 1. Current Architecture: Manager-Based Dependency Injection

### Core Pattern: Interface-Driven Managers

The codebase follows a **Manager Pattern** where each major system is encapsulated in a dedicated manager class that implements a specific interface. This creates a clear separation of concerns and enables dependency injection.

#### Architecture Components:

```
MainController (Orchestrator)
├── GridManager (GridManagerInterface)
├── TowerManager (TowerManagerInterface) 
├── CurrencyManager (CurrencyManagerInterface)
├── WaveManager (WaveManagerInterface)
├── GameManager (GameManagerInterface)
├── RivalHackerManager (RivalHackerManagerInterface)
├── ProgramDataPacketManager (ProgramDataPacketManagerInterface)
└── FreezeMineManager (MineManagerInterface)
```

### Key Design Principles

#### 1. **Interface Contracts**
- Every manager implements a specific interface that defines its public API
- Interfaces are defined in `scripts/Interfaces/` directory
- Concrete implementations extend these interfaces
- Example: `CurrencyManager extends CurrencyManagerInterface`

#### 2. **Dependency Injection**
- Managers receive their dependencies through `initialize()` methods
- No direct instantiation of dependencies within classes
- Dependencies are injected by the orchestrator (MainController)
- Example:
```gdscript
# Good - Dependency Injection
func initialize(grid_mgr: GridManagerInterface, currency_mgr: CurrencyManagerInterface):
    grid_manager = grid_mgr
    currency_manager = currency_mgr

# Bad - Direct Instantiation (Avoid)
func _ready():
    grid_manager = GridManager.new()  # ❌ Don't do this
```

#### 3. **Manager Orchestration**
- `MainController` acts as the central orchestrator
- Creates all manager instances and injects dependencies
- Handles signal connections between systems
- Manages the overall game flow

#### 4. **Signal-Driven Communication**
- Managers communicate through Godot signals
- Loose coupling between systems
- Event-driven architecture
- Example:
```gdscript
# TowerManager emits signal
tower_placed.emit(grid_pos, tower_type)

# MainController connects and handles
tower_manager.tower_placed.connect(_on_tower_placed)
```

---

## 2. Current Implementation Status

### ✅ **Completed Interface Refactors:**

| System | Interface | Implementation | Status |
|--------|-----------|----------------|---------|
| **CurrencyManager** | `CurrencyManagerInterface` | `CurrencyManager` | ✅ Complete |
| **TowerManager** | `TowerManagerInterface` | `TowerManager` | ✅ Complete |
| **FreezeMineManager** | `MineManagerInterface` | `FreezeMineManager` | ✅ Complete |

### 🚧 **Pending Interface Refactors:**

| System | Interface | Implementation | Priority |
|--------|-----------|----------------|----------|
| **GridManager** | `GridManagerInterface` | `GridManager` | HIGH |
| **WaveManager** | `WaveManagerInterface` | `WaveManager` | HIGH |
| **GameManager** | `GameManagerInterface` | `GameManager` | MEDIUM |
| **RivalHackerManager** | `RivalHackerManagerInterface` | `RivalHackerManager` | HIGH |
| **ProgramDataPacketManager** | `ProgramDataPacketManagerInterface` | `ProgramDataPacketManager` | MEDIUM |

### 📋 **Current Architecture Assessment:**

#### **Strengths:**
- ✅ **Clear separation of concerns** - Each manager handles one specific domain
- ✅ **Interface contracts** - Well-defined APIs for each system
- ✅ **Dependency injection** - Loose coupling between systems
- ✅ **Testability** - Can easily mock dependencies for unit testing
- ✅ **Signal-driven communication** - Event-driven architecture
- ✅ **Modular design** - Systems can be developed and tested independently

#### **Areas for Improvement:**
- 🔄 **Incomplete interface coverage** - Some managers still need interface refactoring
- 🔄 **Direct instantiation in MainController** - Still creating managers with `.new()`
- 🔄 **Mixed dependency types** - Some managers accept concrete classes instead of interfaces

---

## 3. Future Architecture Evolution

### Phase 1: Complete Interface Coverage (Current)

**Goal:** All managers implement interfaces and use dependency injection consistently.

**Actions:**
1. Create remaining interfaces (`GridManagerInterface`, `WaveManagerInterface`, etc.)
2. Refactor all managers to extend their interfaces
3. Update MainController to accept interface types
4. Ensure all tests use mock implementations

### Phase 2: Service Locator Pattern (Post-Vertical Slice)

**Goal:** Reduce coupling between MainController and individual managers.

**Pattern:**
```gdscript
# Service Locator Pattern
class_name GameServices
extends Node

var grid_manager: GridManagerInterface
var tower_manager: TowerManagerInterface
var currency_manager: CurrencyManagerInterface
# ... etc

func register_service(service_name: String, service: Node):
    set(service_name, service)

func get_service(service_name: String) -> Node:
    return get(service_name)
```

**Benefits:**
- Managers can access other services without direct injection
- Easier to add new services dynamically
- Reduced parameter passing in initialize() methods

### Phase 3: Event Bus Architecture (Full Game)

**Goal:** Decentralized communication for complex game systems.

**Pattern:**
```gdscript
# Event Bus for global communication
class_name EventBus
extends Node

signal enemy_killed(enemy: Enemy)
signal tower_destroyed(tower: Tower)
signal game_state_changed(new_state: String)
# ... etc

# Systems subscribe to events they care about
func _ready():
    EventBus.enemy_killed.connect(_on_enemy_killed)
    EventBus.tower_destroyed.connect(_on_tower_destroyed)
```

**Benefits:**
- Completely decoupled systems
- Easy to add new event listeners
- Supports complex game state management
- Perfect for stealth/hub integration

---

## 4. Design Pattern Analysis

### Is This Architecture Sound?

**YES** - The current approach is well-designed and follows established software engineering principles:

#### ✅ **SOLID Principles Compliance:**

1. **Single Responsibility Principle (SRP)**
   - Each manager has one clear responsibility
   - `CurrencyManager` handles only currency logic
   - `TowerManager` handles only tower placement/management

2. **Open/Closed Principle (OCP)**
   - Interfaces allow extending functionality without modifying existing code
   - New tower types can be added without changing `TowerManagerInterface`
   - New mine types can be added without changing `MineManagerInterface`

3. **Liskov Substitution Principle (LSP)**
   - Any implementation of an interface can be substituted
   - Mock implementations work seamlessly in tests
   - Concrete classes can be swapped without breaking functionality

4. **Interface Segregation Principle (ISP)**
   - Interfaces are focused and specific
   - `CurrencyManagerInterface` only defines currency-related methods
   - `TowerManagerInterface` only defines tower-related methods

5. **Dependency Inversion Principle (DIP)**
   - High-level modules depend on abstractions (interfaces)
   - Low-level modules implement those abstractions
   - Dependencies flow toward abstractions, not concrete implementations

#### ✅ **Game Development Best Practices:**

1. **Modularity**
   - Systems can be developed independently
   - Easy to add new features without affecting existing code
   - Clear boundaries between different game systems

2. **Testability**
   - Each system can be tested in isolation
   - Mock dependencies enable comprehensive unit testing
   - Integration tests can verify system interactions

3. **Maintainability**
   - Clear separation of concerns
   - Easy to locate and fix bugs
   - Simple to add new features

4. **Scalability**
   - Architecture supports adding new systems
   - Pattern can scale to full game complexity
   - Supports future stealth/hub integration

---

## 5. Integration with Game Design Pillars

### How Architecture Serves the Three Pillars:

#### **Pillar 1: The Ghost & The Machine**
- **Modular design** allows seamless transition from stealth (Ghost) to tower defense (Machine) modes
- **Interface contracts** ensure consistent behavior when transitioning between modes
- **Event-driven architecture** supports smooth transitions from stealth breach to TD hacking

#### **Pillar 2: Asymmetrical Warfare**
- **Manager separation** allows AI systems (RivalHackerManager) to operate independently
- **Interface abstraction** enables different AI strategies without affecting core systems
- **Signal communication** supports dynamic AI responses to player actions

#### **Pillar 3: A Living, Breathing Dystopia**
- **Service locator pattern** (future) will support dynamic world state management
- **Event bus architecture** (future) will enable complex narrative systems
- **Modular design** supports episodic content and story progression

---

## 6. Migration Path to Full Game

### Phase 1B → Phase 2 (Stealth Integration)

**Current State:** Tower defense systems with interface-driven architecture
**Target State:** TD system that can be launched from stealth action portion

**Migration Strategy:**
1. **Add mission context interfaces** to receive data from stealth portion
2. **Create transition managers** (StealthToTDTransition, TDToStealthTransition)
3. **Implement player state carryover** from stealth to TD and back
4. **Add mission completion handling** to return to stealth portion

### Phase 2 → Phase 3 (Hub Integration)

**Current State:** Integrated stealth and tower defense
**Target State:** Full game with hub/safehouse systems

**Migration Strategy:**
1. **Implement service locator pattern** for global service access
2. **Add hub-specific managers** (MissionManager, UpgradeManager, etc.)
3. **Create save/load systems** using existing manager patterns
4. **Implement narrative systems** through event-driven architecture

### Phase 3 → Full Game

**Current State:** Complete vertical slice with hub
**Target State:** Full episodic game

**Migration Strategy:**
1. **Implement event bus architecture** for complex system communication
2. **Add content management systems** for episodic content
3. **Scale existing patterns** to support full game complexity
4. **Optimize performance** while maintaining architectural integrity

---

## 7. Testing Strategy

### Current Testing Approach:

#### **Unit Testing:**
- Each manager tested in isolation
- Mock dependencies injected for controlled testing
- Interface contracts verified through mock implementations

#### **Integration Testing:**
- System interactions tested through MainController
- End-to-end gameplay scenarios validated
- Signal communication verified

### Future Testing Strategy:

#### **Service Locator Testing:**
- Service registration/retrieval tested
- Mock services injected through service locator
- System integration tested with service dependencies

#### **Event Bus Testing:**
- Event emission and handling tested
- Complex event chains validated
- Performance testing for event propagation

---

## 8. Conclusion

### Architecture Assessment: **SOUND AND WELL-DESIGNED**

The current architecture successfully combines:
- ✅ **Dependency Injection** for loose coupling
- ✅ **Manager Pattern** for clear separation of concerns  
- ✅ **Interface Contracts** for maintainable APIs
- ✅ **Signal-Driven Communication** for event handling
- ✅ **Modular Design** for scalability

### Key Strengths:
1. **Follows established software engineering principles**
2. **Supports the game's three design pillars**
3. **Enables comprehensive testing**
4. **Scales from prototype to full game**
5. **Supports future feature integration**

### Recommended Next Steps:
1. **Complete interface refactoring** for remaining managers
2. **Implement service locator pattern** post-vertical slice
3. **Add event bus architecture** for full game complexity
4. **Maintain architectural consistency** as new features are added

This architecture provides a solid foundation for CyberCrawler's evolution from a vertical slice prototype to a full episodic game while maintaining code quality, testability, and maintainability throughout the development process.

---

## 9. Preparing for TD System Expansion

### Current TD Scope (Vertical Slice):
- Single grid layout with basic paths
- Basic and powerful tower types
- Simple enemy waves
- Basic rival hacker AI: places enemy towers, sends homing missiles, and changes grid layout occasionally through blocking and unblocking the path
- Program data packet win condition
- Freeze mine tactical element
- Clicking attack mechanic
- **Note:** This TD portion will eventually be launched from the stealth action portion when player jacks into a network breach point

### Future TD Expansion Requirements:

#### **Grid System Expansion:**
- **Multiple grid layouts** (different maps/levels)
- **Dynamic grid generation** (already happens but needs refinement)
- **Grid size variations** (small tactical maps to large strategic maps)
- **Path complexity** (multiple paths, chokepoints, shortcuts)

**Architecture Preparation:**
```gdscript
# GridManagerInterface should support:
func load_grid_layout(layout_name: String) -> bool
func generate_procedural_grid(parameters: Dictionary) -> bool
func get_available_layouts() -> Array[String]
func validate_grid_layout(layout: Dictionary) -> bool
```

#### **Tower System Expansion:**
- **Multiple tower types** (sniper, area damage, support, etc.)
- **Tower upgrades** (damage, range, fire rate, special abilities)
- **Tower synergies** (combinations that work together)
- **Tower placement restrictions** (terrain, adjacency rules)

**Architecture Preparation:**
```gdscript
# TowerManagerInterface should support:
func get_available_tower_types() -> Array[String]
func can_upgrade_tower(tower: Tower, upgrade_type: String) -> bool
func upgrade_tower(tower: Tower, upgrade_type: String) -> bool
func get_tower_synergies(tower_type: String) -> Array[String]
```

#### **Enemy System Expansion:**
- **Multiple enemy types** (fast, armored, flying, boss units)
- **Enemy abilities** (stealth, regeneration, area damage)
- **Enemy formations** (groups, waves, special events)
- **Enemy AI behaviors** (pathfinding, targeting, retreating)

**Architecture Preparation:**
```gdscript
# WaveManagerInterface should support:
func spawn_enemy_type(enemy_type: String, position: Vector2) -> Enemy
func create_enemy_formation(formation_data: Dictionary) -> Array[Enemy]
func get_available_enemy_types() -> Array[String]
func set_enemy_behavior(enemy: Enemy, behavior: String) -> bool
```

#### **Rival Hacker AI Expansion:**
- **Multiple AI personalities** (aggressive, defensive, adaptive)
- **Advanced strategies** (flanking, feints, counter-attacks)
- **Learning/adaptation** (responds to player patterns)
- **Difficulty scaling** (adjusts based on player skill)

**Architecture Preparation:**
```gdscript
# RivalHackerManagerInterface should support:
func set_ai_personality(personality: String) -> bool
func set_difficulty_level(level: int) -> bool
func analyze_player_patterns() -> Dictionary
func adapt_strategy(player_data: Dictionary) -> bool
```

#### **Combat System Expansion:**
- **Damage types** (physical, energy, EMP, etc.)
- **Status effects** (freeze, burn, slow, stun)
- **Critical hits** and **accuracy systems**
- **Line of sight** and **cover mechanics**

**Architecture Preparation:**
```gdscript
# Combat system interfaces needed:
class_name CombatManagerInterface
func calculate_damage(attacker: Node, target: Node, damage_type: String) -> float
func apply_status_effect(target: Node, effect: String, duration: float) -> bool
func check_line_of_sight(from_pos: Vector2, to_pos: Vector2) -> bool
```

### Integration Points for Future Systems:

#### **Stealth Action Integration (Primary Focus):**
- **Mission context** (TD launched from specific stealth mission/breach point)
- **Player state carryover** (health, resources, upgrades from stealth portion)
- **Mission progression** (TD success/failure affects return to stealth portion)
- **Story integration** (TD events trigger narrative elements in stealth portion)
- **Return to stealth** (TD completion returns player to stealth action)

**Architecture Preparation:**
```gdscript
# MissionContextInterface (future):
func get_stealth_mission_context() -> Dictionary
func set_breach_point_data(breach_data: Dictionary) -> bool
func return_to_stealth_action(td_results: Dictionary) -> bool

# PlayerStateInterface (future):
func get_player_state_from_stealth() -> Dictionary
func update_player_state_for_stealth_return(new_state: Dictionary) -> bool

# TransitionManagerInterface (future):
func transition_from_stealth_to_td(stealth_context: Dictionary) -> bool
func transition_from_td_to_stealth(td_results: Dictionary) -> bool
```

#### **Hub System Integration (Later Phase):**
- **Mission selection** (choose stealth missions from hub that lead to TD)
- **Upgrade management** (purchase upgrades that affect both stealth and TD)
- **Progress tracking** (save/load progress across both modes)
- **Story progression** (missions advance narrative across both modes)

**Architecture Preparation:**
```gdscript
# MissionManagerInterface (future):
func get_available_stealth_missions() -> Array[Dictionary]
func start_stealth_mission(mission_id: String) -> bool
func complete_stealth_mission(mission_id: String, td_results: Dictionary) -> bool
```

### Scalability Considerations:

#### **Performance Optimization:**
- **Object pooling** for frequently created/destroyed objects
- **Spatial partitioning** for large grids
- **LOD systems** for complex visual effects
- **Async loading** for large grid layouts

#### **Memory Management:**
- **Resource streaming** for large asset sets
- **Garbage collection** optimization
- **Memory pools** for frequently allocated objects
- **Asset caching** strategies

#### **Modularity for Team Development:**
- **Clear API contracts** between systems
- **Version control** for interface changes
- **Documentation** for all public APIs
- **Testing frameworks** for each system

### Recommended Architecture Evolution:

#### **Phase 1: Complete Current Refactor**
- Finish interface implementation for all managers
- Ensure all systems use dependency injection
- Complete comprehensive testing suite

#### **Phase 2: Prepare for Expansion**
- Add extension points to existing interfaces
- Create factory patterns for object creation
- Implement configuration-driven systems

#### **Phase 3: Scale for Full Game**
- Implement service locator for global access
- Add event bus for complex communication
- Create content management systems

**Bottom Line:** Your current architecture is **excellent** for scaling to a full-featured TD system. The interface-driven approach with dependency injection will handle all the expansion requirements you've outlined. The key is to complete the current refactor first, then gradually add the extension points as you need them. 