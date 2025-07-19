# GitHub Copilot Custom Instructions for CyberCrawler Tower Defense Portion

## Core Project Information

## Coding Guidelines

### Architecture Principles
- **Modular Design**: Each class has a single responsibility
- **Clear Separation**: Player logic ≠ AI logic ≠ Tower logic ≠ Grid logic
- **Strategic Focus**: Support for AI opponent and bidirectional combat
- **Godot Best Practices**: Follow engine conventions and patterns

### Code Organization
```
cybercrawler_basictowerdefense/
├── scripts/                          # Main game logic and systems
│   ├── Currency/                     # Resource management
│   │   └── CurrencyManager.gd
│   ├── Enemy/                        # Enemy AI and behavior
│   │   └── Enemy.gd
│   ├── FreezeMine/                   # Special abilities
│   │   ├── FreezeMine.gd
│   │   └── FreezeMineManager.gd
│   ├── Grid/                         # Grid layout and management
│   │   ├── GridLayout.gd
│   │   └── GridManager.gd
│   ├── Interfaces/                   # Shared interfaces and utilities
│   │   ├── Clickable.gd
│   │   └── TargetingUtil.gd
│   ├── ProgramPacket/                # Core win condition mechanics
│   │   ├── ProgramDataPacket.gd
│   │   └── ProgramDataPacketManager.gd
│   ├── Projectile/                   # Combat projectiles
│   │   └── Projectile.gd
│   ├── Rival/                        # AI opponent systems
│   │   ├── RivalHacker.gd
│   │   ├── RivalHackerManager.gd
│   │   └── RivalAlertSystem.gd
│   ├── Tower/                        # Tower placement and combat
│   │   ├── Tower.gd
│   │   ├── EnemyTower.gd
│   │   ├── PowerfulTower.gd
│   │   └── TowerManager.gd
│   ├── Utils/                        # Shared utilities
│   │   └── PriorityQueue.gd
│   ├── GameManager.gd                # Main game state management
│   ├── MainController.gd             # Primary game controller
│   └── WaveManager.gd                # Enemy wave management
├── tests/                            # Comprehensive test suite
│   ├── unit/                         # Unit tests for all components
│   │   ├── test_clickable.gd
│   │   ├── test_currency_manager.gd
│   │   ├── test_enemy.gd
│   │   ├── test_enemy_tower.gd
│   │   ├── test_freeze_mine.gd
│   │   ├── test_freeze_mine_manager.gd
│   │   ├── test_game_manager.gd
│   │   ├── test_grid_layout.gd
│   │   ├── test_powerful_tower.gd
│   │   ├── test_priority_queue.gd
│   │   ├── test_program_data_packet.gd
│   │   ├── test_program_data_packet_manager.gd
│   │   ├── test_projectile.gd
│   │   ├── test_rival_hacker.gd
│   │   ├── test_targeting_util.gd
│   │   ├── test_tower.gd
│   │   ├── test_tower_manager.gd
│   │   └── test_wave_manager.gd
│   ├── integration/                  # Integration tests
│   │   └── test_tower_placement.gd
│   ├── system/                       # System-level tests
│   ├── pre_run_hook.gd               # Coverage validation
│   └── post_run_hook.gd              # Test cleanup
├── scenes/                           # Godot scene files
│   ├── Main.tscn                     # Main game scene
│   ├── Enemy.tscn                    # Enemy scene
│   ├── EnemyTower.tscn               # Enemy tower scene
│   ├── FreezeMine.tscn               # Freeze mine scene
│   ├── PowerfulTower.tscn            # Powerful tower scene
│   ├── ProgramDataPacket.tscn        # Program data packet scene
│   ├── Projectile.tscn               # Projectile scene
│   ├── RivalHacker.tscn              # Rival hacker scene
│   └── Tower.tscn                    # Basic tower scene
├── addons/                           # Godot addons
│   ├── gut/                          # GUT testing framework
│   └── coverage/                     # Test coverage tracking
```
**The above should change and be updated as needed based on design decisions**

**Key Architecture Points:**
- **Modular Design**: Each system has its own directory with clear responsibilities
- **Comprehensive Testing**: Full test coverage with unit, integration, and system tests
- **Separation of Concerns**: Game logic (scripts) separate from presentation (scenes)
- **Manager Pattern**: Each major system has a manager class for coordination
- **Interface-Driven**: Shared interfaces for common functionality

### Testing Requirements
- **Coverage**: All new code must have corresponding tests
- **Organization**: Unit tests in `tests/unit/`, integration in `tests/integration/`
- **Framework**: GUT with proper setup/teardown patterns
- **Validation**: Tests must actually verify functionality

### Code Review Standards
- **Architecture quality**: Modular design with proper separation
- **Test coverage**: Adequate tests for all new functionality
- **Documentation**: Clear comments and README updates

## Quality Standards

### Code Quality
- **Readability**: Clear, self-documenting code
- **Maintainability**: Modular, extensible design
- **Performance**: Efficient algorithms and resource usage
- **Reliability**: Proper error handling and edge cases

### Documentation
- **Code Comments**: Explain complex logic and design decisions
- **README Updates**: Document new features and changes
- **Design Compliance**: All changes align with Game Design Doc and Toolkit Doc

1. **Test Everything**: Coverage requirements are mandatory
2. **Follow Godot Patterns**: Use engine conventions and best practices
3. **Document Changes**: Keep documentation updated with code changes

## Code Review Specific Instructions

When performing a code review, respond in English.

When performing a code review, focus on readability and avoid nested ternary operators.

When performing a code review, ensure:
- Modular design with single responsibility classes
- Proper separation of Player logic ≠ AI logic ≠ Tower logic ≠ Grid logic
- Adequate test coverage for all new functionality
- No breaking changes to existing functionality
- Follows Godot/GDScript best practices
- Aligns with CyberCrawler design principles 