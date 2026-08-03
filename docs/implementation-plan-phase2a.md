# Phase 2A: NPC Trading Network - Implementation Plan

**Objective:** Implement 6 NPCs with full trading system, persistence, reputation, and bust mechanics.

**Duration:** 1 week (20 hours)

**Definition of Done:**
- ✅ 6 NPCs implemented and fully tradeable
- ✅ Reputation persists across game restarts
- ✅ Supply decay prevents exploitation
- ✅ Bust mechanics tested and balanced
- ✅ All tests passing
- ✅ Game playable with NPC routes as alternative to market trading

---

## Step 1: Data Model & Persistence (2 hours)

**Goal:** Add NPC state to game persistence layer.

### 1.1 Create NPC Models
- [ ] `lib/domain/npc/entities/npc.dart` (already stubbed, flesh it out)
  - Add all NPC template data
  - Add supply decay tracking
  - Add bust mechanics

- [ ] `lib/domain/npc/entities/npc_relationship.dart` (new file)
  ```dart
  class NpcRelationship {
    String npcId;
    int reputation;           // 0-100
    int suppliesUsedThisTurn; // Track decay
    bool isUnavailable;       // Busted?
    DateTime? lastTradeDate;
    List<String> rivals;      // Current rivalries
  }
  ```

- [ ] `lib/domain/npc/entities/npc_roster.dart` (new file)
  - Define 6 starter NPCs as constants
  - Store NPC templates (name, role, location, multiplier, bust chance)

### 1.2 Update GameSession Serialization
- [ ] Add `npcRelationships: Map<String, NpcRelationship>` to `GameSession`
- [ ] Update `GameSession` json_serializable to include NPC state
- [ ] Migration: Load old sessions, initialize empty NPC relationships

### 1.3 Create NPC Repository
- [ ] `lib/domain/npc/repositories/npc_repository.dart`
  - Get NPC by ID
  - Get NPCs at location
  - Get NPC relationship
  - Update NPC relationship

**Tests:**
- [ ] `test/domain/npc/entities/npc_test.dart` - NPC data validation
- [ ] `test/domain/npc/repositories/npc_repository_test.dart` - CRUD operations

---

## Step 2: State Management (3 hours)

**Goal:** Create NpcNetworkCubit to manage all NPC state.

### 2.1 Create NpcNetworkCubit
- [ ] `lib/presentation/cubits/npc_network/npc_network_cubit.dart`
  ```dart
  class NpcNetworkCubit extends Cubit<NpcNetworkState> {
    // Methods:
    - tradeWithNpc(npcId, drugType, quantity)
    - getAvailableNpcsAtLocation(locationIndex)
    - getNpcReputation(npcId)
    - applyDecay()  // Called per turn
    - handleBust(npcId)
    - addReputation(npcId, amount)
  }
  ```

- [ ] `lib/presentation/cubits/npc_network/npc_network_state.dart`
  - `NpcNetworkState` with `npcRelationships`, `currentRivals`, `unavailableNpcs`

### 2.2 Register with GetIt DI
- [ ] Add `NpcNetworkCubit` to `lib/injection_container.dart`
- [ ] Wire it to receive `GameSession` on load

### 2.3 Wire Into GameCubit
- [ ] `GameCubit` should inject `NpcNetworkCubit`
- [ ] On `travel()`, call `npcNetworkCubit.applyDecay()`
- [ ] On game end, save NPC relationships back to `GameSession`

**Tests:**
- [ ] `test/presentation/cubits/npc_network_cubit_test.dart` (5 tests)
  - Test reputation tracking
  - Test supply decay
  - Test bust mechanics
  - Test rivalry system
  - Test unavailability after bust

---

## Step 3: Trading System Integration (4 hours)

**Goal:** Wire NPC prices into buy/sell flow.

### 3.1 Update PriceGenerator
- [ ] Add method `getNpcPrice(npcId, drugType)`
  - Takes NPC reputation into account
  - Applies relationship bonus
  - Returns markup/discount

