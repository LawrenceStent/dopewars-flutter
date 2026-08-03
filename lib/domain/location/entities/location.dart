import 'package:equatable/equatable.dart';

/// Location type enum for the 12 global cities.
enum LocationType {
  newYork,
  losAngeles,
  mexicoCity,
  london,
  capeTown,
  tokyo,
  macau,
  rioDeJaneiro,
  paris,
  barcelona,
  lagos,
  darkWeb,
}

/// Geographic region for grouping locations.
enum Region {
  northAmerica,
  latinAmerica,
  europe,
  africa,
  asia,
  virtual,
}

/// Represents a game location (one of 12 global cities).
class Location extends Equatable {
  final LocationType type;
  final String name;
  final String country;
  final Region region;

  /// Police presence percentage (0-100).
  /// Higher means more likely to encounter police.
  final int policePresence;

  /// Regional price multiplier (e.g., 0.3 for Lagos, 1.8 for Tokyo).
  final double priceMultiplier;

  /// Transaction tax percentage (e.g., 5 for 5%).
  final int transactionTaxPercent;

  /// Travel cost in turns from New York (baseline).
  final int travelCostFromNYC;

  /// Which drugs are available at this location (by DrugType index).
  final Set<int> availableDrugIndices;

  /// Special facilities at this location.
  final Set<LocationFacility> facilities;

  const Location({
    required this.type,
    required this.name,
    required this.country,
    required this.region,
    required this.policePresence,
    required this.priceMultiplier,
    required this.transactionTaxPercent,
    required this.travelCostFromNYC,
    required this.availableDrugIndices,
    this.facilities = const {},
  });

  /// Get the index of this location.
  int get index => type.index;

  /// Check if a drug index is available at this location.
  bool hasDrug(int drugIndex) => availableDrugIndices.contains(drugIndex);

  /// Number of drugs available at this location.
  int get drugCount => availableDrugIndices.length;

  /// Check if this location has a specific facility.
  bool hasFacility(LocationFacility facility) => facilities.contains(facility);

  @override
  List<Object?> get props => [
        type,
        name,
        country,
        region,
        policePresence,
        priceMultiplier,
        transactionTaxPercent,
        travelCostFromNYC,
        availableDrugIndices,
        facilities,
      ];

  @override
  String toString() => 'Location($name)';
}

/// Special facilities that can exist at a location.
enum LocationFacility {
  bank,
  loanShark,
  gunShop,
  roughPub,
  darkWebTerminal,
  smugglingPort,
}

/// Default locations for the modernized game.
class DefaultLocations {
  DefaultLocations._();

  // TODO: Populate availableDrugIndices from pricing-matrix.md
  // TODO: Wire up facilities per location

