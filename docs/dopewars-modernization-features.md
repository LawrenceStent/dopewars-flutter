# Dopewars Modernization Features

## Vision
Make the game more modern with different global locations, realistic law enforcement agencies, and modern UI for mobile. Modernize the game with relevant scenarios. For mobile, move the travel tab to a floating action button that brings up a bottom sheet.

---

## Modernization Ideas (Prioritized)

### TIER 1: High-Impact, Foundation Changes

#### 1. Global Location Network
Replace 8 local NYC locations with 12 international hubs:

- **New York (USA)** - Classic starting point
- **Los Angeles (USA)** - West coast
- **Mexico City (Mexico)** - Street-level trafficking
- **London (UK)** - Corporate dealing
- **Cape Town (South Africa)** - High risk
- **Tokyo (Japan)** - Tech-focused market
- **Macau (China)** - High-stakes gambling hub
- **Rio de Janeiro (Brazil)** - Favela operations
- **Paris (France)** - Luxury goods
- **Barcelona (Spain)** - Port city smuggling
- **Lagos (Nigeria)** - African hub
- **Dark Web (Onion Network)** - Anonymous marketplace

**Why:** Creates global trading asymmetry (drugs expensive in Europe, cheap in South America, etc.), forces strategy planning

---

#### 2. Regional Law Enforcement Agencies
Replace 3 generic "cops" with realistic agencies

**Agency System:**
- **USA:** DEA, FBI (narcotics division), NYPD
- **UK:** Met Police (London), National Crime Agency
- **Mexico:** SEIDO (Mexican federal prosecutors)
- **South Africa:** SAPS (South African Police Service)
- **China:** PSB (Public Security Bureau)
- **Brazil:** ENAFCOD (Federal anti-drug agency)
- **Nigeria:** NDLEA (National Drug Law Enforcement)
- **International:** Interpol, Europol

**Agency Properties:**
- name, country, jurisdiction (global/local)
- aggressiveness level (0-100)
- detection range (how far they patrol)
- resources (number of officers)
- weapons tier
- bribery vulnerability (0-100)

**Why:** Creates location-specific risks, adds tactical depth, enables story beats ("Interpol is closing in on you")

---

#### 3. Dynamic Scenario System
Replace random encounters with contextual scenarios

**Scenario Types:**

**Police Encounter:**
- Random patrol (catch you with drugs)
- Tip-off (someone snitched)
- Roadblock (planned checkpoint)

**Criminal Underworld:**
- Rival dealer conflict
- Territory dispute
- Supply chain theft

**Environmental:**
- Border customs search
- Port inspection
- Airport security

**Social:**
- Informant turned
- Buyer defaults on payment
- Supplier raises prices

**Why:** Makes the world feel alive and reactive, not random

---

#### 4. Reputation & Heat System
RPG progression for modern feel

**Reputation (0-100):**
- Increases: Successful deals, beating cops, expanding territory
- Decreases: Losses in combat, getting caught, backing down

**Heat Level (0-100):**
- Increases: Police encounters, large deals, killed cops
- Decreases: Laying low (skipping turns, staying in safe zones)
- Effect: Higher heat = more frequent/aggressive police

**Wanted Level (Per Agency):**
- **INTERPOL:** Global (high level = worldwide hunted)
- **DEA:** USA only
- **LOCAL:** Regional
- Effect: Affects travel difficulty, bribery costs

**Why:** Creates consequence, encourages varied playstyle, adds narrative tension

---

#### 5. NPC Trading Network
Beyond just buying/selling drugs

**Archetypes:**

**Suppliers:**
- Street dealer (cheap, risky)
- Cartel boss (expensive, high volume)
- Dark web merchant (anonymous, premium)

**Buyers:**
- Street addict (small buys, risky)
- Club owner (bulk orders, recurring)
- Corporate exec (premium prices, safe)

**Support:**
- Fixer (pays for heat reduction)
- Lawyer (helps with arrest)
- Doctor (heals without losing time)

**Reputation with NPCs:**
- Build relationships through trades
- Better prices for loyal customers
- Access to exclusive deals
- Can request favors (safe houses, intel)

**Why:** Turns it from a pure trading game into a relationship-building simulation

---

### TIER 2: Gameplay Enhancements

#### 6. Location-Specific Mechanics

