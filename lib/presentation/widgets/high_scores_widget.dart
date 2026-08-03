import 'package:flutter/material.dart';

import '../../domain/game/entities/high_score.dart';
import '../../domain/game/services/high_score_service.dart';
import '../../injection_container.dart';

/// Widget for displaying high scores.
class HighScoresWidget extends StatefulWidget {
  final VoidCallback onClose;

  const HighScoresWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<HighScoresWidget> createState() => _HighScoresWidgetState();
}

class _HighScoresWidgetState extends State<HighScoresWidget> {
  late Future<List<HighScore>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() {
    _scoresFuture = _getHighScores();
  }

  Future<List<HighScore>> _getHighScores() async {
    try {
      final service = _getHighScoreService();
      return await service.getHighScores();
    } catch (e) {
      return [];
    }
  }

  HighScoreService _getHighScoreService() {
    // Import service locator
    return sl();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[400], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'HIGH SCORES',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Scores list
                  FutureBuilder<List<HighScore>>(
                    future: _scoresFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No high scores yet. Be the first!',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final scores = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scores.length,
                        itemBuilder: (context, index) {
                          final score = scores[index];
                          final rank = index + 1;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _getRankColor(rank),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[900],
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '#$rank',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _getRankColor(rank),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              score.playerName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Turn ${score.turn}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${score.netWorth}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[400],
                                      ),
                                    ),
                                    Text(
                                      score.date
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('CLOSE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    return switch (rank) {
      1 => Colors.amber[400]!,
      2 => Colors.grey[300]!,
      3 => Colors.orange[700]!,
      _ => Colors.grey[500]!,
    };
  }
}
