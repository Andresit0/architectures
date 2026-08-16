import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/features/auth/presentation/notifiers/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFailure', () {
    test('carries an AppError', () {
      const error = NetworkError();
      const state = AuthFailure(error);
      expect(state.error, error);
      expect(state.error, isA<NetworkError>());
    });
  });
}
