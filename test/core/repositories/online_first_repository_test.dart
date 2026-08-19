import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/core/repositories/online_first_repository.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';

import '../../helpers/mocks.dart';

class _FakeOnlineFirstRepository extends OnlineFirstRepository<String> {
  _FakeOnlineFirstRepository({
    required super.logger,
    required this._remote,
    required this._local,
    this._cache,
    super.logTag = 'fake',
  });

  final Future<List<String>> Function() _remote;
  final Future<List<String>?> Function() _local;
  final Future<void> Function(List<String>)? _cache;

  @override
  Future<List<String>> remoteLoader() => _remote();

  @override
  Future<List<String>?> localLoader() => _local();

  @override
  Future<void> cacheWriter(List<String> data) =>
      _cache?.call(data) ?? Future.value();
}

void main() {
  late FakeLogger logger;

  setUp(() {
    logger = FakeLogger();
  });

  _FakeOnlineFirstRepository repo({
    required Future<List<String>> Function() remote,
    Future<List<String>?> Function()? local,
    Future<void> Function(List<String>)? cache,
  }) => _FakeOnlineFirstRepository(
    logger: logger,
    remote: remote,
    local: local ?? () async => null,
    cache: cache,
  );

  group('OnlineFirstRepository.load', () {
    test('remote success returns remote data and writes the cache', () async {
      final cacheWrites = <List<String>>[];
      final sut = repo(
        remote: () async => ['a', 'b'],
        cache: (data) async => cacheWrites.add(data),
      );

      final result = await sut.load();

      expect(result, isA<Success<List<String>>>());
      expect((result as Success<List<String>>).data, ['a', 'b']);
      expect(cacheWrites, [
        ['a', 'b'],
      ]);
      expect(logger.infoMessages, ['[fake] load origin=remote']);
    });

    test('empty local cache without network falls back to failure', () async {
      final sut = repo(
        remote: () async => throw const NoConnectionException(),
        local: () async => <String>[],
      );

      final result = await sut.load();

      expect(result, isA<Failure<List<String>>>());
      expect((result as Failure<List<String>>).error, isA<NetworkError>());
    });

    test('network failure falls back to the cached data', () async {
      final sut = repo(
        remote: () async => throw const NoConnectionException(),
        local: () async => ['cached'],
      );

      final result = await sut.load();

      expect(result, isA<Success<List<String>>>());
      expect((result as Success<List<String>>).data, ['cached']);
      expect(logger.infoMessages, ['[fake] load origin=cache']);
    });

    test('non-network remote error does NOT fall back to cache', () async {
      final sut = repo(
        remote: () async => throw const ApiException(500),
        local: () async => ['cached'],
      );

      final result = await sut.load();

      expect(result, isA<Failure<List<String>>>());
      expect((result as Failure<List<String>>).error, isA<ApiError>());
      expect(logger.infoMessages, ['[fake] load origin=remote']);
    });

    test(
      'a failed local read surfaces as Failure with its stack trace',
      () async {
        final sut = repo(
          remote: () async => throw const NoConnectionException(),
          local: () async => throw Exception('cache corrupt'),
        );

        final result = await sut.load();

        expect(result, isA<Failure<List<String>>>());
        final error = (result as Failure<List<String>>).error;
        expect(error, isA<UnexpectedError>());
        expect(error.technicalMessage, contains('cache corrupt'));
        expect(error.stackTrace, isNotNull);
      },
    );

    test(
      'cache write failure is best-effort and still returns remote data',
      () async {
        final sut = repo(
          remote: () async => ['a'],
          cache: (_) async => throw Exception('disk full'),
        );

        final result = await sut.load();

        expect(result, isA<Success<List<String>>>());
        expect((result as Success<List<String>>).data, ['a']);
        expect(logger.errorMessages, ['[fake] cache write failed (load)']);
        expect(logger.errorTechnicalMessages.first, contains('disk full'));
      },
    );
  });

  group('OnlineFirstRepository.refresh', () {
    test('refresh success returns remote data and writes the cache', () async {
      final cacheWrites = <List<String>>[];
      final sut = repo(
        remote: () async => ['fresh'],
        cache: (data) async => cacheWrites.add(data),
      );

      final result = await sut.refresh();

      expect(result, isA<Success<List<String>>>());
      expect((result as Success<List<String>>).data, ['fresh']);
      expect(cacheWrites, [
        ['fresh'],
      ]);
      expect(logger.infoMessages, ['[fake] refresh origin=remote']);
    });

    test('refresh failure does NOT fall back to cache', () async {
      final sut = repo(
        remote: () async => throw const NoConnectionException(),
        local: () async => ['cached'],
      );

      final result = await sut.refresh();

      expect(result, isA<Failure<List<String>>>());
      expect((result as Failure<List<String>>).error, isA<NetworkError>());
    });
  });
}
