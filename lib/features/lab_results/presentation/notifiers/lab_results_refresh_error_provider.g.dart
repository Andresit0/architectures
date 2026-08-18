// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_results_refresh_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LabResultsRefreshError)
final labResultsRefreshErrorProvider = LabResultsRefreshErrorProvider._();

final class LabResultsRefreshErrorProvider
    extends $NotifierProvider<LabResultsRefreshError, AppError?> {
  LabResultsRefreshErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labResultsRefreshErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labResultsRefreshErrorHash();

  @$internal
  @override
  LabResultsRefreshError create() => LabResultsRefreshError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppError? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppError?>(value),
    );
  }
}

String _$labResultsRefreshErrorHash() =>
    r'b88cbe7edd257ace47e3d04753cb4bdf9f354a33';

abstract class _$LabResultsRefreshError extends $Notifier<AppError?> {
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
