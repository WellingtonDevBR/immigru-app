import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/domain/repositories/data_repository.dart';

/// Implementation of the DataRepository using the SupabaseDataSource
class DataRepositoryImpl implements DataRepository {
  final SupabaseDataSource _dataSource;

  DataRepositoryImpl(this._dataSource);

  @override
  Future<List<Map<String, dynamic>>> deleteFromTable(String tableName, {required String filter}) {
    return _dataSource.deleteFromTable(tableName, filter: filter);
  }

  @override
  Future<List<Map<String, dynamic>>> getDataFromTable(
    String tableName, {
    List<String>? columns,
    String? filter,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    return _dataSource.getDataFromTable(
      tableName,
      columns: columns,
      filter: filter,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> insertIntoTable(String tableName, Map<String, dynamic> data) {
    return _dataSource.insertIntoTable(tableName, data);
  }

  @override
  Future<List<Map<String, dynamic>>> updateInTable(
    String tableName,
    Map<String, dynamic> data, {
    required String filter,
  }) {
    return _dataSource.updateInTable(tableName, data, filter: filter);
  }
}
