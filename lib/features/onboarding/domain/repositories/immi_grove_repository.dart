import '../entities/immi_grove.dart';

/// Repository interface for ImmiGrove operations
abstract class ImmiGroveRepository {
  /// Get recommended ImmiGroves for the current user
  /// 
  /// [limit] is the maximum number of ImmiGroves to return
  Future<List<ImmiGrove>> getRecommendedImmiGroves({int limit = 6});
  
  /// Join an ImmiGrove community
  /// 
  /// [immiGroveId] is the ID of the ImmiGrove to join
  Future<void> joinImmiGrove(String immiGroveId);
  
  /// Leave an ImmiGrove community
  /// 
  /// [immiGroveId] is the ID of the ImmiGrove to leave
  Future<void> leaveImmiGrove(String immiGroveId);
  
  /// Get ImmiGroves that the current user has joined
  Future<List<ImmiGrove>> getJoinedImmiGroves();
  
  /// Save selected ImmiGroves during onboarding
  /// 
  /// [immiGroveIds] is the list of ImmiGrove IDs selected by the user
  Future<void> saveSelectedImmiGroves(List<String> immiGroveIds);
}
