import '../repositories/immi_grove_repository.dart';

/// Use case for saving selected ImmiGroves during onboarding
class SaveSelectedImmiGrovesUseCase {
  final ImmiGroveRepository _repository;

  /// Creates a new instance of [SaveSelectedImmiGrovesUseCase]
  const SaveSelectedImmiGrovesUseCase(this._repository);

  /// Save selected ImmiGroves during onboarding
  /// 
  /// [immiGroveIds] is the list of ImmiGrove IDs selected by the user
  Future<void> call(List<String> immiGroveIds) {
    return _repository.saveSelectedImmiGroves(immiGroveIds);
  }
}
