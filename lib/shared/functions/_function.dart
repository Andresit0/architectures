part of '_function.lib.dart';

class CustomFunction {
  static final ICpPathProvider pathProvider = CpPathProvider();
  static final ICpLogger logger = CpLogger();
  static final ICpFpdart fpdart = CpFpdart();
  static final IFailurePropagation failure = FailurePropagation();
  static final ICpFlutterSecureStorage flutterSecureStorage =
      CpFlutterSecureStorage();
  static final ICpEncrypt encrypt = CpEncrypt();
  static final IDatabaseKeyService databaseKeyService = DatabaseKeyService(
    storage: flutterSecureStorage,
  );
  static final ITokenService tokenService = TokenService(
    storage: flutterSecureStorage,
  );
  static final IInternetService internetService = InternetService();
  static final ICpDio dio = CpDio(internetService, tokenService);
  static final ICpDrift drift = CpDrift(AppDatabase(), databaseKeyService, encrypt);
  static final ICpSharePlus sharePlus = CpSharePlus();
  static late ICpGoRouter goRouter;
}
