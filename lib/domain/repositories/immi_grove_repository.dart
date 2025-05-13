import 'package:immigru/domain/entities/immi_grove.dart';

/// Repository interface for ImmiGrove operations
abstract class ImmiGroveRepository {
  /// Get recommended ImmiGroves for the current user
  Future<List<ImmiGrove>> getRecommendedImmiGroves({int limit = 6});
  
  /// Join an ImmiGrove community
  Future<void> joinImmiGrove(String immiGroveId);
  
  /// Leave an ImmiGrove community
  Future<void> leaveImmiGrove(String immiGroveId);
  
  /// Get ImmiGroves that the user has joined
  Future<List<ImmiGrove>> getJoinedImmiGroves();
}
