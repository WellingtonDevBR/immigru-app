import 'package:immigru/domain/entities/interest.dart';

/// Repository interface for interest-related operations
abstract class InterestRepository {
  /// Get a list of all available interests
  Future<List<Interest>> getInterests();
}
