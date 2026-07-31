import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SecureStorageWrapper cpSecureStorage;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    cpSecureStorage = SecureStorageWrapper(storage: mockStorage);
  });

  group('SecureStorageWrapper', () {
    test('implements ISecureStorageWrapper', () {
      expect(cpSecureStorage, isA<ISecureStorageWrapper>());
    });

    group('read', () {
      test('delegates to FlutterSecureStorage.read and returns value', () async {
        when(
          () => mockStorage.read(key: 'my_key'),
        ).thenAnswer((_) async => 'my_value');

        final result = await cpSecureStorage.read(key: 'my_key');

        expect(result, 'my_value');
        verify(() => mockStorage.read(key: 'my_key')).called(1);
      });

      test('returns null when key not found', () async {
        when(
          () => mockStorage.read(key: 'missing_key'),
        ).thenAnswer((_) async => null);

        final result = await cpSecureStorage.read(key: 'missing_key');

        expect(result, isNull);
      });
    });

    group('write', () {
      test('delegates to FlutterSecureStorage.write', () async {
        when(
          () => mockStorage.write(key: 'my_key', value: 'my_value'),
        ).thenAnswer((_) async {});

        await cpSecureStorage.write(key: 'my_key', value: 'my_value');

        verify(
          () => mockStorage.write(key: 'my_key', value: 'my_value'),
        ).called(1);
      });
    });

    group('delete', () {
      test('delegates to FlutterSecureStorage.delete', () async {
        when(
          () => mockStorage.delete(key: 'my_key'),
        ).thenAnswer((_) async {});

        await cpSecureStorage.delete(key: 'my_key');

        verify(() => mockStorage.delete(key: 'my_key')).called(1);
      });
    });

    group('containsKey', () {
      test('returns true when key exists', () async {
        when(
          () => mockStorage.containsKey(key: 'my_key'),
        ).thenAnswer((_) async => true);

        final result = await cpSecureStorage.containsKey(key: 'my_key');

        expect(result, isTrue);
        verify(() => mockStorage.containsKey(key: 'my_key')).called(1);
      });

      test('returns false when key does not exist', () async {
        when(
          () => mockStorage.containsKey(key: 'missing_key'),
        ).thenAnswer((_) async => false);

        final result = await cpSecureStorage.containsKey(key: 'missing_key');

        expect(result, isFalse);
      });
    });
  });
}
