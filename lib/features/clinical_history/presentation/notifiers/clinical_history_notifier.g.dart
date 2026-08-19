// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'clinical_history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClinicalHistoryNotifier)
final clinicalHistoryProvider = ClinicalHistoryNotifierProvider._();

final class ClinicalHistoryNotifierProvider
    extends $NotifierProvider<ClinicalHistoryNotifier, ClinicalHistoryState> {
  ClinicalHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clinicalHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clinicalHistoryNotifierHash();

  @$internal
  @override
  ClinicalHistoryNotifier create() => ClinicalHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClinicalHistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClinicalHistoryState>(value),
    );
  }
}

String _$clinicalHistoryNotifierHash() =>
    r'865d5b4295971138c744d1115e7af0bdbc38f183';

abstract class _$ClinicalHistoryNotifier
    extends $Notifier<ClinicalHistoryState> {
  ClinicalHistoryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ClinicalHistoryState, ClinicalHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClinicalHistoryState, ClinicalHistoryState>,
              ClinicalHistoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
