// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sembast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sembast)
final sembastProvider = SembastProvider._();

final class SembastProvider
    extends $FunctionalProvider<ICpSembast, ICpSembast, ICpSembast>
    with $Provider<ICpSembast> {
  SembastProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sembastProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sembastHash();

  @$internal
  @override
  $ProviderElement<ICpSembast> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ICpSembast create(Ref ref) {
    return sembast(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICpSembast value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICpSembast>(value),
    );
  }
}

String _$sembastHash() => r'ff32c22704319d13682811adf019d2a221f78bd4';
