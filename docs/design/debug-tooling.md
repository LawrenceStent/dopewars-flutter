# Debug Tooling Design (Implement Later)

This document specifies debug tools to build during development. Do NOT implement these yet -- this is a spec for future work.

---

## 1. Debug Console Overlay

### Purpose
In-app developer overlay for manipulating game state during testing.

### Activation
```dart
// Only available in debug builds
assert(() {
  // Register debug overlay
  return true;
}());

// Or use kDebugMode
if (kDebugMode) {
  // Show debug FAB
}
```

### Features
- **Player State Panel:**
  - Set cash (text field, Money value)
  - Set debt (text field)
  - Set bank balance (text field)
  - Set health (slider, 0-100)
  - Set coat size (slider)
  - Set turn number (slider, 1-31)

- **Heat & Reputation Panel:**
  - Set global heat (slider, 0-100)
  - Set reputation (slider, 0-100)
  - Set wanted level per agency (dropdown + slider)
  - Reset all heat button
  - Reset all wanted levels button

- **Location Panel:**
  - Teleport to any location (dropdown of 12 cities)
  - No travel cost or risk
  - Instant market regeneration

- **God Mode Toggle:**
  - No damage in combat
  - No arrests
  - No drug confiscation
  - Infinite money mode

### Implementation Notes
- Use a `DebugOverlayWidget` wrapped in `kDebugMode` check
- Access `GameStateCubit` and `GameCubit` via `context.read<>()`
- Position as a slide-out drawer from the left edge
- Semi-transparent background so game state is visible underneath

---

## 2. Scenario Spawner

### Purpose
Force-trigger any scenario type without waiting for RNG.

### UI
- Dropdown: Select scenario type (all 20 from `ScenarioType` enum)
- Parameter fields (dynamic based on scenario):
  - Agency involved (for police scenarios)
  - NPC involved (for social scenarios)
  - Drug type affected (for market scenarios)
- "Trigger Now" button

### Implementation Notes
```dart
// In debug panel:
void triggerScenario(ScenarioType type, {Map<String, dynamic>? params}) {
  final scenario = DefaultScenarios.phase1.firstWhere((s) => s.type == type);
  context.read<GameStateCubit>().setActiveScenario(scenario);
}
```

---

## 3. Market Inspector

### Purpose
Real-time view of drug prices at ALL 12 locations simultaneously. Crucial for balance testing.

### UI
- 12-column table (one per location)
- 12 rows (one per drug)
- Each cell shows: current price, supply level, supply factor
- Color coding:
  - Green: supply > 100 (surplus, cheap)
  - Yellow: supply 50-100 (normal-scarce)
  - Red: supply < 50 (very scarce, expensive)
- NPC stock levels overlay (toggle)
- Active market events shown as badges on location columns

### Price Trend Graph
- Line chart showing price history for selected drug across locations
- X-axis: turns (last 10)
- Y-axis: price
- One line per location

### Implementation Notes
- Use a `DataTable` widget or custom `Table`
- Read `MarketSupplyState` from `GameStateCubit`
- Read `DrugMarket` from `GameCubit`
- Update every time state changes (use `BlocBuilder`)
- Open as a full-screen modal (too much data for overlay)

---

## 4. Economy Monitor

### Purpose
Track whether the game economy is balanced. Flag dominant strategies.

### Metrics Tracked
- **Net worth over time:** Line chart, one data point per turn
- **Profit per turn:** Bar chart
- **Most profitable route:** Table of "from -> to" routes ranked by profit
- **Heat accumulation rate:** How fast heat rises
- **Drug most traded:** Pie chart of trade volume by drug type
- **NPC usage distribution:** Which NPCs are being used most

### Balance Alarms
Flag these conditions in red:
- Player earning > $50,000/turn average (too easy)
- Single route producing > 60% of profit (dominant strategy)
- Player net worth > $500,000 by turn 15 (too fast)
- Heat never exceeding 30 (risk too low)
- One NPC accounting for > 40% of trades (over-reliance)

### Implementation Notes
```dart
class EconomyMonitor {
  final List<Money> netWorthHistory = [];
  final List<Money> profitHistory = [];
  final Map<String, int> routeUsage = {};
  final Map<String, Money> routeProfit = {};
  final Map<String, int> npcTradeCount = {};

  void recordTurn(Player player, {String? route, String? npcId}) {
    netWorthHistory.add(player.netWorth);
    // ... calculate and record metrics
  }

  List<String> getAlarms() {
    // Check thresholds and return warning messages
  }
}
```

