import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';
import 'package:immigru/features/home/domain/entities/immi_grove.dart';
import 'package:immigru/features/home/domain/repositories/immi_grove_repository.dart';

/// Use case for getting recommended ImmiGroves
class GetRecommendedImmiGrovesUseCase {
  final ImmiGroveRepository repository;

  /// Create a new GetRecommendedImmiGrovesUseCase
  GetRecommendedImmiGrovesUseCase(this.repository);

  /// Execute the use case
  /// 
  /// [limit] - Maximum number of ImmiGroves to return
  Future<Either<Failure, List<ImmiGrove>>> call({
    int limit = 5,
  }) {
    return repository.getRecommendedImmiGroves(
      limit: limit,
    );
  }
}
