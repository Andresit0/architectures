// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tokenService)
final tokenServiceProvider = TokenServiceProvider._();

final class TokenServiceProvider
    extends $FunctionalProvider<ITokenService, ITokenService, ITokenService>
    with $Provider<ITokenService> {
  TokenServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenServiceHash();

  @$internal
  @override
  $ProviderElement<ITokenService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ITokenService create(Ref ref) {
    return tokenService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ITokenService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ITokenService>(value),
    );
  }
}

String _$tokenServiceHash() => r'0e61b134da0172323e2c12d611e6601d49c79dc4';
