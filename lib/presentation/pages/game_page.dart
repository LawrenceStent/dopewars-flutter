import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/entities/fight.dart';
import '../../domain/location/entities/location.dart';
import '../../domain/npc/entities/npc.dart';
import '../../domain/npc/repositories/npc_repository.dart';
import '../../injection_container.dart';
import '../cubits/combat/combat_cubit.dart';
import '../cubits/game/game_cubit.dart';
import '../cubits/game/game_state.dart';
import '../cubits/game_state/game_state_cubit.dart';
import '../widgets/bank_widget.dart';
import '../widgets/combat_widget.dart';
import '../widgets/contracts_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/drug_market_widget.dart';
import '../widgets/event_dialog.dart';
import '../widgets/gun_shop_widget.dart';
import '../widgets/high_score_submission_dialog.dart';
import '../widgets/inventory_widget.dart';
import '../widgets/loan_shark_widget.dart';
import '../widgets/location_selector.dart';
import '../widgets/npc_list_widget.dart';
import '../widgets/npc_trade_dialog.dart';
import '../widgets/player_stats_widget.dart';
import '../widgets/pub_widget.dart';
import '../widgets/scenario_dialog.dart';
import '../widgets/travel_bottom_sheet.dart';

/// Main game page.
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerName = GoRouterState.of(context).extra as String? ?? 'Player';

    return BlocProvider(
      create: (_) => sl<GameCubit>()..startGame(playerName),
      child: const _GamePageContent(),
    );
  }
}

