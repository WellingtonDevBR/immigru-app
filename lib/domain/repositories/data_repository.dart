/// Abstract repository for general data operations
abstract class DataRepository {
  /// Get data from a table
  Future<List<Map<String, dynamic>>> getDataFromTable(
    String tableName, {
    List<String>? columns,
    String? filter,
    List<String>? orderBy,
    int? limit,
    int? offset,
  });
  
  /// Insert data into a table
  Future<List<Map<String, dynamic>>> insertIntoTable(
    String tableName,
    Map<String, dynamic> data,
  );
  
  /// Update data in a table
  Future<List<Map<String, dynamic>>> updateInTable(
    String tableName,
    Map<String, dynamic> data, {
    required String filter,
  });
  
  /// Delete data from a table
  Future<List<Map<String, dynamic>>> deleteFromTable(
    String tableName, {
    required String filter,
  });
}
