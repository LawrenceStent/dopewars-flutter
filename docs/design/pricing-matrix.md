# Drug Pricing Matrix - 12 Global Locations

## Design Principles

1. No single route should guarantee profit -- every high-margin route must carry proportional risk
2. Regional price bands create asymmetry, but supply/demand dynamics prevent exploitation
3. Drug availability varies by location -- not every drug is sold everywhere
4. Special events (gluts, busts, crackdowns) disrupt stable pricing

---

## Regional Price Multipliers

Each location applies a multiplier to the base drug price. This creates natural arbitrage incentives, which are then counteracted by travel risk, supply/demand shifts, and transaction costs.

| Location         | Region         | Price Multiplier | Police Presence | Travel Cost (turns from NYC) |
|------------------|----------------|-----------------|-----------------|------------------------------|
| New York         | North America  | 1.0x (baseline) | 50              | 0                            |
| Los Angeles      | North America  | 0.9x            | 60              | 1                            |
| Mexico City      | Latin America  | 0.5x            | 30              | 1                            |
| London           | Europe         | 1.5x            | 70              | 2                            |
| Cape Town        | Africa         | 0.7x            | 80              | 3                            |
| Tokyo            | Asia           | 1.8x            | 90              | 3                            |
| Macau            | Asia           | 1.6x            | 40              | 3                            |
| Rio de Janeiro   | Latin America  | 0.4x            | 35              | 2                            |
| Paris            | Europe         | 1.6x            | 65              | 2                            |
| Barcelona        | Europe         | 1.3x            | 55              | 2                            |
| Lagos            | Africa         | 0.3x            | 20              | 3                            |
| Dark Web         | Virtual        | 1.2x            | 10              | 1 (from anywhere)            |

---

## Base Drug Prices (from existing game)

These are the base min/max prices. Location multipliers apply to both min and max.

| Drug     | Base Min ($) | Base Max ($) | Can Be Cheap | Can Be Expensive |
|----------|-------------|-------------|-------------|-----------------|
| Acid     | 1,000       | 4,400       | Yes         | No              |
| Cocaine  | 15,000      | 29,000      | No          | Yes             |
| Hashish  | 480         | 1,280       | Yes         | No              |
| Heroin   | 5,500       | 13,000      | No          | Yes             |
| Ludes    | 11          | 60          | Yes         | No              |
| MDA      | 1,500       | 4,400       | No          | No              |
| Opium    | 540         | 1,250       | No          | Yes             |
| PCP      | 1,000       | 2,500       | No          | No              |
| Peyote   | 220         | 700         | No          | No              |
| Shrooms  | 630         | 1,300       | No          | No              |
| Speed    | 90          | 250         | No          | Yes             |
| Weed     | 315         | 890         | Yes         | No              |

---

## Drug Availability by Location

Not all drugs available everywhere. Each location has 6-9 drugs. This limits arbitrage by restricting what you can buy/sell where.

| Drug     | NYC | LA  | MEX | LON | CPT | TKY | MAC | RIO | PAR | BCN | LAG | DW  |
|----------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Acid     | Yes | Yes | No  | Yes | No  | Yes | No  | No  | Yes | Yes | No  | Yes |
| Cocaine  | Yes | Yes | Yes | Yes | Yes | No  | Yes | Yes | Yes | Yes | Yes | Yes |
| Hashish  | Yes | No  | Yes | Yes | Yes | No  | No  | No  | Yes | Yes | Yes | Yes |
| Heroin   | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | No  | No  | Yes | Yes |
| Ludes    | Yes | Yes | No  | Yes | No  | Yes | Yes | No  | Yes | No  | No  | Yes |
| MDA      | Yes | Yes | No  | Yes | No  | Yes | Yes | No  | Yes | Yes | No  | Yes |
| Opium    | No  | No  | Yes | No  | No  | Yes | Yes | No  | No  | No  | Yes | Yes |
| PCP      | Yes | Yes | No  | No  | No  | No  | No  | No  | No  | No  | No  | Yes |
| Peyote   | No  | Yes | Yes | No  | No  | No  | No  | Yes | No  | No  | No  | Yes |
| Shrooms  | Yes | No  | Yes | Yes | Yes | No  | No  | Yes | Yes | No  | Yes | Yes |
| Speed    | Yes | Yes | No  | Yes | No  | Yes | Yes | No  | Yes | Yes | No  | Yes |
| Weed     | Yes | Yes | Yes | Yes | Yes | No  | No  | Yes | Yes | Yes | Yes | Yes |

**Key design notes:**
- Cocaine available almost everywhere (high value, high risk universal commodity)
- Opium concentrated in Asia/Africa/Latin America (supply regions)
- PCP mostly NYC/LA (limited market, reduces exploitation)
- Dark Web has everything but at 1.2x multiplier (premium for anonymity)

---

## Example Price Calculations

### Cocaine at different locations:
- **Base range:** $15,000 - $29,000
- **Lagos (0.3x):** $4,500 - $8,700
- **Mexico City (0.5x):** $7,500 - $14,500
- **New York (1.0x):** $15,000 - $29,000
- **Tokyo (1.8x):** $27,000 - $52,200

### Maximum theoretical arbitrage (Cocaine: Lagos -> Tokyo):
- Buy at Lagos max: $8,700
- Sell at Tokyo min: $27,000
- **Gross margin: $18,300 per unit (210%)**

