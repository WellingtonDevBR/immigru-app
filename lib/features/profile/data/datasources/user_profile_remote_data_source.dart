import 'dart:io';

import 'package:immigru/core/config/storage_config.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/logging/unified_logger.dart';
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
  
  /// Remove a profile cover image
  Future<bool> removeCoverImage(String userId);
  
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
      // Get the current authenticated user to ensure proper permissions
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Permission denied: Cannot upload avatar for another user');
      }
      
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      
      // Generate a unique file ID for the avatar
      final fileId = StorageConfig.generateFileId();
      final fileName = 'avatars-$fileId.$fileExt';
      
      // Generate the storage path using the config
      final storagePath = '${StorageConfig.userPaths.avatarPath(userId)}/$fileName';
      
      // Upload the file to Supabase storage
      await _supabaseClient
          .storage
          .from(StorageConfig.buckets.users)
          .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));
      
      // Store only the file name in the database, not the full path or URL
      // The application will build the full path when needed
      await _supabaseClient
          .from('UserProfile')
          .update({'AvatarUrl': fileName})
          .eq('UserId', userId);
      
      // Get the public URL for immediate return
      final avatarUrl = _supabaseClient
          .storage
          .from(StorageConfig.buckets.users)
          .getPublicUrl(storagePath);
      
      return avatarUrl;
    } catch (e) {
      final logger = UnifiedLogger();
      logger.e('Error uploading avatar: ${e.toString()}', tag: 'UserProfileRemoteDataSource');
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<String> uploadCoverImage(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      
      // Get the current authenticated user to ensure proper permissions
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Permission denied: Cannot upload cover image for another user');
      }
      
      // Generate a unique file ID for the cover image
      final fileId = StorageConfig.generateFileId();
      final fileName = 'covers-$fileId.$fileExt';
      
      // Generate the storage path using the config
      final storagePath = '${StorageConfig.userPaths.coverPath(userId)}/$fileName';
      
      // Upload the file to Supabase storage with proper path
      await _supabaseClient
          .storage
          .from(StorageConfig.buckets.users)
          .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));
      
      // Store only the file name in the database, not the full path or URL
      // The application will build the full path when needed
      await _supabaseClient
          .from('UserProfile')
          .update({'CoverImageUrl': fileName})
          .eq('UserId', userId);
      
      // Get the public URL for immediate return
      final coverUrl = _supabaseClient
          .storage
          .from(StorageConfig.buckets.users)
          .getPublicUrl(storagePath);
      
      return coverUrl;
    } catch (e) {
      // Log the error using the appropriate logger
      final logger = UnifiedLogger();
      logger.e('Error uploading cover image: ${e.toString()}', tag: 'UserProfileRemoteDataSource');
      
      throw ErrorHandler.instance.handleException(e, tag: 'UserProfileRemoteDataSource');
    }
  }
  
  @override
  Future<bool> removeCoverImage(String userId) async {
    try {
      // Get the current authenticated user to ensure proper permissions
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw Exception('Permission denied: Cannot remove cover image for another user');
      }
      
      // Get the current cover image file name from the profile
      final profileData = await _supabaseClient
          .from('UserProfile')
          .select('CoverImageUrl')
          .eq('UserId', userId)
          .single();
      
      final fileName = profileData['CoverImageUrl'] as String?;
      
      // If there's no cover image, just update the profile and return success
      if (fileName == null || fileName.isEmpty) {
        await _supabaseClient
            .from('UserProfile')
            .update({'CoverImageUrl': ''})
            .eq('UserId', userId);
        return true;
      }
      
      // We need to build the full path to delete the file
      // If it's already a full path, use it directly
      String fullPath;
      if (fileName.contains('/')) {
        fullPath = fileName;
      } else {
        // Build the path: userId/covers/fileName
        fullPath = '${userId}/covers/$fileName';
      }
      
      // Delete the file from storage
      await _supabaseClient
          .storage
          .from(StorageConfig.buckets.users)
          .remove([fullPath]);
      
      // Update the profile with an empty cover image path
      await _supabaseClient
          .from('UserProfile')
          .update({'CoverImageUrl': ''})
          .eq('UserId', userId);
      
      return true;
    } catch (e) {
      // Log the error using the appropriate logger
      final logger = UnifiedLogger();
      logger.e('Error removing cover image: ${e.toString()}', tag: 'UserProfileRemoteDataSource');
      
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
