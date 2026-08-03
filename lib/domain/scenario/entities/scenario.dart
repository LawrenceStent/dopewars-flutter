import 'package:equatable/equatable.dart';

import '../../location/entities/location.dart';

/// Category of scenario.
enum ScenarioCategory {
  police,
  criminal,
  environmental,
  social,
}

/// Specific scenario types within each category.
enum ScenarioType {
  // Police encounters
  randomPatrol,
  tipOff,
  roadblock,

  // Criminal underworld
  rivalDealerConflict,
  territoryDispute,
  supplyChainTheft,

  // Environmental
  borderCustomsSearch,
  portInspection,
  airportSecurity,

  // Social
  informantTurned,
  buyerDefaultsPayment,
  supplierRaisesPrices,

  // Phase 2 additions (mapped but not implemented yet)
  undercover,
  cartelWar,
  safehouseRaided,
  drugLabDiscovered,
  corruptOfficer,
  streetProtest,
  hurricaneDisruption,
  marketCrash,
}

/// A choice the player can make in response to a scenario.
class ScenarioChoice extends Equatable {
  final String id;
  final String label;
  final String description;

  const ScenarioChoice({
    required this.id,
    required this.label,
    required this.description,
  });

  @override
  List<Object?> get props => [id, label, description];
}

/// Outcome of a scenario choice.
class ScenarioOutcome extends Equatable {
  /// Cash change (positive = gain, negative = loss).
  final int cashChange;

  /// Heat change.
  final int heatChange;

  /// Reputation change.
  final int reputationChange;

  /// Health change (negative = damage).
  final int healthChange;

  /// Drugs lost (quantity).
  final int drugsLost;

  /// Message to display.
  final String message;

  const ScenarioOutcome({
    this.cashChange = 0,
    this.heatChange = 0,
    this.reputationChange = 0,
    this.healthChange = 0,
    this.drugsLost = 0,
    required this.message,
  });

  @override
  List<Object?> get props => [
        cashChange,
        heatChange,
        reputationChange,
        healthChange,
        drugsLost,
        message,
      ];
}

/// A game scenario (event that can occur during gameplay).
class Scenario extends Equatable {
  final String id;
  final ScenarioType type;
  final ScenarioCategory category;
  final String title;
  final String description;

  /// Which locations this scenario can trigger in (empty = any).
  final Set<LocationType> validLocations;

  /// Minimum heat level required to trigger.
  final int minHeatToTrigger;

  /// Base probability of triggering (0.0 - 1.0).
  final double baseProbability;

  /// Available player choices.
  final List<ScenarioChoice> choices;

  /// Outcomes for each choice (choiceId -> outcome).
  final Map<String, ScenarioOutcome> outcomes;

  const Scenario({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    this.validLocations = const {},
    this.minHeatToTrigger = 0,
    required this.baseProbability,
    required this.choices,
    this.outcomes = const {},
  });

  /// Whether this scenario can trigger at a given location.
  bool canTriggerAt(LocationType location) =>
      validLocations.isEmpty || validLocations.contains(location);

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        title,
        description,
        validLocations,
        minHeatToTrigger,
        baseProbability,
        choices,
        outcomes,
      ];

  @override
  String toString() => 'Scenario($title)';
}

/// Default scenario templates.
/// Phase 1: Implement first 6 scenarios.
/// Phase 2: Build remaining 14.
class DefaultScenarios {
  DefaultScenarios._();

