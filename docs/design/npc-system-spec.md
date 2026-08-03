# NPC Trading Network System Specification

## Overview

NPCs provide alternative trading routes with dynamic pricing based on relationship. They introduce both opportunity (better deals) and risk (reputation costs, rivalries, bust chances).

---

## NPC Archetypes (5 Core Roles)

### 1. Supplier
Sells drugs at quantity discounts. Lower prices than market, but limited supply per turn.

**Example:** "Street chemist" in Lagos
- **Base markup:** -15% (sells 15% below market)
- **Supply per turn:** 20-50 units of specialty drugs
- **Pricing:** Fixed (no negotiation)
- **Bust chance:** 5% per trade
- **Relationship bonus:** -10% per 5 reputation levels (max -30%)

### 2. Buyer
Purchases drugs at premium prices. Limited demand per turn.

**Example:** "Club owner" in New York
- **Base markup:** +20% (buys 20% above market)
- **Demand per turn:** 10-30 units
- **Negotiation:** Yes, +5% per 10 reputation
- **Bust chance:** 3% per large sale (>$50k)
- **Reliability:** 95% chance they have cash

### 3. Fixer
Reduces heat by paying bribes. Expensive but effective.

**Example:** "Corrupt official" in Tokyo
- **Cost:** $500-$1000 per heat point
- **Heat reduction:** 1:1 (spend $500 = -1 heat)
- **Bust chance:** 8% if used repeatedly
- **Availability:** Once per 3 turns
- **Relationship:** Cheaper as reputation increases (-5% per level)

### 4. Lawyer
Reduces consequences of arrest or police encounters. One-time use per game.

**Example:** "Street lawyer" in Rio
- **Cost:** $5000-$10000
- **Effect:** Convert one arrest to fine instead
- **Availability:** Once per game
- **Bust chance:** None
- **Reliability:** 100%

### 5. Doctor
Heals player health outside of combat. Expensive.

**Example:** "Black market medic" in Cape Town
- **Cost:** $100-$500 per health point
- **Effect:** Restore health (max 100)
- **Availability:** Always
- **Bust chance:** 2% per visit
- **Speed:** Instant

---

## NPC Attributes

Each NPC has:

```dart
class NpcTemplate {
  String id;                    // "supplier_1_lagos"
  String name;                  // "Street Chemist"
  NpcRole role;                 // supplier, buyer, fixer, lawyer, doctor
  LocationType baseLocation;    // Where they're found

  // Pricing
  double priceMultiplier;       // -0.15 (supplier), +0.20 (buyer)
  int supplyPerTurn;            // How much they offer (suppliers)
  int demandPerTurn;            // How much they want (buyers)

  // Risk
  double bustChance;            // 0.05 (5% per trade)
  double reliabilityRate;       // 0.95 (95% chance they show up)

  // Relationship
  double reputationBonus;       // -0.05 per reputation level
  int maxReputation;            // Capped relationship (100 = complete trust)
}
```

---

## Relationship System

### NPC Reputation (0-100)

Each NPC relationship is tracked independently.

**How reputation increases:**
- Successful trade: +5 reputation
- Large trade (>$50k): +10 reputation
- Repeat trading: +2 per additional trade (up to 30 total)

**How reputation decreases:**
- Failed trade/arrest during trade: -20 reputation
- Not trading for 10 turns: -1 per turn (represents cooling off)
- Betrayal (selling to rival): -30 reputation

**Reputation Effects:**
- 0-20: "Stranger" - baseline pricing, high bust chance
- 21-50: "Regular" - 10% better pricing, lower bust chance
- 51-80: "Friend" - 20% better pricing, much lower bust chance
- 81-100: "Trusted" - 30% better pricing, minimal bust chance

---

## Supply Caps (Arbitrage Prevention)

**Core Rule:** No NPC can be traded with more than once per 5 turns profitably.

### Supplier Supply Decay
```
turn 1: 50 units available
turn 2: 40 units available (20% decay)
turn 3: 30 units available
turn 4: 20 units available
turn 5: 10 units available
turn 6: Restocks (back to 50)
```

**Rationale:** Player can't just buy everything from one supplier repeatedly.

### Buyer Demand Fluctuation
```
turn 1: 30 units wanted
turn 2: 25 units wanted (20% decay)
turn 3: 20 units wanted
turn 4: 15 units wanted
turn 5: 10 units wanted
turn 6: Resets to 30
```

---

## NPC Rivalries

NPCs compete with each other. Trading with one can make others jealous.

