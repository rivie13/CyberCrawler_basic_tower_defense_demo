# CyberCrawler Basic Tower Defense Demo

This repository contains the **Phase 1B** prototype for CyberCrawler - an enhanced tower defense demo that serves as the foundation for the vertical slice. This is part of CyberCrawler, a 2.5D game that mixes stealth action and tower defense gameplay.

## 🎯 Project Scope

This repository is **strictly for the enhanced tower defense demo** that represents Phase 1B of CyberCrawler development.

### What This Repository IS For:
- **Enhanced tower defense gameplay mechanics** with rival AI opponent
- **Strategic grid-based combat system** (player vs AI hacker)
- **Bidirectional tower combat** (towers fight towers)
- **Program data packet transmission mechanics** (core win condition)
- **Dynamic grid layouts** with strategic positioning
- **Tower health and destruction systems**
- **Rival hacker AI** that places and manages enemy towers
- **Advanced resource management** for strategic depth
- **Freeze Mine mechanic** for tactical play
- **Click-to-destroy enemy entities** for direct player interaction
- **Comprehensive testing system** with 455 tests and 83.2% code coverage

### What This Repository IS NOT For:
- ❌ **Stealth gameplay mechanics** (separate project)
- ❌ **Hub/Safehouse systems** (separate project)
- ❌ **Character dialogue or story elements**
- ❌ **Multiple game modes beyond enhanced tower defense**
- ❌ **Networking or multiplayer features**
- ❌ **Final art assets** (placeholder art only)

### Current Development Constraints
- **Enhanced tower defense scope only** - No stealth or hub mechanics
- **Strategic depth over visual polish** - Gameplay first, art later  
- **AI opponent focus** - Rival hacker must provide meaningful challenge
- **Modular architecture** - Systems must support future integration
- **Prototype-level implementation** - Functional over polished

## 🛠️ Development Tools

### Game Engine
- **Godot Engine** - Primary game engine for 2.5D development

### 3D Modeling & Assets
- **Blender** - For creating 3D models and rendering to 2D sprites (isometric workflow)
- **Microsoft Paint** - For concept art and basic 2D editing

