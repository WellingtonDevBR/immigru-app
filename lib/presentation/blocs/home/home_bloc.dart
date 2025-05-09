import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/domain/usecases/post_usecases.dart';
import 'package:immigru/presentation/blocs/home/home_event.dart';
import 'package:immigru/presentation/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUseCase _getPostsUseCase;
  final CreatePostUseCase _createPostUseCase;
  final GetEventsUseCase _getEventsUseCase;
  final CreateEventUseCase _createEventUseCase;
  final LoggerService _logger = LoggerService();

  // Sample data for fallback when backend is not ready
  final List<Map<String, dynamic>> _samplePosts = [
    {
      'category': 'Immigration News',
      'userName': 'Jane Doe',
      'timeAgo': '2h ago',
      'location': 'New York, USA',
      'content': 'Just got my green card approved! The process was smoother than I expected. Happy to share my experience with anyone going through the same process.',
      'commentCount': 12,
      'imageUrl': null,
    },
    {
      'category': 'Legal Advice',
      'userName': 'John Smith',
      'timeAgo': '5h ago',
      'location': 'Los Angeles, USA',
      'content': 'If you\'re applying for citizenship, make sure to double-check all your documentation. I made a small mistake that delayed my application by months.',
      'commentCount': 8,
      'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8ZG9jdW1lbnRzfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60',
    },
    {
      'category': 'Community',
      'userName': 'Maria Garcia',
      'timeAgo': '1d ago',
      'location': 'Chicago, USA',
      'content': 'Hosting a cultural exchange event next weekend. Everyone is welcome! We\'ll have food, music, and activities from around the world.',
      'commentCount': 24,
      'imageUrl': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fGN1bHR1cmFsJTIwZXZlbnR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
    },
  ];
  
  final List<Map<String, dynamic>> _sampleEvents = [
    {
      'title': 'Immigration Workshop',
      'event_date': '2025-05-15T10:00:00.000Z',
      'location': 'Online',
      'icon': 'video_call',
    },
    {
      'title': 'Citizenship Application Seminar',
      'event_date': '2025-05-20T14:00:00.000Z',
      'location': 'New York Community Center',
      'icon': 'location_on',
    },
    {
      'title': 'Cultural Exchange Festival',
      'event_date': '2025-06-05T12:00:00.000Z',
      'location': 'Central Park, NY',
      'icon': 'celebration',
    },
    {
      'title': 'Legal Aid Clinic',
      'event_date': '2025-06-12T15:00:00.000Z',
      'location': 'Online',
      'icon': 'gavel',
    },
  ];

  HomeBloc({
    required GetPostsUseCase getPostsUseCase,
    required CreatePostUseCase createPostUseCase,
    required GetEventsUseCase getEventsUseCase,
    required CreateEventUseCase createEventUseCase,
  })  : _getPostsUseCase = getPostsUseCase,
        _createPostUseCase = createPostUseCase,
        _getEventsUseCase = getEventsUseCase,
        _createEventUseCase = createEventUseCase,
        super(const HomeState()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<LoadEventsEvent>(_onLoadEvents);
    on<CreatePostEvent>(_onCreatePost);
    on<CreateEventEvent>(_onCreateEvent);
    on<FilterPostsByCategoryEvent>(_onFilterPostsByCategory);
  }

  Future<void> _onLoadPosts(LoadPostsEvent event, Emitter<HomeState> emit) async {
    if (state.isLoadingPosts) return;
    
    emit(state.copyWith(isLoadingPosts: true));
    
    try {
      _logger.info('HomeBloc', 'Loading posts with category: ${event.category ?? "All"}');
      
      List<Map<String, dynamic>> posts = [];
      
      try {
        posts = await _getPostsUseCase.call(
          category: event.category != 'All Posts' ? event.category : null,
          limit: 20,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        _logger.info('HomeBloc', 'Using sample posts data as fallback', error: e);
        posts = _samplePosts;
      }
      
      emit(state.copyWith(
        posts: posts,
        isLoadingPosts: false,
        errorMessage: null,
      ));
    } catch (e) {
      _logger.error('HomeBloc', 'Error loading posts', error: e);
      emit(state.copyWith(
        isLoadingPosts: false,
        posts: _samplePosts,
        errorMessage: 'Failed to load posts. Using sample data.',
      ));
    }
  }

  Future<void> _onLoadEvents(LoadEventsEvent event, Emitter<HomeState> emit) async {
    if (state.isLoadingEvents) return;
    
    emit(state.copyWith(isLoadingEvents: true));
    
    try {
      _logger.info('HomeBloc', 'Loading events with upcomingOnly: ${event.upcomingOnly}');
      
      List<Map<String, dynamic>> events = [];
      
      try {
        events = await _getEventsUseCase.call(
          upcoming: event.upcomingOnly,
          limit: 10,
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        _logger.info('HomeBloc', 'Using sample events data as fallback', error: e);
        events = _sampleEvents;
      }
      
      emit(state.copyWith(
        events: events,
        isLoadingEvents: false,
        errorMessage: null,
      ));
    } catch (e) {
      _logger.error('HomeBloc', 'Error loading events', error: e);
      emit(state.copyWith(
        isLoadingEvents: false,
        events: _sampleEvents,
        errorMessage: 'Failed to load events. Using sample data.',
      ));
    }
  }

  Future<void> _onCreatePost(CreatePostEvent event, Emitter<HomeState> emit) async {
    try {
      _logger.info('HomeBloc', 'Creating new post');
      
      emit(state.copyWith(isLoadingPosts: true));
      
      await _createPostUseCase.call(
        userId: event.userId,
        content: event.content,
        category: event.category,
        location: event.location,
        imageUrl: event.imageUrl,
      );
      
      // Reload posts after creating a new one
      add(LoadPostsEvent(category: state.selectedCategory));
    } catch (e) {
      _logger.error('HomeBloc', 'Error creating post', error: e);
      emit(state.copyWith(
        isLoadingPosts: false,
        errorMessage: 'Failed to create post. Please try again.',
      ));
    }
  }

  Future<void> _onCreateEvent(CreateEventEvent event, Emitter<HomeState> emit) async {
    try {
      _logger.info('HomeBloc', 'Creating new event');
      
      emit(state.copyWith(isLoadingEvents: true));
      
      await _createEventUseCase.call(
        title: event.title,
        eventDate: event.eventDate,
        location: event.location,
        description: event.description,
        imageUrl: event.imageUrl,
        createdBy: event.createdBy,
      );
      
      // Reload events after creating a new one
      add(const LoadEventsEvent());
    } catch (e) {
      _logger.error('HomeBloc', 'Error creating event', error: e);
      emit(state.copyWith(
        isLoadingEvents: false,
        errorMessage: 'Failed to create event. Please try again.',
      ));
    }
  }

  void _onFilterPostsByCategory(FilterPostsByCategoryEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
    add(LoadPostsEvent(category: event.category));
  }
}