- Only instantiate in debug builds
- Store in a `DebugServiceLocator` (separate from production DI)
- Display as a separate debug screen accessible from debug menu

---

## 5. State Inspector

### Purpose
View the complete state tree of all cubits. Like Flutter DevTools but game-specific.

### Features
- **Cubit State Tree:**
  - `GameStateCubit` state (reputation, heat, supply, NPCs, contracts)
  - `GameCubit` state (player, market, messages)
  - `TradingCubit` state (selected drug, mode, quantity)
  - `CombatCubit` state (opponent, health, log)
  - Expand/collapse each section

- **Event History Log:**
  - Chronological list of all cubit emissions
  - Timestamp, cubit name, state summary
  - Filter by cubit type
  - Scrollable, searchable

- **Undo/Redo (Stretch Goal):**
  - Record state snapshots per turn
  - "Rewind to turn N" button
  - Useful for reproducing bugs

### Implementation Notes
- Use `BlocObserver` to log all state changes:
```dart
class DebugBlocObserver extends BlocObserver {
  final List<StateChange> history = [];

  @override
  void onChange(BlocBase bloc, Change change) {
    history.add(StateChange(
      timestamp: DateTime.now(),
      blocName: bloc.runtimeType.toString(),
      currentState: change.currentState.toString(),
      nextState: change.nextState.toString(),
    ));
  }
}
```
- Register in `main.dart` only for debug builds:
```dart
if (kDebugMode) {
  Bloc.observer = DebugBlocObserver();
}
```

---

## 6. Balance Test Runner

### Purpose
Automated playthroughs to detect dominant strategies and balance issues.

### Strategies to Test
1. **Random walker:** Random location, random trades (baseline)
2. **Arbitrageur:** Always buy cheapest drug, sell at most expensive location
3. **Single route:** Only Lagos <-> Tokyo cocaine
4. **NPC exploiter:** Max out NPC relationships, trade exclusively through NPCs
5. **Stealth player:** Low heat, small trades, many locations
6. **Aggressive player:** Fight all cops, high heat, big trades

### Output Report
```
Strategy: "Lagos-Tokyo Cocaine Loop"
Games run: 100
Average net worth at turn 31: $1,245,000
Median: $890,000
Best: $3,200,000
Worst: -$45,000 (debt)
Average times intercepted: 4.2
Average times arrested: 1.8
Average heat at end: 67
Dominant drug: Cocaine (92% of trades)
FLAG: Single route producing 89% of profit
```

### Implementation Notes
```dart
class BalanceTestRunner {
  final int numberOfGames;
  final TradingStrategy strategy;

  Future<BalanceReport> run() async {
    final results = <GameResult>[];
    for (int i = 0; i < numberOfGames; i++) {
      final result = await simulateGame(strategy);
      results.add(result);
    }
    return BalanceReport.fromResults(results);
  }
}

abstract class TradingStrategy {
  TradingAction decideAction(Player player, DrugMarket market);
}

class ArbitrageStrategy extends TradingStrategy {
  @override
  TradingAction decideAction(Player player, DrugMarket market) {
    // Find cheapest available drug, buy max
    // Travel to highest-multiplier location
    // Sell everything
  }
}
```

- Run headlessly (no UI, just game logic)
- Output to console or JSON file
- Can be run as a Dart script: `dart run test/balance_test.dart`
- Separate from production code entirely

---

## Integration Plan

### Where to Put Debug Code
```
lib/
  debug/                          # All debug tooling
    debug_overlay.dart            # Main overlay widget
    scenario_spawner.dart         # Scenario trigger UI
    market_inspector.dart         # Price/supply viewer
    economy_monitor.dart          # Balance tracking
    state_inspector.dart          # Cubit state viewer
    debug_bloc_observer.dart      # BlocObserver for logging

test/
  balance/                        # Balance test runner
    balance_test_runner.dart
    strategies/
      random_strategy.dart
      arbitrage_strategy.dart
      single_route_strategy.dart
```

### Enabling Debug Mode
```dart
// In main.dart
void main() {
  if (kDebugMode) {
    Bloc.observer = DebugBlocObserver();
    GetIt.I.registerSingleton<EconomyMonitor>(EconomyMonitor());
  }
  runApp(const DopeWarsApp());
}

// In app.dart - wrap root with debug overlay
Widget build(BuildContext context) {
  Widget app = MaterialApp(...);
  if (kDebugMode) {
    app = DebugOverlay(child: app);
  }
  return app;
}
```

### Access Pattern
All debug tools access cubits via `context.read<>()` -- same pattern as production code. No special debug APIs needed. The debug tools are purely UI + observation, never bypassing cubit methods.
