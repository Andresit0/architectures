import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:clean_architecture_sdd_harness/core/database/tables/clinical_history_providers.dart';
import 'package:clean_architecture_sdd_harness/core/network/api_endpoints.dart';
import 'package:clean_architecture_sdd_harness/core/network/dio/dio_providers.dart';
import 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/datasources/i_clinical_history_local_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/datasources/i_clinical_history_remote_datasource.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/repositories/i_clinical_history_repository.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/load_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/domain/usecases/refresh_clinical_histories_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/datasources/clinical_history_local_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/datasources/clinical_history_remote_datasource_impl.dart';
import 'package:clean_architecture_sdd_harness/features/clinical_history/infrastructure/repositories/clinical_history_repository_impl.dart';

export 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
export 'package:clean_architecture_sdd_harness/core/services/logging/logging_providers.dart';

part 'clinical_history_provider.g.dart';

@riverpod
IClinicalHistoryRemoteDatasource _clinicalHistoryRemoteDatasource(Ref ref) =>
    ClinicalHistoryRemoteDatasourceImpl(
      dio: ref.watch(httpServiceProvider),
      appUries: ref.watch(appUriesProvider),
    );

@riverpod
IClinicalHistoryLocalDatasource _clinicalHistoryLocalDatasource(Ref ref) =>
    ClinicalHistoryLocalDatasourceImpl(
      store: ref.watch(clinicalHistoryStoreProvider),
    );

@riverpod
IClinicalHistoryRepository clinicalHistoryRepository(Ref ref) =>
    ClinicalHistoryRepositoryImpl(
      remoteDatasource: ref.watch(_clinicalHistoryRemoteDatasourceProvider),
      localDatasource: ref.watch(_clinicalHistoryLocalDatasourceProvider),
      logger: ref.watch(loggerProvider),
    );

@riverpod
LoadClinicalHistoriesUseCase loadClinicalHistoriesUseCase(Ref ref) =>
    LoadClinicalHistoriesUseCase(
      repository: ref.watch(clinicalHistoryRepositoryProvider),
    );

@riverpod
RefreshClinicalHistoriesUseCase refreshClinicalHistoriesUseCase(Ref ref) =>
    RefreshClinicalHistoriesUseCase(
      repository: ref.watch(clinicalHistoryRepositoryProvider),
    );
