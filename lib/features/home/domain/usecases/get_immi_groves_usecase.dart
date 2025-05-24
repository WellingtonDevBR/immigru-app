import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/immi_grove.dart';
import 'package:immigru/features/home/domain/repositories/immi_grove_repository.dart';

/// Use case for getting ImmiGroves
class GetImmiGrovesUseCase {
  final ImmiGroveRepository repository;

  /// Create a new GetImmiGrovesUseCase
  GetImmiGrovesUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [query] - Optional search query
  /// [limit] - Maximum number of ImmiGroves to return
  /// [offset] - Pagination offset
  Future<Either<Failure, List<ImmiGrove>>> call({
    String? query,
    int limit = 10,
    int offset = 0,
  }) {
    return repository.getImmiGroves(
      query: query,
      limit: limit,
      offset: offset,
    );
  }
}
