// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'lab_results_period_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LabResultsPeriod)
final labResultsPeriodProvider = LabResultsPeriodProvider._();

final class LabResultsPeriodProvider
    extends $NotifierProvider<LabResultsPeriod, Period> {
  LabResultsPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'labResultsPeriodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$labResultsPeriodHash();

  @$internal
  @override
  LabResultsPeriod create() => LabResultsPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Period value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Period>(value),
    );
  }
}

String _$labResultsPeriodHash() => r'93ca20ce90349f2dadcf5bf44586ba0efc183d78';

abstract class _$LabResultsPeriod extends $Notifier<Period> {
  Period build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Period, Period>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Period, Period>,
              Period,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
