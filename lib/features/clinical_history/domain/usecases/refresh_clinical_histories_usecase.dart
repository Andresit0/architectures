import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class RefreshClinicalHistoriesUseCase
    implements IUseCase<NoParams, List<ClinicalHistoryEntity>> {
  const RefreshClinicalHistoriesUseCase({required this._repository});

  final IClinicalHistoryRepository _repository;

  @override
  Future<Result<List<ClinicalHistoryEntity>>> call(NoParams input) =>
      _repository.refreshClinicalHistories();
}
