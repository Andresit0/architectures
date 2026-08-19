import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tokenStoreProvider', () {
    test('should provide an ITokenStore', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(tokenStoreProvider);
      expect(store, isA<ITokenStore>());
    });
  });

  group('tokenVerifierProvider', () {
    test('should provide an ITokenVerifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final verifier = container.read(tokenVerifierProvider);
      expect(verifier, isA<ITokenVerifier>());
    });
  });

  group('credentialStoreProvider', () {
    test('should provide an ICredentialStore', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final store = container.read(credentialStoreProvider);
      expect(store, isA<ICredentialStore>());
    });
  });

  group('jwtWrapperProvider', () {
    test('should provide an IJwtWrapper', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final jwt = container.read(jwtWrapperProvider);
      expect(jwt, isA<IJwtWrapper>());
    });
  });

  group('secureStorageProvider', () {
    test('should provide an ISecureStorageWrapper', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final storage = container.read(secureStorageProvider);
      expect(storage, isA<ISecureStorageWrapper>());
    });
  });
}
