import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:immigru/core/config/google_auth_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/features/auth/data/models/user_model.dart';
import 'package:immigru/features/auth/domain/entities/auth_error.dart';

/// Data source for authentication operations using Supabase
class AuthDataSource {
  final SupabaseClient _client;
  final UnifiedLogger _logger = UnifiedLogger();

  // Cache for user profile data
  static Map<String, dynamic>? _cachedUserProfile;
  static Map<String, dynamic>? _cachedUserData;
  static DateTime? _lastFetchTime;

  // Cache expiration time (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Constructor
  AuthDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get the current authenticated user with caching to prevent excessive fetching
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return null;
      }

      // Check if we have a valid cache
      final bool isCacheValid = _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheExpiration &&
          _cachedUserProfile != null &&
          _cachedUserData != null;

      Map<String, dynamic> profileResponse;
      bool hasCompletedOnboarding = false;

      // Use cached data if available and valid
      if (isCacheValid) {
        _logger.d('Using cached user profile data', tag: 'AuthDataSource');
        profileResponse = _cachedUserProfile!;
        hasCompletedOnboarding =
            _cachedUserData!['HasCompletedOnboarding'] ?? false;
      } else {
        // Fetch user profile data from the database
        _logger.d('Fetching fresh user profile data', tag: 'AuthDataSource');
        profileResponse = await _client
            .from('UserProfile') // Use PascalCase table name
            .select()
            .eq('UserId', user.id) // Use PascalCase field name
            .single();

        // Cache the profile response
        _cachedUserProfile = profileResponse;

        try {
          // Get the HasCompletedOnboarding flag from the User table
          final userResponse = await _client
              .from('User') // Use PascalCase table name
              .select('HasCompletedOnboarding')
              .eq('Id', user.id) // Use PascalCase field name
              .single();

          // Cache the user data
          _cachedUserData = userResponse;
          _lastFetchTime = DateTime.now();

          hasCompletedOnboarding =
              userResponse['HasCompletedOnboarding'] ?? false;
        } catch (e) {
          // If there's an error, default to false
          hasCompletedOnboarding = false;
        }
      }

      // Logging removed to prevent excessive console output

      return UserModel(
        id: user.id,
        email: user.email,
        phone: user.phone,
        displayName: profileResponse['DisplayName']
            as String?, // Use PascalCase field name
        photoUrl: profileResponse['AvatarUrl']
            as String?, // Use PascalCase field name
        emailVerified: user.emailConfirmedAt != null,
        hasCompletedOnboarding: hasCompletedOnboarding,
      );
    } catch (e) {
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthError.userNotFound();
      }

      try {
        // Fetch additional user data from the database
        final profileResponse = await _client
            .from('UserProfile') // Use PascalCase table name
            .select()
            .eq('UserId', user.id) // Use PascalCase field name
            .single();

        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: profileResponse['DisplayName']
              as String?, // Use PascalCase field name
          photoUrl: profileResponse['AvatarUrl']
              as String?, // Use PascalCase field name
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding:
              profileResponse['HasCompletedOnboarding'] as bool? ??
                  false, // Use PascalCase field name
        );
      } catch (profileError) {
        // If we can't fetch the profile, create one and return a basic user model

        // Try to create a profile for this user
        try {
          await _createUserProfile(user.id);
        } catch (createError) {
          // Ignore profile creation errors during login
        }

        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: 'User',
          photoUrl: null,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: false,
        );
      }
    } catch (e) {
      if (e is AuthError) {
        rethrow;
      }

      if (e is AuthException) {
        if (e.message.contains('Invalid login credentials')) {
          throw AuthError.invalidCredentials();
        } else if (e.message.contains('Email not confirmed')) {
          throw AuthError(
            message: 'Please verify your email before logging in.',
            code: 'email_not_verified',
          );
        } else if (e.message.contains('Rate limit')) {
          throw AuthError.tooManyRequests();
        }
      }

      if (e.toString().contains('network')) {
        throw AuthError.network();
      } else if (e.toString().contains('too many requests')) {
        throw AuthError.tooManyRequests();
      }

      // Default error case
      throw AuthError.unknown('Failed to sign in: ${e.toString()}');
    }
  }

  /// Sign in with phone number (start the process)
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
        channel: OtpChannel.sms,
        shouldCreateUser: true,
      );
    } catch (e) {
      throw Exception('Failed to start phone authentication: ${e.toString()}');
    }
  }

  /// Verify phone authentication code
  Future<UserModel> verifyPhoneCode(String phoneNumber, String code) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: code,
        type: OtpType.sms,
      );

      final user = response.user;
      if (user == null) {
        throw AuthError.unknown('Failed to verify phone: No user returned');
      }

      // Save user data to the User table using upsert
      try {
        // Use upsert to create or update user in one operation
        await _client.from('User').upsert(
          {
            'Id': user.id,
            'Email': user.email ?? '',
            'PhoneNumber': phoneNumber,
            'PhoneVerified': true,
            'PasswordHash': '', // No password for phone auth
            'AuthProvider': 'phone',
            'Role': 'user',
            'Status': 'active',
            'UpdatedAt': DateTime.now().toIso8601String(),
          },
          onConflict: 'Id', // Use Id as the conflict resolution column
        );
      } catch (e) {
        _logger.e('Failed to save user data to User table: $e',
            tag: 'AuthDataSource');
        // Continue even if this fails, as the auth part worked
      }

      // Check if profile exists, create if it doesn't
      // Use a more robust approach that doesn't throw errors
      final profileExists = await _checkProfileExists(user.id);
      if (!profileExists) {
        await _createUserProfile(user.id);
      }

      // Fetch user data from the User table to check HasCompletedOnboarding
      bool hasCompletedOnboarding = false;
      try {
        // First get the User record to check HasCompletedOnboarding
        final userRecords =
            await _client.from('User').select().eq('Id', user.id);

        if (userRecords.isNotEmpty) {
          hasCompletedOnboarding =
              userRecords[0]['HasCompletedOnboarding'] as bool? ?? false;

          _logger.d(
              'PHONE AUTH: User record found, HasCompletedOnboarding = $hasCompletedOnboarding',
              tag: 'AuthDataSource');
        } else {
          _logger.w('PHONE AUTH: No User record found for ID: ${user.id}',
              tag: 'AuthDataSource');
        }

        // Then get the profile data
        final profileResponse = await _client
            .from('UserProfile')
            .select()
            .eq('UserId', user.id)
            .maybeSingle();

        // Return user model with HasCompletedOnboarding from User table
        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: profileResponse?['DisplayName'] as String?,
          photoUrl: profileResponse?['AvatarUrl'] as String?,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: hasCompletedOnboarding,
        );
      } catch (e) {
        // Return basic user model if data fetch fails
        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: null,
          photoUrl: null,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: false,
        );
      }
    } catch (e) {
      throw Exception('Failed to verify phone: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // Create a completer to handle the async auth flow
      final completer = Completer<UserModel>();

      // For mobile platforms, we want to use the native Google Sign-In experience
      if (!kIsWeb) {
        try {
          // Get client IDs from config
          final webClientId = GoogleAuthConfig.webClientId;
          final iosClientId = GoogleAuthConfig.iosClientId;

          // Initialize Google Sign-In with appropriate client IDs based on platform
          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: iosClientId, // Used for iOS
            serverClientId: webClientId, // Used for web and as a fallback
            scopes: [
              'email',
              'profile',
              'openid'
            ], // openid scope is required for ID tokens
          );

          // Perform interactive sign-in
          final googleUser = await googleSignIn.signIn();

          // Handle user cancellation
          if (googleUser == null) {
            throw Exception('Google sign-in was canceled');
          }

          // Get auth details from Google
          final googleAuth = await googleUser.authentication;
          final accessToken = googleAuth.accessToken;
          final idToken = googleAuth.idToken;

          // Validate tokens
          if (idToken == null) {
            throw Exception('Authentication failed: Missing ID token');
          }

          // Sign in to Supabase with the Google tokens
          final response = await _client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          final authUser = response.user;
          if (authUser == null) {
            throw Exception('Failed to sign in with Google');
          }

          // Save user data to the User table
          try {
            // Check if user exists in our custom User table
            final userExists = await _client
                .from('User')
                .select('Id')
                .eq('Id', authUser.id)
                .maybeSingle();

            if (userExists == null) {
              // Create user in our custom User table
              await _client.from('User').insert({
                'Id': authUser.id,
                'Email': authUser.email ?? '',
                'PhoneNumber': authUser.phone ?? '',
                'PhoneVerified': authUser.phone != null,
                'PasswordHash': '', // No password for Google auth
                'AuthProvider': 'google',
                'EmailVerified': true, // Google auth always verifies email
                'Status': 'active',
                'CreatedAt': DateTime.now().toIso8601String(),
                'UpdatedAt': DateTime.now().toIso8601String(),
              });
            } else {
              // Update existing user with Google auth info
              await _client.from('User').update({
                'Email': authUser.email ?? '',
                'EmailVerified': true,
                'AuthProvider': 'google',
                'UpdatedAt': DateTime.now().toIso8601String(),
              }).eq('Id', authUser.id);
            }
          } catch (e) {
            // Continue even if this fails, as the auth part worked
          }

          // Check if profile exists, create if it doesn't
          final profileExists = await _checkProfileExists(authUser.id);
          if (!profileExists) {
            await _createUserProfile(authUser.id);
          }

          try {
            // First check the User table for HasCompletedOnboarding flag
            bool hasCompletedOnboarding = false;
            try {
              final userRecord = await _client
                  .from('User')
                  .select('HasCompletedOnboarding')
                  .eq('Id', authUser.id)
                  .single();

              hasCompletedOnboarding =
                  userRecord['HasCompletedOnboarding'] as bool? ?? false;
              _logger.d(
                  'Google sign-in: HasCompletedOnboarding = $hasCompletedOnboarding',
                  tag: 'AuthDataSource');
            } catch (e) {
              _logger.e('Error fetching User record: $e',
                  tag: 'AuthDataSource');
              // Default to false if we can't fetch the User record
              hasCompletedOnboarding = false;
            }

            // Fetch profile data
            final profileResponse = await _client
                .from('UserProfile')
                .select()
                .eq('UserId', authUser.id)
                .single();

            final user = UserModel(
              id: authUser.id,
              email: authUser.email,
              phone: authUser.phone,
              displayName: profileResponse['DisplayName'] as String? ??
                  authUser.userMetadata?['full_name'] as String?,
              photoUrl: profileResponse['AvatarUrl'] as String? ??
                  authUser.userMetadata?['avatar_url'] as String?,
              emailVerified: authUser.emailConfirmedAt != null,
              hasCompletedOnboarding: hasCompletedOnboarding,
            );

            return user;
          } catch (e) {
            // If we can't fetch the profile, still return a basic user model
            final user = UserModel(
              id: authUser.id,
              email: authUser.email,
              phone: authUser.phone,
              displayName: authUser.userMetadata?['full_name'] as String?,
              photoUrl: authUser.userMetadata?['avatar_url'] as String?,
              emailVerified: authUser.emailConfirmedAt != null,
              hasCompletedOnboarding: false,
            );

            return user;
          }
        } catch (e) {
          throw Exception('Failed to sign in with Google. Please try again.');
        }
      } else {
        // For web, use the standard OAuth flow
        // Set up a subscription to auth state changes BEFORE starting the OAuth flow
        late final StreamSubscription subscription;
        subscription = _client.auth.onAuthStateChange.listen((data) async {
          final authUser = data.session?.user;
          if (authUser != null && !completer.isCompleted) {
            // Check if profile exists, create if it doesn't
            final profileExists = await _checkProfileExists(authUser.id);
            if (!profileExists) {
              await _createUserProfile(authUser.id);
            }

            try {
              // Fetch additional user data from the database
              // First check the User table for HasCompletedOnboarding flag
              bool hasCompletedOnboarding = false;
              try {
                final userRecord = await _client
                    .from('User')
                    .select('HasCompletedOnboarding')
                    .eq('Id', authUser.id)
                    .single();

                hasCompletedOnboarding =
                    userRecord['HasCompletedOnboarding'] as bool? ?? false;
                _logger.d(
                    'Google sign-in web: HasCompletedOnboarding = $hasCompletedOnboarding',
                    tag: 'AuthDataSource');
              } catch (e) {
                _logger.e('Error fetching User record: $e',
                    tag: 'AuthDataSource');
                // Default to false if we can't fetch the User record
                hasCompletedOnboarding = false;
              }

              // Then fetch profile data
              final profileResponse = await _client
                  .from('UserProfile')
                  .select()
                  .eq('UserId', authUser.id)
                  .single();

              final user = UserModel(
                id: authUser.id,
                email: authUser.email,
                phone: authUser.phone,
                displayName: profileResponse['DisplayName'] as String? ??
                    authUser.userMetadata?['full_name'] as String?,
                photoUrl: profileResponse['AvatarUrl'] as String? ??
                    authUser.userMetadata?['avatar_url'] as String?,
                emailVerified: authUser.emailConfirmedAt != null,
                hasCompletedOnboarding: hasCompletedOnboarding,
              );

              completer.complete(user);
            } catch (e) {
              // Try to at least check the User table for HasCompletedOnboarding flag
              bool hasCompletedOnboarding = false;
              try {
                final userRecord = await _client
                    .from('User')
                    .select('HasCompletedOnboarding')
                    .eq('Id', authUser.id)
                    .single();

                hasCompletedOnboarding =
                    userRecord['HasCompletedOnboarding'] as bool? ?? false;
                _logger.d(
                    'Google sign-in web: HasCompletedOnboarding = $hasCompletedOnboarding',
                    tag: 'AuthDataSource');
              } catch (e) {
                _logger.e('Error fetching User record: $e',
                    tag: 'AuthDataSource');
                // Default to false if we can't fetch the User record
                hasCompletedOnboarding = false;
              }

              // Return a user model with the onboarding status from User table
              final user = UserModel(
                id: authUser.id,
                email: authUser.email,
                phone: authUser.phone,
                displayName: authUser.userMetadata?['full_name'] as String?,
                photoUrl: authUser.userMetadata?['avatar_url'] as String?,
                emailVerified: authUser.emailConfirmedAt != null,
                hasCompletedOnboarding: hasCompletedOnboarding,
              );

              completer.complete(user);
            }

            await subscription.cancel();
          }
        });

        // Set a timeout
        Future.delayed(const Duration(minutes: 2), () {
          if (!completer.isCompleted) {
            completer
                .completeError(Exception('Timeout waiting for Google sign-in'));
            subscription.cancel();
          }
        });

        // Now start the OAuth flow
        final response = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null, // null for web
          queryParams: {
            'access_type': 'offline',
            'prompt': 'consent',
          },
        );

        if (!response) {
          throw Exception('Failed to sign in with Google: OAuth flow canceled');
        }
      }

      // Return the future from the completer
      return completer.future;
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      // First, sign up the user with Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthError.unknown('Failed to sign up: No user returned');
      }

      // Save user data to the User table
      try {
        // Create user in our custom User table
        await _client.from('User').upsert({
          'Id': user.id,
          'Email': email,
          'PasswordHash': '', // We don't store the actual password hash
          'PhoneNumber': user.phone ?? '',
          'PhoneVerified': false,
          'AuthProvider': 'email',
          'EmailVerified': false, // Email verification is handled separately
          'Status': 'active',
          'CreatedAt': DateTime.now().toIso8601String(),
          'UpdatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Continue even if this fails, as the auth part worked
      }

      // Generate a username based on the email
      final username = _generateUsername(email);

      // Create a comprehensive user profile with all required fields
      await _createComprehensiveUserProfile(
        userId: user.id,
        email: email,
        username: username,
      );

      // Try to fetch the newly created profile
      try {
        final profileResponse = await _client
            .from('UserProfile')
            .select()
            .eq('UserId', user.id)
            .single();

        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: profileResponse['DisplayName'] as String?,
          photoUrl: profileResponse['AvatarUrl'] as String?,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: false,
        );
      } catch (profileError) {
        // If we can't fetch the profile, return a basic user model

        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: 'New User',
          photoUrl: null,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: false,
        );
      }
    } catch (e) {
      if (e is AuthError) {
        rethrow;
      }

      if (e is AuthException) {
        if (e.message.contains('already registered')) {
          throw AuthError.emailAlreadyInUse();
        } else if (e.message.contains('password')) {
          throw AuthError.weakPassword();
        }
      }

      if (e.toString().contains('network')) {
        throw AuthError.network();
      } else if (e.toString().contains('too many requests')) {
        throw AuthError.tooManyRequests();
      }

      throw AuthError.unknown('Failed to sign up: ${e.toString()}');
    }
  }

  /// Generate a username based on the email address
  String _generateUsername(String email) {
    // Extract the part before @ in the email
    final namePart = email.split('@').first;

    // Remove special characters and replace spaces with underscores
    final sanitized = namePart.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    // Add a random suffix to make it more unique
    final random =
        DateTime.now().millisecondsSinceEpoch.toString().substring(9, 13);

    return '${sanitized}_$random'.toLowerCase();
  }

  /// Create a comprehensive user profile with all required fields
  Future<void> _createComprehensiveUserProfile({
    required String userId,
    required String email,
    required String username,
  }) async {
    try {
      // Create a display name from the email (part before @)
      final displayName = email
          .split('@')
          .first
          .split('.')
          .map((part) => part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1)}'
              : '')
          .join(' ');

      await _client.from('UserProfile').upsert({
        'UserId': userId,
        'FullName': displayName, // Use the display name as a default full name
        'UserName': username,
        'DisplayName': displayName,
        'Bio': '', // Empty bio by default
        'HasCompletedOnboarding': false,
        'CreatedAt': DateTime.now().toIso8601String(),
        'UpdatedAt': DateTime.now().toIso8601String(),
        // Set default privacy settings
        'ShowEmail': 'private',
        'ShowLocation': 'private',
        'ShowBirthdate': 'private',
        'ShowProfession': 'private',
        'ShowJourneyInfo': 'private',
        'ShowRelationshipStatus': 'private',
        // Set IsMentor to false by default
        'IsMentor': false,
      });
    } catch (e) {
      // Try a simpler profile creation as fallback
      await _createUserProfile(userId);
    }
  }

  /// Sign out the current user
  /// Sign out the current user and clear all cached data
  Future<void> signOut() async {
    try {
      _logger.d('Signing out user', tag: 'AuthDataSource');
      
      // Clear all cached user data
      _cachedUserProfile = null;
      _cachedUserData = null;
      _lastFetchTime = null;
      
      // Sign out from Supabase
      await _client.auth.signOut();
      
      // Sign out from Google if it was used for authentication
      try {
        final googleSignIn = GoogleSignIn(
          clientId: GoogleAuthConfig.webClientId,
        );
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
          _logger.d('Signed out from Google', tag: 'AuthDataSource');
        }
      } catch (googleError) {
        // Log but don't fail if Google sign out fails
        _logger.e('Error signing out from Google: $googleError', tag: 'AuthDataSource');
      }
      
      _logger.d('Successfully signed out', tag: 'AuthDataSource');
    } catch (e) {
      _logger.e('Failed to sign out: $e', tag: 'AuthDataSource');
      throw AuthException(
        'Failed to sign out: ${e.toString()}',
        code: 'sign_out_failed',
      );
    }
  }

  /// Reset password for the given email
  Future<void> resetPassword(String email) async {
    try {
      // Use Supabase's resetPasswordForEmail method
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.immigru.app://reset-password/callback',
      );

      // Note: For security reasons, Supabase doesn't indicate whether the email exists
      // This is intentional to prevent email enumeration attacks
    } catch (e) {
      final logger = UnifiedLogger();
      logger.e('Error resetting password', tag: 'AuthDataSource', error: e);
    }
  }

  /// Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final session = _client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  /// Get authentication state stream
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) {
        return null;
      }

      try {
        // Fetch additional user data from the database
        final profileResponse = await _client
            .from('UserProfile') // Use PascalCase table name
            .select()
            .eq('UserId', user.id) // Use PascalCase field name
            .single();

        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: profileResponse['DisplayName']
              as String?, // Use PascalCase field name
          photoUrl: profileResponse['AvatarUrl']
              as String?, // Use PascalCase field name
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding:
              profileResponse['HasCompletedOnboarding'] as bool? ??
                  false, // Use PascalCase field name
        );
      } catch (e) {
        // If profile doesn't exist yet, return basic user
        return UserModel(
          id: user.id,
          email: user.email,
          phone: user.phone,
          displayName: null,
          photoUrl: null,
          emailVerified: user.emailConfirmedAt != null,
          hasCompletedOnboarding: false,
        );
      }
    });
  }

  /// Check if a profile exists for the given user ID
  Future<bool> _checkProfileExists(String userId) async {
    try {
      final response = await _client
          .from('UserProfile') // Use PascalCase table name
          .select('Id') // Use PascalCase field name
          .eq('UserId', userId) // Use PascalCase field name
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Create a user profile for the given user ID
  Future<void> _createUserProfile(String userId) async {
    try {
      // First check if profile exists to avoid duplicate entries
      final existingProfiles =
          await _client.from('UserProfile').select().eq('UserId', userId);

      // Only create if it doesn't exist
      if (existingProfiles.isEmpty) {
        // Create a basic profile with required fields
        final profileData = {
          'UserId': userId,
          'FullName': '',
          'UserName': 'user_${userId.substring(0, 8)}',
          'DisplayName': 'New User',
          'CreatedAt': DateTime.now().toIso8601String(),
          'UpdatedAt': DateTime.now().toIso8601String(),
        };

        // Use insert instead of upsert since there's no unique constraint
        await _client.from('UserProfile').insert(profileData);
      } else {}
    } catch (e) {
      // Don't throw here, as this is a background operation
    }
  }
}
