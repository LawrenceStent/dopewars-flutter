# DopeWars Flutter Documentation

Welcome to the comprehensive documentation for the DopeWars Flutter modernization project.

## 📖 Quick Links

### For Players
- **[PLAYER_GUIDE.md](PLAYER_GUIDE.md)** - Complete guide to gameplay mechanics, strategies, and features
  - Locations & trading
  - Heat & reputation system
  - NPCs & relationships
  - Scenarios & dynamic events
  - Contracts & missions
  - Strategy tips

### For Developers
- **[implementation-roadmap.md](implementation-roadmap.md)** - High-level project status and planning
  - Phase 1 completion summary (41 tests)
  - Phase 2 completion details (150+ tests total)
  - Phase 3 planning
  - Known issues & resolutions
  - Lessons learned

- **[PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md)** - Detailed Phase 2 implementation report
  - Phase 2A: NPC Trading Network (86 tests)
  - Phase 2B: Dynamic Scenarios (20 templates)
  - Phase 2C: Contracts UI & Integration
  - Test coverage breakdown
  - Code quality metrics
  - Phase 3 planning

### Design Documentation
- **[design/](design/)** - System design specifications
  - `npc-price-manipulation-mitigation.md` - NPC balance mechanics (6-layer mitigation)
  - `pricing-matrix.md` - Location pricing system
  - `arbitrage-mitigation.md` - Market balance strategies
  - `debug-tooling.md` - Debug features spec

---

## 🎮 Current Game Features

### ✅ Phase 1: Foundation (Complete)
- 12 global locations with regional pricing (0.3x - 1.8x multipliers)
- Heat & reputation system (0-100 range)
- Police encounters with dynamic probability
- Supply/demand market mechanics
- Special locations (Bank, Loan Shark, Gun Shop, Pub)
- **41 tests passing**

### ✅ Phase 2A: NPC Trading Network (Complete)
- 5 specialized traders (Supplier, Buyer, Fixer, Lawyer, Doctor)
- Relationship system with reputation bonuses (up to 20%)
- Dynamic pricing based on relationships
- Supply caps (3-15 units/turn per NPC)
- Bust mechanics (8-15% chance during trades)
- **86 tests passing**

### ✅ Phase 2B: Dynamic Scenarios (Complete)
- 20 unique scenario templates
- Scenario trigger engine (location/heat-aware)
- Multi-choice outcomes with branching results
- Impacts on cash, health, drugs, heat, reputation
- Cooldown & spam prevention (max 1 per travel, 3-turn cooldown per type)
- All integration tests passing

### ✅ Phase 2C: Contracts UI & Integration (Complete)
- 5 active contract types (Transport, Logistics)
- 5 stubbed templates for Phase 3 (Stealth, Collection)
- Contract generation (2-3 per turn, refresh every 5 turns)
- Progress tracking with visual indicators
- Completion rewards (cash + reputation)
- Responsive UI (mobile tabs + desktop panel)
- **Clean build, flutter analyze passing**

---

## 📊 Build & Test Status

### Build Status
```
✅ flutter build web --release - Clean build
✅ flutter analyze - Zero errors in main code
✅ All dependencies resolved
```

### Test Coverage
| Phase | Category | Tests | Status |
|-------|----------|-------|--------|
| Phase 1 | Foundation | 41 | ✅ Passing |
| Phase 2A | NPC Domain | 48 | ✅ Passing |
| Phase 2A | NPC Cubit | 30 | ✅ Passing |
| Phase 2A | Integration | 8 | ✅ Passing |
| Phase 2B | Scenarios | Integration | ✅ Passing |
| Phase 2C | Contracts | Build | ✅ Passing |
| **Total** | **All** | **150+** | **✅ Passing** |

---

## 🚀 Implementation Timeline

### Phase 1: Foundation - ✅ COMPLETE
- Dates: Initial development through February 2026
- Focus: Core mechanics (locations, heat, police, trading)
- Tests: 41 passing
- Status: Stable, no known issues

### Phase 2A: NPC Trading Network - ✅ COMPLETE
- Date: Completed March 2026
- Focus: Relationship-based trading system
- Tests: 86 passing (domain + cubit + integration)
- Status: Production-ready

### Phase 2B: Dynamic Scenarios - ✅ COMPLETE
- Date: Completed March 2026
- Focus: 20 event templates with branching outcomes
- Tests: All integration tests passing
- Status: Production-ready

### Phase 2C: Contracts UI - ✅ COMPLETE
- Date: Completed March 17, 2026
- Focus: Mission system with progress tracking
- Tests: Build clean, analyze passing
- Status: Production-ready

### Phase 3: Polish & Expansion - 📋 PLANNED
- **Estimated Start:** Post Phase 2 playtesting
- **Planned Features:**
  - Skill system (5 trees)
  - Contract completion (Stealth, Collection types)
  - Agency system integration
  - World map visualization
  - Visual modernization

---

## 📝 Architecture Overview

