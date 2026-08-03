# Arbitrage Mitigation Design

## Problem

With 12 global locations at different price multipliers, players can exploit guaranteed profit routes (e.g., buy cocaine in Lagos at 0.3x, sell in Tokyo at 1.8x = 600% markup). Without mitigation, the optimal strategy becomes a single repetitive loop.

---

## Strategy 1: Dynamic Supply & Demand

### Mechanism
Each location tracks a supply pool per drug (0-200, starts at 100). Player activity shifts supply, which shifts prices.

### Rules
- **On buy:** `supply -= quantityBought` (direct reduction)
- **On sell:** `supply += quantitySold * 0.5` (market absorbs half)
- **Per-turn recovery:** `supply += 10` (natural resupply)
- **Clamped:** [0, 200]

### Price Impact
```
supplyFactor = 100.0 / currentSupply
```
- Supply 100 (normal): factor = 1.0x
- Supply 50 (scarce): factor = 2.0x (prices double)
- Supply 150 (surplus): factor = 0.67x (prices drop 33%)
- Clamped to [0.5, 2.0]

### Final price formula
```
finalPrice = baseDrugPrice * locationMultiplier * supplyFactor * (1 + transactionTax)
```

### Example: Cocaine at Lagos
- Base range: $15,000-$29,000
- Lagos multiplier: 0.3x
- Normal price: $4,500-$8,700

Player buys 60 units:
- Supply drops: 100 -> 40
- Supply factor: 100/40 = 2.0x (capped)
- New price: $9,000-$17,400 (doubled)
- Second trip is much less profitable
- Takes 6 turns to recover (60 supply deficit / 10 recovery per turn)

### Implementation
Already stubbed in `supply_demand.dart` with `DrugSupply` and `MarketSupplyState`.

---

## Strategy 2: Travel Risk Scaling

### Mechanism
Longer routes and larger drug quantities increase interception probability at borders.

### Interception Formula
```
baseChance = travelRiskMatrix[fromRegion][toRegion]  // 5-20%
drugPenalty = unitsCarried * 0.3%                     // per unit
heatPenalty = globalHeat * 0.5%                       // per heat level
bulkPenalty = (unitsCarried > 50) ? 10% : 0%          // bulk flag
interpolPenalty = (interpolWanted > 50) ? 15% : 0%   // global warrant

totalChance = baseChance + drugPenalty + heatPenalty + bulkPenalty + interpolPenalty
```

### Example: 80 cocaine, Lagos -> Tokyo, heat 40
```
Base:     15% (Africa -> Asia)
Drug:     80 * 0.3% = 24%
Heat:     40 * 0.5% = 20%
Bulk:     10% (over 50 units)
Interpol: 0% (not wanted)
Total:    69% interception chance
```

At 69%, the expected value of carrying 80 cocaine is:
- If caught: lose all drugs ($696,000 in purchase value at Lagos prices) + heat increase
- If not caught: sell at Tokyo for ~$2.16M
- Expected value: 0.31 * $2.16M - 0.69 * $696,000 = $669,600 - $480,240 = $189,360
- Compare to carrying 20 units (safe run): ~$366,000 guaranteed

This naturally pushes players toward smaller, safer shipments.

### Interception Consequences
- Lose 50-100% of carried drugs (random)
- Heat +15
- Wanted level +10 for relevant agency
- Cash fine (10% of drug value)

---

## Strategy 3: Regional Price Bands

### Mechanism
Each region has hard floor/ceiling multipliers that prevent extreme margins.

| Region         | Min Multiplier | Max Multiplier | Notes                    |
|----------------|---------------|---------------|--------------------------|
| North America  | 0.7x          | 1.3x          | Balanced baseline        |
| Latin America  | 0.3x          | 0.8x          | Cheap but capped         |
| Europe         | 1.0x          | 2.0x          | Expensive but capped     |
| Africa         | 0.2x          | 0.9x          | Cheapest source          |
| Asia           | 1.2x          | 2.2x          | Most expensive market    |
| Virtual        | 0.8x          | 1.5x          | Moderate, high tax       |

### Maximum Theoretical Margin
- Cheapest possible: Africa floor 0.2x
- Most expensive possible: Asia ceiling 2.2x
- Max ratio: 11:1
- After taxes (2% buy + 10% sell): effectively ~9.7:1
- After supply depletion on second purchase: ratio drops to ~5:1
- After travel risk (3 turns, high interception): expected ratio ~2:1

This is still profitable but not game-breaking, and requires significant risk.

---

## Strategy 4: Transaction Taxes

### Mechanism
Each location charges a "street tax" on all transactions. Applied as percentage of transaction value.

