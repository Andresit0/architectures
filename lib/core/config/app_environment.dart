import 'dart:ui' show Locale;

sealed class AppEnvironment {
  const AppEnvironment();

  String get host;
  int get port;
  bool get useHttps => resolveUseHttps(
    port,
    const bool.fromEnvironment('API_USE_HTTPS', defaultValue: false),
  );
  List<String> get pinnedCertificates;
  bool get requirePinnedCertificates;
  Locale get defaultLocale;

  static List<String> _readPinnedCertificates() {
    final hash1 = const String.fromEnvironment('PINNED_CERT_1');
    final hash2 = const String.fromEnvironment('PINNED_CERT_2');
    return [if (hash1.isNotEmpty) hash1, if (hash2.isNotEmpty) hash2];
  }

  static AppEnvironment selectEnvironment() {
    return switch (const String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    )) {
      'staging' => const StagingEnvironment(),
      'production' || 'prod' => const ProductionEnvironment(),
      _ => const DevEnvironment(),
    };
  }
}

bool resolveUseHttps(int port, bool forcedHttps) => port == 443 || forcedHttps;

class DevEnvironment extends AppEnvironment {
  const DevEnvironment();
  @override
  String get host =>
      const String.fromEnvironment('API_HOST', defaultValue: 'localhost');
  @override
  int get port => 5111;
  @override
  List<String> get pinnedCertificates => const [];
  @override
  bool get requirePinnedCertificates => false;
  @override
  Locale get defaultLocale => const Locale('es');
}

class StagingEnvironment extends AppEnvironment {
  const StagingEnvironment();
  @override
  String get host => 'staging.example.com';
  @override
  int get port => 443;
  @override
  List<String> get pinnedCertificates =>
      AppEnvironment._readPinnedCertificates();
  @override
  bool get requirePinnedCertificates => true;
  @override
  Locale get defaultLocale => const Locale('es');
}

class ProductionEnvironment extends AppEnvironment {
  const ProductionEnvironment();
  @override
  String get host => 'api.example.com';
  @override
  int get port => 443;
  @override
  List<String> get pinnedCertificates =>
      AppEnvironment._readPinnedCertificates();
  @override
  bool get requirePinnedCertificates => true;
  @override
  Locale get defaultLocale => const Locale('es');
}
