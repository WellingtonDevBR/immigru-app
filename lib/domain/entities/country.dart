import 'package:equatable/equatable.dart';

/// Entity class representing a country based on the database schema
class Country extends Equatable {
  final int id;
  final String isoCode;
  final String name;
  final String officialName;
  final String continent;
  final String region;
  final String subRegion;
  final String nationality;
  final String phoneCode;
  final String currency;
  final String currencySymbol;
  final String timezones;
  final String flagUrl;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime createdAt;

  const Country({
    required this.id,
    required this.isoCode,
    required this.name,
    required this.officialName,
    required this.continent,
    required this.region,
    required this.subRegion,
    required this.nationality,
    required this.phoneCode,
    required this.currency,
    required this.currencySymbol,
    required this.timezones,
    required this.flagUrl,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        isoCode,
        name,
        officialName,
        continent,
        region,
        subRegion,
        nationality,
        phoneCode,
        currency,
        currencySymbol,
        timezones,
        flagUrl,
        isActive,
        updatedAt,
        createdAt,
      ];

  /// Create an empty country object
  factory Country.empty() => Country(
        id: 0,
        isoCode: '',
        name: '',
        officialName: '',
        continent: '',
        region: '',
        subRegion: '',
        nationality: '',
        phoneCode: '',
        currency: '',
        currencySymbol: '',
        timezones: '',
        flagUrl: '',
        isActive: true,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
}
