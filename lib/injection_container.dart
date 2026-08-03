import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/trading/buy_drug.dart';
import 'application/trading/sell_drug.dart';
import 'core/utils/random_generator.dart';
import 'domain/banking/services/interest_calculator.dart';
import 'domain/combat/services/damage_calculator.dart';
import 'domain/contract/services/contract_service.dart';
import 'domain/game/services/game_save_service.dart';
import 'domain/game/services/high_score_service.dart';
import 'domain/game/services/random_encounter_service.dart';
import 'domain/npc/repositories/npc_repository.dart';
import 'domain/scenario/services/scenario_trigger_service.dart';
import 'domain/trading/services/price_generator.dart';
import 'presentation/cubits/game/game_cubit.dart';
import 'presentation/cubits/game_state/game_state_cubit.dart';
import 'presentation/cubits/npc/npc_network_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initialize all dependencies.
Future<void> initDependencies() async {
  // Persistent storage
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Core utilities
  sl.registerLazySingleton<RandomGenerator>(
    () => DefaultRandomGenerator(),
  );

  // Domain services
  sl.registerLazySingleton<InterestCalculator>(
    () => const InterestCalculator(),
  );

  sl.registerLazySingleton<PriceGenerator>(
    () => PriceGenerator(random: sl()),
  );

  sl.registerLazySingleton<RandomEncounterService>(
    () => RandomEncounterService(random: sl()),
  );

  sl.registerLazySingleton<DamageCalculator>(
    () => DamageCalculator(random: sl()),
  );

  sl.registerLazySingleton<HighScoreService>(
    () => HighScoreService(prefs: sl()),
  );

  sl.registerLazySingleton<GameSaveService>(
    () => GameSaveService(prefs: sl()),
  );

  sl.registerLazySingleton<ScenarioTriggerService>(
    () => ScenarioTriggerService(random: sl()),
  );

  sl.registerLazySingleton<ContractService>(
    () => ContractService(random: sl()),
  );

  // Application use cases
  sl.registerLazySingleton<BuyDrug>(
    () => const BuyDrug(),
  );

  sl.registerLazySingleton<SellDrug>(
    () => const SellDrug(),
  );

  // Cubits
  // GameStateCubit is a singleton - top-level state shared across the app
  sl.registerSingleton<GameStateCubit>(
    GameStateCubit(),
  );

  // NPC repository is a singleton
  sl.registerSingleton<NpcRepository>(
    const NpcRepository(),
  );

  // NpcNetworkCubit is a factory because each game needs a fresh instance
  sl.registerFactory<NpcNetworkCubit>(
    () => NpcNetworkCubit(npcRepository: sl()),
  );

  // GameCubit is a factory because each game needs a fresh instance
  sl.registerFactory<GameCubit>(
    () => GameCubit(
      random: sl(),
      priceGenerator: sl(),
      interestCalculator: sl(),
      gameStateCubit: sl(),
      npcNetworkCubit: sl(),
      scenarioService: sl(),
      contractService: sl(),
    ),
  );
}

/// Reset all dependencies (useful for testing).
Future<void> resetDependencies() async {
  await sl.reset();
}
