import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_local_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockLocalAuthRepository extends Mock implements ILocalAuthRepository {}

class MockTokenStore extends Mock implements ITokenStore {}

class MockConnectivityChecker extends Mock implements IConnectivityChecker {}

class MockISecureStorageWrapper extends Mock implements ISecureStorageWrapper {}

class FakeSecureStorage implements ISecureStorageWrapper {
  final _values = <String, String>{};

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> delete({required String key}) async => _values.remove(key);

  @override
  Future<void> deleteAll() async => _values.clear();

  @override
  Future<bool> containsKey({required String key}) async =>
      _values.containsKey(key);
}

class FakeLogger implements ILogger {
  final infoMessages = <String>[];
  final errorMessages = <String>[];
  final errorTechnicalMessages = <Object?>[];

  @override
  void info(String message, {String? technicalMessage}) {
    infoMessages.add(message);
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    errorMessages.add(message);
    errorTechnicalMessages.add(technicalMessage);
  }
}
