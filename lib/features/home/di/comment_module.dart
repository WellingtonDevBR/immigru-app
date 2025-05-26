import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/features/home/data/datasources/comment_data_source_impl.dart';
import 'package:immigru/features/home/data/repositories/comment_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/comment_repository.dart';
import 'package:immigru/features/home/domain/usecases/create_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/delete_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/edit_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/get_comments_usecase.dart';
import 'package:immigru/features/home/domain/usecases/like_comment_usecase.dart';
import 'package:immigru/features/home/domain/usecases/unlike_comment_usecase.dart';
import 'package:immigru/features/home/presentation/bloc/comments/comments_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for comment feature dependency injection
class CommentModule {
  /// Register all dependencies for the comment feature
  static void init(GetIt sl) {
    try {
      // Data sources
      if (!sl.isRegistered<CommentDataSource>()) {
        sl.registerLazySingleton<CommentDataSource>(
          () => CommentDataSourceImpl(
            supabase: sl<SupabaseClient>(),
          ),
        );
      }

      // Repositories
      if (!sl.isRegistered<CommentRepository>()) {
        sl.registerLazySingleton<CommentRepository>(
          () => CommentRepositoryImpl(
            dataSource: sl<CommentDataSource>(),
            logger: sl<LoggerInterface>(),
          ),
        );
      }

      // Use cases
      if (!sl.isRegistered<GetCommentsUseCase>()) {
        sl.registerLazySingleton(
          () => GetCommentsUseCase(sl<CommentRepository>()),
        );
      }

      if (!sl.isRegistered<CreateCommentUseCase>()) {
        sl.registerLazySingleton(
          () => CreateCommentUseCase(repository: sl<CommentRepository>()),
        );
      }

      if (!sl.isRegistered<EditCommentUseCase>()) {
        sl.registerLazySingleton(
          () => EditCommentUseCase(repository: sl<CommentRepository>()),
        );
      }

      if (!sl.isRegistered<DeleteCommentUseCase>()) {
        sl.registerLazySingleton(
          () => DeleteCommentUseCase(repository: sl<CommentRepository>()),
        );
      }

      if (!sl.isRegistered<LikeCommentUseCase>()) {
        sl.registerLazySingleton(
          () => LikeCommentUseCase(sl<CommentRepository>()),
        );
      }

      if (!sl.isRegistered<UnlikeCommentUseCase>()) {
        sl.registerLazySingleton(
          () => UnlikeCommentUseCase(sl<CommentRepository>()),
        );
      }

      // BLoCs
      if (!sl.isRegistered<CommentsBloc>()) {
        sl.registerFactory(
          () => CommentsBloc(
            getCommentsUseCase: sl<GetCommentsUseCase>(),
            createCommentUseCase: sl<CreateCommentUseCase>(),
            editCommentUseCase: sl<EditCommentUseCase>(),
            deleteCommentUseCase: sl<DeleteCommentUseCase>(),
            likeCommentUseCase: sl<LikeCommentUseCase>(),
            unlikeCommentUseCase: sl<UnlikeCommentUseCase>(),
          ),
        );
      }
    } catch (e) {
      // Log the error but don't rethrow to prevent app crashes during initialization
      final logger = UnifiedLogger();
      logger.e('Error initializing CommentModule: $e', tag: 'CommentModule');
    }
  }
}
