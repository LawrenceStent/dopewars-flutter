import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/random_generator.dart';
import '../../../core/value_objects/health.dart';
import '../../../core/value_objects/money.dart';
import '../../../domain/banking/services/interest_calculator.dart';
import '../../../domain/combat/entities/cop.dart';
import '../../../domain/combat/entities/fight.dart';
import '../../../domain/combat/entities/gun.dart';
import '../../../domain/contract/entities/contract.dart';
import '../../../domain/contract/services/contract_service.dart';
import '../../../domain/game/entities/game_session.dart';
import '../../../domain/game/services/game_save_service.dart';
import '../../../domain/game/services/high_score_service.dart';
import '../../../domain/game/services/random_encounter_service.dart';
import '../../../domain/location/entities/location.dart';
import '../../../domain/player/entities/player.dart';
import '../../../domain/player/value_objects/player_flags.dart';
import '../../../domain/npc/entities/npc.dart';
import '../../../domain/npc/repositories/npc_repository.dart';
import '../../../domain/scenario/services/scenario_trigger_service.dart';
import '../../../domain/trading/entities/drug.dart';
import '../../../domain/trading/services/price_generator.dart';
import '../game_state/game_state_cubit.dart';
import '../npc/npc_network_cubit.dart';
import 'game_state.dart';

/// Main game cubit managing all game state.
class GameCubit extends Cubit<GameState> {
  final RandomGenerator _random;
  final PriceGenerator _priceGenerator;
  final InterestCalculator _interestCalculator;
  final RandomEncounterService _encounterService;
  final ScenarioTriggerService _scenarioService;
  final ContractService _contractService;
  final HighScoreService? _highScoreService;
  final GameSaveService? _gameSaveService;
  final GameStateCubit _gameStateCubit;
  final NpcNetworkCubit _npcNetworkCubit;
  final NpcRepository _npcRepository;
  final Uuid _uuid = const Uuid();

  GameCubit({
    required RandomGenerator random,
    required PriceGenerator priceGenerator,
    required InterestCalculator interestCalculator,
    required GameStateCubit gameStateCubit,
    required NpcNetworkCubit npcNetworkCubit,
    RandomEncounterService? encounterService,
    ScenarioTriggerService? scenarioService,
    ContractService? contractService,
    HighScoreService? highScoreService,
    GameSaveService? gameSaveService,
  })  : _random = random,
        _priceGenerator = priceGenerator,
        _interestCalculator = interestCalculator,
        _gameStateCubit = gameStateCubit,
        _npcNetworkCubit = npcNetworkCubit,
        _npcRepository = const NpcRepository(),
        _encounterService = encounterService ??
            RandomEncounterService(random: random),
        _scenarioService = scenarioService ??
            ScenarioTriggerService(random: random),
        _contractService = contractService ??
            ContractService(random: random),
        _highScoreService = highScoreService,
        _gameSaveService = gameSaveService,
        super(const GameInitial());

  /// Expose NpcNetworkCubit for UI access.
  NpcNetworkCubit get npcNetworkCubit => _npcNetworkCubit;

  /// Start a new game.
  void startGame(String playerName) {
    emit(const GameLoading());

    try {
      // Reset game state cubits for new game
      _gameStateCubit.initializeGame();
      _npcNetworkCubit.initializeForNewGame();

      // Create new player
      final startingLocation = _random.nextInt(0, DefaultLocations.count - 1);
      final player = Player.newPlayer(
        id: _uuid.v4(),
        name: playerName,
        startingLocation: startingLocation,
      );

      // Generate initial market with supply/demand state
      final market = _priceGenerator.generateMarket(
        startingLocation,
        supplyState: _gameStateCubit.state.marketSupply,
      );

      final location = DefaultLocations.byIndex(startingLocation);
      emit(GamePlaying(
        player: player,
        currentMarket: market,
        messages: ['Welcome to ${location.name}, ${player.name}!'],
      ));

      // Generate initial contracts
      _generateInitialContracts(player.turn);
    } catch (e) {
      emit(GameError('Failed to start game: $e'));
    }
  }

  /// Generate and add initial contracts to GameStateCubit.
  void _generateInitialContracts(int turn) {
    final contracts = _contractService.generateAvailableContracts(turn);
    for (final contract in contracts) {
      _gameStateCubit.addContract(contract);
    }
  }

  /// Travel to a new location.
  void travel(int newLocationIndex) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;

    // Can't travel if already at this location
    if (player.locationIndex == newLocationIndex) return;

    // Clear first turn flag if set
    var updatedFlags = player.flags;
    if (updatedFlags.isFirstTurn) {
      updatedFlags = updatedFlags.withoutFlag(PlayerFlag.firstTurn);
    }

    // Apply interest
    final interestResult = _interestCalculator.applyTurnInterest(
      currentDebt: player.debt,
      currentBank: player.bank,
    );