### Rivalry Rules

**When you trade with Supplier A:**
- Rivalry: 1-3 other suppliers get -10% reputation penalty
- Duration: 3 turns
- Effect: They offer worse prices or refuse to trade

**When you trade with Buyer A:**
- Rivalry: Other buyers in same region get -15% markup
- Duration: 2 turns
- Effect: They'll pay less for drugs

**Relationship threshold:** Rivalries only activate if both have reputation >= 40

---

## Bust Mechanics

**What happens when busted with NPC:**

1. **Arrest:** Player taken to jail, loses cargo, heat +30
2. **NPC Impact:** That NPC permanently loses 50% of reputation
3. **Contagion:** Related NPCs (same role in region) lose -20 reputation
4. **Recovery:** Takes 10 turns before NPC will deal with you again

**Bust Chance Calculation:**
```
base_chance = role.bustChance          // 0.05 for supplier
heat_modifier = globalHeat * 0.01      // +1% per heat level
relationship_bonus = -reputation / 500 // -0.2% per reputation level
final_chance = base_chance + heat_modifier + relationship_bonus

Example:
- Supplier base: 5%
- Player heat: 50 (+5%)
- Reputation: 80 (-16%)
- Final: 5% + 5% - 16% = -6% (clamped to 0%)
```

High relationship literally makes you safer.

---

## Initial NPC Roster (Phase 2A - MVP)

Start with **6 NPCs** across different locations and roles:

| Name | Role | Location | Markup | Notes |
|------|------|----------|--------|-------|
| "Street Chemist" | Supplier | Lagos | -15% | Cheap, frequent busts |
| "Club Owner" | Buyer | New York | +20% | Reliable, high demand |
| "Fixer" | Fixer | Rio | - | $500/heat, 8% bust rate |
| "Lawyer" | Lawyer | Cape Town | - | One-time save, $5k |
| "Doc" | Doctor | Tokyo | - | Heal $100/hp, 2% bust |
| "Cartel Supplier" | Supplier | Mexico City | -10% | More dangerous |

**Phase 2B (Expansion):** 8-14 more NPCs

---

## NPC Persistence

**What needs to persist across game sessions:**
- Reputation with each NPC (0-100)
- Last trade timestamp (for decay calculation)
- Bust history (is NPC currently unavailable?)
- Rival status (who dislikes player right now?)

**Storage:** GameSession serialization includes `npcRelationships: Map<String, NpcRelationship>`

```dart
class NpcRelationship {
  String npcId;
  int reputation;              // 0-100
  DateTime lastTrade;          // When did we last trade?
  bool isUnavailable;          // Busted? Wait 10 turns.
  List<String> currentRivals;  // Who's mad at us?
}
```

---

## Phase 2A Implementation Plan

### Week 1: Core NPC System

1. **Persistence Layer (2 hours)**
   - Add `NpcRelationships` to `GameSession`
   - Implement serialization with json_serializable

2. **NPC State Management (3 hours)**
   - Create `NpcNetworkCubit` (separate from GameStateCubit)
   - Wire reputation tracking
   - Implement decay logic

3. **Trading Integration (4 hours)**
   - Wire NPC prices into `GameCubit.buyDrug()` / `sellDrug()`
   - Add bust chance rolls
   - Implement arrest flow

4. **NPC UI (3 hours)**
   - List view of available NPCs at current location
   - Trade dialog with NPC pricing
   - Reputation display

5. **Testing (2 hours)**
   - Unit tests for reputation system
   - Integration tests for NPC trades
   - Bust chance distribution tests

---

## Design Decisions & Rationale

**Why fixed supply/demand decay?**
- Prevents "infinite profit" from one source
- Forces route diversification
- Encourages NPC network growth

**Why relationship-based pricing?**
- Rewards player for commitment to NPCs
- Creates emotional investment
- Differentiates from market trading

**Why bust chance decreases with reputation?**
- Safety = relationship reward
- High reputation = "they trust you"
- Counterintuitive but makes sense narratively

**Why rivalries?**
- Prevents "collect all NPCs" exploit
- Adds drama and player choice
- Limits max profitable NPCs to 3-4

---

## Success Criteria for Phase 2A

✅ 6 NPCs fully implemented and tradeable
✅ Reputation persists across sessions
✅ Supply decay prevents repeated exploitation
✅ Bust mechanics work and feel risky
✅ Rivalries create interesting trade-offs
✅ No single NPC route more profitable than market routes