class _GamePageContent extends StatelessWidget {
  const _GamePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          if (state is GameOver) {
            _showGameOverDialog(context, state);
          }
          if (state is EventOccurred) {
            _showEventDialog(context, state);
          }
          if (state is ScenarioOccurred) {
            _showScenarioDialog(context, state);
          }
        },
        child: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            return switch (state) {
              GameInitial() => const _LoadingView(),
              GameLoading() => const _LoadingView(),
              GamePlaying() => _PlayingView(state: state),
              GameAtLocation() => _LocationView(state: state),
              GameInCombat() => _CombatView(state: state),
              GameOver() => const _LoadingView(),
              GameError() => _ErrorView(message: state.message),
              EventOccurred() => _PlayingView(state: GamePlaying(
                player: state.player,
                currentMarket: state.currentMarket,
              )),
              ScenarioOccurred() => _PlayingView(state: GamePlaying(
                player: state.player,
                currentMarket: state.currentMarket,
              )),
            };
          },
        ),
      ),
    );
  }

  void _showEventDialog(BuildContext context, EventOccurred state) {
    EventDialog.showEncounter(
      context: context,
      encounter: state.encounter,
    ).then((_) {
      if (context.mounted) {
        context.read<GameCubit>().acknowledgeEvent();
      }
    });
  }

  void _showScenarioDialog(BuildContext context, ScenarioOccurred state) {
    ScenarioDialog.show(
      context: context,
      scenario: state.scenario,
      onChoiceMade: (choiceId) {
        if (context.mounted) {
          context.read<GameCubit>().resolveScenarioChoice(choiceId);
        }
      },
    );
  }

  Future<void> _showGameOverDialog(BuildContext context, GameOver state) async {
    // Check if score is a high score
    final gameCubit = context.read<GameCubit>();
    final isHighScore =
        await gameCubit.isHighScore(state.finalPlayer.netWorth.dollars);

    if (!context.mounted) return;

    if (isHighScore) {
      // Show high score submission dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => HighScoreSubmissionDialog(
          netWorth: state.finalPlayer.netWorth.dollars,
          turn: state.finalPlayer.turn,
          onClose: () {
            if (context.mounted) {
              Navigator.of(context).pop();
              context.go('/');
            }
          },
        ),
      );
    } else {
      // Show regular game over dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            state.isDead ? 'GAME OVER' : 'TIME\'S UP!',
            style: TextStyle(
              color: state.isDead ? Colors.red : Colors.green[400],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Final Net Worth: ${state.finalPlayer.netWorth}',
                style: TextStyle(
                  color: Colors.green[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      );
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: LoadingStateWidget(message: 'Loading game...'),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ErrorStateWidget(
        message: message,
        onRetry: () => context.go('/'),
        icon: Icons.error_outline,
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  final GamePlaying state;

  const _PlayingView({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return _WideLayout(state: state);
        } else {
          return _NarrowLayout(state: state);
        }
      },
    );
  }
}

class _WideLayout extends StatelessWidget {
  final GamePlaying state;

  const _WideLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel - Stats and locations
        SizedBox(
          width: 300,
          child: Column(
            children: [
              PlayerStatsWidget(player: state.player),
              const Divider(color: Colors.grey),
              // Location list (scrollable, expanded)
              Expanded(
                child: LocationSelector(
                  currentLocation: state.player.locationIndex,
                  onLocationSelected: (index) {
                    context.read<GameCubit>().travel(index);
                  },
                  onVisitBank: () => context.read<GameCubit>().visitBank(),
                  onVisitLoanShark: () => context.read<GameCubit>().visitLoanShark(),
                  onVisitNpcs: () => _showNpcList(context, state),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(color: Colors.grey),
        // Center panel - Market
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Messages
              if (state.messages.isNotEmpty)
                _MessagesBar(messages: state.messages),
              // Market
              Expanded(
                child: DrugMarketWidget(
                  market: state.currentMarket,
                  player: state.player,
                  onBuy: (type, qty) =>
                      context.read<GameCubit>().buyDrug(type, qty),
                  onSell: (type, qty) =>
                      context.read<GameCubit>().sellDrug(type, qty),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(color: Colors.grey),
        // Right panel - Inventory and Jobs
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stash section (top half)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'YOUR STASH',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: InventoryWidget(
                  player: state.player,
                  market: state.currentMarket,
                  onSell: (type, qty) =>
                      context.read<GameCubit>().sellDrug(type, qty),
                ),
              ),
              const Divider(color: Colors.grey),
              // Jobs section (bottom half)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'JOBS',
                  style: TextStyle(
                    color: Colors.amber[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ContractsWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNpcList(BuildContext context, GamePlaying state) {
    final location = DefaultLocations.byIndex(state.player.locationIndex);
    final gameCubit = context.read<GameCubit>();
    showDialog(
      context: context,
      builder: (context) => NpcListWidget(
        player: state.player,
        npcsAtLocation: const NpcRepository().getNpcsAtLocation(location.type),
        npcNetworkCubit: gameCubit.npcNetworkCubit,
        onNpcSelected: (npcId, npcName) {
          Navigator.pop(context);
          _showNpcTradeDialog(context, state, npcId);
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showNpcTradeDialog(BuildContext context, GamePlaying state, String npcId) {
    final npc = const NpcRepository().getNpcById(npcId);
    if (npc == null) return;

    final gameCubit = context.read<GameCubit>();
    final gameStateCubit = sl<GameStateCubit>();

    showDialog(
      context: context,
      builder: (context) => NpcTradeDialog(
        npcId: npcId,
        npc: npc,
        player: state.player,
        currentHeat: gameStateCubit.state.reputation.globalHeat,
        npcNetworkCubit: gameCubit.npcNetworkCubit,
        npcRepository: const NpcRepository(),
        onBuyFromNpc: (npcId, drugType, quantity) {
          gameCubit.buyDrugFromNpc(npcId, drugType, quantity);
        },
        onSellToNpc: (npcId, drugType, quantity) {
          gameCubit.sellDrugToNpc(npcId, drugType, quantity);
        },
        onUseFixerService: (npcId, heatToReduce) {
          gameCubit.useFixerService(npcId, heatToReduce);
        },
        onUseDoctorService: (npcId, healthToRestore) {
          gameCubit.useDoctorService(npcId, healthToRestore);
        },
        onUseLawyerService: (npcId) {
          gameCubit.useLawyerService(npcId);
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final GamePlaying state;

  const _NarrowLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            TravelBottomSheet.show(
              context,
              player: state.player,
              onLocationSelected: (index) {
                context.read<GameCubit>().travel(index);
              },
              onVisitBank: () => context.read<GameCubit>().visitBank(),
              onVisitLoanShark: () => context.read<GameCubit>().visitLoanShark(),
            );
          },
          tooltip: 'Travel',
          child: const Icon(Icons.flight),
        ),
        body: Column(
          children: [
            // Messages
            if (state.messages.isNotEmpty)
              _MessagesBar(messages: state.messages),
            // Stats header
            PlayerStatsWidget(player: state.player, compact: true),
            // Tab bar
            TabBar(
              labelColor: Colors.green[400],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green[400],
              tabs: const [
                Tab(text: 'MARKET'),
                Tab(text: 'STASH'),
                Tab(text: 'JOBS'),
                Tab(text: 'CONTACTS'),
                Tab(text: 'STATS'),
              ],
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Market tab
                  DrugMarketWidget(
                    market: state.currentMarket,
                    player: state.player,
                    onBuy: (type, qty) =>
                        context.read<GameCubit>().buyDrug(type, qty),
                    onSell: (type, qty) =>
                        context.read<GameCubit>().sellDrug(type, qty),
                  ),
                  // Inventory tab
                  InventoryWidget(
                    player: state.player,
                    market: state.currentMarket,
                    onSell: (type, qty) =>
                        context.read<GameCubit>().sellDrug(type, qty),
                  ),
                  // Jobs tab
                  SingleChildScrollView(
                    child: ContractsWidget(),
                  ),
                  // Contacts tab
                  _NpcContactsTab(state: state),
                  // Stats tab
                  SingleChildScrollView(
                    child: PlayerStatsWidget(player: state.player),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NpcContactsTab extends StatelessWidget {
  final GamePlaying state;

  const _NpcContactsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final location = DefaultLocations.byIndex(state.player.locationIndex);
    final npcs = const NpcRepository().getNpcsAtLocation(location.type);
    final gameCubit = context.read<GameCubit>();
    final gameStateCubit = sl<GameStateCubit>();

    if (npcs.isEmpty) {
      return Center(
        child: Text(
          'No contacts in ${location.name}',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: npcs.map((npc) {
          return Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                _getRoleIcon(npc.role),
                color: _getRoleColor(npc.role),
              ),
              title: Text(
                npc.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _getRoleLabel(npc.role),
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                final npcId = npc.id;
                showDialog(
                  context: context,
                  builder: (context) => NpcTradeDialog(
                    npcId: npcId,
                    npc: npc,
                    player: state.player,
                    currentHeat: gameStateCubit.state.reputation.globalHeat,
                    npcNetworkCubit: gameCubit.npcNetworkCubit,
                    npcRepository: const NpcRepository(),
                    onBuyFromNpc: (npcId, drugType, quantity) {
                      gameCubit.buyDrugFromNpc(npcId, drugType, quantity);
                    },
                    onSellToNpc: (npcId, drugType, quantity) {
                      gameCubit.sellDrugToNpc(npcId, drugType, quantity);
                    },
                    onUseFixerService: (npcId, heatToReduce) {
                      gameCubit.useFixerService(npcId, heatToReduce);
                    },
                    onUseDoctorService: (npcId, healthToRestore) {
                      gameCubit.useDoctorService(npcId, healthToRestore);
                    },
                    onUseLawyerService: (npcId) {
                      gameCubit.useLawyerService(npcId);
                    },
                    onClose: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getRoleColor(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return Colors.green[400]!;
      case NpcRole.buyer:
        return Colors.blue[400]!;
      case NpcRole.fixer:
        return Colors.yellow[700]!;
      case NpcRole.lawyer:
        return Colors.purple[400]!;
      case NpcRole.doctor:
        return Colors.red[400]!;
    }
  }

  IconData _getRoleIcon(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return Icons.local_shipping;
      case NpcRole.buyer:
        return Icons.shopping_cart;
      case NpcRole.fixer:
        return Icons.handshake;
      case NpcRole.lawyer:
        return Icons.gavel;
      case NpcRole.doctor:
        return Icons.local_hospital;
    }
  }

  String _getRoleLabel(NpcRole role) {
    switch (role) {
      case NpcRole.supplier:
        return 'Supplier';
      case NpcRole.buyer:
        return 'Buyer';
      case NpcRole.fixer:
        return 'Fixer';
      case NpcRole.lawyer:
        return 'Lawyer';
      case NpcRole.doctor:
        return 'Doctor';
    }
  }
}

class _MessagesBar extends StatelessWidget {
  final List<String> messages;

  const _MessagesBar({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.grey[850],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messages
            .map((msg) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: Colors.green[300],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _LocationView extends StatelessWidget {
  final GameAtLocation state;

  const _LocationView({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.location) {
      SpecialLocation.bank => BankWidget(
          player: state.player,
          messages: state.messages,
          onDeposit: (amount) => context.read<GameCubit>().depositMoney(amount),
          onWithdraw: (amount) => context.read<GameCubit>().withdrawMoney(amount),
          onLeave: () => context.read<GameCubit>().leaveLocation(),
        ),
      SpecialLocation.loanShark => LoanSharkWidget(
          player: state.player,
          messages: state.messages,
          onPayDebt: (amount) => context.read<GameCubit>().payDebt(amount),
          onBorrow: (amount) => context.read<GameCubit>().borrowMoney(amount),
          onLeave: () => context.read<GameCubit>().leaveLocation(),
        ),
      SpecialLocation.gunShop => GunShopWidget(
          player: state.player,
          messages: state.messages,
          onBuyGun: (gunIndex, quantity) =>
              context.read<GameCubit>().buyGun(gunIndex, quantity),
          onLeave: () => context.read<GameCubit>().leaveLocation(),
        ),
      SpecialLocation.roughPub => PubWidget(
          player: state.player,
          messages: state.messages,
          onHireBitch: (quantity) =>
              context.read<GameCubit>().hireBitch(quantity),
          onLeave: () => context.read<GameCubit>().leaveLocation(),
        ),
    };
  }
}

class _CombatView extends StatelessWidget {
  final GameInCombat state;

  const _CombatView({required this.state});

  @override
  Widget build(BuildContext context) {
    final initialFight = Fight.start(
      player: state.player,
      cop: state.cop,
      playerGun: state.playerGun,
    );

    return BlocProvider(
      create: (context) => CombatCubit(
        initialFight: initialFight,
        damageCalculator: sl(),
        random: sl(),
        onCombatEnd: (updatedPlayer, won) {
          // Emit GamePlaying state with updated player
          context.read<GameCubit>().leaveCombat(updatedPlayer);
        },
      ),
      child: _CombatViewContent(state: state),
    );
  }
}

class _CombatViewContent extends StatelessWidget {
  final GameInCombat state;

  const _CombatViewContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CombatCubit, CombatState>(
      builder: (context, combatState) {
        return CombatWidget(
          opponentName: combatState.opponentName,
          opponentHealth: combatState.opponentHealth,
          playerHealth: state.player.health.value,
          deputyCount: combatState.deputyCount,
          combatLog: combatState.combatLog,
          canFire: combatState.canShoot,
          canFlee: combatState.canFlee,
          onFire: () {
            context.read<CombatCubit>().fire();
          },
          onFlee: () {
            context.read<CombatCubit>().attemptFlee();
          },
        );
      },
    );
  }
}
