import 'package:immigru/core/network/api_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for home screen data
/// 
/// This interface has been refactored to move functionality to more specific data sources:
/// - PostDataSource: For post-related operations
/// - CommentDataSource: For comment-related operations
/// - EventDataSource: For event-related operations
/// - ImmiGroveDataSource: For ImmiGrove-related operations
/// 
/// This interface is kept for backward compatibility but will be deprecated in future versions.
/// @deprecated - Use specific data sources instead
abstract class HomeDataSource {
  // All methods have been moved to more specific data sources
}

/// Implementation of HomeDataSource using Supabase
/// 
/// This implementation is kept for backward compatibility but will be deprecated in future versions.
/// All functionality has been moved to more specific data sources:
/// - PostDataSourceImpl: For post-related operations
/// - CommentDataSourceImpl: For comment-related operations
/// - EventDataSourceImpl: For event-related operations
/// - ImmiGroveDataSourceImpl: For ImmiGrove-related operations
/// @deprecated - Use specific data source implementations instead
class HomeDataSourceImpl implements HomeDataSource {
  final ApiClient apiClient;
  final SupabaseClient supabase;

  HomeDataSourceImpl({
    required this.apiClient,
    required this.supabase,
  });

  // All methods have been moved to specific data sources
}
