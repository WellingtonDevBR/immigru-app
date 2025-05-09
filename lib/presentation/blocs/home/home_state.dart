import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> events;
  final bool isLoadingPosts;
  final bool isLoadingEvents;
  final String selectedCategory;
  final String? errorMessage;

  const HomeState({
    this.posts = const [],
    this.events = const [],
    this.isLoadingPosts = false,
    this.isLoadingEvents = false,
    this.selectedCategory = 'All Posts',
    this.errorMessage,
  });

  HomeState copyWith({
    List<Map<String, dynamic>>? posts,
    List<Map<String, dynamic>>? events,
    bool? isLoadingPosts,
    bool? isLoadingEvents,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      events: events ?? this.events,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        events,
        isLoadingPosts,
        isLoadingEvents,
        selectedCategory,
        errorMessage,
      ];

  // Helper methods for UI
  bool get hasError => errorMessage != null;
  bool get isLoading => isLoadingPosts || isLoadingEvents;
  bool get hasPosts => posts.isNotEmpty;
  bool get hasEvents => events.isNotEmpty;
}
