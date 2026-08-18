import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/core/database/tables/lab_results_providers.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/datasources/i_lab_results_local_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/datasources/i_lab_results_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/repositories/i_lab_results_repository.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/load_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/domain/usecases/refresh_lab_results_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/datasources/lab_results_local_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/datasources/lab_results_remote_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/features/lab_results/infrastructure/repositories/lab_results_repository_impl.dart';

export 'package:clean_architecture_sdd_harness/core/services/charts/charts_providers.dart';
export 'package:clean_architecture_sdd_harness/core/services/charts/fl_chart_wrapper.dart'
    show ITrendChart;
export 'package:clean_architecture_sdd_harness/core/services/charts/models/trend_chart_data.dart';
export 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';

part 'lab_results_provider.g.dart';

@riverpod
ILabResultsRemoteDatasource _labResultsRemoteDatasource(Ref ref) =>
    LabResultsRemoteDatasourceImpl(
      dio: ref.watch(httpServiceProvider),
      appUries: ref.watch(appUriesProvider),
    );

@riverpod
ILabResultsLocalDatasource _labResultsLocalDatasource(Ref ref) =>
    LabResultsLocalDatasourceImpl(store: ref.watch(labResultsStoreProvider));

@riverpod
ILabResultsRepository labResultsRepository(Ref ref) => LabResultsRepositoryImpl(
  remoteDatasource: ref.watch(_labResultsRemoteDatasourceProvider),
  localDatasource: ref.watch(_labResultsLocalDatasourceProvider),
  logger: ref.watch(loggerProvider),
);

@riverpod
LoadLabResultsUseCase loadLabResultsUseCase(Ref ref) =>
    LoadLabResultsUseCase(repository: ref.watch(labResultsRepositoryProvider));

@riverpod
RefreshLabResultsUseCase refreshLabResultsUseCase(Ref ref) =>
    RefreshLabResultsUseCase(
      repository: ref.watch(labResultsRepositoryProvider),
    );
