import 'package:immigru/features/home/data/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface for event data source operations
abstract class EventDataSource {
  /// Get upcoming events
  ///
  /// [upcoming] - Whether to only include upcoming events
  /// [limit] - Maximum number of events to return
  /// [offset] - Pagination offset
  Future<List<EventModel>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  });

  /// Register for an event
  ///
  /// [eventId] - ID of the event to register for
  /// [userId] - ID of the user registering
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  });
}

/// Implementation of EventDataSource using Supabase
class EventDataSourceImpl implements EventDataSource {
  final SupabaseClient supabase;

  /// Create a new EventDataSourceImpl
  EventDataSourceImpl({required this.supabase});

  @override
  Future<List<EventModel>> getEvents({
    bool upcoming = true,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      // Start with a base query
      var query = supabase.from('Event').select();

      // Filter for upcoming events if requested
      if (upcoming) {
        final now = DateTime.now().toIso8601String();
        query = query.gte('EventDate', now);
      }

      // Apply pagination and ordering
      final response = await query
          .order('EventDate', ascending: true)
          .limit(limit)
          .range(offset, offset + limit - 1);

      // If no events found, return empty list
      if (response.isEmpty) {
        return [];
      }

      // Extract all organizer IDs to get user profiles
      final Set<String> organizerIds =
          response.map((event) => event['OrganizerId'] as String).toSet();

      // Get user profiles for all organizers
      var userProfilesQuery = supabase.from('UserProfile').select('*');

      // Apply filter for organizer IDs using OR conditions
      if (organizerIds.isNotEmpty) {
        final organizerIdsList = organizerIds.toList();
        // Start with the first ID
        userProfilesQuery = userProfilesQuery.eq('UserId', organizerIdsList[0]);

        // Add 'or' conditions for the rest of the IDs
        for (int i = 1; i < organizerIdsList.length; i++) {
          userProfilesQuery =
              userProfilesQuery.or('UserId.eq.${organizerIdsList[i]}');
        }
      }

      final userProfilesResponse = await userProfilesQuery;

      // Create a map of userId to userProfile for quick lookup
      final Map<String, Map<String, dynamic>> userProfilesMap = {};
      for (final profile in userProfilesResponse) {
        userProfilesMap[profile['UserId']] = profile;
      }

      // Get the current user ID for determining if the user is registered for each event
      final currentUser = supabase.auth.currentUser;
      final currentUserId = currentUser?.id;

      // Create EventModel objects
      final List<EventModel> events = [];
      for (final event in response) {
        final eventId = event['Id'] as String;
        final organizerId = event['OrganizerId'] as String;
        final organizerProfile = userProfilesMap[organizerId];

        // Check if the current user is registered for this event
        bool isRegistered = false;
        if (currentUserId != null) {
          final registrationResponse = await supabase
              .from('EventRegistration')
              .select()
              .eq('EventId', eventId)
              .eq('UserId', currentUserId);
          isRegistered = registrationResponse.isNotEmpty;
        }

        // We don't need to get registration count as it's not used in the model

        // Create an EventModel with all the data
        final eventModel = EventModel(
          id: eventId,
          title: event['Title'],
          description: event['Description'],
          eventDate: DateTime.parse(event['EventDate']),
          location: event['Location'],
          imageUrl: event['ImageUrl'],
          organizerId: organizerId,
          organizerName: organizerProfile?['DisplayName'] ?? 'Organizer',
          isRegistered: isRegistered,
          icon: event['Icon'] ?? '',
        );

        events.add(eventModel);
      }

      return events;
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  @override
  Future<bool> registerForEvent({
    required String eventId,
    required String userId,
  }) async {
    try {
      // Check if the user is already registered for this event
      final existingRegistration = await supabase
          .from('EventRegistration')
          .select()
          .eq('EventId', eventId)
          .eq('UserId', userId);

      if (existingRegistration.isNotEmpty) {
        // User is already registered, so unregister them
        await supabase
            .from('EventRegistration')
            .delete()
            .eq('EventId', eventId)
            .eq('UserId', userId);
      } else {
        // Register the user for the event
        await supabase.from('EventRegistration').insert({
          'EventId': eventId,
          'UserId': userId,
        });
      }

      return true;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }
}
