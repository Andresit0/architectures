import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_sdd_harness/shared/interceptors/_interceptors.lib.dart';

void main() {
  group('AuthInterceptor', () {
    test('should be created with readToken function', () {
      String? testToken;
      final interceptor = AuthInterceptor(() async => testToken);
      expect(interceptor, isA<AuthInterceptor>());
    });

    test('should use CustomInterceptors.auth factory', () {
      // Test que la factory crearInterceptor funciona
      final interceptor = CustomInterceptors.auth(() async => 'test_token');
      expect(interceptor, isA<AuthInterceptor>());
    });
  });
}
