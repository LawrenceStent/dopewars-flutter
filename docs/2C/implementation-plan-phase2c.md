# Phase 2C: Contracts UI & Integration — Implementation Plan

## Context

Phase 2A completed the NPC trading network. Phase 2B activated the scenario trigger system. Phase 2C completes the Phase 2 depth expansion by fully wiring the Contract system.

**What already exists:**
- `Contract` entity with all fields (`lib/domain/contract/entities/contract.dart`)
- `ContractService` with `generateAvailableContracts`, `evaluateProgress`, `checkCompletion` (`lib/domain/contract/services/contract_service.dart`)
- `GameStateCubit` methods: `addContract`, `updateContract`, `removeContract`
- `ContractService` registered in `injection_container.dart`
- 3 contract templates in `DefaultContracts.templates`

**What is missing:**
- GameCubit methods (`acceptContract`, `abandonContract`, contract evaluation in `travel()`)
- Contract generation on `startGame()`
- `processTurnEnd()` call wired into `travel()`
- 7 more contract templates (only 3 exist)
- All contracts UI

**Player experience goal:** Player opens JOBS tab → sees 2-3 available contracts → accepts one → travels to the target city → progress bar advances → contract completes → cash + reputation reward applied automatically.

---

## Step 1: Expand Contract Templates (3 → 10)

**File:** `lib/domain/contract/entities/contract.dart`

Add 7 new templates to `DefaultContracts.templates`:

| id | title | type | locations | reward | turns | diff |
|----|-------|------|-----------|--------|-------|------|
| `transport_lagos_nyc` | Nigerian Express | transport | Lagos, NYC | $40,000 | 6 | 2 |
| `transport_tokyo_london` | Far East Run | transport | Tokyo, London | $60,000 | 8 | 3 |
| `logistics_local_circuit` | Home Circuit | logistics | LA, Chicago, NYC | $80,000 | 10 | 3 |
| `stealth_avoid_5` | Stay Clean (Short) | stealth | (any) | $20,000 | 5 | 2 |
| `stealth_ghost_premium` | Ghost Protocol | stealth | (any) | $75,000 | 15 | 5 |
| `collection_50k` | Small Score | collection | (any) | $15,000 | 8 | 1 |
| `collection_200k` | Big Score | collection | (any) | $50,000 | 15 | 4 |

**`stealth` and `collection` types are excluded from `generateAvailableContracts()`** — templates exist for Phase 3 but players won't be offered them in 2C. Keeps the UI clean with no WIP labels.

---

## Step 2: Wire ContractService into GameCubit

**File:** `lib/presentation/cubits/game/game_cubit.dart`

### 2a. Add dependency

Add `ContractService _contractService` as optional constructor param (same pattern as `RandomEncounterService`):

```dart
ContractService? contractService,
// in initializer list:
_contractService = contractService ?? ContractService(random: random),
```

Add imports:
```dart
import '../../../domain/contract/entities/contract.dart';
import '../../../domain/contract/services/contract_service.dart';
```

Also add `package:collection/collection.dart` for `firstWhereOrNull`.

### 2b. In `startGame()` — generate initial contracts

After emitting the first `GamePlaying`, call:
```dart
void _generateInitialContracts(int turn) {
  final contracts = _contractService.generateAvailableContracts(turn);
  for (final c in contracts) {
    _gameStateCubit.addContract(c);
  }
}
```

### 2c. In `travel()` — hooks

**Hook 1:** At the start (after interest calculation):
```dart
_gameStateCubit.processTurnEnd();
```

**Hook 2:** After updating player location and before the scenario roll, call `ContractService.processTurnUpdate()` (see Step 2f). Apply returned rewards and messages to the final emit.

**Hook 3 (contract refresh):** If `newTurn % 5 == 0`, generate a fresh batch of available contracts to replace expired/completed ones:
```dart
if (newTurn % 5 == 0) {
  _generateInitialContracts(newTurn);
}
```

### 2f. Move evaluation logic into ContractService

Rather than a private `_evaluateContracts` in `GameCubit`, add `processTurnUpdate` to `ContractService`. This keeps business logic in the service layer and keeps the cubit focused on state:

```dart
// lib/domain/contract/services/contract_service.dart
class ContractTurnResult {
  final List<Contract> updated;   // contracts with new status/progress to persist
  final List<String> messages;    // player feedback strings
  final int cashReward;           // total cents earned from completions
  final int reputationReward;     // total rep earned
}

ContractTurnResult processTurnUpdate({
  required List<Contract> contracts,
  required Player player,
  required int currentTurn,
});
```

`GameCubit.travel()` calls it, then applies each updated contract via `_gameStateCubit.updateContract()`, applies totals to player cash and reputation, and merges messages into the final emit.

### 2d. New public methods

```dart
/// Accept an available contract.
void acceptContract(String contractId) {
  final s = state;
  if (s is! GamePlaying) return;
  final contract = _gameStateCubit.state.activeContracts
      .firstWhereOrNull((c) => c.id == contractId);
  if (contract == null || contract.status != ContractStatus.available) return;
  _gameStateCubit.updateContract(
    contract.copyWith(
      status: ContractStatus.active,
      acceptedOnTurn: s.player.turn,
    ),
  );
  emit(s.withMessage('Job accepted: ${contract.title}'));
}

/// Abandon an active contract (marks as failed).
void abandonContract(String contractId) {
  final s = state;
  if (s is! GamePlaying) return;
  final contract = _gameStateCubit.state.activeContracts
      .firstWhereOrNull((c) => c.id == contractId);
  if (contract == null || contract.status != ContractStatus.active) return;
  _gameStateCubit.updateContract(contract.copyWith(status: ContractStatus.failed));
  emit(s.withMessage('You abandoned: ${contract.title}'));
}
```

