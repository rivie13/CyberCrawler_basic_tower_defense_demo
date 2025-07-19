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
scripts/
├── Currency/         # Resource management
├── Enemy/            # Enemy AI and behavior
├── FreezeMine/       # Special abilities
├── Grid/             # Grid layout and management
├── Interfaces/       # Shared interfaces and utilities
├── ProgramPacket/    # Core win condition mechanics
├── Projectile/       # Combat projectiles
├── Rival/            # AI opponent systems
├── Tower/            # Tower placement and combat
└── Utils/            # Shared utilities
```
This is where main game logic is but there is more. But this is where most of the code changes for this repo happen in.

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