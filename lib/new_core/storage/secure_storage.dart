import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for storing sensitive information
class SecureStorage {
  final FlutterSecureStorage _storage;
  
  /// Creates a new secure storage instance
  SecureStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();
  
  /// Get a value from secure storage
  Future<String?> get(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading from secure storage: $e');
      }
      return null;
    }
  }
  
  /// Set a value in secure storage
  Future<void> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        print('Error writing to secure storage: $e');
      }
    }
  }
  
  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking secure storage: $e');
      }
      return false;
    }
  }
  
  /// Remove a value from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error deleting from secure storage: $e');
    }
  }
  
  /// Clear all values from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
  }
  
  /// Get all keys and values from secure storage
  Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('Error reading all from secure storage: $e');
      return {};
    }
  }
}