### 2e. Update injection_container.dart

Pass `contractService: sl()` to the `GameCubit` factory (ContractService is already registered as a singleton).

---

## Step 3: Tests

**New file:** `test/presentation/cubits/game_cubit_contracts_test.dart`

8 test cases:

| # | Test | Expected |
|---|------|----------|
| 1 | `startGame()` generates contracts | `gameStateCubit.state.activeContracts.length` is 2 or 3 |
| 2 | `startGame()` contracts are all `available` | all have `status == ContractStatus.available` |
| 3 | `acceptContract()` sets status → active | contract `status == active`, `acceptedOnTurn == player.turn` |
| 4 | `acceptContract()` on already-active is no-op | status unchanged |
| 5 | `abandonContract()` sets active → failed | contract `status == failed` |
| 6 | `abandonContract()` on available is no-op | status unchanged |
| 7 | `travel()` to target location increments transport contract progress | `progress > 0` |
| 8 | `travel()` past turnLimit marks contract failed | `status == failed` |
| 9 | (bonus) `travel()` to final location completes transport contract + awards cash | `status == completed`, player cash increased |

---

## Step 4: ContractsWidget

**New file:** `lib/presentation/widgets/contracts_widget.dart`

Outer widget uses two `BlocBuilder`s:
- `BlocBuilder<GameStateCubit, GameStateState>` for `activeContracts`
- `BlocBuilder<GameCubit, GameState>` for `player.turn` (to compute turns remaining)

**Structure:**
```
ExpansionTile(
  leading: Icon(Icons.work, color: amber[400]),
  title: Row[ "JOBS", if active>0 Badge(count) ],
  initiallyExpanded: false,
  backgroundColor: Colors.grey[900],
  children: [
    if (activeContracts not empty) _SectionLabel('ACTIVE'),
    ...activeContracts.map(_ContractCard(contract, currentTurn)),
    if (availableContracts not empty) _SectionLabel('AVAILABLE'),
    ...availableContracts.map(_ContractCard(contract, currentTurn)),
    if (both empty) Padding(Text('No jobs available.', style: grey)),
  ],
)
```

**`_ContractCard` layout (per card):**
```
Container(
  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.grey[850],
    border: Border.all(color: _statusColor, width: 1),
    borderRadius: BorderRadius.circular(6),
  ),
  child: Padding(
    padding: 8,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row[ title (bold), Spacer, difficultyStars ],
        SizedBox(4),
        Text(description, maxLines: 2, overflow: ellipsis, style: grey),
        SizedBox(6),
        if (active) LinearProgressIndicator(value: progress/100, color: amber),
        if (active) Text('${turnsRemaining} turns left', style: small grey),
        if (available) Text('Reward: ${cashReward}  +${repReward} rep', style: green),
        SizedBox(6),
        Align(
          alignment: right,
          child: if (available) ElevatedButton('Accept', onPressed: acceptContract),
          child: if (active) OutlinedButton('Abandon', style: red, onPressed: abandonContract),
        ),
      ],
    ),
  ),
)
```

**Color legend:**
- Active: amber[400] border
- Available: grey[600] border
- Completed: green[400] border (shown briefly before removal)
- Failed: red[400] border

**Difficulty stars helper:**
```dart
String _stars(int difficulty) =>
    '★' * difficulty + '☆' * (5 - difficulty);
```

---

## Step 5: Wire ContractsWidget into game_page.dart

**File:** `lib/presentation/pages/game_page.dart`

Add import:
```dart
import '../widgets/contracts_widget.dart';
```

**Narrow layout** (`_NarrowLayout`):
- Change `DefaultTabController(length: 3)` → `length: 4`
- Add `const Tab(text: 'JOBS')` to `TabBar`
- Add `const ContractsWidget()` as 4th child in `TabBarView`

**Wide layout** (`_WideLayout`):
- In the left column `Column`, after `LocationSelector`, add:
```dart
const SizedBox(height: 8),
const ContractsWidget(),
```

---

## Files to Create

| File | Purpose |
|------|---------|
| `lib/presentation/widgets/contracts_widget.dart` | Contracts panel UI |
| `test/presentation/cubits/game_cubit_contracts_test.dart` | GameCubit contract tests |

## Files to Modify

| File | Change |
|------|--------|
| `lib/domain/contract/entities/contract.dart` | Add 7 new templates |
| `lib/presentation/cubits/game/game_cubit.dart` | ContractService + acceptContract + abandonContract + travel hooks |
| `lib/presentation/pages/game_page.dart` | JOBS tab (narrow) + left panel entry (wide) |
| `lib/injection_container.dart` | Pass `contractService: sl()` to GameCubit factory |

## Implementation Order

1. Contract templates
2. GameCubit wiring (`startGame`, `travel`, `acceptContract`, `abandonContract`)
3. Tests
4. ContractsWidget
5. Wire game_page.dart
6. `flutter test test/presentation/cubits/game_cubit_contracts_test.dart`
7. `flutter analyze`
8. `flutter build web --release`

## Verification

```bash
flutter test test/presentation/cubits/game_cubit_contracts_test.dart
flutter analyze
flutter build web --release
firebase deploy --only hosting
```

Manual test flow:
1. Start game → JOBS tab shows 2-3 available contracts
2. Accept a transport contract (e.g. Lagos → NYC)
3. Travel to Lagos → progress bar appears at 25%
4. Travel to NYC → progress reaches 100% → completion message → cash added to player stats
