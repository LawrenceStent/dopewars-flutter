# NPC Price Manipulation Mitigation Design

## Problem

With NPC traders added, players could build reputation with all cheap suppliers and all expensive buyers simultaneously, creating a guaranteed profit network that bypasses market dynamics.

---

## Strategy 1: Supply Caps Per NPC

### Mechanism
Each NPC has a maximum quantity they can buy/sell per turn. Caps vary by NPC archetype.

| NPC Archetype       | Max Qty/Turn | Reset     | Notes                        |
|----------------------|-------------|-----------|------------------------------|
| Street dealer        | 10          | Per turn  | Small, risky                 |
| Cartel boss          | 80-100      | Per turn  | Expensive, high volume       |
| Dark web merchant    | 50          | Per turn  | Premium, anonymous           |
| Street addict        | 5           | Per turn  | Tiny, desperate              |
| Club owner           | 30          | Per turn  | Bulk, recurring              |
| Corporate exec       | 15          | Per turn  | Premium prices, low volume   |

### Effect
Even if a player builds max rep with "Lisa Chen" (corporate exec buyer in London at 1.2x prices), she only buys 15 units per turn. The player can't dump 100 units of cocaine on her. Forces diversification across multiple NPCs.

### Fluctuation
NPC caps aren't fixed -- they fluctuate +/-20% per turn randomly. On some turns a supplier might only have 6 units available instead of 10.

---

## Strategy 2: Dynamic NPC Pricing

### Mechanism
NPCs remember your trade history and adjust prices accordingly.

### Price Memory Formula
```
priceAdjustment = basePriceModifier * (1 + memoryPenalty)

memoryPenalty = (tradeCount with this NPC in last 5 turns) * priceMemoryFactor
```

### Example: Miguel (Mexico City supplier)
- `basePriceModifier`: 0.85 (15% discount)
- `priceMemoryFactor`: 0.15

Trade history:
- Turn 1: Buy from Miguel. memoryPenalty = 1 * 0.15 = 0.15
- Turn 2: Buy again. memoryPenalty = 2 * 0.15 = 0.30
- Turn 3: Buy again. memoryPenalty = 3 * 0.15 = 0.45

Effective price modifier:
- Turn 1: 0.85 * (1 + 0.15) = 0.98 (barely a discount)
- Turn 2: 0.85 * (1 + 0.30) = 1.11 (now MORE expensive than market)
- Turn 3: 0.85 * (1 + 0.45) = 1.23 (significantly overpriced)

### Decay
If you don't trade with an NPC for 5 turns, their memory resets completely. At 3 turns, penalty halves. This creates a natural cooldown.

### "Welcome Back" Discount
If you haven't traded with an NPC for 5+ turns, they offer a one-time 10% discount to lure you back.

---

## Strategy 3: Reputation Costs

### Mechanism
Building reputation with NPCs has costs and consequences beyond just trading.

### Rep Building Rules
- Each trade with an NPC: +3 reputation
- Completing an NPC's personal request: +10 reputation
- Reputation gates: Some NPCs require minimum rep before trading
  - Street dealer: 0 (anyone can trade)
  - Cartel boss: 30 (need to prove yourself)
  - Corporate exec: 50 (need introductions)

### Heat from NPC Networks
```
npcNetworkHeat = numberOfActiveNpcRelationships * 2
```
- 3 NPCs with rep > 20: +6 heat per turn
- 8 NPCs with rep > 20: +16 heat per turn
- 12 NPCs with rep > 20: +24 heat per turn (very dangerous)

### Interpol Attention
If the player has active relationships with NPCs in 4+ different countries, Interpol wanted level increases by +5 per turn. This prevents building a global trading empire without consequences.

### Effect
Players must choose: wide network (many NPCs, high heat) vs deep network (few NPCs, better prices, manageable heat). Can't have both.

---

## Strategy 4: NPC Exclusivity & Rivalries

### Mechanism
Some NPCs are rivals. Building reputation with one actively decreases reputation with their rival.

### Rivalry Examples
```
Miguel (Mexico City supplier) <-> Carlos (Rio supplier)
  Building +5 rep with Miguel = -3 rep with Carlos

Lisa Chen (London buyer) <-> Viktor (Paris buyer)
  Building +5 rep with Lisa = -2 rep with Viktor

Shadow (Dark Web) <-> Every street-level NPC
  Building +5 rep with Shadow = -1 rep with ALL street dealers
```

### Rivalry Tiers
- **Bitter rivals:** +5 rep with A = -5 rep with B (zero sum)
- **Competitors:** +5 rep with A = -3 rep with B (slight loss)
- **Suspicious:** +5 rep with A = -1 rep with B (minor friction)

