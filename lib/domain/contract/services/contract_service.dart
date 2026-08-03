import '../../../core/utils/random_generator.dart';
import '../../location/entities/location.dart';
import '../../player/entities/player.dart';
import '../entities/contract.dart';

/// Service for managing game contracts.
class ContractService {
  final RandomGenerator _random;

  ContractService({required RandomGenerator random}) : _random = random;

  /// Generate 2-3 available contracts for the current turn.
  /// Only transport and logistics contracts are offered (stealth/collection in Phase 3).
  List<Contract> generateAvailableContracts(int currentTurn) {
    final count = _random.nextInt(2, 3);
    final generated = <Contract>[];

    // Filter to only transport and logistics contracts
    final availableTemplates = DefaultContracts.templates
        .where((c) => c.type == ContractType.transport || c.type == ContractType.logistics)
        .toList();

    for (int i = 0; i < count; i++) {
      final template = availableTemplates[
          _random.nextInt(0, availableTemplates.length - 1)];

      final contract = Contract(
        id: '${template.id}_$currentTurn',
        title: template.title,
        description: template.description,
        type: template.type,
        locations: template.locations,
        cashReward: template.cashReward,
        reputationReward: template.reputationReward,
        turnLimit: template.turnLimit,
        difficulty: template.difficulty,
        status: ContractStatus.available,
        acceptedOnTurn: null,
        progress: 0,
      );

      generated.add(contract);
    }

    return generated;
  }

  /// Evaluate progress for a transport contract based on location changes.
  Contract? evaluateProgress(
    Contract contract,
    Player player,
    int currentTurn,
  ) {
    if (contract.status != ContractStatus.active) return null;
    if (contract.type != ContractType.transport) return null;

    // Check if player is in a target location
    final playerLocation = DefaultLocations.byIndex(player.locationIndex).type;
    if (contract.locations.contains(playerLocation)) {
      // Progress the contract
      final newProgress = (contract.progress + 25).clamp(0, 100);
      return contract.copyWith(progress: newProgress);
    }

    return null;
  }

  /// Check if a contract is completed.
  bool checkCompletion(
    Contract contract,
    Player player,
    int currentTurn,
  ) {
    if (contract.acceptedOnTurn == null) return false;

    // Check if expired
    if (currentTurn - contract.acceptedOnTurn! > contract.turnLimit) {
      return false;
    }

    switch (contract.type) {
      case ContractType.transport:
        // Completed if progress reached 100%
        return contract.progress >= 100;

      case ContractType.elimination:
        // Not implemented yet - would require tracking defeated dealers
        return false;

      case ContractType.relationship:
        // Not implemented yet - would require NPC reputation checks
        return false;

      case ContractType.stealth:
        // Completed if no police encounters in turnLimit turns
        // Would require tracking encounters externally
        return false;

      case ContractType.logistics:
        // Progress-based like transport
        return contract.progress >= 100;

      case ContractType.collection:
        // Not implemented yet - would require cash target checks
        return false;
    }
  }
}
