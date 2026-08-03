import 'package:equatable/equatable.dart';

/// Skill categories.
enum SkillType {
  combat,
  trading,
  stealth,
  driving,
  hacking,
}

/// A player skill.
class Skill extends Equatable {
  final SkillType type;
  final String name;
  final String description;

  /// Current skill level (0-100).
  final int level;

  /// Experience points toward next level.
  final int experience;

  const Skill({
    required this.type,
    required this.name,
    required this.description,
    this.level = 0,
    this.experience = 0,
  });

  Skill copyWith({int? level, int? experience}) {
    return Skill(
      type: type,
      name: name,
      description: description,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }

  @override
  List<Object?> get props => [type, name, description, level, experience];

  @override
  String toString() => 'Skill($name, level: $level)';
}

/// Player's skill set (Phase 3 - stubbed).
class PlayerSkills extends Equatable {
  final Map<SkillType, Skill> skills;

  const PlayerSkills({this.skills = const {}});

  Skill getSkill(SkillType type) =>
      skills[type] ??
      Skill(type: type, name: type.name, description: '');

  int getLevel(SkillType type) => getSkill(type).level;

  @override
  List<Object?> get props => [skills];
}

/// Default skill definitions (Phase 3 - stubbed).
class DefaultSkills {
  DefaultSkills._();

  // TODO: Implement in Phase 3
  static const List<Skill> all = [
    Skill(
      type: SkillType.combat,
      name: 'Combat',
      description: 'Better gun handling, dodging, negotiation.',
    ),
    Skill(
      type: SkillType.trading,
      name: 'Trading',
      description: 'Better prices, faster transactions.',
    ),
    Skill(
      type: SkillType.stealth,
      name: 'Stealth',
      description: 'Lower police detection.',
    ),
    Skill(
      type: SkillType.driving,
      name: 'Driving',
      description: 'Faster travel, escape chances.',
    ),
    Skill(
      type: SkillType.hacking,
      name: 'Hacking',
      description: 'Dark web access, intel gathering.',
    ),
  ];
}
