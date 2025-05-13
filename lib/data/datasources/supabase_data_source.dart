import 'package:immigru/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract class defining the contract for Supabase data operations
abstract class SupabaseDataSource {
  Future<AuthResponse> signInWithEmail({required String email, required String password});
  Future<AuthResponse> signUpWithEmail({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> sendOtpToPhone({required String phone});
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode});
  Future<List<Map<String, dynamic>>> getDataFromTable(String tableName, {List<String>? columns, String? filter});
  Future<List<Map<String, dynamic>>> insertIntoTable(String tableName, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> updateInTable(String tableName, Map<String, dynamic> data, {required String filter});
  Future<List<Map<String, dynamic>>> deleteFromTable(String tableName, {required String filter});
  Future<dynamic> callEdgeFunction(String functionName, {Map<String, dynamic>? params});
  Future<List<Map<String, dynamic>>> getCountries();
  User? get currentUser;
  bool get isAuthenticated;
  SupabaseClient get client;
}

/// Implementation of the SupabaseDataSource using the SupabaseService
class SupabaseDataSourceImpl implements SupabaseDataSource {
  final SupabaseService _supabaseService;

  SupabaseDataSourceImpl(this._supabaseService);

  @override
  User? get currentUser => _supabaseService.currentUser;

  @override
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  
  @override
  SupabaseClient get client => _supabaseService.client;

  @override
  Future<List<Map<String, dynamic>>> deleteFromTable(String tableName, {required String filter}) {
    return _supabaseService.deleteFromTable(tableName, filter: filter);
  }
  
  @override
  Future<dynamic> callEdgeFunction(String functionName, {Map<String, dynamic>? params}) {
    return _supabaseService.callEdgeFunction(functionName, params: params);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      // Use the Supabase client to call the edge function with proper authentication
      final response = await _supabaseService.callEdgeFunction('get-countries');
      
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is List) {
          if (data.isNotEmpty) {
          }
          return data.cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } catch (e) {
      // If there's an error, provide a small set of fallback countries
      return [
        {
          "Id": 1,
          "IsoCode": "US",
          "Name": "United States",
          "OfficialName": "United States of America",
          "Continent": "North America",
          "Region": "Northern America",
          "SubRegion": "Northern America",
          "Nationality": "American",
          "PhoneCode": "+1",
          "Currency": "USD",
          "CurrencySymbol": "\$",
          "Timezones": "UTC-12:00 to UTC+12:00",
          "FlagUrl": "https://flagcdn.com/w320/us.png",
          "IsActive": true,
          "UpdatedAt": "2025-05-12T03:12:51.996882+00:00",
          "CreatedAt": "2025-04-30T16:17:44.803752+00:00"
        },
        {
          "Id": 3,
          "IsoCode": "BR",
          "Name": "Brazil",
          "OfficialName": "Federative Republic of Brazil",
          "Continent": "South America",
          "Region": "Latin America",
          "SubRegion": "South America",
          "Nationality": "Brazilian",
          "PhoneCode": "+55",
          "Currency": "BRL",
          "CurrencySymbol": "R\$",
          "Timezones": "UTC-05:00 to UTC-02:00",
          "FlagUrl": "https://flagcdn.com/w320/br.png",
          "IsActive": true,
          "UpdatedAt": "2025-05-12T03:12:51.996882+00:00",
          "CreatedAt": "2025-04-30T16:17:44.803752+00:00"
        },
        {
          "Id": 14,
          "IsoCode": "AU",
          "Name": "Australia",
          "OfficialName": "Commonwealth of Australia",
          "Continent": "Oceania",
          "Region": "Australia and New Zealand",
          "SubRegion": "Australasia",
          "Nationality": "Australian",
          "PhoneCode": "+61",
          "Currency": "AUD",
          "CurrencySymbol": "A\$",
          "Timezones": "UTC+08:00 to UTC+11:00",
          "FlagUrl": "https://flagcdn.com/w320/au.png",
          "IsActive": true,
          "UpdatedAt": "2025-05-12T03:12:51.996882+00:00",
          "CreatedAt": "2025-04-30T16:17:44.803752+00:00"
        }
      ];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDataFromTable(String tableName, {List<String>? columns, String? filter}) {
    return _supabaseService.getDataFromTable(
      tableName,
      columns: columns,
      filter: filter,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> insertIntoTable(String tableName, Map<String, dynamic> data) {
    return _supabaseService.insertIntoTable(tableName, data);
  }

  @override
  Future<void> resetPassword(String email) {
    return _supabaseService.resetPassword(email);
  }

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) {
    return _supabaseService.signInWithEmail(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpWithEmail({required String email, required String password}) {
    return _supabaseService.signUpWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _supabaseService.signOut();
  }
  
  @override
  Future<void> sendOtpToPhone({required String phone}) async {
    await _supabaseService.client.auth.signInWithOtp(phone: phone);
  }
  
  @override
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String otpCode}) async {
    return await _supabaseService.client.auth.verifyOTP(
      phone: phone,
      token: otpCode,
      type: OtpType.sms,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> updateInTable(String tableName, Map<String, dynamic> data, {required String filter}) {
    return _supabaseService.updateInTable(tableName, data, filter: filter);
  }
}
