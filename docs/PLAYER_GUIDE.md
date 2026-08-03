# DopeWars - Player Guide

Welcome to DopeWars! This modernized version of the classic game features global trading, dynamic law enforcement, NPCs with relationships, dynamic scenarios, and contract missions that reward smart play.

## Table of Contents

1. [Game Overview](#game-overview)
2. [Locations & Trading](#locations--trading)
3. [Heat & Reputation System](#heat--reputation-system)
4. [Travel Mechanics](#travel-mechanics)
5. [Strategy Tips](#strategy-tips)
6. [NPCs & Relationships](#npcs--relationships-phase-2a)
7. [Scenarios & Dynamic Events](#scenarios--dynamic-events-phase-2b)
8. [Contracts & Missions](#contracts--missions-phase-2c)
9. [Game Balance](#game-balance)
10. [Common Mistakes](#common-mistakes-to-avoid)
11. [Glossary](#glossary)
12. [Phase History](#phase-history)
13. [Resources](#resources)

---

## Game Overview

You have 31 turns to build wealth by trading drugs across 12 global locations. Balance profit with risk — high heat from police brings consequences, but smart trades build your reputation.

**Goal:** Maximize net worth (cash + bank - debt + inventory value)

---

## Locations & Trading

### 12 Global Cities

Each location has unique characteristics:

| Location | Region | Price Level | Police Risk | Special |
|----------|--------|------------|------------|---------|
| **New York** | North America | 1.0x (baseline) | Medium | Bank, Loan Shark |
| **Los Angeles** | North America | 0.9x (cheap) | High | Gun Shop, Pub |
| **Mexico City** | Latin America | 0.5x (very cheap) | Low | - |
| **London** | Europe | 1.5x (expensive) | High | - |
| **Cape Town** | Africa | 0.7x (cheap) | Very High | - |
| **Tokyo** | Asia | 1.8x (very expensive) | Very High | - |
| **Macau** | Asia | 1.6x (expensive) | Medium | Bank |
| **Rio de Janeiro** | Latin America | 0.4x (very cheap) | Low | Pub |
| **Paris** | Europe | 1.6x (expensive) | Medium | - |
| **Barcelona** | Spain | 1.3x (expensive) | Medium | Port (future) |
| **Lagos** | Africa | 0.3x (cheapest) | Very Low | - |
| **Dark Web** | Virtual | 1.2x (premium) | Very Low | All drugs |

### Price Multipliers

Prices vary by location:
- **Cheap regions** (South America, Africa): Good for buying
- **Expensive regions** (Europe, Asia): Good for selling
- **Premium price** varies by drug availability and supply/demand

### Supply & Demand

The market is dynamic:
- **When you buy:** Supply decreases, prices increase slightly next turn
- **When you sell:** Supply increases (market absorbs your goods), prices decrease
- **Natural recovery:** Supply recovers 10 units per turn
- **Effect:** Repeated trades on the same route become less profitable — diversify!

### Transaction Taxes

Each location charges a "street tax" on all trades:
- **Lagos** (2%): Lowest tax, safest for locals
- **New York** (5%): Standard
- **Tokyo** (10%): Highest tax, yakuza takes a cut
- **Dark Web** (15%): Premium for anonymity

---

## Heat & Reputation System

### Heat Level (0-100)

Heat represents police attention. Higher heat = more police encounters.

**Heat increases when:**
- Police encounter happens (+15)
- Large transaction (>$50,000) (+5)
- You enter combat with police (+varies)

**Heat decreases when:**
- Time passes (automatically: -2 per turn)
- Laying low without crime

### Reputation (0-100)

Your street cred. Higher reputation unlocks NPC relationships (future update).

**Reputation increases when:**
- Successful trades
- Beating police in combat
- Completing contracts

**Reputation decreases when:**
- Losing fights
- Getting arrested
- Running from conflict

### Police Encounters

Police chance depends on:
1. **Location police presence** (varies by city)
2. **Your heat level** (adds 0-10 bonus to encounter chance)
3. **Drugs carried** (must carry drugs to be caught)

**Formula:** Encounter chance = base police presence + (your heat ÷ 10)

**Example:**
- Lagos police presence: 20%
- Your heat: 50
- Effective police chance: 20 + 5 = 25%

### Wanted Levels (Future)

Each law enforcement agency will track your wanted status separately:
- **DEA** (USA jurisdiction)
- **Interpol** (Global)
- **Local agencies** (Region-specific)

Currently, all law enforcement is represented by generic cops.

---

## Travel Mechanics

### Traveling Between Locations

**Mobile (bottom-sheet travel):**
1. Tap the **airplane FAB** (floating action button) in bottom-right
2. Select destination from the list
3. See risk assessment (police presence indicator)
4. Confirm travel

**Desktop (left sidebar):**
- Click location in the location selector
- Special buttons appear if you're at a location with bank/loan shark/etc.

### Travel Effects

When you travel:
- **Turn advances** (+1 turn)
- **Interest applied**:
  - Debt grows 10% per turn
  - Bank balance grows 5% per turn
- **Random encounters** may occur (mugging, finding cash/drugs)
- **Police check** happens (based on heat + drugs carried)
- **New market generated** at destination

---

## Strategy Tips

### Building Wealth

1. **Start conservative**: Early game, small trades minimize risk
2. **Identify patterns**:
   - Buy cheap in Lagos/Rio/Mexico City
   - Sell expensive in Tokyo/London/Paris
   - But watch for supply/demand shifts!
3. **Diversify routes**: Don't trade the same path repeatedly
   - Supply becomes saturated
   - You become predictable to police

### Managing Heat

1. **Travel to low-police areas** when heat is high
   - Lagos (20% base) vs Tokyo (90% base)
   - High heat + high police presence = certain arrest
2. **Lay low**: Skip a few turns in safe zones to let heat decay
   - Heat decreases 2 per turn naturally
3. **Avoid large transactions** when heat is rising
   - Over $50,000 deals add 5 heat
   - Small, frequent deals are safer

### Dealing with Police

**In Combat:**
- Shoot: Risk death but potentially win
- Flee (50% success): Escape but might take damage
- Having guns helps your accuracy

**Prevention is better:**
- Check police presence before traveling
- Reduce drugs carried (smaller load = less likely to be stopped)
- Lower your heat proactively

### Using Special Locations

**Bank (New York, Macau):**
- Deposit cash to earn 5% interest per turn
- Withdraw when you need liquidity
- Interest pays more than trading profit if you have patience

**Loan Shark (New York):**
- Borrow money at cost (10% interest per turn)
- Useful for early trades if you're short on cash
- High-interest debt compounds fast — pay it off!

**Gun Shop (Los Angeles):**
- Buy better guns for higher accuracy in combat
- Guns take inventory space (4 units each)

**Pub (Los Angeles, Rio):**
- Hire "bitches" (helpers) to increase carrying capacity
- Expensive but allows bigger trades

---

## NPCs & Relationships (Phase 2A)

### NPC Trading Network

The game now features **5 specialized traders** with unique roles:

| Role | Specialty | Benefit | Risk |
|------|-----------|---------|------|
| **Supplier** | Buys your drugs at markup | Lower prices than market | Bust chance (8-15%) |
| **Buyer** | Sells you drugs at discount | Cheaper bulk buys | Supply caps (3-15 units/turn) |
| **Fixer** | Arranges local deals | Fast transactions | High reputation requirement |
| **Lawyer** | Legal protection services | Reduces heat impact | Expensive retainer fees |
| **Doctor** | Medical supplies & services | Restores health | Limited availability |

### Trading with NPCs

**How it works:**
1. View NPC list in the game sidebar (wide layout) or scroll to find NPCs
2. Select an NPC to trade with
3. Pricing adjusts based on:
   - **Base market price** (same as regular trading)
   - **Reputation bonus** (up to 20% discount if you have good reputation)
   - **Supply caps** (NPCs have daily limits to prevent unlimited profit)
4. Roll for bust chance — you could be arrested if unlucky

**Building Reputation with NPCs:**
- Complete trades successfully → increase relationship
- Higher reputation → better prices and larger supply caps
- Low reputation → NPCs refuse to trade with you
- Reputation decays if you get arrested or trade with rivals

### NPC Supply Caps

Each NPC has daily supply limits (varies by role):
- **Suppliers:** 5-15 units per turn (varies by inventory)
- **Buyers:** 3-10 units per turn (depends on demand)
- **Supply regenerates** 10% per turn (recovery rate)

**Strategy:** Don't rely on a single NPC; diversify your network!

### Bust Chance

When trading with an NPC, there's a risk of police attention:
- **Bust chance:** 8-15% depending on NPC reliability
- **If caught:** Your cargo is confiscated, +30 heat, reputation loss
- **Mitigation:** Lower your heat before risky trades, build strong NPC relationships (reduces detection risk)

---

## Scenarios & Dynamic Events (Phase 2B)

### Dynamic Scenario System

As you travel, **unexpected events** occur with increasing frequency. There are **20 unique scenarios** that create strategic challenges:

### Scenario Types

| Type | When | Impact | Example |
|------|------|--------|---------|
| **Supply Surge** | Market gluts | Prices crash 30-50% | "A rival dealer got busted; market flooded" |
| **Police Crackdown** | High heat areas | Heat increases, police frequent | "DEA task force in town" |
| **Gang War** | Territory disputes | Risk/reward trades | "Local gangs fighting for turf" |
| **Price Spike** | Demand surge | Prices surge 20-40% | "Celebrity uses drug; demand booms" |
| **Opportunity** | Random luck | Find cash/drugs/contacts | "You meet a black market contact" |

### How Scenarios Work

1. **Trigger:** When you travel, scenario service rolls for an event (varies by location/heat)
2. **Present choice:** You're given 2-3 options with different outcomes
3. **Choose wisely:** Each choice has rewards and penalties
4. **Outcome applied:** Cash/health/heat/reputation update immediately

### Example Scenario

```
EVENT: "Cartel Message"
You're approached by a mysterious dealer. They offer:

[A] Buy 50 units of heroin at 50% off market price
    → Reward: $25,000 profit (risky: +10 heat)

[B] Politely decline
    → Safe: no consequences

[C] Report them to police for bounty
    → Reward: +50 reputation, -15 heat
    → Cost: $5,000 bribe for tip-off
```

### Scenario Cooldowns

- **One scenario per travel** (prevents spam)
- **3-turn cooldown** per scenario type (avoid repeats)
- **Heat-based probability** (higher heat = more scenarios)

### Strategy Tips for Scenarios

1. **High heat = more events** → either avoid dangerous routes or embrace the chaos
2. **Scenarios can swing fortunes** → a lucky event can fund your next venture
3. **Scenario choices matter** → sometimes safe beats greedy
4. **Record good scenarios** (mentally) and route through those locations strategically

---

## Contracts & Missions (Phase 2C)

### Mission System

**Contracts** (or "jobs") offer fixed-reward missions with multi-turn objectives. There are **5 active mission types** in Phase 2 (plus 5 stubbed for Phase 3):

### Contract Types (Phase 2)

| Type | Objective | Reward | Turns | Difficulty |
|------|-----------|--------|-------|------------|
| **Transport** | Deliver drugs A→B | $50k-$75k | 5-8 | ⭐⭐ |
| **Logistics** | Multi-city supply chain | $80k-$100k | 10-15 | ⭐⭐⭐ |
| **Stealth** | Avoid police (Phase 3) | $20k-$50k | 5-15 | ⭐⭐⭐⭐ |
| **Collection** | Reach net worth target (Phase 3) | $25k-$100k | 20-30 | ⭐⭐⭐⭐⭐ |

### How Contracts Work

**Accepting a contract:**
1. Open the JOBS panel (tab on mobile, left sidebar on desktop)
2. See **AVAILABLE** section with open jobs
3. Click **[ACCEPT]** to activate a contract
4. Contract moves to **ACTIVE** section

**Completing a contract:**
- **Transport/Logistics:** Progress increases when you visit target locations
  - Each target location = +25% progress
  - Reach 100% = mission complete
- **Time limit:** You have N turns to complete (turn limit shown)
  - Exceeding limit = mission fails
  - Few turns left = red warning

**Rewards:**
- **Cash bonus** on completion (varies by contract difficulty)
- **Reputation bonus** (builds your street cred)
- Instant payout — no negotiation

### Contract Strategy

1. **Accept early:** Activate missions on turn 1-5 to give yourself time
2. **Chain logistics:** Multi-city contracts reward you for exploring
3. **Plan routes:** Map out cities beforehand, avoid police-heavy areas
4. **Diversify:** Accept contracts with different timelines (short + long)
5. **Don't overcommit:** Completing 1-2 contracts is usually better than abandoning 5

### Abandoning Contracts

- Click **[ABANDON]** (red button) on active contracts
- Contract marked as **FAILED**
- No penalty currently (Phase 3 will add reputation loss)
- Frees you to accept different contracts

### Contract Refresh

- **New contracts generate every 5 turns**
- You'll always have 2-3 available jobs
- Mix of easy/hard difficulty
- Rewards scale with difficulty

---

## Game Balance

The game is designed to be **challenging but fair**:

- No single "guaranteed profit" route exists
- Heat increases police attention meaningfully
- Supply/demand shifts reward adaptability
- Early debt is manageable if you play smart
- Late game (turns 25+) requires careful planning

### Winning Conditions

You "win" by:
1. Surviving all 31 turns
2. Accumulating maximum net worth
3. Reaching the high score list

**Average winning net worth:** $500k - $2M (depending on difficulty)

---

## Common Mistakes to Avoid

1. **Ignoring heat**: High heat is deadly. Manage it actively.
2. **Repeating the same trade**: Supply dries up; prices tank.
3. **Overleveraging debt**: 10% interest per turn adds up fast.
4. **Carrying too much**: Large shipments = high police detection.
5. **Underestimating police**: Even at "low risk," encounters happen.

---

## Glossary

- **Heat**: Police attention level (0-100)
- **Reputation**: Your street credibility (0-100)
- **Net Worth**: Total assets (cash + bank - debt + inventory)
- **Price Multiplier**: How expensive a location is (0.3x - 1.8x)
- **Supply/Demand**: Market dynamics that shift prices based on activity
- **Transaction Tax**: Local "cut" taken on each trade
- **Wanted Level**: Your criminal status with specific agencies (future)

---

## Phase History

### ✅ Phase 1: Foundation (Completed)
- [x] 12 global locations with regional pricing
- [x] Heat & reputation system
- [x] Police encounters with dynamic probability
- [x] Supply/demand market mechanics
- [x] Special locations (bank, loan shark, gun shop, pub)

### ✅ Phase 2A: NPC Trading Network (Completed)
- [x] 5 NPC traders with specialized roles
- [x] NPC relationship & reputation system
- [x] Dynamic pricing based on relationships
- [x] Bust chance mechanics during NPC trades
- [x] Supply cap system per NPC

### ✅ Phase 2B: Dynamic Scenario System (Completed)
- [x] 20 unique scenario templates
- [x] Scenario trigger engine (location/heat-aware)
- [x] Multi-choice outcomes with branching results
- [x] Scenario cooldown & spam prevention
- [x] Impact on cash, health, heat, reputation

### ✅ Phase 2C: Contracts & Missions (Completed)
- [x] 5 active contract types (Transport, Logistics)
- [x] 5 stubbed for Phase 3 (Stealth, Collection)
- [x] Contract generation system (2-3 per turn)
- [x] Progress tracking with visual indicators
- [x] Completion rewards (cash + reputation)
- [x] Accept/abandon mechanics
- [x] Responsive UI (mobile tabs + desktop panel)

## Upcoming Features (Phase 3 & Beyond)

### Phase 3: Polish & Expansion
- **Skill System**: Specialize in combat, trading, stealth, driving, hacking (5 skill trees)
- **Complete Contracts**: Stealth & collection contract implementation
- **Agency System Integration**: Region-specific law enforcement with escalating wanted levels
- **World Map**: Interactive visualization with heat maps and trade routes

### Future Phases
- **Advanced Combat**: Agency-specific encounters, weapon tiers
- **Expanded NPCs**: More traders, rivalries, dynamic relationships
- **Scenario Chains**: Multi-turn story arcs with persistent consequences
- **Visual Modernization**: Material 3 design, animations, themes

---

## Resources

- **Design Docs:** See `docs/design/` for system specifications
- **Architecture:** See `docs/flutter-architecture.md` for code structure
- **Roadmap:** See `docs/implementation-roadmap.md` for development plans

Good luck, and stay out of trouble! 🚁
