# Phase 2C Implementation Plan Review

## Positives
- **Logical Progression:** The plan follows a clear "Data -> Logic -> UI" flow, which is ideal for feature integration.
- **Comprehensive Testing:** Step 3 includes a robust set of 8+ test cases covering edge cases (like expiration and double-acceptance) that are often overlooked.
- **Surgical Integration:** The hooks in `travel()` are placed correctly to ensure that contract progress and rewards are processed in sync with the core game loop.
- **UI Adaptability:** Planning for both `_NarrowLayout` (tabs) and `_WideLayout` (side panel) ensures the feature feels native on both mobile and desktop/web.
- **Reward Visibility:** Using the `withMessage` pattern in `GameCubit` ensures players get immediate feedback when a job is completed or fails during travel.

## Negatives
- **UI Clutter in Wide Layout:** Adding the `ContractsWidget` directly below `LocationSelector` in the wide layout might make that side panel very long, especially if many contracts are available. It might benefit from being collapsible or limited in height with a scrollbar.
- **Tight Coupling:** `GameCubit` is becoming quite large with these new hooks. While manageable for now, the "Contract Evaluation" logic in `2c` is a private method inside the Cubit.
- **WIP Types:** Marking `stealth` and `collection` as "WIP" in the description is honest but might feel "unfinished" to a player.

## Opportunities
- **Refactoring Evaluation Logic:** Instead of `_evaluateContracts` being a private method in `GameCubit`, it could be a method on `ContractService` (e.g., `processTurnUpdate(player, contracts, turn)`). This would keep the Cubit focused on state management rather than business logic.
- **Contract Refresh:** The plan generates contracts at `startGame()`, but there's no mention of refreshing "Available" contracts if the player ignores them for many turns. Adding a "New jobs available!" message every 5-10 turns would keep the system dynamic.
- **Reputation Impact:** You have `addReputation` in the completion logic. An opportunity exists to scale the *difficulty* or *reward* of available contracts based on that reputation in `generateAvailableContracts`.
- **Visual Feedback:** In the `_ContractCard`, adding a small "New" badge or a different background color for newly appeared contracts would improve UX.