- **NEW YORK:** Start here, balanced gameplay
- **LOS ANGELES:** Cartel war, gang territory control
- **MEXICO CITY:** Smuggling routes, border crossing mechanics
- **LONDON:** Financial regulations, white-collar dealing
- **CAPE TOWN:** High police presence, apartheid echoes, diamond smuggling
- **TOKYO:** Tech drugs (synthetics), yakuza involvement
- **MACAU:** Gambling debt system, VIP clientele
- **RIO:** Favela politics, gang alliances required
- **PARIS:** Luxury goods, art theft side quests
- **BARCELONA:** Port operations, container smuggling
- **LAGOS:** Corruption system, bribery is easier
- **DARK WEB:** Anonymity, bulk trading, but high heat

**Why:** Makes each location feel unique, rewards location mastery

---

#### 7. Mission/Contract System

**Example Contracts:**
- "Move 100 units of cocaine from LA to NYC in 5 turns" (time pressure)
- "Eliminate rival dealer in Barcelona" (combat objective)
- "Establish supply chain: Lagos → London → NYC" (logistics)
- "Build relationship with 5 NPCs" (social objective)
- "Avoid police for 10 turns" (stealth challenge)

**Rewards:**
- Cash bonuses
- Reputation boost
- Agency/NPC goodwill
- Unlock new locations/NPCs

**Why:** Adds narrative structure, gives players goals beyond "make money"

---

#### 8. Skill/Specialization System

**Available Skills:**
- **Combat:** Better gun handling, dodging, negotiation
- **Trading:** Better prices, faster transactions
- **Stealth:** Lower police detection
- **Driving:** Faster travel, escape chances
- **Hacking:** Dark web access, intel gathering

**Leveling:**
- Use skills to unlock improvements
- Risk/reward: High-level skills make you arrogant (more police attention)

**Why:** Adds progression beyond just accumulating cash

---

### TIER 3: UI/UX Modernization

#### 9. Mobile Bottom Sheet Travel UI ✨

**Floating Action Button:**
- Airplane icon in bottom-right
- On tap: Shows world map with 12 locations

**Bottom Sheet Interface:**
- World Map Grid (interactive, swipeable)
- Location Details:
  - Drug prices (preview before travel)
  - Police presence (heat indicator)
  - NPCs available (face icons)
  - Risk Assessment (green/yellow/red)
- Travel Time: Shows turn cost
- Actions: [Travel] [Info] [Back]

**Wide Screen (Desktop):**
- Map sidebar with location selector (keeps existing 3-column layout)

**Why:** Modern, mobile-friendly, reduces menu clicks, game-like feel

---

#### 10. World Map & Location Persistence

**Features:**
- World map showing player location
- Visual representation of "heat" per region (red glow for high heat)
- NPC/Agency positions (rival dealers, cops, suppliers)
- Trade route visualization (your established connections)
- Fog of war: Unexplored locations hidden until visited

**Why:** Creates immersion, helps player strategize movement

---

#### 11. Real-time Notifications/Alerts

**Alerts:**
- "Interpol is increasing patrols in Europe"
- "Your rival dealer just moved to Barcelona"
- "Heat is rising in New York (75/100)"
- "Good news: Cops are distracted by gang war in LA"
- "New supplier available in Tokyo: Offers 20% discount"

**Effect:**
- Players feel world is reactive
- Encourages different playstyle
- Creates urgency

---

#### 12. Visual Modernization

- Modern card-based UI (Google Material 3)
- Gradient backgrounds per location (NYC: blue steel, Rio: vibrant)
- Animated transitions between locations
- Real-world city skylines/photos (if licensed)
- Character portraits for NPCs (pixel art or illustrated)
- Heat level visualized as "warning light" that increases in intensity

---

## 🚀 Quick Implementation Priority

**Phase 1 (Foundation):**
1. Expand locations to 12 global cities
2. Replace cop types with regional agencies
3. Add reputation/heat system
4. Implement floating action button travel UI

**Phase 2 (Depth):**
5. Add NPC network
6. Create scenario system
7. Add contracts/missions

**Phase 3 (Polish):**
8. Skill system
9. World map visualization
10. Visual updates

---

## ⚠️ Pitfalls to Avoid

1. **Balance nightmare:** 12 locations = easy to break trading economy. Map out pricing carefully.
2. **Scope creep:** Don't add all at once. Start with Phase 1.
3. **State complexity:** More systems = more debugging. Implement testing as you go.
4. **Mobile performance:** Flutter web with many animations can lag. Profile on real devices.
5. **Save/load complexity:** Each new system needs persistent state handling.

---

## Next Steps

Would you like to start implementing Phase 1? Recommendations:
1. Expand the Location entity to support 12 cities
2. Create a regional Agency system
3. Add reputation/heat tracking to Player
4. Implement the mobile travel FAB + bottom sheet

Which part should we tackle first?
