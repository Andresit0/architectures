// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_results_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LabResultsNotifier)
final labResultsProvider = LabResultsNotifierProvider._();

final class LabResultsNotifierProvider
    extends $NotifierProvider<LabResultsNotifier, LabResultsState> {
  LabResultsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labResultsNotifierHash();

  @$internal
  @override
  LabResultsNotifier create() => LabResultsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LabResultsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LabResultsState>(value),
    );
  }
}

String _$labResultsNotifierHash() =>
    r'9119ccdc7cb9184409786a3a6ae28628db651a59';

abstract class _$LabResultsNotifier extends $Notifier<LabResultsState> {
  LabResultsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LabResultsState, LabResultsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LabResultsState, LabResultsState>,
              LabResultsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
