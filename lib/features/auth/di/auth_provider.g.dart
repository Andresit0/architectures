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
    r'38db401ed61dca1327c8a9cb7928c648132f8704';

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
    r'09c3d3e9e11eaf53eb4d300b58caf28e0c8bcd63';

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

String _$authRepositoryHash() => r'd7c79f393058dee3299baa54e1a8b3af28f2404c';

@ProviderFor(localAuthRepository)
final localAuthRepositoryProvider = LocalAuthRepositoryProvider._();

final class LocalAuthRepositoryProvider
    extends
        $FunctionalProvider<
          ILocalAuthRepository,
          ILocalAuthRepository,
          ILocalAuthRepository
        >
    with $Provider<ILocalAuthRepository> {
  LocalAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAuthRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<ILocalAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ILocalAuthRepository create(Ref ref) {
    return localAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILocalAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILocalAuthRepository>(value),
    );
  }
}

String _$localAuthRepositoryHash() =>
    r'9b915e661d09542ff2cf7e8dd7c478c2f944f20c';

@ProviderFor(_saveSessionUseCase)
final _saveSessionUseCaseProvider = _SaveSessionUseCaseProvider._();

final class _SaveSessionUseCaseProvider
    extends
        $FunctionalProvider<
          SaveSessionUseCase,
          SaveSessionUseCase,
          SaveSessionUseCase
        >
    with $Provider<SaveSessionUseCase> {
  _SaveSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_saveSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_saveSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveSessionUseCase create(Ref ref) {
    return _saveSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveSessionUseCase>(value),
    );
  }
}

String _$_saveSessionUseCaseHash() =>
    r'f389f612ba181e5d03bc90e851dd6569d08a9cff';

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

String _$loginUseCaseHash() => r'80952ba6ab41ef70791be5e62e55656a24bf3b06';

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
    r'e96d294bb5fb9d6f98066a13c11fb916f2705bc4';

@ProviderFor(resetAccountUseCase)
final resetAccountUseCaseProvider = ResetAccountUseCaseProvider._();

final class ResetAccountUseCaseProvider
    extends
        $FunctionalProvider<
          ResetAccountUseCase,
          ResetAccountUseCase,
          ResetAccountUseCase
        >
    with $Provider<ResetAccountUseCase> {
  ResetAccountUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetAccountUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetAccountUseCase create(Ref ref) {
    return resetAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetAccountUseCase>(value),
    );
  }
}

String _$resetAccountUseCaseHash() =>
    r'c84b9efe438b85b87f20b67f7b1e852d1f60a519';

@ProviderFor(_refreshTokenUseCase)
final _refreshTokenUseCaseProvider = _RefreshTokenUseCaseProvider._();

final class _RefreshTokenUseCaseProvider
    extends
        $FunctionalProvider<
          RefreshTokenUseCase,
          RefreshTokenUseCase,
          RefreshTokenUseCase
        >
    with $Provider<RefreshTokenUseCase> {
  _RefreshTokenUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_refreshTokenUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_refreshTokenUseCaseHash();

  @$internal
  @override
  $ProviderElement<RefreshTokenUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RefreshTokenUseCase create(Ref ref) {
    return _refreshTokenUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshTokenUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshTokenUseCase>(value),
    );
  }
}

String _$_refreshTokenUseCaseHash() =>
    r'6b92a870eafc7208c2c1051c3e97621184e70510';

@ProviderFor(_credentialLoginUseCase)
final _credentialLoginUseCaseProvider = _CredentialLoginUseCaseProvider._();

final class _CredentialLoginUseCaseProvider
    extends
        $FunctionalProvider<
          CredentialLoginUseCase,
          CredentialLoginUseCase,
          CredentialLoginUseCase
        >
    with $Provider<CredentialLoginUseCase> {
  _CredentialLoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_credentialLoginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_credentialLoginUseCaseHash();

  @$internal
  @override
  $ProviderElement<CredentialLoginUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CredentialLoginUseCase create(Ref ref) {
    return _credentialLoginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CredentialLoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CredentialLoginUseCase>(value),
    );
  }
}

String _$_credentialLoginUseCaseHash() =>
    r'b4fb0bf1bdc66ade18339375a3e5f7a2d418bccb';

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
    r'6c21ef041b161df1fd9a579e9760615ef7fed483';

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

String _$handle401UseCaseHash() => r'2609f6ec3d787208bb4351cd7226a69fa66b5444';
