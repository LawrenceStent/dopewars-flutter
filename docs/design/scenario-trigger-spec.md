# Scenario Trigger Specification

## Overview

Scenarios are dynamic events that happen during gameplay. They should feel **natural and occasional**, not overwhelming or predictable.

**Design Goals:**
- Max 1 scenario per location visit (prevents spam)
- Scenarios feel tied to player actions (high heat = more danger, etc.)
- Variety prevents metagaming
- Failure modes exist but are rare

---

## Scenario Categories & Trigger Rules

### Category 1: Police Encounters (Heat-Driven)

These trigger when player is actively engaged in risky behavior.

**Random Patrol (Type A)**
- **Trigger:** Any travel with drugs
- **Probability:** 10% base + 2% per heat level
- **Location restriction:** None (global)
- **Example:** "Officer spotted you at the market..."

**Roadblock (Type B)**
- **Trigger:** Travel to/from major cities
- **Probability:** 5% base + 1% per heat level
- **Location restriction:** Only on routes between major hubs
- **Heat gate:** Only if heat >= 20
- **Example:** "Police have set up a checkpoint..."

**Police Raid (Type C)**
- **Trigger:** After large transaction (> $100k)
- **Probability:** 15% guaranteed if heat > 50, else 5%
- **Location restriction:** None
- **Heat gate:** heat >= 30
- **Example:** "Authorities raided the location!"

---

### Category 2: Criminal Events (Rivalry/NPC-Driven)

These trigger based on NPC relationships and player trading patterns.

**Rival Dealer Conflict (Type D)**
- **Trigger:** Trade with same supplier/buyer multiple times
- **Probability:** 20% per 3rd visit to same NPC
- **Location restriction:** At the NPC's location only
- **Heat impact:** +5 heat if player wins conflict
- **Example:** "Another dealer wants to muscle in on your territory..."

**Supplier Raises Prices (Type E)**
- **Trigger:** High trading volume with one supplier
- **Probability:** 15% per visit after 5 trades with same supplier
- **Location restriction:** At supplier location
- **Heat impact:** None
- **Example:** "The supplier heard you're buying in bulk elsewhere..."

**Buyer Defaults Payment (Type F)**
- **Trigger:** Large sale (> $50k) to NPC buyer
- **Probability:** 8% per transaction
- **Location restriction:** At buyer location, next visit only
- **Heat impact:** -5 heat if player collects debt
- **Example:** "The buyer is refusing to pay what they promised..."

---

### Category 3: Random Luck (Fortune/Misfortune)

These are pure randomness, not driven by player actions.

**Find Cash on Street (Type G)**
- **Trigger:** Any travel
- **Probability:** 3%
- **Location restriction:** High-crime areas only (Lagos, Cape Town, Rio)
- **Heat impact:** None
- **Reward:** $500-$5000
- **Example:** "You found cash dropped by a careless tourist!"

**Mugging (Type H)**
- **Trigger:** Travel with visible cash
- **Probability:** 5%
- **Location restriction:** High-crime areas + night (simulated)
- **Heat impact:** None (street crime, not organized)
- **Example:** "Street thieves surround you!"

**Shipment Hijacked (Type I)**
- **Trigger:** Carrying large drug shipment (>50 units)
- **Probability:** 4%
- **Location restriction:** Border areas
- **Heat impact:** None (rival dealers, not cops)
- **Example:** "Your shipment was intercepted!"

---

### Category 4: Government (Bureaucracy/Bribery)

These create opportunities for negotiation.

**Border Customs Search (Type J)**
- **Trigger:** Travel with drugs across regions
- **Probability:** 8% per cross-border travel
- **Location restriction:** Border locations only
- **Heat gate:** Only if carrying drugs
- **Bribery cost:** $2k-$5k to avoid search
- **Example:** "Customs is inspecting all luggage..."

**Corrupt Official (Type K)**
- **Trigger:** High heat + visited police location
- **Probability:** 10% if heat > 60
- **Location restriction:** Major cities only
- **Bribery cost:** $3k-$8k
- **Example:** "An official has information about your activities..."

---

## Trigger Algorithm (Pseudocode)

```
OnLocationVisit(playerState, location):
  // Step 1: Check if scenario already triggered this visit
  if visitedLocationThisTurn:
    return  // Max 1 per location

  // Step 2: Weight scenarios by type
  availableScenarios = []

  for scenario in allScenarios:
    // Check heat gate
    if scenario.heatGate && playerHeat < scenario.heatGate:
      continue

    // Check location restriction
    if scenario.locationRestriction && !scenario.locationRestriction.contains(location):
      continue

    // Check cargo restriction (e.g., must have drugs)
    if scenario.cargoRestriction && !playerMeets(scenario.cargoRestriction):
      continue

    // Calculate probability
    probability = scenario.baseProbability
    probability += scenario.heatModifier * (playerHeat / 100)

    // Add to weighted pool
    availableScenarios.add((scenario, probability))

  // Step 3: Select random scenario from weighted pool
  selectedScenario = weightedRandom(availableScenarios)

  if selectedScenario:
    triggerScenario(selectedScenario)
    markVisitedThisTurn()
```

---

## Scenario Resolution

Each scenario has **2-3 outcomes**:

### Police Scenarios (A, B, C)
- **Outcome 1 (60%):** Pay bribe ($1k-$5k) and continue
- **Outcome 2 (30%):** Fight/flee (triggers combat or escape)
- **Outcome 3 (10%):** Get caught (arrest, heat +30)

### Criminal Scenarios (D, E, F)
- **Outcome 1 (70%):** Negotiate/resolve (lose some profit)
- **Outcome 2 (20%):** Escalate (combat or theft)
- **Outcome 3 (10%):** Walk away (lost deal)

### Random Luck (G, H, I)
- **Gain:** Fixed reward or loss
- **No choice** - outcomes automatic

### Government (J, K)
- **Outcome 1 (50%):** Bribe official ($cost)
- **Outcome 2 (50%):** Submit to search/audit (potential arrest)

---

## Implementation Priorities

**Phase 2A (MVP):** Implement 6 core scenarios
- Random Patrol (Type A)
- Roadblock (Type B)
- Rival Dealer (Type D)
- Border Customs (Type J)
- Find Cash (Type G)
- Mugging (Type H)

**Phase 2B (Expansion):** Add 8 more
- All remaining types

**Phase 3:** Dynamic branching outcomes

---

## Balance Notes

- **Heat scaling:** Each +20 heat should increase encounter rate by ~10%
- **Location variance:** High-crime areas (Lagos, Cape Town) should see 2x scenario frequency
- **NPC-driven:** Should only trigger after 3+ interactions with same NPC
- **Cooldown:** Once a scenario type triggers, reduce its probability for next 3 turns

---

## Testing Strategy

To validate:
1. Generate 1000 visits with various heat levels
2. Verify scenario frequency matches expected probability
3. Verify scenarios respect location restrictions
4. Verify max-1-per-visit rule is enforced
5. Verify heat scaling is consistent

Example test:
```
heat=0: ~3% encounter rate (base scenarios only)
heat=50: ~8% encounter rate (heat-driven + criminal)
heat=100: ~13% encounter rate (max intensity)
```