### Effect
Players cannot max out reputation with all suppliers. They must choose a network:
- Mexico City route (Miguel) OR Rio route (Carlos), not both
- London buyer (Lisa) OR Paris buyer (Viktor), not both

This creates meaningful player choice and prevents "collecting" all NPCs.

---

## Strategy 5: NPC Reliability

### Mechanism
NPCs can get arrested, disappear, or become unavailable. Higher-value NPCs are higher targets.

### Bust Chance Per Turn
| NPC Type          | Base Bust Chance | At Player Heat 50+ | At Player Heat 80+ |
|-------------------|-----------------|--------------------|--------------------|
| Street dealer     | 5%              | 8%                 | 12%                |
| Cartel boss       | 2%              | 5%                 | 10%                |
| Dark web merchant | 1%              | 2%                 | 3%                 |
| Corporate exec    | 3%              | 7%                 | 15%                |
| Fixer             | 1%              | 2%                 | 4%                 |

### Player Heat Contribution
If the player has high heat and recently traded with an NPC, the NPC's bust chance increases. Your heat makes your contacts vulnerable.

```
effectiveBustChance = baseBustChance + (playerHeat > 50 ? 3% : 0%) + (playerHeat > 80 ? 5% : 0%)
```

### What Happens When Busted
- NPC becomes `isActive = false`
- All reputation with that NPC resets to 0
- NPC may return after 5-10 turns (or never)
- Player's heat +5 (association)
- 30% chance the NPC snitches: player's wanted level +15 with local agency

### Effect
Players who rely on a single high-value NPC risk losing them. Diversification is safer but has its own costs (heat from network size). Creates natural tension.

---

## Strategy 6: Market Saturation

### Mechanism
NPC buyers have demand that depletes when you sell to them. Different buyers absorb stock at different rates.

### Demand Pool
Each buyer NPC has a demand pool per drug type:
```
demand[npc][drug] = maxDemand  // starts full
```

| Buyer Type      | Max Demand | Recovery/Turn | Notes                     |
|-----------------|-----------|---------------|---------------------------|
| Street addict   | 5         | 3             | Quick turnover, tiny       |
| Club owner      | 40        | 10            | Steady, moderate           |
| Corporate exec  | 20        | 5             | Slow, premium              |

### On Sale
```
demand[npc][drug] -= quantitySold
if demand <= 0:
    NPC refuses to buy more this turn
    "Lisa says she's stocked up for now."
```

### Recovery
Demand recovers by `recoveryRate` per turn the player doesn't sell to that NPC.

### Example
Lisa Chen (corporate exec, London):
- Max demand: 20 cocaine
- Player sells 20 cocaine to Lisa on turn 1
- Turn 2: Lisa's demand = 5 (recovered 5). Can only buy 5 units.
- Turn 3: Lisa's demand = 10. Can buy 10.
- Turn 4: Lisa's demand = 15.
- Turn 5: Lisa's demand = 20 (full recovery).

Player must wait 4 turns between max-volume sales to Lisa, or find other buyers.

---

## Combined Effect Analysis

### Scenario: Player tries to exploit Miguel (supplier) + Lisa (buyer)

**Setup:**
- Miguel: Mexico City, supplier, 80 max/turn, 0.85x price modifier
- Lisa: London, buyer, 15 max/turn, 1.2x price modifier

**Turn 1:**
- Buy 80 cocaine from Miguel at 0.85x: $12,750/unit * 80 = $1,020,000
- Travel to London (1 turn)

**Turn 2:**
- Sell 15 cocaine to Lisa at 1.2x: $34,800/unit * 15 = $522,000
- Lisa's demand: depleted (0 remaining)
- Remaining 65 cocaine must be sold at market price or carried

**Turn 3:**
- Lisa's demand: 5 units only. Sell 5 more: $174,000
- Still carrying 60 cocaine. Heat rising.

**Problem for player:**
- Lisa can only absorb 15/turn. 80 units takes 5+ turns to sell through her
- Miguel's price memory kicks in: next buy from Miguel costs 1.11x (more expensive)
- Player's heat is rising from carrying 60 cocaine for multiple turns
- After 3 trades with Miguel, his "discount" becomes a markup
- Meanwhile Interpol attention rises (trading in 2+ countries)

**Result:** The "exploit" yields ~$696,000 profit over 5 turns but with escalating risk, and the route degrades quickly. Much less exploitable than raw arbitrage.

---

## Implementation Priority

**Phase 1 (Foundation):** Strategies 1 (supply caps) and 6 (market saturation) -- simplest, highest impact
**Phase 2 (Depth):** Strategies 2 (dynamic pricing) and 4 (rivalries) -- add strategic depth
**Phase 3 (Polish):** Strategies 3 (reputation costs) and 5 (reliability) -- add tension and consequence
