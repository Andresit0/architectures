// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_plus_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharePlusService)
final sharePlusServiceProvider = SharePlusServiceProvider._();

final class SharePlusServiceProvider
    extends $FunctionalProvider<ICpSharePlus, ICpSharePlus, ICpSharePlus>
    with $Provider<ICpSharePlus> {
  SharePlusServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharePlusServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharePlusServiceHash();

  @$internal
  @override
  $ProviderElement<ICpSharePlus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ICpSharePlus create(Ref ref) {
    return sharePlusService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICpSharePlus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICpSharePlus>(value),
    );
  }
}

String _$sharePlusServiceHash() => r'f928c5c1e005827539cfd998102fc40531fe5f16';
