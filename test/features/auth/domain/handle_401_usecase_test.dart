import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_credential_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/token_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/entities/login_response_entity.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/handle_401_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/password_hash.dart';
import 'package:clean_architecture_sdd_harness/shared/models/patient/patient_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class _MockCredentialStore extends Mock implements ICredentialStore {}

class _MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(Email.tryCreate('test@example.com')!);
    registerFallbackValue(PasswordHash.tryCreate('hash')!);
  });
  late MockTokenStore mockTokenStore;
  late MockConnectivityChecker mockConnectivity;
  late MockAuthRepository mockAuthRepository;
  late _MockCredentialStore mockCredentialStore;
  late _MockRefreshTokenUseCase mockRefreshTokenUseCase;
  late Handle401UseCase useCase;

  setUp(() {
    mockTokenStore = MockTokenStore();
    mockConnectivity = MockConnectivityChecker();
    mockAuthRepository = MockAuthRepository();
    mockCredentialStore = _MockCredentialStore();
    mockRefreshTokenUseCase = _MockRefreshTokenUseCase();
    when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
    useCase = Handle401UseCase(
      tokenStore: mockTokenStore,
      connectivityChecker: mockConnectivity,
      repository: mockAuthRepository,
      credentialStore: mockCredentialStore,
      refreshTokenUseCase: mockRefreshTokenUseCase,
    );
  });

  test('returns_RetryNoConnection_when_offline', () async {
    when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);

    final result = await useCase();

    expect(result, isA<Failure>());
    verifyNever(() => mockTokenStore.read());
  });

  test('returns_RetrySuccess_when_token_refreshed', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
    const tokenEntity = TokenEntity(type: 'bearer', key: 'new');
    when(
      () => mockRefreshTokenUseCase(token: 'old'),
    ).thenAnswer((_) async => const Success(tokenEntity));
    when(() => mockTokenStore.save('new')).thenAnswer((_) async {});

    final result = await useCase();

    final retryResult = switch (result) {
      Success(data: final data) => data,
      Failure() => throw 'Expected Success',
    };
    expect(retryResult, isA<RetrySuccess>());
    expect((retryResult as RetrySuccess).token, 'new');
    verify(() => mockTokenStore.save('new')).called(1);
    verifyNever(
      () => mockAuthRepository.login(
        email: any(named: 'email'),
        passwordHash: any(named: 'passwordHash'),
      ),
    );
  });

  test(
    'returns_RetrySuccess_with_reLogin_when_refresh_fails_and_creds_exist',
    () async {
      when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
      when(
        () => mockRefreshTokenUseCase(token: 'old'),
      ).thenAnswer((_) async => const Failure(NetworkError.technical()));
      when(() => mockCredentialStore.readCredentials()).thenAnswer(
        (_) async => (email: 'test@example.com', passwordHash: 'hash'),
      );
      const patient = PatientEntity(name: 'test', id: '1');
      const token = TokenEntity(type: 'bearer', key: 'reLoginToken');
      const loginResponse = LoginResponseEntity(
        patient: patient,
        token: token,
        clinicalHistory: [],
      );
      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          passwordHash: any(named: 'passwordHash'),
        ),
      ).thenAnswer((_) async => const Success(loginResponse));
      when(() => mockTokenStore.save('reLoginToken')).thenAnswer((_) async {});

      final result = await useCase();

      final retryResult = switch (result) {
        Success(data: final data) => data,
        Failure() => throw 'Expected Success',
      };
      expect(retryResult, isA<RetrySuccess>());
      expect((retryResult as RetrySuccess).token, 'reLoginToken');
      verify(() => mockTokenStore.save('reLoginToken')).called(1);
    },
  );

  test('returns_RetryFailed_when_refresh_fails_and_no_creds', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => 'old');
    when(
      () => mockRefreshTokenUseCase(token: 'old'),
    ).thenAnswer((_) async => const Failure(NetworkError.technical()));
    when(
      () => mockCredentialStore.readCredentials(),
    ).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isA<Failure>());
  });

  test('returns_RetryFailed_when_no_token', () async {
    when(() => mockTokenStore.read()).thenAnswer((_) async => null);

    final result = await useCase();

    expect(result, isA<Failure>());
  });
}
