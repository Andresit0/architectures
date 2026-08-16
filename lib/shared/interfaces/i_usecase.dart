import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';

abstract interface class IUseCase<Input, Output> {
  Future<Result<Output>> call(Input input);
}

class NoParams {
  const NoParams();
}