  static const List<Scenario> all = [
    // ===== PHASE 1 (6 scenarios) =====

    // Police: Random patrol
    Scenario(
      id: 'police_random_patrol',
      type: ScenarioType.randomPatrol,
      category: ScenarioCategory.police,
      title: 'Police Patrol',
      description: 'A patrol car spots you on the street.',
      baseProbability: 0.15,
      minHeatToTrigger: 20,
      choices: [
        ScenarioChoice(id: 'fight', label: 'Fight', description: 'Stand your ground'),
        ScenarioChoice(id: 'flee', label: 'Run', description: 'Try to escape'),
        ScenarioChoice(id: 'bribe', label: 'Bribe', description: 'Offer money'),
      ],
      outcomes: {
        'fight': ScenarioOutcome(
          heatChange: 20,
          healthChange: -15,
          message: 'You fought the cops but took some hits!',
        ),
        'flee': ScenarioOutcome(
          heatChange: 10,
          message: 'You managed to escape but they\'re still looking for you.',
        ),
        'bribe': ScenarioOutcome(
          cashChange: -5000,
          heatChange: -5,
          message: 'You slipped them some cash and they let you go.',
        ),
      },
    ),
    // Police: Roadblock
    Scenario(
      id: 'police_roadblock',
      type: ScenarioType.roadblock,
      category: ScenarioCategory.police,
      title: 'Roadblock',
      description: 'A checkpoint has been set up ahead.',
      baseProbability: 0.10,
      minHeatToTrigger: 40,
      choices: [
        ScenarioChoice(id: 'submit', label: 'Submit', description: 'Stop and comply'),
        ScenarioChoice(id: 'flee', label: 'Evade', description: 'Try to go around'),
        ScenarioChoice(id: 'bribe', label: 'Bribe', description: 'Offer money'),
      ],
      outcomes: {
        'submit': ScenarioOutcome(
          drugsLost: 50,
          message: 'They found some of your stash. At least they let you go.',
        ),
        'flee': ScenarioOutcome(
          heatChange: 30,
          healthChange: -10,
          message: 'You made a dangerous escape but they\'re hot on your trail!',
        ),
        'bribe': ScenarioOutcome(
          cashChange: -10000,
          heatChange: -10,
          message: 'A generous bribe got you through the checkpoint.',
        ),
      },
    ),
    // Criminal: Rival dealer
    Scenario(
      id: 'criminal_rival',
      type: ScenarioType.rivalDealerConflict,
      category: ScenarioCategory.criminal,
      title: 'Rival Dealer',
      description: 'A rival dealer confronts you on their turf.',
      baseProbability: 0.12,
      choices: [
        ScenarioChoice(id: 'fight', label: 'Fight', description: 'Challenge them'),
        ScenarioChoice(id: 'negotiate', label: 'Negotiate', description: 'Try to talk'),
        ScenarioChoice(id: 'retreat', label: 'Retreat', description: 'Back off'),
      ],
      outcomes: {
        'fight': ScenarioOutcome(
          healthChange: -20,
          heatChange: 15,
          cashChange: 5000,
          message: 'You won the fight but lost some blood. At least you got his cash!',
        ),
        'negotiate': ScenarioOutcome(
          heatChange: -5,
          reputationChange: 5,
          message: 'You negotiated peace. Word spreads about your diplomacy.',
        ),
        'retreat': ScenarioOutcome(
          message: 'You backed off. No harm, but your pride took a hit.',
        ),
      },
    ),
    // Environmental: Border search
    Scenario(
      id: 'env_border_search',
      type: ScenarioType.borderCustomsSearch,
      category: ScenarioCategory.environmental,
      title: 'Border Search',
      description: 'Customs officers want to search your belongings.',
      baseProbability: 0.08,
      choices: [
        ScenarioChoice(id: 'comply', label: 'Comply', description: 'Let them search'),
        ScenarioChoice(id: 'bribe', label: 'Bribe', description: 'Slip them some cash'),
        ScenarioChoice(id: 'distract', label: 'Distract', description: 'Create a diversion'),
      ],
      outcomes: {
        'comply': ScenarioOutcome(
          drugsLost: 30,
          message: 'They found some of your drugs. You got away with most of it.',
        ),
        'bribe': ScenarioOutcome(
          cashChange: -3000,
          message: 'A small bribe got you through with your cargo intact.',
        ),
        'distract': ScenarioOutcome(
          heatChange: 10,
          message: 'Your distraction worked but you\'re now on their radar.',
        ),
      },
    ),
    // Social: Buyer defaults
    Scenario(
      id: 'social_default',
      type: ScenarioType.buyerDefaultsPayment,
      category: ScenarioCategory.social,
      title: 'Bad Deal',
      description: 'A buyer is trying to skip on payment.',
      baseProbability: 0.10,
      choices: [
        ScenarioChoice(id: 'threaten', label: 'Threaten', description: 'Intimidate them'),
        ScenarioChoice(id: 'accept', label: 'Accept', description: 'Take the loss'),
        ScenarioChoice(id: 'negotiate', label: 'Negotiate', description: 'Settle for less'),
      ],
      outcomes: {
        'threaten': ScenarioOutcome(
          cashChange: 7500,
          heatChange: 5,
          message: 'They paid up but now the heat\'s on you.',
        ),
        'accept': ScenarioOutcome(
          cashChange: -10000,
          message: 'You let them go. At least you avoided conflict.',
        ),
        'negotiate': ScenarioOutcome(
          cashChange: 3750,
          message: 'You settled for half. Better than nothing.',
        ),
      },
    ),
    // Social: Supplier raises prices
    Scenario(
      id: 'social_price_hike',
      type: ScenarioType.supplierRaisesPrices,
      category: ScenarioCategory.social,
      title: 'Price Hike',
      description: 'Your supplier is demanding more money.',
      baseProbability: 0.08,
      choices: [
        ScenarioChoice(id: 'pay', label: 'Pay Up', description: 'Accept the new price'),
        ScenarioChoice(id: 'negotiate', label: 'Negotiate', description: 'Haggle them down'),
        ScenarioChoice(id: 'walk', label: 'Walk Away', description: 'Find another supplier'),
      ],
      outcomes: {
        'pay': ScenarioOutcome(
          message: 'You paid the higher price. Supply is secure for now.',
        ),
        'negotiate': ScenarioOutcome(
          reputationChange: -5,
          message: 'They reduced the price but respect was lost.',
        ),
        'walk': ScenarioOutcome(
          heatChange: 5,
          message: 'You found another supplier but now someone\'s upset.',
        ),
      },
    ),

    // ===== PHASE 2 (14 scenarios) =====

    // Police: Tip-off
    Scenario(
      id: 'police_tip_off',
      type: ScenarioType.tipOff,
      category: ScenarioCategory.police,
      title: 'Informant',
      description: 'Someone tipped off the police about you.',
      baseProbability: 0.10,
      minHeatToTrigger: 50,
      choices: [
        ScenarioChoice(id: 'go_dark', label: 'Go Dark', description: 'Lay low and hide'),
        ScenarioChoice(id: 'confront', label: 'Confront', description: 'Seek out the snitch'),
        ScenarioChoice(id: 'leave_town', label: 'Leave Town', description: 'Flee the area'),
      ],
      outcomes: {
        'go_dark': ScenarioOutcome(
          heatChange: -15,
          cashChange: -5000,
          message: 'You laid low and the heat cooled down. Cost you though.',
        ),
        'confront': ScenarioOutcome(
          heatChange: 20,
          healthChange: -25,
          message: 'You found the snitch but it got messy. The police know now.',
        ),
        'leave_town': ScenarioOutcome(
          heatChange: -10,
          message: 'You got out of town before they could find you.',
        ),
      },
    ),

    // Criminal: Territory dispute
    Scenario(
      id: 'criminal_territory',
      type: ScenarioType.territoryDispute,
      category: ScenarioCategory.criminal,
      title: 'Territory War',
      description: 'A gang wants to claim your territory.',
      baseProbability: 0.09,
      minHeatToTrigger: 30,
      choices: [
        ScenarioChoice(id: 'defend', label: 'Defend', description: 'Fight for your turf'),
        ScenarioChoice(id: 'negotiate_peace', label: 'Peace Deal', description: 'Share the territory'),
        ScenarioChoice(id: 'surrender', label: 'Surrender', description: 'Give up your turf'),
      ],
      outcomes: {
        'defend': ScenarioOutcome(
          healthChange: -30,
          heatChange: 20,
          reputationChange: 10,
          message: 'You held your ground but took a beating. People respect you now.',
        ),
        'negotiate_peace': ScenarioOutcome(
          reputationChange: 5,
          heatChange: -5,
          message: 'You negotiated a peace deal. Both sides can profit.',
        ),
        'surrender': ScenarioOutcome(
          cashChange: -20000,
          reputationChange: -10,
          message: 'You gave up your turf. Your reputation took a hit.',
        ),
      },
    ),

    // Criminal: Supply chain theft
    Scenario(
      id: 'criminal_supply_theft',
      type: ScenarioType.supplyChainTheft,
      category: ScenarioCategory.criminal,
      title: 'Hijacked!',
      description: 'Your shipment was intercepted by thieves.',
      baseProbability: 0.08,
      minHeatToTrigger: 20,
      choices: [
        ScenarioChoice(id: 'hunt_thieves', label: 'Hunt Them Down', description: 'Track and recover'),
        ScenarioChoice(id: 'write_off', label: 'Write Off', description: 'Accept the loss'),
        ScenarioChoice(id: 'barter', label: 'Negotiate', description: 'Buy it back'),
      ],
      outcomes: {
        'hunt_thieves': ScenarioOutcome(
          cashChange: 15000,
          healthChange: -20,
          heatChange: 15,
          message: 'You hunted them down and got your goods back but took damage.',
        ),
        'write_off': ScenarioOutcome(
          cashChange: -25000,
          message: 'You lost the shipment. Cost of doing business.',
        ),
        'barter': ScenarioOutcome(
          cashChange: -12500,
          message: 'You bought back half your shipment. Better than nothing.',
        ),
      },
    ),

    // Environmental: Port inspection
    Scenario(
      id: 'env_port_inspection',
      type: ScenarioType.portInspection,
      category: ScenarioCategory.environmental,
      title: 'Port Inspection',
      description: 'Dock authorities are doing a surprise inspection.',
      baseProbability: 0.07,
      minHeatToTrigger: 15,
      choices: [
        ScenarioChoice(id: 'hide_cargo', label: 'Hide Cargo', description: 'Conceal your goods'),
        ScenarioChoice(id: 'quick_bribe', label: 'Quick Bribe', description: 'Pay off the inspector'),
        ScenarioChoice(id: 'cooperate', label: 'Cooperate', description: 'Submit to inspection'),
      ],
      outcomes: {
        'hide_cargo': ScenarioOutcome(
          drugsLost: 20,
          message: 'They found some but you managed to hide most.',
        ),
        'quick_bribe': ScenarioOutcome(
          cashChange: -2000,
          message: 'A well-placed bribe made them look the other way.',
        ),
        'cooperate': ScenarioOutcome(
          drugsLost: 50,
          message: 'They confiscated a significant portion of your cargo.',
        ),
      },
    ),

    // Environmental: Airport security
    Scenario(
      id: 'env_airport_security',
      type: ScenarioType.airportSecurity,
      category: ScenarioCategory.environmental,
      title: 'Airport Security',
      description: 'TSA is conducting enhanced screening.',
      baseProbability: 0.06,
      minHeatToTrigger: 25,
      choices: [
        ScenarioChoice(id: 'skip_airport', label: 'Skip Flight', description: 'Leave without flying'),
        ScenarioChoice(id: 'tough_it_out', label: 'Go Through', description: 'Risk the screening'),
        ScenarioChoice(id: 'airport_worker', label: 'Use Connection', description: 'Know someone inside'),
      ],
      outcomes: {
        'skip_airport': ScenarioOutcome(
          message: 'You skipped the flight. Back to the drawing board.',
        ),
        'tough_it_out': ScenarioOutcome(
          drugsLost: 100,
          heatChange: 10,
          message: 'They found everything. You\'re in hot water now.',
        ),
        'airport_worker': ScenarioOutcome(
          cashChange: -4000,
          message: 'Your connection got you through without a hitch.',
        ),
      },
    ),

    // Social: Informant turned
    Scenario(
      id: 'social_informant',
      type: ScenarioType.informantTurned,
      category: ScenarioCategory.social,
      title: 'Snitch',
      description: 'One of your people turned informant.',
      baseProbability: 0.09,
      minHeatToTrigger: 35,
      choices: [
        ScenarioChoice(id: 'eliminate_threat', label: 'Eliminate', description: 'Take them out'),
        ScenarioChoice(id: 'scare_them', label: 'Intimidate', description: 'Make them recant'),
        ScenarioChoice(id: 'cut_ties', label: 'Cut Ties', description: 'Abandon them'),
      ],
      outcomes: {
        'eliminate_threat': ScenarioOutcome(
          heatChange: 40,
          healthChange: -15,
          message: 'The problem is solved but the police are looking for you now.',
        ),
        'scare_them': ScenarioOutcome(
          heatChange: 5,
          message: 'They recanted their statement out of fear.',
        ),
        'cut_ties': ScenarioOutcome(
          reputationChange: -5,
          message: 'Word spread that you abandoned a friend. Bad for business.',
        ),
      },
    ),

    // Phase 2: Undercover cop
    Scenario(
      id: 'phase2_undercover',
      type: ScenarioType.undercover,
      category: ScenarioCategory.police,
      title: 'Undercover Cop',
      description: 'Someone you trust might be a police officer.',
      baseProbability: 0.08,
      minHeatToTrigger: 40,
      choices: [
        ScenarioChoice(id: 'trust_them', label: 'Trust Them', description: 'Play along'),
        ScenarioChoice(id: 'call_out', label: 'Call Them Out', description: 'Confront directly'),
        ScenarioChoice(id: 'lay_trap', label: 'Set Trap', description: 'Test their loyalty'),
      ],
      outcomes: {
        'trust_them': ScenarioOutcome(
          heatChange: 50,
          message: 'It was a setup. You\'re under heavy investigation now.',
        ),
        'call_out': ScenarioOutcome(
          heatChange: 30,
          healthChange: -15,
          message: 'You were right. Things got violent fast.',
        ),
        'lay_trap': ScenarioOutcome(
          heatChange: -10,
          reputationChange: 5,
          message: 'You caught them. Word spreads about your street smarts.',
        ),
      },
    ),

    // Phase 2: Cartel war
    Scenario(
      id: 'phase2_cartel_war',
      type: ScenarioType.cartelWar,
      category: ScenarioCategory.criminal,
      title: 'Cartel War',
      description: 'Major cartels are fighting for control.',
      baseProbability: 0.07,
      minHeatToTrigger: 50,
      choices: [
        ScenarioChoice(id: 'side_with_one', label: 'Join One Side', description: 'Pledge allegiance'),
        ScenarioChoice(id: 'stay_neutral', label: 'Stay Neutral', description: 'Don\'t pick sides'),
        ScenarioChoice(id: 'exploit', label: 'Exploit', description: 'Play both sides'),
      ],
      outcomes: {
        'side_with_one': ScenarioOutcome(
          reputationChange: 15,
          heatChange: 10,
          cashChange: 20000,
          message: 'You joined the winning side and earned respect and cash.',
        ),
        'stay_neutral': ScenarioOutcome(
          heatChange: 20,
          message: 'Staying neutral made you a target. Both sides are watching.',
        ),
        'exploit': ScenarioOutcome(
          cashChange: 30000,
          heatChange: 30,
          message: 'You made huge profits but now everyone wants revenge.',
        ),
      },
    ),

    // Phase 2: Safehouse raided
    Scenario(
      id: 'phase2_safehouse',
      type: ScenarioType.safehouseRaided,
      category: ScenarioCategory.police,
      title: 'Raid!',
      description: 'Your safehouse is under attack by police.',
      baseProbability: 0.06,
      minHeatToTrigger: 60,
      choices: [
        ScenarioChoice(id: 'escape_tunnel', label: 'Escape', description: 'Use back exit'),
        ScenarioChoice(id: 'fight_back', label: 'Fight Back', description: 'Defend position'),
        ScenarioChoice(id: 'surrender', label: 'Surrender', description: 'Give yourself up'),
      ],
      outcomes: {
        'escape_tunnel': ScenarioOutcome(
          drugsLost: 75,
          message: 'You escaped but lost most of your stash.',
        ),
        'fight_back': ScenarioOutcome(
          healthChange: -40,
          heatChange: 50,
          message: 'Epic firefight. You survived but now they really want you.',
        ),
        'surrender': ScenarioOutcome(
          heatChange: -30,
          message: 'You surrendered. At least the heat dies down.',
        ),
      },
    ),

    // Phase 2: Drug lab discovered
    Scenario(
      id: 'phase2_drug_lab',
      type: ScenarioType.drugLabDiscovered,
      category: ScenarioCategory.criminal,
      title: 'Lab Burned',
      description: 'Your production lab was discovered.',
      baseProbability: 0.05,
      minHeatToTrigger: 45,
      choices: [
        ScenarioChoice(id: 'rebuild', label: 'Rebuild', description: 'Start over elsewhere'),
        ScenarioChoice(id: 'cover_up', label: 'Cover Up', description: 'Blame rivals'),
        ScenarioChoice(id: 'move_on', label: 'Move On', description: 'Give it up'),
      ],
      outcomes: {
        'rebuild': ScenarioOutcome(
          cashChange: -50000,
          heatChange: 10,
          message: 'Rebuilding will cost you but production can resume.',
        ),
        'cover_up': ScenarioOutcome(
          heatChange: 5,
          cashChange: -10000,
          message: 'You blamed your rivals. Chaos erupts but heat stays low.',
        ),
        'move_on': ScenarioOutcome(
          reputationChange: -10,
          message: 'You gave it up. Your rep as a player dropped.',
        ),
      },
    ),

    // Phase 2: Corrupt officer
    Scenario(
      id: 'phase2_corrupt_cop',
      type: ScenarioType.corruptOfficer,
      category: ScenarioCategory.police,
      title: 'Cop on the Take',
      description: 'A corrupt officer wants a cut of your action.',
      baseProbability: 0.10,
      minHeatToTrigger: 30,
      choices: [
        ScenarioChoice(id: 'pay_up', label: 'Pay Up', description: 'Regular payments'),
        ScenarioChoice(id: 'refuse', label: 'Refuse', description: 'Tell them no'),
        ScenarioChoice(id: 'expose', label: 'Expose', description: 'Report them'),
      ],
      outcomes: {
        'pay_up': ScenarioOutcome(
          cashChange: -5000,
          heatChange: -20,
          message: 'Regular bribes keep the heat off. It\'s expensive but worth it.',
        ),
        'refuse': ScenarioOutcome(
          heatChange: 25,
          message: 'They\'re now your personal adversary on the force.',
        ),
        'expose': ScenarioOutcome(
          heatChange: -10,
          reputationChange: 5,
          message: 'You exposed corruption. Reputation boost but now you\'re a target.',
        ),
      },
    ),

    // Phase 2: Street protest
    Scenario(
      id: 'phase2_street_protest',
      type: ScenarioType.streetProtest,
      category: ScenarioCategory.social,
      title: 'Street Heat',
      description: 'Community outcry against drug dealers like you.',
      baseProbability: 0.07,
      minHeatToTrigger: 25,
      choices: [
        ScenarioChoice(id: 'lay_low', label: 'Lay Low', description: 'Avoid the area'),
        ScenarioChoice(id: 'community_good', label: 'Give Back', description: 'Fund a program'),
        ScenarioChoice(id: 'silence_them', label: 'Silence', description: 'Use intimidation'),
      ],
      outcomes: {
        'lay_low': ScenarioOutcome(
          message: 'The protests died down on their own.',
        ),
        'community_good': ScenarioOutcome(
          cashChange: -10000,
          reputationChange: 5,
          message: 'Your donation changed hearts. Community support grew.',
        ),
        'silence_them': ScenarioOutcome(
          heatChange: 20,
          reputationChange: -10,
          message: 'Fear quieted the protests but you\'re seen as a villain.',
        ),
      },
    ),

    // Phase 2: Market crash
    Scenario(
      id: 'phase2_market_crash',
      type: ScenarioType.marketCrash,
      category: ScenarioCategory.social,
      title: 'Market Crash',
      description: 'Drug prices plummeted. Market is flooded.',
      baseProbability: 0.09,
      minHeatToTrigger: 0,
      choices: [
        ScenarioChoice(id: 'dump_stock', label: 'Dump Stock', description: 'Sell everything quickly'),
        ScenarioChoice(id: 'hold_out', label: 'Hold Out', description: 'Wait for recovery'),
        ScenarioChoice(id: 'pivot', label: 'Pivot', description: 'Switch to new market'),
      ],
      outcomes: {
        'dump_stock': ScenarioOutcome(
          cashChange: -50000,
          message: 'You dumped your stock before total collapse.',
        ),
        'hold_out': ScenarioOutcome(
          cashChange: -100000,
          message: 'You held too long. Massive losses.',
        ),
        'pivot': ScenarioOutcome(
          cashChange: 25000,
          message: 'You pivoted to a different market. Smart move.',
        ),
      },
    ),

    // Phase 2: Hurricane disruption (environmental)
    Scenario(
      id: 'phase2_hurricane',
      type: ScenarioType.hurricaneDisruption,
      category: ScenarioCategory.environmental,
      title: 'Hurricane Warning',
      description: 'A major hurricane is approaching.',
      baseProbability: 0.04,
      minHeatToTrigger: 0,
      choices: [
        ScenarioChoice(id: 'ride_it_out', label: 'Ride It Out', description: 'Stay and protect stash'),
        ScenarioChoice(id: 'evacuate', label: 'Evacuate', description: 'Get to safety'),
        ScenarioChoice(id: 'move_goods', label: 'Move Goods', description: 'Relocate your cargo'),
      ],
      outcomes: {
        'ride_it_out': ScenarioOutcome(
          drugsLost: 100,
          healthChange: -20,
          message: 'The hurricane destroyed most of your stash.',
        ),
        'evacuate': ScenarioOutcome(
          drugsLost: 50,
          message: 'You evacuated but lost half your goods to the storm.',
        ),
        'move_goods': ScenarioOutcome(
          cashChange: -8000,
          message: 'You safely moved your goods before the hurricane hit.',
        ),
      },
    ),
  ];

  // All 20 scenario types mapped
  static const List<ScenarioType> allMappedTypes = ScenarioType.values;

  @deprecated
  static const List<Scenario> phase1 = all;
}
