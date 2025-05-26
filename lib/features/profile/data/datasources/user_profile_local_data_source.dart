import 'dart:convert';

import 'package:immigru/core/storage/secure_storage.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/profile/data/models/user_profile_model.dart';

/// Interface for the local data source for user profile operations
abstract class UserProfileLocalDataSource {
  /// Get a cached user profile by user ID
  Future<UserProfileModel?> getCachedUserProfile(String userId);
  
  /// Cache a user profile
  Future<void> cacheUserProfile(UserProfileModel profile);
  
  /// Get cached user stats
  Future<Map<String, int>?> getCachedUserStats(String userId);
  
  /// Cache user stats
  Future<void> cacheUserStats(String userId, Map<String, int> stats);
  
  /// Clear cached data for a user
  Future<void> clearCache(String userId);
}

/// Implementation of the local data source using secure storage
class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final SecureStorage _secureStorage;
  
  /// Constructor
  UserProfileLocalDataSourceImpl(this._secureStorage);
  
  /// Key for user profile cache
  String _getUserProfileKey(String userId) => 'user_profile_$userId';
  
  /// Key for user stats cache
  String _getUserStatsKey(String userId) => 'user_stats_$userId';
  
  @override
  Future<UserProfileModel?> getCachedUserProfile(String userId) async {
    final jsonString = await _secureStorage.get(_getUserProfileKey(userId));
    if (jsonString == null) return null;
    
    try {
      final Map<String, dynamic> profileMap = json.decode(jsonString);
      final Map<String, dynamic> userMap = profileMap['user'];
      
      final user = User(
        id: userMap['id'],
        email: userMap['email'],
        phone: userMap['phone'],
        displayName: userMap['displayName'] ?? '',
        photoUrl: userMap['photoUrl'],
      );
      
      return UserProfileModel.fromJson(profileMap, user);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    final Map<String, dynamic> profileMap = profile.toJson();
    
    // Add the user data to the map
    profileMap['user'] = {
      'id': profile.user.id,
      'email': profile.user.email,
      'phone': profile.user.phone,
      'displayName': profile.user.displayName,
      'photoUrl': profile.user.photoUrl,
    };
    
    await _secureStorage.set(
      _getUserProfileKey(profile.user.id),
      json.encode(profileMap),
    );
  }
  
  @override
  Future<Map<String, int>?> getCachedUserStats(String userId) async {
    final jsonString = await _secureStorage.get(_getUserStatsKey(userId));
    if (jsonString == null) return null;
    
    try {
      final Map<String, dynamic> statsMap = json.decode(jsonString);
      return {
        'postsCount': statsMap['postsCount'] ?? 0,
        'followersCount': statsMap['followersCount'] ?? 0,
        'followingCount': statsMap['followingCount'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> cacheUserStats(String userId, Map<String, int> stats) async {
    await _secureStorage.set(
      _getUserStatsKey(userId),
      json.encode(stats),
    );
  }
  
  @override
  Future<void> clearCache(String userId) async {
    await _secureStorage.delete(_getUserProfileKey(userId));
    await _secureStorage.delete(_getUserStatsKey(userId));
  }
}