### 3.2 Update GameCubit.buyDrug()
- [ ] Check if trading with NPC vs market
- [ ] If NPC:
  - Get price from NPC
  - Roll bust chance
  - If busted: arrest + lose cargo + heat +30
  - If success: add reputation +5, reduce supply
  - Update NPC supply decay

- [ ] If market: use existing logic

### 3.3 Update GameCubit.sellDrug()
- [ ] Check if selling to NPC buyer vs market
- [ ] If NPC buyer:
  - Get demand from NPC
  - Get price (markup based on reputation)
  - Roll bust chance (lower than supplier)
  - If success: add reputation +5, increase demand decay

- [ ] If market: use existing logic

### 3.4 Add Arrest Flow
- [ ] When busted: `onBust(npcId)` callback
- [ ] Show modal: "You were arrested!"
- [ ] Options:
  - Continue game (lose cargo, player health -50)
  - Use lawyer (one-time, costs $5k)

### 3.5 Add Supply Decay Timer
- [ ] At turn end, call `npcNetworkCubit.applyDecay()`
- [ ] Each NPC loses 20% of available supply per turn
- [ ] Restock when supply reaches 0

**Tests:**
- [ ] `test/presentation/cubits/game_cubit_npc_test.dart` (8 tests)
  - NPC buy pricing
  - NPC sell pricing
  - Bust chance mechanics
  - Supply decay
  - Reputation changes
  - Arrest flow
  - Lawyer usage
  - Cannot trade when unavailable

---

## Step 4: UI - NPC List & Trading (3 hours)

**Goal:** Show NPCs at location and allow trading.

### 4.1 Create NpcListWidget
- [ ] `lib/presentation/widgets/npc_list_widget.dart`
  - Show NPCs available at current location
  - Display: Name, Role, Reputation (0-100), Status (Available/Busted)
  - Tap to trade

### 4.2 Create NpcTradeDialog
- [ ] `lib/presentation/widgets/npc_trade_dialog.dart`
  - Show NPC details (name, reputation, price multiplier)
  - Drug selector dropdown
  - Quantity slider
  - Show final price vs market price
  - Risk warning (bust chance %)
  - Trade button
  - Cancel button

### 4.3 Create NpcRelationshipWidget
- [ ] `lib/presentation/widgets/npc_relationship_widget.dart`
  - Reputation bar (0-100)
  - "Stranger" / "Regular" / "Friend" / "Trusted" labels
  - Last trade timestamp
  - Supply level indicator (for suppliers)
  - Demand level indicator (for buyers)

### 4.4 Update GamePage
- [ ] Add NPC section to current location view
- [ ] Show NPC list when at location with NPCs
- [ ] Replace/supplement "Travel tab" for NPC interactions

### 4.5 Add Arrest Modal
- [ ] `lib/presentation/widgets/arrest_dialog.dart`
  - "You were arrested!"
  - Show consequences (health -50, heat +30, cargo lost)
  - Options: Continue / Use Lawyer (if available)

**Tests:**
- [ ] `test/presentation/widgets/npc_list_widget_test.dart` (3 tests)
- [ ] `test/presentation/widgets/npc_trade_dialog_test.dart` (4 tests)

---

## Step 5: Integration Testing (2 hours)

**Goal:** Full end-to-end NPC trading flow.

### 5.1 Create Integration Tests
- [ ] `test/integration/npc_trading_integration_test.dart` (10 tests)
  - Start game with fresh NPC relationships
  - Trade with supplier (price, reputation, supply decay)
  - Trade with buyer (demand, markup, reputation)
  - Get busted, fail arrest roll
  - Use lawyer to avoid arrest
  - Reputation decays when not trading
  - Can't trade with unavailable NPC
  - Rivalries prevent trading with competing NPC
  - Fixer reduces heat
  - Doctor heals health

### 5.2 Verify Balance
- [ ] Check: No single NPC more profitable than market routes
- [ ] Check: Supply decay prevents exploitation
- [ ] Check: Bust chance feels risky (5-8% base)
- [ ] Check: High reputation (80+) makes NPCs safe (bust chance ~0%)

