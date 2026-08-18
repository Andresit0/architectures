import 'package:clean_architecture_sdd_harness/features/lab_results/domain/repositories/i_lab_results_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/models/_models.lib.dart';

class LoadLabResultsUseCase
    implements IUseCase<NoParams, List<LabResultEntity>> {
  const LoadLabResultsUseCase({required this._repository});

  final ILabResultsRepository _repository;

  @override
  Future<Result<List<LabResultEntity>>> call(NoParams input) =>
      _repository.loadLabResults();
}
