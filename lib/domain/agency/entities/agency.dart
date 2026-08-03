import 'package:equatable/equatable.dart';

import '../../location/entities/location.dart';

/// Law enforcement agency type.
enum AgencyType {
  dea,
  fbi,
  nypd,
  metPolice,
  nationalCrimeAgency,
  seido,
  saps,
  psb,
  enafcod,
  ndlea,
  interpol,
  europol,
}

/// Jurisdiction scope of an agency.
enum Jurisdiction {
  local,   // Only operates in one location
  national, // Operates in all locations within a country
  regional, // Operates across a region (e.g., Europol in Europe)
  global,   // Operates everywhere (e.g., Interpol)
}

/// Represents a law enforcement agency.
class Agency extends Equatable {
  final AgencyType type;
  final String name;
  final String country;
  final Jurisdiction jurisdiction;

  /// How aggressive the agency is in pursuing the player (0-100).
  final int aggressiveness;

  /// How far the agency's detection range extends (0-100).
  final int detectionRange;

  /// Number of officers/resources the agency can deploy (0-100).
  final int resources;

  /// Combat capability tier (1-5, higher = better armed).
  final int weaponsTier;

  /// How susceptible the agency is to bribes (0-100, higher = easier to bribe).
  final int briberyVulnerability;

  /// Which regions this agency operates in.
  final Set<Region> operatingRegions;

  const Agency({
    required this.type,
    required this.name,
    required this.country,
    required this.jurisdiction,
    required this.aggressiveness,
    required this.detectionRange,
    required this.resources,
    required this.weaponsTier,
    required this.briberyVulnerability,
    required this.operatingRegions,
  });

  @override
  List<Object?> get props => [
        type,
        name,
        country,
        jurisdiction,
        aggressiveness,
        detectionRange,
        resources,
        weaponsTier,
        briberyVulnerability,
        operatingRegions,
      ];

  @override
  String toString() => 'Agency($name)';
}

/// Default agencies.
class DefaultAgencies {
  DefaultAgencies._();

  static const List<Agency> all = [
    Agency(
      type: AgencyType.dea,
      name: 'DEA',
      country: 'USA',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 85,
      detectionRange: 70,
      resources: 80,
      weaponsTier: 4,
      briberyVulnerability: 15,
      operatingRegions: {Region.northAmerica},
    ),
    Agency(
      type: AgencyType.fbi,
      name: 'FBI',
      country: 'USA',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 75,
      detectionRange: 80,
      resources: 90,
      weaponsTier: 5,
      briberyVulnerability: 5,
      operatingRegions: {Region.northAmerica},
    ),
    Agency(
      type: AgencyType.nypd,
      name: 'NYPD',
      country: 'USA',
      jurisdiction: Jurisdiction.local,
      aggressiveness: 60,
      detectionRange: 50,
      resources: 70,
      weaponsTier: 3,
      briberyVulnerability: 30,
      operatingRegions: {Region.northAmerica},
    ),
    Agency(
      type: AgencyType.metPolice,
      name: 'Met Police',
      country: 'UK',
      jurisdiction: Jurisdiction.local,
      aggressiveness: 65,
      detectionRange: 60,
      resources: 65,
      weaponsTier: 2,
      briberyVulnerability: 10,
      operatingRegions: {Region.europe},
    ),
    Agency(
      type: AgencyType.nationalCrimeAgency,
      name: 'National Crime Agency',
      country: 'UK',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 70,
      detectionRange: 75,
      resources: 60,
      weaponsTier: 3,
      briberyVulnerability: 10,
      operatingRegions: {Region.europe},
    ),
    Agency(
      type: AgencyType.seido,
      name: 'SEIDO',
      country: 'Mexico',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 55,
      detectionRange: 40,
      resources: 50,
      weaponsTier: 3,
      briberyVulnerability: 60,
      operatingRegions: {Region.latinAmerica},
    ),
    Agency(
      type: AgencyType.saps,
      name: 'SAPS',
      country: 'South Africa',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 70,
      detectionRange: 55,
      resources: 45,
      weaponsTier: 3,
      briberyVulnerability: 50,
      operatingRegions: {Region.africa},
    ),
    Agency(
      type: AgencyType.psb,
      name: 'PSB',
      country: 'China',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 90,
      detectionRange: 85,
      resources: 95,
      weaponsTier: 4,
      briberyVulnerability: 20,
      operatingRegions: {Region.asia},
    ),
    Agency(
      type: AgencyType.enafcod,
      name: 'ENAFCOD',
      country: 'Brazil',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 50,
      detectionRange: 35,
      resources: 40,
      weaponsTier: 3,
      briberyVulnerability: 55,
      operatingRegions: {Region.latinAmerica},
    ),
    Agency(
      type: AgencyType.ndlea,
      name: 'NDLEA',
      country: 'Nigeria',
      jurisdiction: Jurisdiction.national,
      aggressiveness: 40,
      detectionRange: 30,
      resources: 30,
      weaponsTier: 2,
      briberyVulnerability: 80,
      operatingRegions: {Region.africa},
    ),
    Agency(
      type: AgencyType.interpol,
      name: 'Interpol',
      country: 'International',
      jurisdiction: Jurisdiction.global,
      aggressiveness: 90,
      detectionRange: 90,
      resources: 85,
      weaponsTier: 4,
      briberyVulnerability: 5,
      operatingRegions: {
        Region.northAmerica,
        Region.latinAmerica,
        Region.europe,
        Region.africa,
        Region.asia,
      },
    ),
    Agency(
      type: AgencyType.europol,
      name: 'Europol',
      country: 'EU',
      jurisdiction: Jurisdiction.regional,
      aggressiveness: 75,
      detectionRange: 70,
      resources: 70,
      weaponsTier: 3,
      briberyVulnerability: 5,
      operatingRegions: {Region.europe},
    ),
  ];

  static Agency byType(AgencyType type) =>
      all.firstWhere((a) => a.type == type);

  /// Get all agencies that operate in a given region.
  static List<Agency> forRegion(Region region) =>
      all.where((a) => a.operatingRegions.contains(region)).toList();

  static int get count => all.length;
}
