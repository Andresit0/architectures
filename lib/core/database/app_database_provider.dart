import 'package:clean_architecture_sdd_harness/core/database/app_database.dart';
import 'package:clean_architecture_sdd_harness/core/services/device/path_provider_provider.dart';
import 'package:clean_architecture_sdd_harness/core/database/i_app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<IAppDatabase>((ref) {
  final pathProvider = ref.watch(pathProviderProvider);
  return AppDatabase(pathProvider: pathProvider);
});