### Why this doesn't break the game:
1. **Travel cost:** Lagos -> Tokyo = 3+ turns. At 10% debt interest/turn, $5,500 debt becomes $7,320 in 3 turns
2. **Carry limit:** 100 coat slots max. Cocaine takes 1 slot. 100 units max
3. **Supply/demand:** Buying 100 cocaine in Lagos depletes supply, raising price next turn
4. **Detection risk:** Carrying 100 cocaine across 3 borders = very high interception chance
5. **Heat:** Large purchase in Lagos + large sale in Tokyo = massive heat spike
6. **Turn limit:** 31 turns total. Lagos->Tokyo->Lagos = 6 turns. Only 5 round trips possible
7. **Not all turns profitable:** Police encounters, lost drugs, combat damage

---

## Supply & Demand Mechanics

### Supply Pool
Each location has a supply pool per drug. Starts at 100 units per available drug.

```
supply[location][drug] = 100 (initial)
```

### Price Impact Formula
```
priceMultiplier = baseRegionalMultiplier * supplyFactor

supplyFactor = supply / 100
  - supply = 100: factor = 1.0 (normal price)
  - supply = 50:  factor = 1.5 (scarce, price goes up 50%)
  - supply = 150: factor = 0.75 (surplus, price drops 25%)
  - Clamped to range [0.5, 2.0]
```

### Supply Changes
```
On buy:  supply[location][drug] -= quantityBought
On sell: supply[location][drug] += quantitySold * 0.5 (market absorbs half)

Per turn recovery: supply[location][drug] += 10 (natural resupply)
Clamped to range [0, 200]
```

### Effect on Arbitrage
If a player buys 50 cocaine in Lagos:
- Lagos supply drops from 100 to 50
- Lagos cocaine price multiplier: 0.3 * 1.5 = 0.45x (was 0.3x)
- Next purchase is 50% more expensive
- After 5 turns of not buying, supply recovers to 100

---

## Transaction Tax (Street Tax)

Each location charges a percentage on transactions. This eats into margins.

| Location       | Buy Tax | Sell Tax | Notes                          |
|----------------|---------|----------|--------------------------------|
| New York       | 5%      | 5%       | Standard                       |
| Los Angeles    | 5%      | 5%       | Standard                       |
| Mexico City    | 3%      | 3%       | Cheap but dangerous            |
| London         | 8%      | 8%       | Financial regulations          |
| Cape Town      | 4%      | 4%       | Moderate                       |
| Tokyo          | 10%     | 10%      | Yakuza takes a cut             |
| Macau          | 6%      | 6%       | Casino-adjacent                |
| Rio de Janeiro | 3%      | 3%       | Favela discount                |
| Paris          | 8%      | 8%       | High cost of doing business    |
| Barcelona      | 5%      | 5%       | Port city, moderate            |
| Lagos          | 2%      | 2%       | Low overhead                   |
| Dark Web       | 15%     | 15%      | Anonymity premium              |

### Effect on Cocaine Lagos -> Tokyo example:
- Buy 1 unit at Lagos: $8,700 * 1.02 = $8,874
- Sell 1 unit at Tokyo: $27,000 * 0.90 = $24,300
- **Net margin: $15,426 (174%)** -- still profitable but reduced from 210%
- After supply depletion on 50 units: margin drops to ~120%

---

## Market Events (Random Disruptions)

These fire randomly each turn to prevent stable arbitrage routes.

| Event                    | Probability | Duration  | Effect                                           |
|--------------------------|-------------|-----------|--------------------------------------------------|
| Police crackdown         | 10%/turn    | 2-3 turns | All prices at location +50%, police presence +30  |
| Supply glut              | 8%/turn     | 1-2 turns | One drug price -60% at location                   |
| Border closure           | 5%/turn     | 2-4 turns | Cannot travel to/from location                    |
| Rival dealer undercut    | 12%/turn    | 1 turn    | One drug price -30% at location                   |
| Customs alert            | 8%/turn     | 2 turns   | Travel to location has +40% detection chance      |
| Lab bust                 | 6%/turn     | 3 turns   | One drug unavailable at location                  |
| Gang war                 | 7%/turn     | 2 turns   | All transactions at location have +20% tax        |

---

## Travel Risk Matrix

Interception probability when traveling between regions. Applies per border crossed.

| From/To        | N. America | Latin America | Europe | Africa | Asia | Dark Web |
|----------------|-----------|--------------|--------|--------|------|----------|
| N. America     | 5%        | 15%          | 10%    | 10%    | 10%  | 0%       |
| Latin America  | 20%       | 5%           | 15%    | 10%    | 15%  | 0%       |
| Europe         | 10%       | 15%          | 5%     | 10%    | 10%  | 0%       |
| Africa         | 15%       | 10%          | 15%    | 5%     | 15%  | 0%       |
| Asia           | 10%       | 15%          | 10%    | 15%    | 5%   | 0%       |
| Dark Web       | 0%        | 0%           | 0%     | 0%     | 0%   | 0%       |

**Modifiers:**
- Per unit of drug carried: +0.3% detection chance
- Per heat level: +0.5% detection chance
- If carrying > 50 units: flat +10% bonus
- If wanted by Interpol: +15% on all international routes

**Example:** Carrying 80 cocaine from Lagos to Tokyo at heat 40:
- Base: 15% (Africa -> Asia)
- Drug carry: 80 * 0.3% = +24%
- Heat: 40 * 0.5% = +20%
- Over 50 units: +10%
- **Total: 69% interception chance**

This makes the "guaranteed profit" route extremely risky at scale.

---

## Balance Targets

These are the targets we should validate during playtesting:

| Metric                          | Target Range        |
|---------------------------------|---------------------|
| Average profit per turn         | $5,000 - $15,000    |
| Turns to pay off starting debt  | 8-15 turns          |
| Maximum net worth at turn 31    | $500,000 - $2,000,000 |
| Best single-turn profit         | $50,000 - $100,000  |
| Interception rate (mid-game)    | 15-30%              |
| Average drugs lost to police    | 20-30% of purchased |
