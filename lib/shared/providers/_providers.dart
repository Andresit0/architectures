part of '_providers.lib.dart';

class CustomProviders {
  static final token = tokenServiceProvider;
  static final dio = httpServiceProvider;
  static final sharePlus = sharePlusServiceProvider;
  static final goRouter = goRouterListenableProvider;
}
