part of '_function.lib.dart';

class CustomFunction {
  static final ICpPathProvider pathProvider = CpPathProvider();
  static final ICpLogger logger = CpLogger();
  static final ICpFpdart fpdart = CpFpdart();
  static final IFailurePropagation failure = FailurePropagation();
  static final ICpFlutterSecureStorage flutterSecureStorage =
      CpFlutterSecureStorage();
  static final ICpEncrypt encrypt = CpEncrypt();
  static final ITokenService tokenService = TokenService(
    storage: flutterSecureStorage,
  );
  static final IInternetService internetService = InternetService(
    strategy: kIsWeb
        ? HttpReachability(
            dio: Dio(),
            baseUri: Uri(
              scheme: 'http',
              host: CustomConfigs.vars.host,
              port: CustomConfigs.vars.port,
            ),
          )
        : NativeSocketReachability(
            host: CustomConfigs.uries.host,
            port: CustomConfigs.uries.port,
          ),
  );
  static final ICpDio dio = CpDio(internetService, tokenService);
  static final ICpSembast sembast = CpSembast();
  static final ICpSharePlus sharePlus = CpSharePlus();
  static final ICpCrypto crypto = CpCrypto();
  static late ICpGoRouter goRouter;
}
