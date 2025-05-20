import '../entities/interest.dart';

/// Repository interface for managing interests in the onboarding flow
abstract class InterestRepository {
  /// Get all available interests
  Future<List<Interest>> getInterests();
  
  /// Save user's selected interests
  Future<bool> saveUserInterests(List<int> interestIds);
  
  /// Get user's selected interests
  Future<List<Interest>> getUserInterests();
}