    // Advance turn and update location
    final newTurn = player.turn + 1;
    final newDate = player.date.add(const Duration(days: 1));

    // Check for game over
    if (newTurn > GameConstants.numTurns) {
      emit(GameOver(
        finalPlayer: player,
        isDead: false,
        message: 'Time\'s up! Your dealing days are over.',
      ));
      return;
    }

    // Update player
    final updatedPlayer = player.copyWith(
      turn: newTurn,
      date: newDate,
      locationIndex: newLocationIndex,
      debt: interestResult.debt,
      bank: interestResult.bank,
      flags: updatedFlags,
    );

    // Generate new market with supply/demand state
    final newMarket = _priceGenerator.generateMarket(
      newLocationIndex,
      supplyState: _gameStateCubit.state.marketSupply,
    );

    // Build messages
    final messages = <String>[];
    final location = DefaultLocations.byIndex(newLocationIndex);
    messages.add('You\'ve arrived in ${location.name}.');

    // Add special deal messages
    for (final deal in newMarket.specialDeals) {
      if (deal.message != null) {
        messages.add(deal.message!);
      }
    }

    // Check for random encounters
    var finalPlayer = updatedPlayer;
    final encounter = _encounterService.checkForEncounter(
      playerCash: finalPlayer.cash,
      playerDrugCount: finalPlayer.totalDrugsCarried,
      turn: newTurn,
    );

    if (encounter.hasEncounter) {
      // Show event dialog instead of applying effects immediately
      final newMarket = _priceGenerator.generateMarket(
        newLocationIndex,
        supplyState: _gameStateCubit.state.marketSupply,
      );
      emit(EventOccurred(
        player: finalPlayer,
        encounter: encounter,
        currentMarket: newMarket,
      ));
      return;
    }

    // Check for police encounter (affected by player heat)
    final newLocation = DefaultLocations.byIndex(newLocationIndex);
    if (_encounterService.shouldPoliceAttack(
      policePresence: newLocation.policePresence,
      playerDrugCount: finalPlayer.totalDrugsCarried,
      globalHeat: _gameStateCubit.state.reputation.globalHeat,
    )) {
      // Transition to combat
      final copIndex = _random.nextInt(0, DefaultCops.count - 1);
      final cop = DefaultCops.byIndex(copIndex);

      // Get player's best gun or default
      Gun playerGun = DefaultGuns.all.first;
      if (finalPlayer.totalGunsCarried > 0) {
        // Use first gun they have
        for (final gun in DefaultGuns.all) {
          if (finalPlayer.guns.containsKey(gun.index)) {
            playerGun = gun;
            break;
          }
        }
      }

      final fight = Fight.start(
        player: finalPlayer,
        cop: cop,
        playerGun: playerGun,
      );

      emit(GameInCombat(
        player: finalPlayer,
        cop: cop,
        playerGun: playerGun,
        currentMarket: newMarket,
        combat: CombatState(
          opponentName: cop.name,
          opponentHealth: fight.copHealth,
          deputyCount: fight.deputyCount,
          canShoot: true,
          canFlee: true,
          combatLog: fight.combatLog,
        ),
        messages: messages,
      ));

      // Increase heat when police encounter happens
      _gameStateCubit.addHeat(15);

      return;
    }

    // Update contracts: check progress, expiry, and generate new if needed
    finalPlayer = _updateContracts(finalPlayer, newTurn, messages);

    // Apply NPC turn effects (supply decay, reputation decay, unavailability timers)
    _npcNetworkCubit.applyTurnEffects();

    // Check for scenario trigger
    final scenario = _scenarioService.rollForScenario(
      location: newLocation.type,
      heat: _gameStateCubit.state.reputation.globalHeat,
      playerDrugCount: finalPlayer.totalDrugsCarried,
      recentlyTriggered: _gameStateCubit.state.recentlyTriggeredScenarios,
    );

    if (scenario != null) {
      emit(ScenarioOccurred(
        player: finalPlayer,
        scenario: scenario,
        currentMarket: newMarket,
      ));
      return;
    }