  static const List<Location> all = [
    Location(
      type: LocationType.newYork,
      name: 'New York',
      country: 'USA',
      region: Region.northAmerica,
      policePresence: 50,
      priceMultiplier: 1.0,
      transactionTaxPercent: 5,
      travelCostFromNYC: 0,
      availableDrugIndices: {0, 1, 2, 3, 4, 5, 7, 9, 10, 11},
      facilities: {
        LocationFacility.bank,
        LocationFacility.loanShark,
        LocationFacility.gunShop,
        LocationFacility.roughPub,
      },
    ),
    Location(
      type: LocationType.losAngeles,
      name: 'Los Angeles',
      country: 'USA',
      region: Region.northAmerica,
      policePresence: 60,
      priceMultiplier: 0.9,
      transactionTaxPercent: 5,
      travelCostFromNYC: 1,
      availableDrugIndices: {0, 1, 3, 4, 5, 7, 8, 10, 11},
      facilities: {LocationFacility.gunShop},
    ),
    Location(
      type: LocationType.mexicoCity,
      name: 'Mexico City',
      country: 'Mexico',
      region: Region.latinAmerica,
      policePresence: 30,
      priceMultiplier: 0.5,
      transactionTaxPercent: 3,
      travelCostFromNYC: 1,
      availableDrugIndices: {1, 2, 3, 6, 8, 9, 11},
      facilities: {LocationFacility.smugglingPort},
    ),
    Location(
      type: LocationType.london,
      name: 'London',
      country: 'UK',
      region: Region.europe,
      policePresence: 70,
      priceMultiplier: 1.5,
      transactionTaxPercent: 8,
      travelCostFromNYC: 2,
      availableDrugIndices: {0, 1, 2, 3, 4, 5, 9, 10, 11},
      facilities: {LocationFacility.bank},
    ),
    Location(
      type: LocationType.capeTown,
      name: 'Cape Town',
      country: 'South Africa',
      region: Region.africa,
      policePresence: 80,
      priceMultiplier: 0.7,
      transactionTaxPercent: 4,
      travelCostFromNYC: 3,
      availableDrugIndices: {1, 2, 3, 9, 11},
      facilities: {},
    ),
    Location(
      type: LocationType.tokyo,
      name: 'Tokyo',
      country: 'Japan',
      region: Region.asia,
      policePresence: 90,
      priceMultiplier: 1.8,
      transactionTaxPercent: 10,
      travelCostFromNYC: 3,
      availableDrugIndices: {1, 3, 4, 5, 6, 10},
      facilities: {},
    ),
    Location(
      type: LocationType.macau,
      name: 'Macau',
      country: 'China',
      region: Region.asia,
      policePresence: 40,
      priceMultiplier: 1.6,
      transactionTaxPercent: 6,
      travelCostFromNYC: 3,
      availableDrugIndices: {1, 3, 4, 5, 6},
      facilities: {LocationFacility.bank},
    ),
    Location(
      type: LocationType.rioDeJaneiro,
      name: 'Rio de Janeiro',
      country: 'Brazil',
      region: Region.latinAmerica,
      policePresence: 35,
      priceMultiplier: 0.4,
      transactionTaxPercent: 3,
      travelCostFromNYC: 2,
      availableDrugIndices: {1, 3, 8, 9, 11},
      facilities: {LocationFacility.roughPub},
    ),
    Location(
      type: LocationType.paris,
      name: 'Paris',
      country: 'France',
      region: Region.europe,
      policePresence: 65,
      priceMultiplier: 1.6,
      transactionTaxPercent: 8,
      travelCostFromNYC: 2,
      availableDrugIndices: {0, 1, 2, 4, 5, 9, 10, 11},
      facilities: {},
    ),
    Location(
      type: LocationType.barcelona,
      name: 'Barcelona',
      country: 'Spain',
      region: Region.europe,
      policePresence: 55,
      priceMultiplier: 1.3,
      transactionTaxPercent: 5,
      travelCostFromNYC: 2,
      availableDrugIndices: {0, 1, 5, 9, 10, 11},
      facilities: {LocationFacility.smugglingPort},
    ),
    Location(
      type: LocationType.lagos,
      name: 'Lagos',
      country: 'Nigeria',
      region: Region.africa,
      policePresence: 20,
      priceMultiplier: 0.3,
      transactionTaxPercent: 2,
      travelCostFromNYC: 3,
      availableDrugIndices: {1, 2, 3, 6, 9, 11},
      facilities: {},
    ),
    Location(
      type: LocationType.darkWeb,
      name: 'Dark Web',
      country: 'Onion Network',
      region: Region.virtual,
      policePresence: 10,
      priceMultiplier: 1.2,
      transactionTaxPercent: 15,
      travelCostFromNYC: 1,
      availableDrugIndices: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
      facilities: {LocationFacility.darkWebTerminal},
    ),
  ];

  static Location byType(LocationType type) =>
      all.firstWhere((l) => l.type == type);

  static Location byIndex(int index) => all[index];

  static int get count => all.length;

  /// Get the index of the bank location.
  static int bankIndex() =>
      all.indexWhere((l) => l.hasFacility(LocationFacility.bank));

  /// Get the index of the loan shark location.
  static int loanSharkIndex() =>
      all.indexWhere((l) => l.hasFacility(LocationFacility.loanShark));

  /// Get the index of the gun shop location.
  static int gunShopIndex() =>
      all.indexWhere((l) => l.hasFacility(LocationFacility.gunShop));

  /// Get the index of the rough pub location.
  static int roughPubIndex() =>
      all.indexWhere((l) => l.hasFacility(LocationFacility.roughPub));
}
