# CyberCrawler Basic Tower Defense Demo

This repository contains the **Phase 1** prototype for CyberCrawler - a basic tower defense demo that will serve as the foundation for the vertical slice. This is part of CyberCrawler, a 2.5D game that mixes stealth action and tower defense gameplay.

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

**Current Phase**: Advanced Phase 1 - Enhanced Tower Defense with Rival AI (July 2025)

**Goal**: Evolve the basic tower defense into a dynamic hacker vs hacker conflict with:
- Enhanced grid system with more interesting layouts
- Bidirectional combat (player towers vs enemy towers)
- Rival hacker AI that places defensive towers
- Player program data packet win condition
- Tower health systems and destructible defenses

**Note**: Core tower defense mechanics are functional. Now enhancing with strategic depth and asymmetrical AI opponent.

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

### Phase 1B: Enhanced Strategic Tower Defense 🚧 IN PROGRESS
**Current Focus**: Evolving from simple "survive waves" to **strategic hacker duel**

**Core New Mechanics:**
- **Rival Hacker AI** - AI opponent places enemy towers to counter player strategies
- **Bidirectional Combat** - Towers fight towers (not just towers vs creeps)
- **Program Data Packet** - Player win condition requires getting data through enemy defenses
- **Enhanced Grid** - More complex layouts enabling strategic depth
- **Tower Health Systems** - Destructible towers create dynamic battlefield

**Why This Evolution:**
The basic tower defense worked but lacked strategic depth. The enhanced version creates a **chess-like tactical experience** where player and AI opponent compete for grid control, making each placement decision critical.

### Technical Implementation Status
- ✅ Core tower defense loop functional
- ✅ Currency and purchasing systems working
- ✅ Wave management and victory conditions fixed
- 🚧 Enhanced grid layouts in development
- 🚧 Rival hacker AI system in development
- 🚧 Bidirectional combat system in development

## 🚀 Current Development Focus (From Trello Board)

### Currently in Development
1. **Debug and improve tower defense prototype** - Fix critical bugs preventing proper gameplay flow
2. **Code organization** - Better class separation and project structure (continuous)

### Immediate Priorities (To Do)
1. **Enhanced Grid System** - Replace straight-line path with more interesting grid layouts for strategic depth
2. **Player Program Data Packet** - Core win condition mechanic where player must transport data through enemy defenses
3. **Rival Hacker AI System** - AI opponent that places enemy towers to defend against player incursions
4. **Bidirectional Combat** - Player towers can attack enemy towers and vice versa
5. **Tower Health Systems** - Both player and enemy towers have health bars and can be destroyed
6. **Continuous Balancing** - Ongoing gameplay tuning to ensure fun and engaging mechanics

### Enhanced Tower Defense Vision
Moving beyond simple "waves of enemies" to a **strategic hacker duel** where:
- Player and AI hacker both place towers on the same grid
- Player must send a program data packet through enemy defenses
- Enemy AI actively counters player strategies
- Dynamic, chess-like gameplay emerges from tower placement decisions

### Development Path
This enhanced tower defense will serve as the foundation for the full CyberCrawler experience, eventually connecting to stealth infiltration and hub progression systems in later phases.

## 🎯 Development Priorities (Updated January 2025)

### HIGH PRIORITY - Core Functionality
1. **Debug and improve tower defense prototype** 
   - Fix any remaining bugs from Phase 1A
   - Ensure victory/defeat conditions work correctly
   - Optimize performance for enhanced features

2. **Code organization and architecture**
   - Separate systems into proper classes
   - Prepare codebase for AI opponent integration
   - Ensure modular design for future expansion

### NEXT PRIORITIES - Enhanced Mechanics
3. **Enhanced Grid System**
   - Replace straight-line path with strategic layouts
   - Multiple paths and chokepoints
   - Grid positions that favor different strategies

4. **Player Program Data Packet**
   - Core win condition mechanic
   - Must traverse from player start to enemy end
   - Can be attacked by enemy towers
   - Success = player victory

5. **Rival Hacker AI Foundation**
   - AI system that places enemy towers
   - Basic strategic decision making
   - Responds to player tower placement

### MEDIUM PRIORITY - Strategic Depth
6. **Bidirectional Combat System**
   - Player towers can target enemy towers
   - Enemy towers can target player towers
   - Tower vs tower combat mechanics

7. **Tower Health Systems**
   - Both player and enemy towers have health
   - Visual health indicators
   - Destruction and rebuilding mechanics

### ONGOING PRIORITIES
- **Continuous balancing** - Ensure gameplay remains fun
- **Code organization** - Maintain clean, expandable architecture
- **Testing and debugging** - Each feature must be stable before moving on

### Future Phases
This prototype will eventually connect to the stealth sections and hub systems in later phases, forming the complete CyberCrawler vertical slice.
