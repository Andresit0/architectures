// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, implicit_dynamic_parameter, implicit_dynamic_type, implicit_dynamic_method, implicit_dynamic_variable

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider = AuthRemoteDatasourceProvider._();

final class AuthRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          IAuthRemoteDatasource,
          IAuthRemoteDatasource,
          IAuthRemoteDatasource
        >
    with $Provider<IAuthRemoteDatasource> {
  AuthRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<IAuthRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IAuthRemoteDatasource create(Ref ref) {
    return authRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRemoteDatasource>(value),
    );
  }
}

String _$authRemoteDatasourceHash() =>
    r'edecec428aed8deccdb31dd8d31b1c3b48e64586';

@ProviderFor(localAuthDatasource)
final localAuthDatasourceProvider = LocalAuthDatasourceProvider._();

final class LocalAuthDatasourceProvider
    extends
        $FunctionalProvider<
          ILocalAuthDatasource,
          ILocalAuthDatasource,
          ILocalAuthDatasource
        >
    with $Provider<ILocalAuthDatasource> {
  LocalAuthDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAuthDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAuthDatasourceHash();

  @$internal
  @override
  $ProviderElement<ILocalAuthDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ILocalAuthDatasource create(Ref ref) {
    return localAuthDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILocalAuthDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILocalAuthDatasource>(value),
    );
  }
}

String _$localAuthDatasourceHash() =>
    r'514334569f1ca205dac539eada58703c7ff7e7a6';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'f4bf3a2a7223b9124cdc245de18d22d2f95fb265';

@ProviderFor(loginUseCase)
final loginUseCaseProvider = LoginUseCaseProvider._();

final class LoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  LoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return loginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$loginUseCaseHash() => r'450cc7b21efd992d21470e2f412f0978f7ea09d8';

@ProviderFor(clearSessionUseCase)
final clearSessionUseCaseProvider = ClearSessionUseCaseProvider._();

final class ClearSessionUseCaseProvider
    extends
        $FunctionalProvider<
          ClearSessionUseCase,
          ClearSessionUseCase,
          ClearSessionUseCase
        >
    with $Provider<ClearSessionUseCase> {
  ClearSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearSessionUseCase create(Ref ref) {
    return clearSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearSessionUseCase>(value),
    );
  }
}

String _$clearSessionUseCaseHash() =>
    r'02ef21e6ad3de9a84d8d2fdfe262f52f7158d8c4';

@ProviderFor(refreshTokenUseCase)
final refreshTokenUseCaseProvider = RefreshTokenUseCaseProvider._();

final class RefreshTokenUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshTokenUseCase,
          RefreshTokenUseCase,
          RefreshTokenUseCase
        >
    with $Provider<RefreshTokenUseCase> {
  RefreshTokenUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshTokenUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshTokenUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshTokenUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshTokenUseCase create(Ref ref) {
    return refreshTokenUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshTokenUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshTokenUseCase>(value),
    );
  }
}

String _$refreshTokenUseCaseHash() =>
    r'f5fe01f1e28b2fa76a69250276d8850dc1393941';

@ProviderFor(restoreSessionUseCase)
final restoreSessionUseCaseProvider = RestoreSessionUseCaseProvider._();

final class RestoreSessionUseCaseProvider
    extends
        $FunctionalProvider<
          RestoreSessionUseCase,
          RestoreSessionUseCase,
          RestoreSessionUseCase
        >
    with $Provider<RestoreSessionUseCase> {
  RestoreSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<RestoreSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RestoreSessionUseCase create(Ref ref) {
    return restoreSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreSessionUseCase>(value),
    );
  }
}

String _$restoreSessionUseCaseHash() =>
    r'33d4086dc8c61a15209aeee69f10a88ebdbce73c';

@ProviderFor(handle401UseCase)
final handle401UseCaseProvider = Handle401UseCaseProvider._();

final class Handle401UseCaseProvider
    extends
        $FunctionalProvider<
          Handle401UseCase,
          Handle401UseCase,
          Handle401UseCase
        >
    with $Provider<Handle401UseCase> {
  Handle401UseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'handle401UseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$handle401UseCaseHash();

  @$internal
  @override
  $ProviderElement<Handle401UseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Handle401UseCase create(Ref ref) {
    return handle401UseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Handle401UseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Handle401UseCase>(value),
    );
  }
}

String _$handle401UseCaseHash() => r'88d0f98168546205435a111fa508af34e96a5e96';
