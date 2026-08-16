// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_clinicalHistoryRemoteDatasource)
final _clinicalHistoryRemoteDatasourceProvider =
    _ClinicalHistoryRemoteDatasourceProvider._();

final class _ClinicalHistoryRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          IClinicalHistoryRemoteDatasource,
          IClinicalHistoryRemoteDatasource,
          IClinicalHistoryRemoteDatasource
        >
    with $Provider<IClinicalHistoryRemoteDatasource> {
  _ClinicalHistoryRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_clinicalHistoryRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_clinicalHistoryRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<IClinicalHistoryRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IClinicalHistoryRemoteDatasource create(Ref ref) {
    return _clinicalHistoryRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IClinicalHistoryRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IClinicalHistoryRemoteDatasource>(
        value,
      ),
    );
  }
}

String _$_clinicalHistoryRemoteDatasourceHash() =>
    r'f47c4055291c5eb370bdc8934f1d428900f5a736';

@ProviderFor(_clinicalHistoryLocalDatasource)
final _clinicalHistoryLocalDatasourceProvider =
    _ClinicalHistoryLocalDatasourceProvider._();

final class _ClinicalHistoryLocalDatasourceProvider
    extends
        $FunctionalProvider<
          IClinicalHistoryLocalDatasource,
          IClinicalHistoryLocalDatasource,
          IClinicalHistoryLocalDatasource
        >
    with $Provider<IClinicalHistoryLocalDatasource> {
  _ClinicalHistoryLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_clinicalHistoryLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_clinicalHistoryLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<IClinicalHistoryLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IClinicalHistoryLocalDatasource create(Ref ref) {
    return _clinicalHistoryLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IClinicalHistoryLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IClinicalHistoryLocalDatasource>(
        value,
      ),
    );
  }
}

String _$_clinicalHistoryLocalDatasourceHash() =>
    r'0557133102e9501818569334c3b8be280d581c60';

@ProviderFor(clinicalHistoryRepository)
final clinicalHistoryRepositoryProvider = ClinicalHistoryRepositoryProvider._();

final class ClinicalHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          IClinicalHistoryRepository,
          IClinicalHistoryRepository,
          IClinicalHistoryRepository
        >
    with $Provider<IClinicalHistoryRepository> {
  ClinicalHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clinicalHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clinicalHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<IClinicalHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IClinicalHistoryRepository create(Ref ref) {
    return clinicalHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IClinicalHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IClinicalHistoryRepository>(value),
    );
  }
}

String _$clinicalHistoryRepositoryHash() =>
    r'd1342041f2fab720a976048e91e1aa2615308ddf';

@ProviderFor(loadClinicalHistoriesUseCase)
final loadClinicalHistoriesUseCaseProvider =
    LoadClinicalHistoriesUseCaseProvider._();

final class LoadClinicalHistoriesUseCaseProvider
    extends
        $FunctionalProvider<
          LoadClinicalHistoriesUseCase,
          LoadClinicalHistoriesUseCase,
          LoadClinicalHistoriesUseCase
        >
    with $Provider<LoadClinicalHistoriesUseCase> {
  LoadClinicalHistoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadClinicalHistoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadClinicalHistoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadClinicalHistoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadClinicalHistoriesUseCase create(Ref ref) {
    return loadClinicalHistoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadClinicalHistoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadClinicalHistoriesUseCase>(value),
    );
  }
}

String _$loadClinicalHistoriesUseCaseHash() =>
    r'67884103da0d1fc658f6def11338def364405aeb';

@ProviderFor(refreshClinicalHistoriesUseCase)
final refreshClinicalHistoriesUseCaseProvider =
    RefreshClinicalHistoriesUseCaseProvider._();

final class RefreshClinicalHistoriesUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshClinicalHistoriesUseCase,
          RefreshClinicalHistoriesUseCase,
          RefreshClinicalHistoriesUseCase
        >
    with $Provider<RefreshClinicalHistoriesUseCase> {
  RefreshClinicalHistoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshClinicalHistoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshClinicalHistoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshClinicalHistoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshClinicalHistoriesUseCase create(Ref ref) {
    return refreshClinicalHistoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshClinicalHistoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshClinicalHistoriesUseCase>(
        value,
      ),
    );
  }
}

String _$refreshClinicalHistoriesUseCaseHash() =>
    r'28006a4b53301d86b14141e3063a674d04d8682f';
