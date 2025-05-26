import 'dart:io';

import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/features/auth/domain/entities/user.dart' as auth_entities;
import 'package:immigru/features/profile/data/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for the remote data source for user profile operations
abstract class UserProfileRemoteDataSource {
  /// Get a user profile by user ID
  Future<UserProfileModel> getUserProfile(String userId);
  
  /// Update a user profile
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  
  /// Upload a profile avatar
  Future<String> uploadAvatar(String userId, String filePath);
  
  /// Upload a profile cover image
  Future<String> uploadCoverImage(String userId, String filePath);
  
  /// Get user stats (posts count, followers count, following count)
  Future<Map<String, int>> getUserStats(String userId);
}

/// Implementation of the remote data source using Supabase
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;
  
  /// Constructor
  UserProfileRemoteDataSourceImpl(this._supabaseClient);
  
  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      // First get the user data
      final userData = await _supabaseClient
          .from('User')
          .select()
          .eq('Id', userId)
          .single();
      
      final user = auth_entities.User(
        id: userData['Id'],
        email: userData['Email'],
        phone: userData['Phone'],
        displayName: userData['DisplayName'] ?? '',
        photoUrl: userData['PhotoUrl'],
      );
      
      // Then get the profile data
      final profileData = await _supabaseClient
          .from('UserProfile')
          .select()
          .eq('UserId', userId)
          .single();
      
      return UserProfileModel.fromJson(profileData, user);
    } catch (e) {
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      final updatedProfile = await _supabaseClient
          .from('UserProfile')
          .update(profile.toJson())
          .eq('UserId', profile.user.id)
          .select()
          .single();
      
      return UserProfileModel.fromJson(updatedProfile, profile.user);
    } catch (e) {
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = 'avatar_$userId.$fileExt';
      
      // Upload the file to Supabase storage
      await _supabaseClient
          .storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      
      final avatarUrl = _supabaseClient
          .storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      // Update the profile with the new avatar URL
      await _supabaseClient
          .from('UserProfile')
          .update({'AvatarUrl': avatarUrl})
          .eq('UserId', userId);
      
      return avatarUrl;
    } catch (e) {
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<String> uploadCoverImage(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName = 'cover_$userId.$fileExt';
      
      // Upload the file to Supabase storage
      await _supabaseClient
          .storage
          .from('covers')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      
      final coverUrl = _supabaseClient
          .storage
          .from('covers')
          .getPublicUrl(fileName);
      
      // Update the profile with the new cover image URL
      await _supabaseClient
          .from('UserProfile')
          .update({'CoverImageUrl': coverUrl})
          .eq('UserId', userId);
      
      return coverUrl;
    } catch (e) {
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Use a more efficient approach to get counts
      final postsCountQuery = await _supabaseClient
          .from('Post')
          .select()
          .eq('UserId', userId);
      
      // Followers are users who sent connection requests to this user (this user is the receiver)
      final followersCountQuery = await _supabaseClient
          .from('UserConnection')
          .select()
          .eq('ReceiverId', userId)
          .eq('Status', 'accepted');
      
      // Following are users to whom this user sent connection requests (this user is the sender)
      final followingCountQuery = await _supabaseClient
          .from('UserConnection')
          .select()
          .eq('SenderId', userId)
          .eq('Status', 'accepted');
      
      // Calculate counts from the query results
      final postsCount = postsCountQuery.length;
      final followersCount = followersCountQuery.length;
      final followingCount = followingCountQuery.length;
      
      return {
        'postsCount': postsCount,
        'followersCount': followersCount,
        'followingCount': followingCount,
      };
    } catch (e) {
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
}
