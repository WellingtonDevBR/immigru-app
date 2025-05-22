import 'package:get_it/get_it.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';

/// Module for registering post creation feature dependencies
class PostCreationModule {
  /// Register all dependencies for the post creation feature
  static void register(GetIt sl) {
    // Register BLoC
    sl.registerFactory(() => PostCreationBloc());
  }
}
