import 'package:immigru/domain/entities/country.dart';

/// Data model class for Country based on the database schema
class CountryModel extends Country {
  const CountryModel({
    required super.id,
    required super.isoCode,
    required super.name,
    required super.officialName,
    required super.continent,
    required super.region,
    required super.subRegion,
    required super.nationality,
    required super.phoneCode,
    required super.currency,
    required super.currencySymbol,
    required super.timezones,
    required super.flagUrl,
    required super.isActive,
    required super.updatedAt,
    required super.createdAt,
  });

  /// Create a CountryModel from a JSON map
  factory CountryModel.fromJson(Map<String, dynamic> json) {
    // Try both camelCase and lowercase field names to handle different API formats
    return CountryModel(
      id: json['id'] ?? json['Id'] ?? 0,
      isoCode: json['iso_code'] ?? json['IsoCode'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      officialName: json['official_name'] ?? json['OfficialName'] ?? '',
      continent: json['continent'] ?? json['Continent'] ?? '',
      region: json['region'] ?? json['Region'] ?? '',
      subRegion: json['subregion'] ?? json['sub_region'] ?? json['SubRegion'] ?? '',
      nationality: json['nationality'] ?? json['Nationality'] ?? '',
      phoneCode: json['phone_code'] ?? json['PhoneCode'] ?? '',
      currency: json['currency_code'] ?? json['currency'] ?? json['Currency'] ?? '',
      currencySymbol: json['currency_symbol'] ?? json['CurrencySymbol'] ?? '',
      timezones: json['timezones'] ?? json['Timezones'] ?? '',
      flagUrl: json['flag_url'] ?? json['FlagUrl'] ?? '',
      isActive: json['is_active'] ?? json['IsActive'] ?? true,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['UpdatedAt'] != null
              ? DateTime.parse(json['UpdatedAt'])
              : DateTime.now()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['CreatedAt'] != null
              ? DateTime.parse(json['CreatedAt'])
              : DateTime.now()),
    );
  }

  /// Convert CountryModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iso_code': isoCode,
      'name': name,
      'official_name': officialName,
      'continent': continent,
      'region': region,
      'subregion': subRegion,
      'nationality': nationality,
      'phone_code': phoneCode,
      'currency_code': currency,
      'currency_symbol': currencySymbol,
      'timezones': timezones,
      'flag_url': flagUrl,
      'is_active': isActive,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a list of CountryModel objects from a list of JSON maps
  static List<CountryModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CountryModel.fromJson(json)).toList();
  }
}
