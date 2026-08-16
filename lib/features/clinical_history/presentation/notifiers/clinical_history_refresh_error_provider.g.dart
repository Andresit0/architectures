// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_refresh_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClinicalHistoryRefreshError)
final clinicalHistoryRefreshErrorProvider =
    ClinicalHistoryRefreshErrorProvider._();

final class ClinicalHistoryRefreshErrorProvider
    extends $NotifierProvider<ClinicalHistoryRefreshError, AppError?> {
  ClinicalHistoryRefreshErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clinicalHistoryRefreshErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clinicalHistoryRefreshErrorHash();

  @$internal
  @override
  ClinicalHistoryRefreshError create() => ClinicalHistoryRefreshError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppError? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppError?>(value),
    );
  }
}

String _$clinicalHistoryRefreshErrorHash() =>
    r'429953b17d1980d9549edf224ee1712b2fdbb5b7';

abstract class _$ClinicalHistoryRefreshError extends $Notifier<AppError?> {
  AppError? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppError?, AppError?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppError?, AppError?>,
              AppError?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