### 5.3 Manual Playtesting
- [ ] Start new game, trade with all 6 NPCs
- [ ] Verify relationships persist on restart
- [ ] Verify UI displays correctly
- [ ] Verify arrest/lawyer flow works
- [ ] Verify decay prevents farming single NPC

---

## File Changes Summary

### New Files
- `lib/domain/npc/entities/npc_relationship.dart`
- `lib/domain/npc/entities/npc_roster.dart`
- `lib/domain/npc/repositories/npc_repository.dart`
- `lib/presentation/cubits/npc_network/npc_network_cubit.dart`
- `lib/presentation/cubits/npc_network/npc_network_state.dart`
- `lib/presentation/widgets/npc_list_widget.dart`
- `lib/presentation/widgets/npc_trade_dialog.dart`
- `lib/presentation/widgets/npc_relationship_widget.dart`
- `lib/presentation/widgets/arrest_dialog.dart`
- `test/domain/npc/entities/npc_test.dart`
- `test/domain/npc/repositories/npc_repository_test.dart`
- `test/presentation/cubits/npc_network_cubit_test.dart`
- `test/presentation/cubits/game_cubit_npc_test.dart`
- `test/presentation/widgets/npc_list_widget_test.dart`
- `test/presentation/widgets/npc_trade_dialog_test.dart`
- `test/integration/npc_trading_integration_test.dart`

### Modified Files
- `lib/domain/npc/entities/npc.dart` (flesh out)
- `lib/domain/game/entities/game_session.dart` (add NPC state)
- `lib/domain/trading/services/price_generator.dart` (add NPC pricing)
- `lib/presentation/cubits/game/game_cubit.dart` (wire NPC trades)
- `lib/presentation/pages/game_page.dart` (add NPC UI)
- `lib/injection_container.dart` (register NpcNetworkCubit)
- `pubspec.yaml` (ensure json_serializable)

---

## Risk Mitigation

**Risk: NPC pricing becomes too profitable**
- Mitigation: Heavy supply decay (20% per turn)
- Mitigation: Bust chances scale with frequency
- Mitigation: Rivalries limit max usable NPCs

**Risk: State bloat (NpcNetworkCubit grows too large)**
- Mitigation: Keep Cubit focused on relationship tracking only
- Mitigation: PriceGenerator handles pricing logic
- Mitigation: GameCubit orchestrates the flow

**Risk: Serialization breaks old saves**
- Mitigation: Migration logic in GameSession loader
- Mitigation: Gracefully initialize empty NPC relationships

**Risk: Tests become too complex**
- Mitigation: Mock NpcRepository for unit tests
- Mitigation: Use DeterministicRandomGenerator for reproducible tests
- Mitigation: Keep integration tests to happy-path + 1-2 edge cases

---

## Success Metrics

After completing Phase 2A:

1. **Functionality**
   - ✅ 6 NPCs tradeable with different prices
   - ✅ Reputation system working (increases/decreases)
   - ✅ Bust mechanics implemented (5-8% base rate)
   - ✅ Supply decay prevents exploitation
   - ✅ Rivalries limit profitable NPCs to 3-4 max

2. **Testing**
   - ✅ 40+ new tests, all passing
   - ✅ Integration tests cover happy path + edge cases
   - ✅ Manual playtesting confirmed playable

3. **Balance**
   - ✅ Best NPC route ≈ best market route (within 10%)
   - ✅ Bust feeling risky but not unfair
   - ✅ Reputation system creates interesting trade-offs

4. **Code Quality**
   - ✅ No new technical debt
   - ✅ State management clean and testable
   - ✅ UI components reusable

---

## Ready to Start?

Before we begin coding, confirm:

1. ✅ Scenario trigger spec complete?
2. ✅ NPC system spec complete?
3. ✅ Implementation order approved?
4. ✅ Ready to start Step 1 (Data Model & Persistence)?

