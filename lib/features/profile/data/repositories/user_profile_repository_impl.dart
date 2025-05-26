import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:immigru/core/error/error_handler.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/profile/data/datasources/user_profile_local_data_source.dart';
import 'package:immigru/features/profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:immigru/features/profile/data/models/user_profile_model.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';
import 'package:immigru/features/profile/domain/repositories/user_profile_repository.dart';

/// Implementation of the UserProfileRepository
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileLocalDataSource localDataSource;
  final Connectivity _connectivity;
  final ErrorHandler _errorHandler;

  /// Constructor
  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    Connectivity? connectivity,
    ErrorHandler? errorHandler,
  }) : _connectivity = connectivity ?? Connectivity(),
       _errorHandler = errorHandler ?? ErrorHandler.instance;

  /// Check if the device is connected to the internet
  Future<bool> _isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile({
    required String userId,
    bool bypassCache = false,
  }) async {
    try {
      // Try to get from cache first if not bypassing cache
      if (!bypassCache) {
        final cachedProfile = await localDataSource.getCachedUserProfile(userId);
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
      }

      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          // Fetch from remote
          final remoteProfile = await remoteDataSource.getUserProfile(userId);
          
          // Cache the result - ensure we're using UserProfileModel
          await localDataSource.cacheUserProfile(remoteProfile);
          
          return Right(remoteProfile);
        } catch (e) {
          // If remote fails, try to get from cache as fallback
          if (!bypassCache) {
            final cachedProfile = await localDataSource.getCachedUserProfile(userId);
            if (cachedProfile != null) {
              return Right(cachedProfile);
            }
          }
          
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        // If offline, try to get from cache
        final cachedProfile = await localDataSource.getCachedUserProfile(userId);
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    required UserProfile profile,
  }) async {
    try {
      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          // Ensure we're working with a UserProfileModel
          final UserProfileModel profileModel;
          if (profile is UserProfileModel) {
            profileModel = profile;
          } else {
            profileModel = UserProfileModel.fromEntity(profile);
          }
          
          final updatedProfile = await remoteDataSource.updateUserProfile(profileModel);
          
          // Update the cache
          await localDataSource.cacheUserProfile(updatedProfile);
          
          return Right(updatedProfile);
        } catch (e) {
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          final avatarUrl = await remoteDataSource.uploadAvatar(userId, filePath);
          
          // Update the cached profile with the new avatar URL
          final cachedProfile = await localDataSource.getCachedUserProfile(userId);
          if (cachedProfile != null) {
            final updatedProfile = cachedProfile.copyWith(avatarUrl: avatarUrl);
            await localDataSource.cacheUserProfile(updatedProfile as UserProfileModel);
          }
          
          return Right(avatarUrl);
        } catch (e) {
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCoverImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          final coverUrl = await remoteDataSource.uploadCoverImage(userId, filePath);
          
          // Update the cached profile with the new cover image URL
          final cachedProfile = await localDataSource.getCachedUserProfile(userId);
          if (cachedProfile != null) {
            final updatedProfile = cachedProfile.copyWith(coverImageUrl: coverUrl);
            await localDataSource.cacheUserProfile(updatedProfile as UserProfileModel);
          }
          
          return Right(coverUrl);
        } catch (e) {
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> removeCoverImage({
    required String userId,
  }) async {
    try {
      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          final success = await remoteDataSource.removeCoverImage(userId);
          
          // Update the cached profile with empty cover image URL
          final cachedProfile = await localDataSource.getCachedUserProfile(userId);
          if (cachedProfile != null) {
            final updatedProfile = cachedProfile.copyWith(coverImageUrl: '');
            await localDataSource.cacheUserProfile(updatedProfile as UserProfileModel);
          }
          
          return Right(success);
        } catch (e) {
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserStats({
    required String userId,
    bool bypassCache = false,
  }) async {
    try {
      // Try to get from cache first if not bypassing cache
      if (!bypassCache) {
        final cachedStats = await localDataSource.getCachedUserStats(userId);
        if (cachedStats != null) {
          return Right(cachedStats);
        }
      }

      // Check connectivity before making network request
      if (await _isConnected()) {
        try {
          // Fetch from remote
          final remoteStats = await remoteDataSource.getUserStats(userId);
          
          // Cache the result
          await localDataSource.cacheUserStats(userId, remoteStats);
          
          return Right(remoteStats);
        } catch (e) {
          // If remote fails, try to get from cache as fallback
          if (!bypassCache) {
            final cachedStats = await localDataSource.getCachedUserStats(userId);
            if (cachedStats != null) {
              return Right(cachedStats);
            }
          }
          
          return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
        }
      } else {
        // If offline, try to get from cache
        final cachedStats = await localDataSource.getCachedUserStats(userId);
        if (cachedStats != null) {
          return Right(cachedStats);
        }
        return Left(Failure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(_errorHandler.handleException(e, tag: 'UserProfileRepository'));
    }
  }
}
