import 'package:immigru/domain/entities/interest.dart';

/// Repository interface for interest-related operations
abstract class InterestRepository {
  /// Get a list of all available interests
  Future<List<Interest>> getInterests();
  
  /// Save user interests
  /// 
  /// [interestIds] is a list of interest IDs to save
  Future<bool> saveUserInterests(List<int> interestIds);
  
  /// Get user interests
  Future<List<Interest>> getUserInterests();
}
