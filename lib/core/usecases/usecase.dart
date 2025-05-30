import 'package:dartz/dartz.dart';
import 'package:immigru/core/network/models/failure.dart';

/// Abstract class for a Use Case (Interactor in Clean Architecture).
/// This interface represents a execution unit for different use cases (this means any use case
/// in the application should implement this contract).
///
/// The Use Case abstraction represents the execution logic of a specific use case in the application.
/// It is part of the Domain layer and defines the operations that can be performed by the application.
///
/// The [Type] and [Params] types should be defined by the implementing use case.
/// [Type] is the return type of the use case
/// [Params] is the parameter type of the use case
abstract class UseCase<Type, Params> {
  /// Call method which will be called by the client
  /// [params] is the parameters required by the use case
  /// Returns [Either] with a [Failure] or the result of type [Type]
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters class for use cases that don't require parameters
class NoParams {
  /// Constructor
  const NoParams();
}
