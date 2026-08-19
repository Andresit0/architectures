import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/functions/online_first.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

abstract class OnlineFirstRepository<T> {
  const OnlineFirstRepository({required this._logger, required this._logTag});

  final ILogger _logger;
  final String _logTag;

  Future<List<T>> remoteLoader();

  Future<List<T>?> localLoader();

  Future<void> cacheWriter(List<T> data);

  Future<Result<List<T>>> load() async {
    final r = await fetchOrFallback(
      remote: remoteLoader,
      local: () async {
        final data = await localLoader();
        return data == null || data.isEmpty ? null : data;
      },
      onRemoteSuccess: (list) => _storeCacheBestEffort(list, 'load'),
    );
    _logger.info('[$_logTag] load origin=${r.origin.name}');
    return r.result;
  }

  Future<Result<List<T>>> refresh() async {
    final result = await guard(() async {
      final list = await remoteLoader();
      await _storeCacheBestEffort(list, 'refresh');
      return list;
    });
    _logger.info('[$_logTag] refresh origin=remote');
    return result;
  }

  Future<void> _storeCacheBestEffort(List<T> list, String context) async {
    try {
      await cacheWriter(list);
    } on Exception catch (e, st) {
      _logger.error(
        '[$_logTag] cache write failed ($context)',
        technicalMessage: e.toString(),
        stackTrace: st,
      );
    }
  }
}
