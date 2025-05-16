import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for storing simple key-value pairs
class LocalStorage {
  static LocalStorage? _instance;
  late final SharedPreferences _prefs;
  
  /// Private constructor for singleton pattern
  LocalStorage._();
  
  /// Get the singleton instance of the local storage service
  static Future<LocalStorage> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorage._();
      await _instance!._init();
    }
    return _instance!;
  }
  
  /// Initialize the local storage service
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get a string value from storage
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  /// Set a string value in storage
  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }
  
  /// Get a boolean value from storage
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  /// Set a boolean value in storage
  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }
  
  /// Get an integer value from storage
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  /// Set an integer value in storage
  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }
  
  /// Get a double value from storage
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }
  
  /// Set a double value in storage
  Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }
  
  /// Get a list of strings from storage
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
  
  /// Set a list of strings in storage
  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }
  
  /// Get an object from storage
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }
  
  /// Set an object in storage
  Future<bool> setObject<T>(String key, T value, Map<String, dynamic> Function(T value) toJson) {
    final json = toJson(value);
    final jsonString = jsonEncode(json);
    return _prefs.setString(key, jsonString);
  }
  
  /// Check if a key exists in storage
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
  
  /// Remove a value from storage
  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }
  
  /// Clear all values from storage
  Future<bool> clear() {
    return _prefs.clear();
  }
}
