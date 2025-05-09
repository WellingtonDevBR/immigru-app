import 'package:immigru/domain/repositories/data_repository.dart';

/// Use case for getting data from a table
class GetDataFromTableUseCase {
  final DataRepository _repository;

  GetDataFromTableUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(
    String tableName, {
    List<String>? columns,
    String? filter,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    return _repository.getDataFromTable(
      tableName,
      columns: columns,
      filter: filter,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for inserting data into a table
class InsertIntoTableUseCase {
  final DataRepository _repository;

  InsertIntoTableUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(
    String tableName,
    Map<String, dynamic> data,
  ) {
    return _repository.insertIntoTable(tableName, data);
  }
}

/// Use case for updating data in a table
class UpdateInTableUseCase {
  final DataRepository _repository;

  UpdateInTableUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(
    String tableName,
    Map<String, dynamic> data, {
    required String filter,
  }) {
    return _repository.updateInTable(
      tableName,
      data,
      filter: filter,
    );
  }
}

/// Use case for deleting data from a table
class DeleteFromTableUseCase {
  final DataRepository _repository;

  DeleteFromTableUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(
    String tableName, {
    required String filter,
  }) {
    return _repository.deleteFromTable(
      tableName,
      filter: filter,
    );
  }
}