    emit(GamePlaying(
      player: finalPlayer,
      currentMarket: newMarket,
      messages: messages,
    ));
  }

  /// Buy drugs.
  void buyDrug(DrugType drugType, int quantity) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final market = currentState.currentMarket;

    // Check if drug is available
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) {
      emit(currentState.withMessage('${drugType.name} is not available here.'));
      return;
    }

    // Check if player can afford it
    final totalCost = priceInfo.price * quantity;
    if (totalCost > player.cash) {
      emit(currentState.withMessage('You can\'t afford that much!'));
      return;
    }

    // Check if player has space
    if (!player.canCarry(quantity)) {
      emit(currentState.withMessage('You don\'t have enough space!'));
      return;
    }

    // Execute purchase
    final updatedPlayer = player
        .copyWith(cash: player.cash - totalCost)
        .addDrug(drugType, quantity, priceInfo.price);

    // Add heat for large transactions (>$50,000)
    if (totalCost.dollars > 50000) {
      _gameStateCubit.addHeat(5);
    }

    // Update supply/demand
    _gameStateCubit.onDrugBought(
      DefaultLocations.byIndex(player.locationIndex).type,
      drugType,
      quantity,
    );

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You bought $quantity ${DefaultDrugs.byType(drugType).name} for $totalCost.',
      ],
    ));
  }

  /// Sell drugs.
  void sellDrug(DrugType drugType, int quantity) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final market = currentState.currentMarket;

    // Check if drug is available in market
    final priceInfo = market.getPrice(drugType);
    if (priceInfo == null) {
      emit(currentState.withMessage('Nobody\'s buying ${drugType.name} here.'));
      return;
    }

    // Check if player has enough
    final inventory = player.getDrugInventory(drugType);
    if (inventory.carried < quantity) {
      emit(currentState.withMessage('You don\'t have that much to sell!'));
      return;
    }

    // Execute sale
    final totalValue = priceInfo.price * quantity;
    final profit = inventory.profitAt(priceInfo.price);

    final updatedPlayer = player
        .copyWith(cash: player.cash + totalValue)
        .removeDrug(drugType, quantity);

    // Add heat for large transactions (>$50,000)
    if (totalValue.dollars > 50000) {
      _gameStateCubit.addHeat(5);
    }

    // Update supply/demand
    _gameStateCubit.onDrugSold(
      DefaultLocations.byIndex(player.locationIndex).type,
      drugType,
      quantity,
    );

    final profitStr = profit.isNegative ? 'lost' : 'made';
    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You sold $quantity ${DefaultDrugs.byType(drugType).name} for $totalValue.',
        if (quantity == inventory.carried)
          'You $profitStr ${profit.abs()} on the deal.',
      ],
    ));
  }

  /// Buy drugs from an NPC.
  ///
  /// Applies NPC-specific pricing with reputation bonus and handles
  /// bust chance rolls. On bust, initiates arrest flow.
  void buyDrugFromNpc(String npcId, DrugType drugType, int quantity) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final market = currentState.currentMarket;
    final npc = _npcRepository.getNpcById(npcId);

    // Validate NPC exists and is a supplier
    if (npc == null || npc.role != NpcRole.supplier) {
      emit(currentState.withMessage('That NPC is not available.'));
      return;
    }

    // Get or initialize relationship
    final relationship = _npcNetworkCubit.getOrCreateRelationship(npcId);

    // Check if NPC can trade
    if (!_npcRepository.canTrade(relationship)) {
      final reason = _npcRepository.getUnavailableReason(relationship);
      emit(currentState.withMessage(reason ?? 'That NPC is unavailable.'));
      return;
    }

    // Get market price for reference
    final marketPriceInfo = market.getPrice(drugType);
    if (marketPriceInfo == null) {
      emit(currentState.withMessage('${drugType.name} is not available here.'));
      return;
    }

    // Calculate NPC price with reputation bonus
    final npcPrice = _npcRepository.calculateNpcPrice(
      marketPriceInfo.price.dollars.toDouble(),
      npc,
      relationship,
    );
    final totalCost = Money(npcPrice * quantity ~/ 1);

    // Check if player can afford it
    if (totalCost > player.cash) {
      emit(currentState.withMessage('You can\'t afford that much!'));
      return;
    }

    // Check if player has space
    if (!player.canCarry(quantity)) {
      emit(currentState.withMessage('You don\'t have enough space!'));
      return;
    }

    // Check NPC has supply
    if (npc.role == NpcRole.supplier && relationship.currentSupply < quantity) {
      emit(currentState.withMessage(
        'That supplier only has ${relationship.currentSupply} units available.',
      ));
      return;
    }

    // Roll for bust chance
    final bustChance = npc.bustChance;
    final isBusted = _random.nextDouble() < bustChance;

    if (isBusted) {
      // Handle arrest
      _handleArrestDuringNpcTrade(npcId, player, currentState);
      return;
    }

    // Execute purchase
    final npcPriceMoney = Money(npcPrice.toInt());
    final updatedPlayer = player
        .copyWith(cash: player.cash - totalCost)
        .addDrug(drugType, quantity, npcPriceMoney);

    // Record trade in NPC network
    _npcNetworkCubit.recordTrade(
      npcId: npcId,
      tradeValue: totalCost.cents,
      currentTurn: player.turn,
      quantityTraded: quantity,
    );

    // Add heat for large transactions (>$50,000)
    if (totalCost.dollars > 50000) {
      _gameStateCubit.addHeat(5);
    }

    final discount = ((marketPriceInfo.price.dollars - npcPrice) /
        marketPriceInfo.price.dollars * 100).toStringAsFixed(0);

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You bought $quantity ${DefaultDrugs.byType(drugType).name} from ${npc.name} for $totalCost.',
        'That\'s $discount% off market price!',
      ],
    ));
  }

  /// Sell drugs to an NPC buyer.
  ///
  /// Applies NPC-specific pricing with reputation bonus and handles
  /// bust chance rolls. On bust, initiates arrest flow.
  void sellDrugToNpc(String npcId, DrugType drugType, int quantity) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final market = currentState.currentMarket;
    final npc = _npcRepository.getNpcById(npcId);

    // Validate NPC exists and is a buyer
    if (npc == null || npc.role != NpcRole.buyer) {
      emit(currentState.withMessage('That NPC is not available.'));
      return;
    }

    // Get or initialize relationship
    final relationship = _npcNetworkCubit.getOrCreateRelationship(npcId);

    // Check if NPC can trade
    if (!_npcRepository.canTrade(relationship)) {
      final reason = _npcRepository.getUnavailableReason(relationship);
      emit(currentState.withMessage(reason ?? 'That NPC is unavailable.'));
      return;
    }

    // Check if player has enough
    final inventory = player.getDrugInventory(drugType);
    if (inventory.carried < quantity) {
      emit(currentState.withMessage('You don\'t have that much to sell!'));
      return;
    }

    // Get market price for reference
    final marketPriceInfo = market.getPrice(drugType);
    if (marketPriceInfo == null) {
      emit(currentState.withMessage('Nobody\'s buying ${drugType.name} here.'));
      return;
    }

    // Calculate NPC price with reputation bonus
    final npcPrice = _npcRepository.calculateNpcPrice(
      marketPriceInfo.price.dollars.toDouble(),
      npc,
      relationship,
    );
    final totalValue = Money(npcPrice * quantity ~/ 1);

    // Roll for bust chance
    final bustChance = npc.bustChance;
    final isBusted = _random.nextDouble() < bustChance;

    if (isBusted) {
      // Handle arrest
      _handleArrestDuringNpcTrade(npcId, player, currentState);
      return;
    }

    // Execute sale
    final updatedPlayer = player
        .copyWith(cash: player.cash + totalValue)
        .removeDrug(drugType, quantity);

    // Record trade in NPC network
    _npcNetworkCubit.recordTrade(
      npcId: npcId,
      tradeValue: totalValue.cents,
      currentTurn: player.turn,
      quantityTraded: quantity,
    );

    // Add heat for large transactions (>$50,000)
    if (totalValue.dollars > 50000) {
      _gameStateCubit.addHeat(5);
    }

    final npcPriceMoney = Money(npcPrice.toInt());
    final profit = inventory.profitAt(npcPriceMoney);
    final profitStr = profit.isNegative ? 'lost' : 'made';

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You sold $quantity ${DefaultDrugs.byType(drugType).name} to ${npc.name} for $totalValue.',
        if (quantity == inventory.carried)
          'You $profitStr ${profit.abs()} on the deal.',
      ],
    ));
  }

  /// Handle arrest during NPC trade.
  ///
  /// Mark NPC as busted and transition to game over.
  void _handleArrestDuringNpcTrade(
    String npcId,
    Player player,
    GamePlaying currentState,
  ) {
    final npc = _npcRepository.getNpcById(npcId);
    if (npc == null) return;

    // Mark NPC as busted (unavailable for 10 turns)
    _npcNetworkCubit.markNpcBusted(npcId, 10);

    // Add heat penalty
    _gameStateCubit.addHeat(30);

    // Create busted player with empty cargo
    final bustedPlayer = player.copyWith(
      drugs: {},
    );

    emit(GameOver(
      finalPlayer: bustedPlayer,
      isDead: false,
      message: 'You were busted trading with ${npc.name}! '
          'Your cargo was confiscated and you paid a heavy fine.',
    ));
  }

  /// Use fixer service to reduce heat via bribery.
  ///
  /// Cost: $750/heat point, discounted by reputation.
  /// Cooldown: Once per 3 turns.
  /// Risk: Bust chance on failure = arrest and bust NPC.
  void useFixerService(String npcId, int heatToReduce) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final npc = _npcRepository.getNpcById(npcId);

    // Validate NPC exists and is a fixer
    if (npc == null || npc.role != NpcRole.fixer) {
      emit(currentState.withMessage('That NPC is not available.'));
      return;
    }

    // Get or initialize relationship
    final relationship = _npcNetworkCubit.getOrCreateRelationship(npcId);

    // Check if NPC can trade
    if (!_npcRepository.canTrade(relationship)) {
      final reason = _npcRepository.getUnavailableReason(relationship);
      emit(currentState.withMessage(reason ?? 'That NPC is unavailable.'));
      return;
    }

    // Check cooldown (once per 3 turns)
    if (!_npcRepository.canUseFixerService(relationship, player.turn)) {
      emit(currentState.withMessage(
        'The Fixer is busy. Come back later.',
      ));
      return;
    }

    // Calculate cost
    final cost = Money(_npcRepository.calculateFixerCost(
      heatToReduce,
      relationship,
    ).toInt());

    // Check if player can afford it
    if (cost > player.cash) {
      emit(currentState.withMessage('You can\'t afford that!'));
      return;
    }

    // Check heat is positive
    if (heatToReduce <= 0) {
      emit(currentState.withMessage('Invalid heat amount.'));
      return;
    }

    // Roll for bust chance
    final bustChance = npc.bustChance;
    final isBusted = _random.nextDouble() < bustChance;

    if (isBusted) {
      // Handle arrest
      _handleArrestDuringNpcTrade(npcId, player, currentState);
      return;
    }

    // Execute service
    final updatedPlayer = player.copyWith(
      cash: player.cash - cost,
    );

    // Reduce heat
    _gameStateCubit.reduceHeat(heatToReduce);

    // Record trade in NPC network (for cooldown tracking)
    _npcNetworkCubit.recordTrade(
      npcId: npcId,
      tradeValue: cost.cents,
      currentTurn: player.turn,
      quantityTraded: heatToReduce,
    );

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You paid the Fixer $cost to reduce heat by $heatToReduce.',
        'Heat reduced.',
      ],
    ));
  }

  /// Use doctor service to restore health.
  ///
  /// Cost: $300/health point, discounted by reputation.
  /// Risk: Bust chance on failure = arrest and bust NPC.
  void useDoctorService(String npcId, int healthToRestore) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final npc = _npcRepository.getNpcById(npcId);

    // Validate NPC exists and is a doctor
    if (npc == null || npc.role != NpcRole.doctor) {
      emit(currentState.withMessage('That NPC is not available.'));
      return;
    }

    // Get or initialize relationship
    final relationship = _npcNetworkCubit.getOrCreateRelationship(npcId);

    // Check if NPC can trade
    if (!_npcRepository.canTrade(relationship)) {
      final reason = _npcRepository.getUnavailableReason(relationship);
      emit(currentState.withMessage(reason ?? 'That NPC is unavailable.'));
      return;
    }

    // Check if health is already at max
    if (player.health.value >= 100) {
      emit(currentState.withMessage('You\'re already in perfect health!'));
      return;
    }

    // Clamp to max 100 health
    final maxRestorable = 100 - player.health.value;
    final actualRestore = healthToRestore.clamp(0, maxRestorable);

    if (actualRestore <= 0) {
      emit(currentState.withMessage('Invalid health amount.'));
      return;
    }

    // Calculate cost
    final cost = Money(_npcRepository.calculateDoctorCost(
      actualRestore,
      relationship,
    ).toInt());

    // Check if player can afford it
    if (cost > player.cash) {
      emit(currentState.withMessage('You can\'t afford that!'));
      return;
    }

    // Roll for bust chance
    final bustChance = npc.bustChance;
    final isBusted = _random.nextDouble() < bustChance;

    if (isBusted) {
      // Handle arrest
      _handleArrestDuringNpcTrade(npcId, player, currentState);
      return;
    }

    // Execute service
    final updatedPlayer = player.copyWith(
      cash: player.cash - cost,
      health: Health((player.health.value + actualRestore).clamp(0, 100)),
    );

    // Record trade in NPC network
    _npcNetworkCubit.recordTrade(
      npcId: npcId,
      tradeValue: cost.cents,
      currentTurn: player.turn,
      quantityTraded: actualRestore,
    );

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You paid the Doctor $cost to restore $actualRestore health.',
        'Health restored to ${updatedPlayer.health.value}.',
      ],
    ));
  }

  /// Use lawyer service for arrest protection.
  ///
  /// Cost: $7500, discounted by reputation.
  /// One-time use per game (no bust risk).
  /// Effect: Sets PlayerFlag.lawyerActive, which converts one arrest to a fine.
  void useLawyerService(String npcId) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    final npc = _npcRepository.getNpcById(npcId);

    // Validate NPC exists and is a lawyer
    if (npc == null || npc.role != NpcRole.lawyer) {
      emit(currentState.withMessage('That NPC is not available.'));
      return;
    }

    // Get or initialize relationship
    final relationship = _npcNetworkCubit.getOrCreateRelationship(npcId);

    // Check if NPC can trade
    if (!_npcRepository.canTrade(relationship)) {
      final reason = _npcRepository.getUnavailableReason(relationship);
      emit(currentState.withMessage(reason ?? 'That NPC is unavailable.'));
      return;
    }

    // Check if lawyer already used
    if (_npcRepository.lawyerAlreadyUsed(relationship)) {
      emit(currentState.withMessage('You\'ve already hired the Lawyer once.'));
      return;
    }

    // Calculate cost
    final cost = Money(_npcRepository.calculateLawyerCost(relationship).toInt());

    // Check if player can afford it
    if (cost > player.cash) {
      emit(currentState.withMessage('You can\'t afford that!'));
      return;
    }

    // Execute service (no bust chance for lawyer - 100% safe)
    var updatedPlayer = player.copyWith(
      cash: player.cash - cost,
    );

    // Set lawyer protection flag
    if (!updatedPlayer.flags.hasLawyer) {
      updatedPlayer = updatedPlayer.copyWith(
        flags: updatedPlayer.flags.withFlag(PlayerFlag.lawyerActive),
      );
    }

    // Record trade in NPC network
    _npcNetworkCubit.recordTrade(
      npcId: npcId,
      tradeValue: cost.cents,
      currentTurn: player.turn,
      quantityTraded: 1,
    );

    emit(currentState.copyWith(
      player: updatedPlayer,
      messages: [
        'You hired the Lawyer for $cost.',
        'Protection active: Your next arrest will be converted to a fine.',
      ],
    ));
  }

  /// Visit the bank.
  void visitBank() {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    if (player.locationIndex != DefaultLocations.bankIndex()) {
      emit(currentState.withMessage('The bank is in the Ghetto.'));
      return;
    }

    emit(GameAtLocation(
      player: player,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.bank,
    ));
  }

  /// Deposit money in bank.
  void depositMoney(Money amount) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.bank) return;

    final player = currentState.player;
    if (amount > player.cash) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.bank,
        messages: ['You don\'t have that much cash!'],
      ));
      return;
    }

    final updatedPlayer = player.copyWith(
      cash: player.cash - amount,
      bank: player.bank + amount,
    );

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: ['You deposited $amount in the bank.'],
    ));
  }

  /// Withdraw money from bank.
  void withdrawMoney(Money amount) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.bank) return;

    final player = currentState.player;
    if (amount > player.bank) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.bank,
        messages: ['You don\'t have that much in the bank!'],
      ));
      return;
    }

    final updatedPlayer = player.copyWith(
      cash: player.cash + amount,
      bank: player.bank - amount,
    );

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: ['You withdrew $amount from the bank.'],
    ));
  }

  /// Visit the loan shark.
  void visitLoanShark() {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    if (player.locationIndex != DefaultLocations.loanSharkIndex()) {
      emit(currentState.withMessage('The Loan Shark is in the Ghetto.'));
      return;
    }

    emit(GameAtLocation(
      player: player,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.loanShark,
    ));
  }

  /// Pay off debt to loan shark.
  void payDebt(Money amount) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.loanShark) return;

    final player = currentState.player;
    if (amount > player.cash) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.loanShark,
        messages: ['You don\'t have that much cash!'],
      ));
      return;
    }

    // Can't pay more than owed
    final payAmount = amount > player.debt ? player.debt : amount;

    final updatedPlayer = player.copyWith(
      cash: player.cash - payAmount,
      debt: player.debt - payAmount,
    );

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: ['You paid $payAmount to the Loan Shark.'],
    ));
  }

  /// Borrow money from loan shark.
  void borrowMoney(Money amount) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.loanShark) return;

    final player = currentState.player;

    // Maximum borrow amount (can't borrow more than 2x current debt)
    final maxBorrow = Money(GameConstants.startDebt * 2) - player.debt;
    if (maxBorrow.dollars <= 0) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.loanShark,
        messages: ['The Loan Shark says: "You already owe me too much!"'],
      ));
      return;
    }

    final borrowAmount = amount > maxBorrow ? maxBorrow : amount;

    final updatedPlayer = player.copyWith(
      cash: player.cash + borrowAmount,
      debt: player.debt + borrowAmount,
    );

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: [
        'You borrowed $borrowAmount from the Loan Shark.',
        'Remember: 10% interest per day!',
      ],
    ));
  }

  /// Leave current special location.
  void leaveLocation() {
    final currentState = state;
    if (currentState is! GameAtLocation) return;

    emit(GamePlaying(
      player: currentState.player,
      currentMarket: currentState.currentMarket,
    ));
  }

  /// Leave combat and return to normal play.
  void leaveCombat(Player updatedPlayer) {
    final currentState = state;
    if (currentState is! GameInCombat) return;

    // Check if player died
    if (updatedPlayer.health.value <= 0) {
      emit(GameOver(
        finalPlayer: updatedPlayer,
        isDead: true,
        message: 'You were killed in combat!',
      ));
      return;
    }

    // Return to normal play with updated player
    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: ['You survived the encounter!'],
    ));
  }

  /// Visit the gun shop.
  void visitGunShop() {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    if (player.locationIndex != DefaultLocations.gunShopIndex()) {
      emit(currentState.withMessage('The gun shop is at the Gun Shop.'));
      return;
    }

    emit(GameAtLocation(
      player: player,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.gunShop,
    ));
  }

  /// Buy a gun from the gun shop.
  void buyGun(int gunIndex, int quantity) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.gunShop) {
      return;
    }

    final player = currentState.player;
    final gun = DefaultGuns.byIndex(gunIndex);

    // Check if player can afford it
    final totalCost = gun.price * quantity;
    if (totalCost > player.cash) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.gunShop,
        messages: ['You can\'t afford that!'],
      ));
      return;
    }

    // Check if player has space (each gun takes 4 space)
    final spaceNeeded = gun.space * quantity;
    if (!player.canCarry(spaceNeeded)) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.gunShop,
        messages: ['You don\'t have enough space!'],
      ));
      return;
    }

    // Execute purchase
    var updatedPlayer = player.copyWith(
      cash: player.cash - totalCost,
    );

    // Add guns to inventory
    for (int i = 0; i < quantity; i++) {
      updatedPlayer = updatedPlayer.addGun(gunIndex, gun.price);
    }

    emit(GameAtLocation(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.gunShop,
      messages: [
        'You bought $quantity ${gun.name} for $totalCost.',
      ],
    ));
  }

  /// Visit the pub.
  void visitPub() {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    final player = currentState.player;
    if (player.locationIndex != DefaultLocations.roughPubIndex()) {
      emit(currentState.withMessage('The pub is at The Pub.'));
      return;
    }

    emit(GameAtLocation(
      player: player,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.roughPub,
    ));
  }

  /// Hire a bitch to increase carrying capacity.
  void hireBitch(int quantity) {
    final currentState = state;
    if (currentState is! GameAtLocation ||
        currentState.location != SpecialLocation.roughPub) {
      return;
    }

    final player = currentState.player;
    final totalCost = Money(GameConstants.bitchHireCost * quantity);

    // Check if player can afford it
    if (totalCost > player.cash) {
      emit(GameAtLocation(
        player: player,
        currentMarket: currentState.currentMarket,
        location: SpecialLocation.roughPub,
        messages: ['You can\'t afford that!'],
      ));
      return;
    }

    // Hire bitches and increase coat size
    final capacityIncrease = GameConstants.bitchCarryCapacity * quantity;
    final updatedPlayer = player.copyWith(
      cash: player.cash - totalCost,
      coatSize: player.coatSize.add(capacityIncrease),
    );

    emit(GameAtLocation(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      location: SpecialLocation.roughPub,
      messages: [
        'You hired $quantity bitch${quantity > 1 ? 'es' : ''} for $totalCost.',
        'Your carrying capacity is now ${updatedPlayer.coatSize.value}.',
      ],
    ));
  }

  /// Acknowledge an event and return to normal play, applying effects.
  void acknowledgeEvent() {
    final currentState = state;
    if (currentState is! EventOccurred) return;

    var updatedPlayer = currentState.player;
    final encounter = currentState.encounter;

    // Apply encounter effects
    if (encounter.moneyChange != null) {
      final newCash = updatedPlayer.cash + encounter.moneyChange!;
      updatedPlayer = updatedPlayer.copyWith(
        cash: newCash.dollars < 0 ? Money.zero : newCash,
      );
    }

    if (encounter.drugType != null && encounter.drugQuantity != null) {
      // Found drugs - add them to inventory at zero cost
      updatedPlayer = updatedPlayer.addDrug(
        encounter.drugType!,
        encounter.drugQuantity!,
        Money.zero,
      );
    }

    if (encounter.extraSpace != null) {
      updatedPlayer = updatedPlayer.copyWith(
        coatSize: updatedPlayer.coatSize.add(encounter.extraSpace!),
      );
    }

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: [encounter.message],
    ));
  }

  /// Resolve a scenario choice and apply its outcome.
  void resolveScenarioChoice(String choiceId) {
    final currentState = state;
    if (currentState is! ScenarioOccurred) return;

    final scenario = currentState.scenario;
    final outcome = scenario.outcomes[choiceId];
    if (outcome == null) return;

    var updatedPlayer = currentState.player;

    // Apply cash change
    if (outcome.cashChange != 0) {
      final newCash = updatedPlayer.cash + Money(outcome.cashChange);
      updatedPlayer = updatedPlayer.copyWith(
        cash: newCash.dollars < 0 ? Money.zero : newCash,
      );
    }

    // Apply health change
    if (outcome.healthChange != 0) {
      final newHealth = updatedPlayer.health.value + outcome.healthChange;
      updatedPlayer = updatedPlayer.copyWith(
        health: Health(newHealth.clamp(0, 100)),
      );
    }

    // Apply drugs lost
    if (outcome.drugsLost > 0) {
      // Lose drugs from inventory
      for (final drug in DefaultDrugs.all) {
        final inventory = updatedPlayer.getDrugInventory(drug.type);
        if (inventory.carried > 0) {
          final toRemove = outcome.drugsLost.clamp(0, inventory.carried);
          updatedPlayer = updatedPlayer.removeDrug(drug.type, toRemove);
          if (toRemove >= outcome.drugsLost) break;
        }
      }
    }

    // Apply heat and reputation changes through GameStateCubit
    if (outcome.heatChange != 0) {
      _gameStateCubit.addHeat(outcome.heatChange);
    }

    if (outcome.reputationChange != 0) {
      _gameStateCubit.addReputation(outcome.reputationChange);
    }

    // Mark this scenario as recently triggered (3-turn cooldown)
    _gameStateCubit.markScenarioTriggered(scenario.id, 3);

    emit(GamePlaying(
      player: updatedPlayer,
      currentMarket: currentState.currentMarket,
      messages: [outcome.message],
    ));
  }

  /// Update contracts: evaluate progress, check expiry, and refresh if needed.
  /// Returns the updated player (may have cash rewards applied).
  Player _updateContracts(Player player, int currentTurn, List<String> messages) {
    var updatedPlayer = player;
    final contracts = _gameStateCubit.state.activeContracts;

    for (final contract in contracts) {
      // Check if contract expired
      if (contract.status == ContractStatus.active && contract.hasExpired(currentTurn)) {
        _gameStateCubit.updateContract(contract.copyWith(status: ContractStatus.expired));
        messages.add('Contract expired: ${contract.title}');
        continue;
      }

      // Evaluate progress for active contracts
      if (contract.status == ContractStatus.active) {
        final progressed = _contractService.evaluateProgress(contract, player, currentTurn);
        if (progressed != null) {
          _gameStateCubit.updateContract(progressed);

          // Check if completed
          if (progressed.progress >= 100) {
            _gameStateCubit.updateContract(progressed.copyWith(status: ContractStatus.completed));
            messages.add('Contract completed: ${progressed.title}');
            // Apply rewards to player
            updatedPlayer = updatedPlayer
                .copyWith(cash: updatedPlayer.cash + Money(progressed.cashReward));
            _gameStateCubit.addReputation(progressed.reputationReward);
          }
        }
      }
    }

    // Generate new contracts every 5 turns
    if (currentTurn % 5 == 0) {
      _generateInitialContracts(currentTurn);
    }

    return updatedPlayer;
  }

  /// Accept an available contract.
  void acceptContract(String contractId) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    Contract? contract;
    for (final c in _gameStateCubit.state.activeContracts) {
      if (c.id == contractId) {
        contract = c;
        break;
      }
    }

    if (contract == null || contract.status != ContractStatus.available) return;

    _gameStateCubit.updateContract(
      contract.copyWith(
        status: ContractStatus.active,
        acceptedOnTurn: currentState.player.turn,
      ),
    );
    emit(currentState.withMessage('Job accepted: ${contract.title}'));
  }

  /// Abandon an active contract.
  void abandonContract(String contractId) {
    final currentState = state;
    if (currentState is! GamePlaying) return;

    Contract? contract;
    for (final c in _gameStateCubit.state.activeContracts) {
      if (c.id == contractId) {
        contract = c;
        break;
      }
    }

    if (contract == null || contract.status != ContractStatus.active) return;

    _gameStateCubit.updateContract(contract.copyWith(status: ContractStatus.failed));
    emit(currentState.withMessage('You abandoned: ${contract.title}'));
  }

  /// Clear messages.
  void clearMessages() {
    final currentState = state;
    if (currentState is GamePlaying) {
      emit(currentState.clearMessages());
    }
  }

  /// Check if a net worth qualifies for high scores.
  Future<bool> isHighScore(int netWorth) async {
    if (_highScoreService == null) return false;
    return await _highScoreService.isHighScore(netWorth);
  }

  /// Save the current game.
  Future<bool> saveGame() async {
    final currentState = state;
    if (currentState is! GamePlaying) return false;
    if (_gameSaveService == null) return false;

    try {
      final session = GameSession(
        id: _uuid.v4(),
        playerName: currentState.player.name,
        turn: currentState.player.turn,
        netWorth: currentState.player.netWorth.dollars,
        locationIndex: currentState.player.locationIndex,
        savedAt: DateTime.now(),
      );

      return await _gameSaveService.saveGame(session);
    } catch (e) {
      return false;
    }
  }

  /// Get all saved games.
  Future<List<GameSession>> getSaves() async {
    if (_gameSaveService == null) return [];
    return await _gameSaveService.getSaves();
  }

  /// Load a saved game.
  Future<bool> loadGame(String saveId) async {
    if (_gameSaveService == null) return false;

    try {
      final session = await _gameSaveService.loadGame(saveId);
      if (session == null) return false;

      // Load the game by starting a new game with the saved player name
      // and advancing to the saved turn and location
      // Note: This is a simplified restoration. A full restoration would
      // require serializing the complete game state.
      emit(const GameLoading());
      startGame(session.playerName);
      return true;
    } catch (e) {
      emit(GameError('Failed to load game: $e'));
      return false;
    }
  }

  /// Delete a saved game.
  Future<bool> deleteSave(String saveId) async {
    if (_gameSaveService == null) return false;
    return await _gameSaveService.deleteSave(saveId);
  }
}
