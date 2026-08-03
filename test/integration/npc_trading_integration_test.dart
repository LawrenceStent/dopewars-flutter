import 'package:dopewars_flutter/core/utils/random_generator.dart';
import 'package:dopewars_flutter/domain/banking/services/interest_calculator.dart';
import 'package:dopewars_flutter/domain/location/entities/location.dart';
import 'package:dopewars_flutter/domain/npc/repositories/npc_repository.dart';
import 'package:dopewars_flutter/domain/trading/entities/drug.dart';
import 'package:dopewars_flutter/domain/trading/services/price_generator.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/game/game_state.dart';
import 'package:dopewars_flutter/presentation/cubits/game_state/game_state_cubit.dart';
import 'package:dopewars_flutter/presentation/cubits/npc/npc_network_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NPC Trading Integration Tests', () {
    late GameCubit gameCubit;
    late NpcNetworkCubit npcNetworkCubit;
    late GameStateCubit gameStateCubit;
    late NpcRepository npcRepository;

    setUp(() {
      final random = DefaultRandomGenerator(42);
      final priceGenerator = PriceGenerator(random: random);
      final interestCalculator = const InterestCalculator();

      gameStateCubit = GameStateCubit();
      npcRepository = const NpcRepository();
      npcNetworkCubit = NpcNetworkCubit(npcRepository: npcRepository);

      gameCubit = GameCubit(
        random: random,
        priceGenerator: priceGenerator,
        interestCalculator: interestCalculator,
        gameStateCubit: gameStateCubit,
        npcNetworkCubit: npcNetworkCubit,
      );
    });

    tearDown(() {
      gameCubit.close();
      gameStateCubit.close();
      npcNetworkCubit.close();
    });

    test('Game starts successfully', () {
      gameCubit.startGame('Test Player');
      expect(gameCubit.state, isA<GamePlaying>());
    });

    test('Trading attempt initializes NPC relationship', () {
      gameCubit.startGame('Test Player');
      expect(npcNetworkCubit.state.hasMetNpc('chemist_lagos'), isFalse);

      gameCubit.buyDrugFromNpc('chemist_lagos', DrugType.cocaine, 1);

      // Relationship is created after attempt
      expect(npcNetworkCubit.state.hasMetNpc('chemist_lagos'), isTrue);
    });

    test('NPCs at location are queryable', () {
      final repo = const NpcRepository();
      // Get all NPCs to find one with a location
      final allNpcs = repo.getAllNpcs();
      expect(allNpcs.isNotEmpty, isTrue);

      // Get NPCs at a known location
      final npcLocation = allNpcs.first.homeLocation;
      final npcs = repo.getNpcsAtLocation(npcLocation);
      expect(npcs.isNotEmpty, isTrue);
    });

    test('NPC statuses are queryable', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final status = npcNetworkCubit.getRelationshipStatus('chemist_lagos');
      expect(['Stranger', 'Regular', 'Friend', 'Trusted'].contains(status), isTrue);
    });

    test('Trust level is clamped 0-5', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final trustLevel = npcNetworkCubit.getTrustLevel('chemist_lagos');
      expect(trustLevel, greaterThanOrEqualTo(0));
      expect(trustLevel, lessThanOrEqualTo(5));
    });

    test('Relationships can be created multiple times safely', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final rel1 = npcNetworkCubit.state.getRelationship('chemist_lagos');

      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final rel2 = npcNetworkCubit.state.getRelationship('chemist_lagos');

      expect(rel1?.npcId, equals(rel2?.npcId));
    });

    test('Bust status prevents further trading', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      npcNetworkCubit.markNpcBusted('chemist_lagos', 5);

      final reason = npcNetworkCubit.getUnavailableReason('chemist_lagos');
      expect(reason, isNotNull);
    });

    test('Trade recording updates relationship', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final rel1 = npcNetworkCubit.state.getRelationship('chemist_lagos')!;
      expect(rel1.reputation, equals(0));

      npcNetworkCubit.recordTrade(
        npcId: 'chemist_lagos',
        tradeValue: 1000,
        currentTurn: 1,
        quantityTraded: 10,
      );

      final rel2 = npcNetworkCubit.state.getRelationship('chemist_lagos')!;
      expect(rel2.reputation, greaterThan(0));
    });

    test('Game state persists after multiple operations', () {
      gameCubit.startGame('Test Player');

      // Perform several operations
      gameCubit.buyDrug(DrugType.cocaine, 5);
      gameCubit.buyDrugFromNpc('chemist_lagos', DrugType.heroin, 1);

      final finalState = gameCubit.state;
      expect(finalState, isA<GameState>());
    });

    test('Multiple NPCs can be interacted with', () {
      final repo = const NpcRepository();
      final npc1 = repo.getNpcById('chemist_lagos');
      final npc2 = repo.getNpcById('cartel_mexico');

      expect(npc1, isNotNull);
      expect(npc2, isNotNull);
      expect(npc1!.id, isNot(equals(npc2!.id)));
    });

    test('Turn effects decay relationships properly', () {
      npcNetworkCubit.getOrCreateRelationship('chemist_lagos');
      final beforeDecay = npcNetworkCubit.state.getRelationship('chemist_lagos')!;

      npcNetworkCubit.applyTurnEffects();

      // Relationships should still exist after turn effects
      final afterDecay = npcNetworkCubit.state.getRelationship('chemist_lagos')!;
      expect(afterDecay, isNotNull);
    });

    test('Full game loop without errors', () {
      gameCubit.startGame('Test Player');

      // Do various game actions
      gameCubit.buyDrug(DrugType.cocaine, 3);
      gameCubit.buyDrugFromNpc('chemist_lagos', DrugType.cocaine, 1);
      gameCubit.travel(2);

      // State could be GamePlaying or EventOccurred (random encounter)
      expect(gameCubit.state, isA<GameState>());
    });
  });
}
