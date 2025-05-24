import 'package:immigru/features/home/data/models/immi_grove_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for ImmiGrove data source operations
abstract class ImmiGroveDataSource {
  /// Get ImmiGroves (communities)
  ///
  /// [query] - Optional search query
  /// [limit] - Maximum number of ImmiGroves to return
  /// [offset] - Pagination offset
  Future<List<ImmiGroveModel>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  });

  /// Get recommended ImmiGroves for the user
  ///
  /// [limit] - Maximum number of ImmiGroves to return
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({
    int limit = 5,
  });

  /// Join or leave an ImmiGrove
  ///
  /// [immiGroveId] - ID of the ImmiGrove to join/leave
  /// [userId] - ID of the user performing the action
  /// [join] - Whether to join (true) or leave (false)
  Future<bool> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  });
}

/// Implementation of ImmiGroveDataSource using Supabase
class ImmiGroveDataSourceImpl implements ImmiGroveDataSource {
  final SupabaseClient supabase;

  /// Create a new ImmiGroveDataSourceImpl
  ImmiGroveDataSourceImpl({required this.supabase});

  @override
  Future<List<ImmiGroveModel>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Start with a base query
      var dbQuery = supabase.from('ImmiGrove').select();

      // Apply search filter if provided
      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.ilike('Name', '%$query%');
      }

      // Apply pagination and ordering
      final response = await dbQuery
          .order('Name')
          .limit(limit)
          .range(offset, offset + limit - 1);

      // If no ImmiGroves found, return empty list
      if (response.isEmpty) {
        return [];
      }

      // Get the current user ID for determining if the user is a member of each ImmiGrove
      final currentUser = supabase.auth.currentUser;
      final currentUserId = currentUser?.id;

      // Create ImmiGroveModel objects
      final List<ImmiGroveModel> immiGroves = [];
      for (final grove in response) {
        final groveId = grove['Id'] as String;

        // Get member count for this ImmiGrove
        final memberCountResponse = await supabase
            .from('ImmiGroveMember')
            .select()
            .eq('ImmiGroveId', groveId);

        final memberCount = memberCountResponse.length;

        // Check if the current user is a member of this ImmiGrove
        bool isMember = false;
        if (currentUserId != null) {
          final membershipResponse = await supabase
              .from('ImmiGroveMember')
              .select()
              .eq('ImmiGroveId', groveId)
              .eq('UserId', currentUserId);
          isMember = membershipResponse.isNotEmpty;
        }

        // Create an ImmiGroveModel with all the data
        final immiGroveModel = ImmiGroveModel(
          id: groveId,
          name: grove['Name'],
          description: grove['Description'],
          imageUrl: grove['ImageUrl'],
          memberCount: memberCount,
          isJoined: isMember,
        );

        immiGroves.add(immiGroveModel);
      }

      return immiGroves;
    } catch (e) {
      print('Error fetching ImmiGroves: $e');
      return [];
    }
  }

  @override
  Future<List<ImmiGroveModel>> getRecommendedImmiGroves({
    int limit = 5,
  }) async {
    try {
      // Get the current user ID
      final currentUser = supabase.auth.currentUser;
      final currentUserId = currentUser?.id;

      if (currentUserId == null) {
        // If no current user, return popular ImmiGroves
        return getPopularImmiGroves(limit: limit);
      }

      // Get the user's interests
      final userInterestsResponse = await supabase
          .from('UserInterest')
          .select('Category')
          .eq('UserId', currentUserId);

      // Extract categories from the response
      final List<String> userInterests = userInterestsResponse
          .map((item) => item['Category'] as String)
          .toList();

      // If the user has no interests, return popular ImmiGroves
      if (userInterests.isEmpty) {
        return getPopularImmiGroves(limit: limit);
      }

      // Get ImmiGroves matching the user's interests
      var query = supabase.from('ImmiGrove').select();

      // Start with the first interest
      query = query.eq('Category', userInterests[0]);

      // Add OR conditions for the rest of the interests
      for (int i = 1; i < userInterests.length; i++) {
        query = query.or('Category.eq.${userInterests[i]}');
      }

      // Get ImmiGroves that the user is not already a member of
      final membershipResponse = await supabase
          .from('ImmiGroveMember')
          .select('ImmiGroveId')
          .eq('UserId', currentUserId);

      final List<String> memberImmiGroveIds = membershipResponse
          .map((item) => item['ImmiGroveId'] as String)
          .toList();

      // Exclude ImmiGroves that the user is already a member of
      for (final groveId in memberImmiGroveIds) {
        query = query.neq('Id', groveId);
      }

      // Apply pagination and ordering
      final response = await query.limit(limit);

      // If no matching ImmiGroves found, return popular ImmiGroves
      if (response.isEmpty) {
        return getPopularImmiGroves(limit: limit);
      }

      // Create ImmiGroveModel objects
      final List<ImmiGroveModel> immiGroves = [];
      for (final grove in response) {
        final groveId = grove['Id'] as String;

        // Get member count for this ImmiGrove
        final memberCountResponse = await supabase
            .from('ImmiGroveMember')
            .select()
            .eq('ImmiGroveId', groveId);

        final memberCount = memberCountResponse.length;

        // Create an ImmiGroveModel with all the data
        final immiGroveModel = ImmiGroveModel(
          id: groveId,
          name: grove['Name'],
          description: grove['Description'],
          imageUrl: grove['ImageUrl'],
          memberCount: memberCount,
          isJoined: false, // We already excluded ImmiGroves the user is a member of
        );

        immiGroves.add(immiGroveModel);
      }

      return immiGroves;
    } catch (e) {
      print('Error fetching recommended ImmiGroves: $e');
      return [];
    }
  }

  /// Helper method to get popular ImmiGroves
  Future<List<ImmiGroveModel>> getPopularImmiGroves({
    int limit = 5,
  }) async {
    try {
      // Get ImmiGroves with the most members
      final response = await supabase
          .from('ImmiGrove')
          .select('*, ImmiGroveMember!inner(ImmiGroveId)')
          .limit(limit);

      // If no ImmiGroves found, return empty list
      if (response.isEmpty) {
        return [];
      }

      // Get the current user ID for determining if the user is a member of each ImmiGrove
      final currentUser = supabase.auth.currentUser;
      final currentUserId = currentUser?.id;

      // Create ImmiGroveModel objects
      final List<ImmiGroveModel> immiGroves = [];
      for (final grove in response) {
        final groveId = grove['Id'] as String;

        // Get member count for this ImmiGrove
        final memberCountResponse = await supabase
            .from('ImmiGroveMember')
            .select()
            .eq('ImmiGroveId', groveId);

        final memberCount = memberCountResponse.length;

        // Check if the current user is a member of this ImmiGrove
        bool isMember = false;
        if (currentUserId != null) {
          final membershipResponse = await supabase
              .from('ImmiGroveMember')
              .select()
              .eq('ImmiGroveId', groveId)
              .eq('UserId', currentUserId);
          isMember = membershipResponse.isNotEmpty;
        }

        // Create an ImmiGroveModel with all the data
        final immiGroveModel = ImmiGroveModel(
          id: groveId,
          name: grove['Name'],
          description: grove['Description'],
          imageUrl: grove['ImageUrl'],
          memberCount: memberCount,
          isJoined: isMember,
        );

        immiGroves.add(immiGroveModel);
      }

      return immiGroves;
    } catch (e) {
      print('Error fetching popular ImmiGroves: $e');
      return [];
    }
  }

  @override
  Future<bool> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  }) async {
    try {
      if (join) {
        // Check if the user is already a member of this ImmiGrove
        final existingMembership = await supabase
            .from('ImmiGroveMember')
            .select()
            .eq('ImmiGroveId', immiGroveId)
            .eq('UserId', userId);

        if (existingMembership.isEmpty) {
          // Add the user as a member
          await supabase.from('ImmiGroveMember').insert({
            'ImmiGroveId': immiGroveId,
            'UserId': userId,
          });
        }
      } else {
        // Remove the user's membership
        await supabase
            .from('ImmiGroveMember')
            .delete()
            .eq('ImmiGroveId', immiGroveId)
            .eq('UserId', userId);
      }

      return true;
    } catch (e) {
      print('Error joining/leaving ImmiGrove: $e');
      return false;
    }
  }
}
