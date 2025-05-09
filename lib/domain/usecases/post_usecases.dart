import 'package:immigru/domain/repositories/data_repository.dart';

/// Use case for getting posts from the database
class GetPostsUseCase {
  final DataRepository _repository;

  GetPostsUseCase(this._repository);

  /// Get posts with optional filtering
  /// 
  /// [category] - Optional category to filter posts by
  /// [limit] - Optional limit on number of posts to return
  /// [offset] - Optional offset for pagination
  Future<List<Map<String, dynamic>>> call({
    String? category,
    int? limit,
    int? offset,
  }) async {
    String filter = '';
    
    if (category != null && category.isNotEmpty && category != 'All Posts') {
      filter = "category='$category'";
    }
    
    return _repository.getDataFromTable(
      'posts',
      filter: filter.isNotEmpty ? filter : null,
      orderBy: ['created_at DESC'],
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for creating a new post
class CreatePostUseCase {
  final DataRepository _repository;

  CreatePostUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call({
    required String userId,
    required String content,
    required String category,
    String? location,
    String? imageUrl,
  }) async {
    final postData = {
      'user_id': userId,
      'content': content,
      'category': category,
      'location': location,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    return _repository.insertIntoTable('posts', postData);
  }
}

/// Use case for getting events from the database
class GetEventsUseCase {
  final DataRepository _repository;

  GetEventsUseCase(this._repository);

  /// Get events with optional filtering
  /// 
  /// [upcoming] - If true, only return events in the future
  /// [limit] - Optional limit on number of events to return
  /// [offset] - Optional offset for pagination
  Future<List<Map<String, dynamic>>> call({
    bool upcoming = true,
    int? limit,
    int? offset,
  }) async {
    String filter = '';
    
    if (upcoming) {
      final now = DateTime.now().toIso8601String();
      filter = "event_date>='$now'";
    }
    
    return _repository.getDataFromTable(
      'events',
      filter: filter.isNotEmpty ? filter : null,
      orderBy: ['event_date ASC'],
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for creating a new event
class CreateEventUseCase {
  final DataRepository _repository;

  CreateEventUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call({
    required String title,
    required DateTime eventDate,
    required String location,
    String? description,
    String? imageUrl,
    required String createdBy,
  }) async {
    final eventData = {
      'title': title,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'created_by': createdBy,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    return _repository.insertIntoTable('events', eventData);
  }
}
