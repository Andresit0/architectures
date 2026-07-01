// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(httpService)
final httpServiceProvider = HttpServiceProvider._();

final class HttpServiceProvider
    extends $FunctionalProvider<ICpDio, ICpDio, ICpDio>
    with $Provider<ICpDio> {
  HttpServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpServiceHash();

  @$internal
  @override
  $ProviderElement<ICpDio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ICpDio create(Ref ref) {
    return httpService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICpDio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICpDio>(value),
    );
  }
}

String _$httpServiceHash() => r'1bf61811ff098bec2b10eef19d744d82a7c788cc';
