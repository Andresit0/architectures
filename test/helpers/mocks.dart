import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_connectivity_checker.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/i_token_store.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockTokenStore extends Mock implements ITokenStore {}

class MockConnectivityChecker extends Mock implements IConnectivityChecker {}

class MockISecureStorageWrapper extends Mock implements ISecureStorageWrapper {}
