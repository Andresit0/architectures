import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<ISecureStorageWrapper>(
  (ref) => const SecureStorageWrapper(),
);

final jwtWrapperProvider = Provider<IJwtWrapper>((ref) => const JwtWrapper());

final tokenStoreProvider = Provider<ITokenStore>(
  (ref) => SecureTokenStore(storage: ref.watch(secureStorageProvider)),
);

final tokenVerifierProvider = Provider<ITokenVerifier>(
  (ref) => JwtTokenExpiryChecker(jwtWrapper: ref.watch(jwtWrapperProvider)),
);

final credentialStoreProvider = Provider<ICredentialStore>(
  (ref) => SecureCredentialStore(storage: ref.watch(secureStorageProvider)),
);