| Location       | Tax  | Rationale                     |
|----------------|------|-------------------------------|
| Lagos          | 2%   | Low overhead, corruption      |
| Mexico City    | 3%   | Cheap market                  |
| Rio de Janeiro | 3%   | Favela discount               |
| Cape Town      | 4%   | Moderate                      |
| New York       | 5%   | Standard                      |
| Los Angeles    | 5%   | Standard                      |
| Barcelona      | 5%   | Port city                     |
| Macau          | 6%   | Casino adjacent               |
| London         | 8%   | Financial regulations         |
| Paris          | 8%   | High cost of business         |
| Tokyo          | 10%  | Yakuza cut                    |
| Dark Web       | 15%  | Anonymity premium             |

### Bulk Transaction Heat
Transactions over $50,000 add +5 heat. Over $100,000 add +10 heat. This discourages massive single trades.

### Implementation
Applied in the `PriceGenerator` when calculating final buy/sell prices:
```dart
buyPrice = basePrice * locationMultiplier * supplyFactor * (1 + buyTax)
sellPrice = basePrice * locationMultiplier * supplyFactor * (1 - sellTax)
```

---

## Strategy 5: Market Events

### Mechanism
Random events disrupt stable trading patterns each turn.

| Event                 | Chance/Turn | Duration  | Effect                                        |
|-----------------------|-------------|-----------|-----------------------------------------------|
| Police crackdown      | 10%         | 2-3 turns | All prices +50%, police presence +30          |
| Supply glut           | 8%          | 1-2 turns | One drug price -60%                           |
| Border closure        | 5%          | 2-4 turns | Cannot travel to/from location                |
| Rival undercut        | 12%         | 1 turn    | One drug -30%                                 |
| Customs alert         | 8%          | 2 turns   | Travel interception +40%                      |
| Lab bust              | 6%          | 3 turns   | One drug unavailable                          |
| Gang war              | 7%          | 2 turns   | All transactions +20% extra tax               |

### Anti-Arbitrage Effect
- A player running Lagos->Tokyo cocaine can be disrupted by:
  - Lagos border closure (can't leave for 2-4 turns, losing turns to debt interest)
  - Tokyo customs alert (+40% interception on arrival)
  - Cocaine supply glut in Tokyo (price crash, margin disappears)
  - Lagos police crackdown (buy prices spike 50%)

### Implementation
Track active events in `GameStateState.activeMarketEvents`. Check on each travel action and at turn start.

---

## Strategy 6: Carry Limit & Smuggling Routes

### Mechanism
Coat size remains finite (starts at 100). Players can't increase it indefinitely. Smuggling routes that are used too often get "burned."

### Route Burning
```
routeUsage[from][to] += 1  // each time player travels this route
if routeUsage[from][to] > 3:
    interceptionBonus += (routeUsage - 3) * 5%  // escalating risk

// Decay: routeUsage -= 1 per 3 turns of not using that route
```

### Example
Player runs Lagos->London 5 times:
- Trip 1-3: Normal interception
- Trip 4: +5% extra interception (route is being watched)
- Trip 5: +10% extra interception
- Trip 6: +15% extra interception

Forces players to vary routes or face escalating risk.

### Coat Size Constraints
- Starting: 100 units
- Each bitch adds 10 units
- Bitches cost $10,000 + $50,000-$150,000 each
- Max practical coat: ~200 units (10 bitches = $600,000-$1.6M investment)
- This hard-caps maximum shipment size

---

## Combined Effect Analysis

### Scenario: Player attempts Lagos->Tokyo cocaine loop

**Trip 1 (turns 1-4):**
- Buy 80 cocaine at Lagos: $8,700 * 80 * 1.02 tax = $709,920
- Lagos supply drops: 100 -> 20
- Travel: 3 turns, 15% base interception + 24% drug + 0% heat = 39%
- If successful: Sell at Tokyo: $27,000 * 80 * 0.90 tax = $1,944,000
- Profit: $1,234,080
- Heat gained: +15 (large transaction x2)
- Tokyo supply rises: 100 -> 140 (absorbed 40)

**Trip 2 (turns 5-8):**
- Lagos supply has recovered: 20 + 40 (4 turns) = 60
- Buy price now: $8,700 * (100/60) = $14,500 per unit (67% more expensive)
- Heat is now 15: interception = 15% + 24% + 7.5% = 46.5%
- Tokyo supply: 140 - 30 recovery = 110. Sell factor: 100/110 = 0.91x
- Tokyo price: $27,000 * 0.91 = $24,570 per unit (9% cheaper)
- Margin per unit: $24,570 * 0.9 - $14,500 * 1.02 = $22,113 - $14,790 = $7,323
- Compare to trip 1 margin: ($27,000 * 0.9 - $8,700 * 1.02) = $24,300 - $8,874 = $15,426
- **Profit halved on second trip**

**Trip 3 (turns 9-12):**
- Route burned: +5% extra interception
- Even less profitable
- Player should switch routes or diversify

### Conclusion
The combined systems make arbitrage self-correcting. First trip is profitable, subsequent trips on the same route face diminishing returns from supply depletion, rising heat, route burning, and potential market events.
