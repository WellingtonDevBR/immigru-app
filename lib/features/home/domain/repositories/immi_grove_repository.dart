import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/immi_grove.dart';

/// Repository interface for ImmiGrove-related operations
abstract class ImmiGroveRepository {
  /// Get ImmiGroves (communities)
  ///
  /// [query] - Optional search query
  /// [limit] - Maximum number of ImmiGroves to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<ImmiGrove>>> getImmiGroves({
    String? query,
    int limit = 10,
    int offset = 0,
  });

  /// Get recommended ImmiGroves for the user
  ///
  /// [limit] - Maximum number of ImmiGroves to return
  Future<Either<Failure, List<ImmiGrove>>> getRecommendedImmiGroves({
    int limit = 5,
  });

  /// Join or leave an ImmiGrove
  ///
  /// [immiGroveId] - ID of the ImmiGrove to join/leave
  /// [userId] - ID of the user performing the action
  /// [join] - Whether to join (true) or leave (false)
  Future<Either<Failure, bool>> joinImmiGrove({
    required String immiGroveId,
    required String userId,
    required bool join,
  });
}