### Project Management
- **Trello Board**: [CyberCrawler_VerticalSlice](https://trello.com/b/ZH9jpFH7/cybercrawlerverticalslice)
  - **Lists**: Backlog → To Do → Doing (prototyping) → Done
  - Tracks development progress through the 5-phase roadmap

### Development Integration (MCP Tools)
- **Godot MCP** - Integration with Godot Engine for development workflow
- **Blender MCP** - Integration with Blender for 3D-to-2D asset pipeline
- **GitHub MCP** - Version control and repository management
- **Trello MCP** - Project management and task tracking

## 📋 Development Phase

**Current Phase**: Phase 1B - Enhanced Tower Defense with Rival AI (July 2025)

**Goal**: Evolve the basic tower defense into a dynamic hacker vs hacker conflict with:
- Enhanced grid system with more interesting layouts
- Bidirectional combat (player towers vs enemy towers)
- Rival hacker AI that places defensive towers
- Player program data packet win condition
- Tower health systems and destructible defenses
- Freeze Mine mechanic for tactical play
- Click-to-destroy enemy entities for direct player interaction

**Note**: All core enhanced tower defense mechanics are functional and tested. Currently focusing on balancing, tuning, and further AI sophistication.

## 🎨 Art Style Guidelines

- **Style**: Stylized 2.5D Isometric
- **Approach**: Hi-Bit Pixel Art or Vector Noir
- **Workflow**: Blender → 2D sprite rendering for consistent isometric perspective
- **Constraint**: No photorealistic or complex 3D assets (solo dev limitations)

## 🎮 Core Design Pillars

Every development decision must serve these three pillars:
1. **The Ghost & The Machine** - Player feels powerful yet vulnerable
2. **Asymmetrical Warfare** - Underdog fighting through cunning, not brute force
3. **A Living, Breathing Dystopia** - Technology oppression narrative

## 📈 Project Evolution

### Phase 1A: Basic Tower Defense ✅ COMPLETED
- [x] Single grid map with simple path
- [x] Basic player towers that shoot at enemies  
- [x] Enemy waves that move along path
- [x] Currency system and tower purchasing
- [x] Win/lose conditions (10 waves survival)
- [x] Victory screen implementation

### Phase 1B: Enhanced Strategic Tower Defense ✅ COMPLETED
**Current Focus**: **Strategic hacker duel** fully implemented and tested

**Core New Mechanics (All Implemented and Tested):**
- **Rival Hacker AI** - AI opponent places enemy towers to counter player strategies (alert-driven and adaptive)
- **Bidirectional Combat** - Towers fight towers (not just towers vs creeps)
- **Program Data Packet** - Player win condition requires getting data through enemy defenses (fully implemented)
- **Enhanced Grid** - More complex layouts enabling strategic depth (multiple path types implemented)
- **Tower Health Systems** - Destructible towers create dynamic battlefield (health bars, destruction, and rebuilding)
- **Freeze Mine Mechanic** - Players can place freeze mines to temporarily disable enemy towers
- **Click-to-Destroy Enemy Entities** - Players can directly click on enemies, enemy towers, and rival hackers to deal damage

**Why This Evolution:**
The basic tower defense worked but lacked strategic depth. The enhanced version creates a **chess-like tactical experience** where player and AI opponent compete for grid control, making each placement decision critical.

### Technical Implementation Status
- ✅ Core tower defense loop functional
- ✅ Currency and purchasing systems working
- ✅ Wave management and victory conditions fixed
- ✅ Enhanced grid layouts (multiple path types) implemented
- ✅ Rival hacker AI system (alert-driven, adaptive) implemented
- ✅ Bidirectional combat system implemented
- ✅ Program Data Packet system implemented
- ✅ Freeze Mine mechanic implemented
- ✅ Click-to-destroy enemy entities implemented
- ✅ Tower health systems implemented
- ✅ Comprehensive testing system (455 tests, 83.2% coverage)
- 🚧 Continuous balancing, tuning, and bugfixing
- 🚧 Further AI sophistication and strategic depth

## 🧪 Testing System

### Comprehensive Test Coverage
- **Total Tests**: 455 tests across 31 test scripts
- **Test Success Rate**: 100% (455/455 passing)
- **Code Coverage**: 83.2% for files with tests (1574/1892 lines)
- **Files with Tests**: 20 out of 23 script files (87.0% coverage)
- **Execution Time**: 0.792 seconds for 455 tests

### Test Categories
- **Unit Tests**: 429 tests covering individual components
- **Integration Tests**: 26 tests covering cross-system interactions
- **Coverage Validation**: Automated validation prevents merging insufficiently tested code

### Testing Framework
- **GUT (Godot Unit Test)** - Primary testing framework
- **Coverage System** - Advanced code coverage with pre/post-run hooks
- **CI/CD Integration** - GitHub Actions workflow for automated testing
- **Quality Gates** - Automated validation prevents quality regression

## 🚀 Current Development Focus (From Trello Board)

### Currently in Development
1. **Continuous balancing and bugfixing** - Ongoing gameplay tuning to ensure fun and engaging mechanics
2. **Further AI sophistication and strategic depth**
3. **Polish and UI/UX improvements**

### Immediate Priorities (To Do)
- [x] Enhanced Grid System - Complete
- [x] Player Program Data Packet - Complete
- [x] Rival Hacker AI System - Complete
- [x] Bidirectional Combat - Complete
- [x] Tower Health Systems - Complete
- [x] Freeze Mine Mechanic - Complete
- [x] Click-to-Destroy Enemy Entities - Complete
- [x] Comprehensive Testing System - Complete
- [ ] Continuous Balancing and Tuning
- [ ] Further AI sophistication and strategic depth
- [ ] Polish and bugfixing

### Enhanced Tower Defense Vision
Moving beyond simple "waves of enemies" to a **strategic hacker duel** where:
- Player and AI hacker both place towers on the same grid
- Player must send a program data packet through enemy defenses
- Enemy AI actively counters player strategies (alert-driven, adaptive)
- Dynamic, chess-like gameplay emerges from tower placement decisions
- Players can use freeze mines and direct clicks for tactical advantage

### Development Path
This enhanced tower defense will serve as the foundation for the full CyberCrawler experience, eventually connecting to stealth infiltration and hub progression systems in later phases.

## 🧊 Freeze Mine Mechanic

- Players can place freeze mines on the grid using a dedicated UI button.
- Freeze mines temporarily disable ("freeze") enemy towers within a radius when triggered.
- Mines have a cost, limited uses, and visual feedback for activation and depletion.
- Integrated with the currency system and grid validation.
- Adds a new layer of tactical play and counterplay against the rival AI.

## 🖱️ Click-to-Destroy Enemy Entities

- Players can toggle between "build" and "attack" modes using a UI button.
- In attack mode, clicking on enemies, enemy towers, or rival hackers deals direct damage.
- Each entity type has its own click radius, damage, and feedback.
- Adds a new interactive layer to the core gameplay loop.

## 🎯 Development Priorities (Updated July 2025)

### HIGH PRIORITY - Core Functionality ✅ COMPLETED
- [x] Debug and improve tower defense prototype
- [x] Ensure victory/defeat conditions work correctly
- [x] Optimize performance for enhanced features
- [x] Implement comprehensive testing system

### NEXT PRIORITIES - Enhanced Mechanics ✅ COMPLETED
- [x] Enhanced Grid System
- [x] Player Program Data Packet
- [x] Rival Hacker AI Foundation
- [x] Bidirectional Combat System
- [x] Tower Health Systems
- [x] Freeze Mine Mechanic
- [x] Click-to-Destroy Enemy Entities

### ONGOING PRIORITIES
- **Continuous balancing** - Ensure gameplay remains fun
- **Code organization** - Maintain clean, expandable architecture
- **Testing and debugging** - Each feature must be stable before moving on
- **Further AI sophistication** - Enhance rival hacker intelligence and strategic depth
- **Find and Fix Bugs** - Continue to search and figure out run time errors and fix mechanics accordingly

### Future Phases
This prototype will eventually connect to the stealth sections and hub systems in later phases, forming the complete CyberCrawler vertical slice.

## ✅ Phase 1B Complete When:
- Player can place towers strategically on enhanced grid ✅
- AI opponent places enemy towers that create meaningful challenge (alert-driven, adaptive) ✅
- Bidirectional combat works (towers fight towers) ✅
- Program data packet system provides core win condition ✅
- Freeze mine and click-to-destroy mechanics are functional ✅
- Strategic depth creates engaging hacker vs hacker gameplay ✅
- Core enhanced tower defense loop is fun and tactically rich ✅
- Comprehensive testing system ensures code quality ✅

## 📈 Ready for Phase 2 When:
- Enhanced tower defense mechanics proven strategically engaging ✅
- AI opponent provides satisfying challenge ✅
- Code structure supports stealth integration ✅
- All Phase 1B requirements met ✅
- Trello board shows Phase 1B tasks complete ✅
- Testing system provides confidence for future development ✅

**Status**: Phase 1B is functionally complete with comprehensive testing. Working out kinks now and fixing issues that may be present. Ready to begin Phase 2 development when approved.
