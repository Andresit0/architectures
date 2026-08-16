import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_input.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class _MockRefreshTokenUseCase extends Mock
    implements IUseCase<RefreshTokenInput, TokenEntity> {}

class _MockCredentialLoginUseCase extends Mock
    implements IUseCase<NoParams, LoginResponseEntity?> {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(Email.raw('test@example.com'));
    registerFallbackValue(PasswordHash.raw('hash'));
    registerFallbackValue(const RefreshTokenInput(token: ''));
  });
  late MockTokenStore mockTokenStore;
  late MockConnectivityChecker mockConnectivity;
  late _MockRefreshTokenUseCase mockRefreshTokenUseCase;
  late _MockCredentialLoginUseCase mockCredentialLoginUseCase;
  late Handle401UseCase useCase;

  setUp(() {
    mockTokenStore = MockTokenStore();
    mockConnectivity = MockConnectivityChecker();
    mockRefreshTokenUseCase = _MockRefreshTokenUseCase();
    mockCredentialLoginUseCase = _MockCredentialLoginUseCase();
    when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
    useCase = Handle401UseCase(
      tokenStore: mockTokenStore,
      connectivityChecker: mockConnectivity,
      refreshTokenUseCase: mockRefreshTokenUseCase,
      credentialLoginUseCase: mockCredentialLoginUseCase,
    );
  });

  test('returns_RetryNoConnection_when_offline', () async {
    when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);

    final result = await useCase(NoParams());

    final retryResult = switch (result) {
      Success(data: final data) => data,
      Failure() => throw 'Expected Success(RetryNoConnection)',
    };
    expect(retryResult, isA<RetryNoConnection>());
    verifyNever(() => mockTokenStore.read());
  });

  test('returns_RetrySuccess_when_token_refreshed', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
    const tokenEntity = TokenEntity(key: 'new');
    when(
      () => mockRefreshTokenUseCase(any()),
    ).thenAnswer((_) async => const Success(tokenEntity));
    when(() => mockTokenStore.save('new')).thenAnswer((_) async {});

    final result = await useCase(NoParams());

    final retryResult = switch (result) {
      Success(data: final data) => data,
      Failure() => throw 'Expected Success',
    };
    expect(retryResult, isA<RetrySuccess>());
    expect((retryResult as RetrySuccess).token, 'new');
    verify(() => mockTokenStore.save('new')).called(1);
    verifyNever(() => mockCredentialLoginUseCase(any()));
  });

  test(
    'returns_RetrySuccess_with_reLogin_when_refresh_fails_and_creds_exist',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
      when(
        () => mockRefreshTokenUseCase(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));
      const patient = PatientEntity(name: 'test', id: '1');
      const token = TokenEntity(key: 'reLoginToken');
      const loginResponse = LoginResponseEntity(
        patient: patient,
        token: token,
        clinicalHistory: [],
      );
      when(() => mockCredentialLoginUseCase(any())).thenAnswer(
        (_) async => const Success<LoginResponseEntity?>(loginResponse),
      );
      when(() => mockTokenStore.save('reLoginToken')).thenAnswer((_) async {});

      final result = await useCase(NoParams());

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() => throw 'Expected Success',
      };
      expect(retryResult, isA<RetrySuccess>());
      expect((retryResult as RetrySuccess).token, 'reLoginToken');
      verify(() => mockTokenStore.save('reLoginToken')).called(1);
    },
  );

  test(
    'returns_RetryNoConnection_when_refresh_fails_with_network_error_and_no_creds',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
      when(
        () => mockRefreshTokenUseCase(any()),
      ).thenAnswer((_) async => const Failure(NetworkError()));
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));

      final result = await useCase(NoParams());

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() =>
          throw 'Expected Success(RetryNoConnection) — no logout on network error',
      };
      expect(retryResult, isA<RetryNoConnection>());
    },
  );

  test(
    'returns_RetryNoConnection_when_refresh_fails_with_server_unreachable_and_no_creds',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
      when(
        () => mockRefreshTokenUseCase(any()),
      ).thenAnswer((_) async => const Failure(ServerUnreachableError()));
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));

      final result = await useCase(NoParams());

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() => throw 'Expected Success(RetryNoConnection)',
      };
      expect(retryResult, isA<RetryNoConnection>());
    },
  );

  test(
    'returns_RetryFailed_when_refresh_fails_with_api_error_and_no_creds',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
      when(
        () => mockRefreshTokenUseCase(any()),
      ).thenAnswer((_) async => const Failure(ApiError()));
      when(
        () => mockCredentialLoginUseCase(any()),
      ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));

      final result = await useCase(NoParams());

      expect(result, isA<Failure>());
    },
  );

  test(
    'returns_RetrySuccess_with_reLogin_when_no_token_and_creds_exist',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => null);
      const patient = PatientEntity(name: 'test', id: '1');
      const token = TokenEntity(key: 'reLoginToken');
      const loginResponse = LoginResponseEntity(
        patient: patient,
        token: token,
        clinicalHistory: [],
      );
      when(() => mockCredentialLoginUseCase(any())).thenAnswer(
        (_) async => const Success<LoginResponseEntity?>(loginResponse),
      );
      when(() => mockTokenStore.save('reLoginToken')).thenAnswer((_) async {});

      final result = await useCase(NoParams());

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() =>
          throw 'Expected Success(RetrySuccess) via stored credentials',
      };
      expect(retryResult, isA<RetrySuccess>());
      expect((retryResult as RetrySuccess).token, 'reLoginToken');
      verify(() => mockTokenStore.save('reLoginToken')).called(1);
    },
  );

  test('returns_RetryFailed_when_no_token_and_no_creds', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => null);
    when(
      () => mockCredentialLoginUseCase(any()),
    ).thenAnswer((_) async => const Success<LoginResponseEntity?>(null));

    final result = await useCase(NoParams());

    expect(result, isA<Failure>());
  });

  test('returns_RetryNoConnection_when_connectivity_check_throws', () async {
    when(
      () => mockConnectivity.isConnected(),
    ).thenThrow(Exception('connectivity down'));

    final result = await useCase(NoParams());

    final retryResult = switch (result) {
      Success(data: final data) => data,
      Failure() =>
        throw 'Expected Success(RetryNoConnection) — no logout on connectivity failure',
    };
    expect(retryResult, isA<RetryNoConnection>());
    verifyNever(() => mockTokenStore.read());
    verifyNever(() => mockTokenStore.save(any()));
  });

  test(
    'returns_RetrySuccess_when_token_store_read_throws_but_creds_login_succeeds',
    () async {
      when(() => mockTokenStore.read()).thenThrow(Exception('storage down'));
      const patient = PatientEntity(name: 'test', id: '1');
      const token = TokenEntity(key: 'reLoginToken');
      const loginResponse = LoginResponseEntity(
        patient: patient,
        token: token,
        clinicalHistory: [],
      );
      when(() => mockCredentialLoginUseCase(any())).thenAnswer(
        (_) async => const Success<LoginResponseEntity?>(loginResponse),
      );
      when(() => mockTokenStore.save('reLoginToken')).thenAnswer((_) async {});

      final result = await useCase(NoParams());

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() =>
          throw 'Expected Success(RetrySuccess) via stored credentials',
      };
      expect(retryResult, isA<RetrySuccess>());
      expect((retryResult as RetrySuccess).token, 'reLoginToken');
    },
  );

  test('returns_RetrySuccess_when_token_save_throws_after_refresh', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
    const tokenEntity = TokenEntity(key: 'new');
    when(
      () => mockRefreshTokenUseCase(any()),
    ).thenAnswer((_) async => const Success(tokenEntity));
    when(() => mockTokenStore.save('new')).thenThrow(Exception('storage down'));

    final result = await useCase(NoParams());

    final retryResult = switch (result) {
      Success(data: final data) => data,
      Failure() => throw 'Expected Success(RetrySuccess) — best-effort save',
    };
    expect(retryResult, isA<RetrySuccess>());
    expect((retryResult as RetrySuccess).token, 'new');
  });
}
