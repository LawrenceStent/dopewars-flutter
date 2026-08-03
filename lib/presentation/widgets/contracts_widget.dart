import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/value_objects/money.dart';
import '../../domain/contract/entities/contract.dart';
import '../cubits/game/game_cubit.dart';
import '../cubits/game/game_state.dart';
import '../cubits/game_state/game_state_cubit.dart';

/// Widget displaying available and active contracts/jobs.
class ContractsWidget extends StatelessWidget {
  const ContractsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameStateCubit, GameStateState>(
      builder: (context, gameState) {
        final contracts = gameState.activeContracts;
        final active = contracts.where((c) => c.status == ContractStatus.active).toList();
        final available = contracts.where((c) => c.status == ContractStatus.available).toList();

        return BlocBuilder<GameCubit, GameState>(
          builder: (context, gameState) {
            final currentTurn = (gameState is GamePlaying) ? gameState.player.turn : 0;

            return ExpansionTile(
              title: Row(
                children: [
                  Text(
                    'JOBS',
                    style: TextStyle(
                      color: Colors.amber[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (active.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${active.length}',
                          style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              collapsedBackgroundColor: Colors.grey[850],
              backgroundColor: Colors.grey[850],
              children: [
                if (active.isNotEmpty) ...[
                  _SectionHeader('ACTIVE'),
                  ...active.map((c) => _ContractCard(
                    contract: c,
                    currentTurn: currentTurn,
                    isActive: true,
                  )),
                ],
                if (available.isNotEmpty) ...[
                  _SectionHeader('AVAILABLE'),
                  ...available.map((c) => _ContractCard(
                    contract: c,
                    currentTurn: currentTurn,
                    isActive: false,
                  )),
                ],
                if (active.isEmpty && available.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No jobs available.',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  final Contract contract;
  final int currentTurn;
  final bool isActive;

  const _ContractCard({
    required this.contract,
    required this.currentTurn,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final turnsRemaining = contract.acceptedOnTurn != null
        ? (contract.turnLimit - (currentTurn - contract.acceptedOnTurn!))
        : null;

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      size: 12,
                      color: i < contract.difficulty ? Colors.orange : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              contract.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            // Progress or rewards
            if (isActive && turnsRemaining != null) ...[
              LinearProgressIndicator(
                value: contract.progress / 100,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation(Colors.amber[400]),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: ${contract.progress}%',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Turns left: $turnsRemaining',
                    style: TextStyle(
                      color: turnsRemaining <= 2 ? Colors.red : Colors.grey[400],
                      fontSize: 10,
                      fontWeight: turnsRemaining <= 2 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ] else if (!isActive) ...[
              Text(
                '💰 ${Money(contract.cashReward)} +${contract.reputationReward} rep',
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isActive)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => context.read<GameCubit>().abandonContract(contract.id),
                    child: const Text(
                      'ABANDON',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[400],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    onPressed: () => context.read<GameCubit>().acceptContract(contract.id),
                    child: const Text(
                      'ACCEPT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
