import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/network/network_info.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/features/media/data/datasources/media_data_source.dart';
import 'package:immigru/features/media/data/datasources/media_data_source_impl.dart';
import 'package:immigru/features/media/data/repositories/media_repository_impl.dart';
import 'package:immigru/features/media/domain/repositories/i_media_repository.dart';
import 'package:immigru/features/media/domain/usecases/add_photo_comment.dart' as domain_add_comment;
import 'package:immigru/features/media/domain/usecases/create_album.dart' as domain_create_album;
import 'package:immigru/features/media/domain/usecases/get_album_photos.dart';
import 'package:immigru/features/media/domain/usecases/get_or_create_default_album.dart' as domain_get_default_album;
import 'package:immigru/features/media/domain/usecases/get_user_albums.dart';
import 'package:immigru/features/media/domain/usecases/like_photo.dart' as domain_like_photo;
import 'package:immigru/features/media/domain/usecases/unlike_photo.dart' as domain_unlike_photo;
import 'package:immigru/features/media/domain/usecases/upload_photo.dart' as domain_upload_photo;
import 'package:immigru/features/media/presentation/bloc/media_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for registering media feature dependencies
class MediaModule {
  /// Register all dependencies for the media feature
  static void register(GetIt getIt) {
    // Data sources
    getIt.registerLazySingleton<IMediaDataSource>(
      () => MediaDataSourceImpl(
        supabaseClient: Supabase.instance.client,
        storageService: getIt<ISupabaseStorage>(),
        logger: getIt<UnifiedLogger>(),
      ),
    );

    // Repositories
    getIt.registerLazySingleton<IMediaRepository>(
      () => MediaRepositoryImpl(
        dataSource: getIt<IMediaDataSource>(),
        networkInfo: getIt<INetworkInfo>(),
        logger: getIt<UnifiedLogger>(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton(
      () => GetUserAlbums(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton(
      () => GetAlbumPhotos(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_create_album.CreateAlbum>(
      () => domain_create_album.CreateAlbum(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_upload_photo.UploadPhoto>(
      () => domain_upload_photo.UploadPhoto(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_get_default_album.GetOrCreateDefaultAlbum>(
      () => domain_get_default_album.GetOrCreateDefaultAlbum(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_add_comment.AddPhotoComment>(
      () => domain_add_comment.AddPhotoComment(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_like_photo.LikePhoto>(
      () => domain_like_photo.LikePhoto(getIt<IMediaRepository>()),
    );
    
    getIt.registerLazySingleton<domain_unlike_photo.UnlikePhoto>(
      () => domain_unlike_photo.UnlikePhoto(getIt<IMediaRepository>()),
    );

    // BLoC
    getIt.registerFactory<MediaBloc>(
      () => MediaBloc(
        getUserAlbums: getIt<GetUserAlbums>(),
        getAlbumPhotos: getIt<GetAlbumPhotos>(),
        createAlbum: getIt<domain_create_album.CreateAlbum>(),
        uploadPhoto: getIt<domain_upload_photo.UploadPhoto>(),
        getOrCreateDefaultAlbum: getIt<domain_get_default_album.GetOrCreateDefaultAlbum>(),
        addPhotoComment: getIt<domain_add_comment.AddPhotoComment>(),
        likePhoto: getIt<domain_like_photo.LikePhoto>(),
        unlikePhoto: getIt<domain_unlike_photo.UnlikePhoto>(),
        logger: getIt<UnifiedLogger>(),
      ),
    );
  }
}
