import 'package:immigru/core/network/network_optimizer.dart';
import 'package:immigru/features/home/domain/entities/post.dart';

/// Extension methods for NetworkOptimizer to handle specific entity types
extension NetworkOptimizerPostExtension on NetworkOptimizer {
  /// Execute a post operation with retry capability
  ///
  /// This method is specifically designed for post-related operations
  /// that return List<Post> and need retry capability
  Future<List<Post>> executePostOperation(
    Future<List<Post>> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    return executeWithRetry<List<Post>>(
      operation,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }
}
