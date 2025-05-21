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
      return null;
    }
  }

  /// Set a value in secure storage
  Future<void> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      return;
    }
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }

  /// Remove a value from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      // Silently ignore errors when deleting from secure storage
    }
  }

  /// Clear all values from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Silently ignore errors when clearing secure storage
    }
  }

  /// Get all keys and values from secure storage
  Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      // Return empty map on error reading from secure storage
      return {};
    }
  }
}
