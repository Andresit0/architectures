import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/_function.lib.dart';
import 'package:mocktail/mocktail.dart';

class MockICpFlutterSecureStorage extends Mock
    implements ICpFlutterSecureStorage {}

class FakeTokenService extends Fake implements ITokenService {}

void main() {
  late TokenService tokenService;
  late MockICpFlutterSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(FakeTokenService());
  });

  setUp(() {
    mockStorage = MockICpFlutterSecureStorage();
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});
    tokenService = TokenService(storage: mockStorage);
  });

  group('TokenService', () {
    group('save', () {
      test('should save token to storage and cache', () async {
        await tokenService.save('test_token');

        verify(
          () => mockStorage.write(
            key: 'tudesarrollador_auth_token',
            value: 'test_token',
          ),
        ).called(1);
      });
    });

    group('read', () {
      test('should return cached token if available', () async {
        tokenService = TokenService(storage: mockStorage);
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'cached_token');

        final result = await tokenService.read();

        expect(result, 'cached_token');
      });
    });

    group('delete', () {
      test('should delete token from storage and clear cache', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'test_token');
        tokenService = TokenService(storage: mockStorage);

        await tokenService.delete();

        verify(
          () => mockStorage.delete(key: 'tudesarrollador_auth_token'),
        ).called(1);
      });
    });

    group('decodeJwtPayload', () {
      test('should return null for invalid token', () {
        final result = tokenService.decodeJwtPayload('invalid_token');
        expect(result, isNull);
      });

      test('should return null for token with invalid base64', () {
        final result = tokenService.decodeJwtPayload('abc.def.ghi');
        expect(result, isNull);
      });
    });

    group('isTokenExpired', () {
      test('should return true for expired token', () async {
        final expiredToken =
            'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEwfQ.signature';
        final result = await tokenService.isTokenExpired(expiredToken);

        expect(result, isTrue);
      });

      test('should return false for token without exp claim', () async {
        final token =
            'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature';
        final result = await tokenService.isTokenExpired(token);

        expect(result, isFalse);
      });
    });
  });
}