### Code Structure
```
lib/
├── domain/              # Business logic entities & services
│   ├── contract/       # Contract system (Phase 2C)
│   ├── scenario/       # Scenario system (Phase 2B)
│   ├── npc/           # NPC system (Phase 2A)
│   ├── location/      # Location data (Phase 1)
│   ├── player/        # Player entity
│   ├── reputation/    # Heat & reputation (Phase 1)
│   └── trading/       # Market mechanics (Phase 1)
├── application/        # Use cases & business rules
├── presentation/       # UI layer
│   ├── cubits/        # State management (flutter_bloc)
│   ├── pages/         # Screen templates
│   └── widgets/       # Reusable components
└── core/              # Utilities, constants, value objects
```

### State Management
- **GameCubit** - Player state, inventory, travel
- **GameStateCubit** - Cross-cutting state (heat, reputation, supply/demand)
- **NpcNetworkCubit** - NPC relationships & trading state
- **CombatCubit** - Combat mechanics
- **TradingCubit** - Market trading state

### Design Patterns
- **Service layer** - ContractService, ScenarioTriggerService, NpcRepository
- **Value objects** - Money, Health, CoatSize, PlayerFlags
- **Immutable models** - Freezed for all entities
- **Dependency injection** - GetIt service locator

---

## 🎯 Game Balance

### Phase 2 Balance Decisions
1. **NPC supply caps** prevent arbitrage while allowing steady profit
2. **Bust chance** (8-15%) adds risk/reward calculation to NPC trades
3. **Scenario rewards** comparable to trading (can swing fortunes)
4. **Contract rewards** ($50k-$100k) provide alternative income stream
5. **Heat scaling** affects police encounters, NPC availability, and scenario triggers

### Difficulty Progression
- **Early game (turns 1-10):** Get established, build NPC relationships
- **Mid game (turns 11-20):** Balance multiple income streams, manage heat
- **Late game (turns 21-31):** Complete ambitious contracts, execute master plan

---

## 🔧 Technical Decisions

### Technology Stack
- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc with Cubits
- **Testing:** flutter_test + Mocktail
- **Serialization:** json_serializable (Phase 2A onwards)
- **DI Container:** GetIt

### Key Architectural Decisions
1. **GameStateCubit** as cross-cutting state owner (heat, reputation, supply/demand)
2. **Service layer pattern** for business logic (ContractService, NpcRepository, etc.)
3. **Immutable state** with Freezed code generation
4. **No persistence layer** (in-memory only, GameSession serialization for save/load)
5. **BLoC pattern** for all stateful widgets

### Performance Optimizations
- Text-based game (no heavy rendering)
- Lazy loading of scenarios (trigger on-demand)
- Supply/demand pool system (O(1) updates)
- Capped game state size (~50KB typical)

---

## 📚 How to Use This Documentation

### If You're a Player
1. Start with **[PLAYER_GUIDE.md](PLAYER_GUIDE.md)**
2. Learn game mechanics in order (locations → heat/reputation → travel)
3. Discover new features (NPCs → scenarios → contracts)
4. Check strategy tips section for advanced gameplay

### If You're a Developer (Onboarding)
1. Read **[implementation-roadmap.md](implementation-roadmap.md)** for overview
2. Check **[PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md)** for current state
3. Review `lib/` structure and feel codebase
4. Look at design docs (`design/`) for system specifications
5. Check tests (`test/`) for usage examples

### If You're Implementing Phase 3
1. Review Phase 3 requirements in **implementation-roadmap.md**
2. Check relevant design docs in **design/** folder
3. Examine Phase 2 implementation for patterns
4. Follow established architecture (service + cubit + widget)

---

## 🐛 Known Issues & Workarounds

### Current Issues (Phase 2)
- None critical - all systems production-ready
- See **implementation-roadmap.md** for resolved Phase 2 issues

### Pre-Existing Issues (Phase 1)
- CombatCubit could use refactor (low priority)
- GamePage layout could be split into smaller widgets (low priority)
- RandomEncounterService could be more testable (low priority)

---

## 🤝 Contributing

### Code Style
- Follow Dart conventions (camelCase for variables, CapitalCase for classes)
- Use immutable models with Freezed
- Write comprehensive tests before merging
- Document public APIs

### Testing Requirements
- Unit tests for business logic (domain layer)
- BLoC tests for state management
- Integration tests for workflows
- Aim for >80% coverage on critical paths

### Documentation Requirements
- Update PLAYER_GUIDE.md for user-facing changes
- Update implementation-roadmap.md for architectural changes
- Inline comments for complex logic
- Design doc for new systems

---

## 📞 Questions & Support

- **Design questions?** Check `docs/design/` folder
- **Architecture questions?** See implementation-roadmap.md
- **Gameplay questions?** Read PLAYER_GUIDE.md
- **Phase 3 planning?** Review roadmap Phase 3 section

---

## 📦 Version Info

- **Current Build:** Phase 2C Complete
- **Flutter Version:** 3.x
- **Dart Version:** 3.8.1+
- **Last Updated:** March 17, 2026
- **Status:** Production-ready for Phase 2 playtesting

---

Happy gaming and coding! 🚁
