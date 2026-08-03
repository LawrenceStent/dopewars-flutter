import 'package:equatable/equatable.dart';

/// Represents a high score entry in the game.
class HighScore extends Equatable {
  final String playerName;
  final int netWorth;
  final int turn;
  final DateTime date;

  const HighScore({
    required this.playerName,
    required this.netWorth,
    required this.turn,
    required this.date,
  });

  /// Convert to JSON for persistence.
  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'netWorth': netWorth,
        'turn': turn,
        'date': date.toIso8601String(),
      };

  /// Create from JSON.
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      playerName: json['playerName'] as String,
      netWorth: json['netWorth'] as int,
      turn: json['turn'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  List<Object?> get props => [playerName, netWorth, turn, date];

  @override
  String toString() =>
      'HighScore($playerName: \$$netWorth at turn $turn on ${date.toLocal()})';
}
