import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockTokenStore extends Mock implements ITokenStore {}

class MockTokenVerifier extends Mock implements ITokenVerifier {}

class MockConnectivityChecker extends Mock implements IConnectivityChecker {}

class MockIDioWrapper extends Mock implements IDioWrapper {}

class MockISecureStorageWrapper extends Mock implements ISecureStorageWrapper {}
