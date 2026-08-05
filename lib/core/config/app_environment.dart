import 'dart:ui' show Locale;

sealed class AppEnvironment {
  const AppEnvironment();

  String get appName;
  String get host;
  int get port;
  /// Whether this is a production environment.
  /// Available for analytics, crash reporting, and feature flags.
  bool get isProduction;
  bool get useHttps => port == 443;
  List<String> get pinnedCertificates;
  Locale get defaultLocale;

  /// Reads certificate SHA-256 hashes from environment variables.
  /// Used by [StagingEnvironment] and [ProductionEnvironment] to avoid
  /// duplicating the same logic.
  static List<String> _readPinnedCertificates() {
    final hash1 = const String.fromEnvironment('PINNED_CERT_1');
    final hash2 = const String.fromEnvironment('PINNED_CERT_2');
    return [if (hash1.isNotEmpty) hash1, if (hash2.isNotEmpty) hash2];
  }

  static final AppEnvironment current = _select();

  static AppEnvironment _select() {
    return switch (
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev')
    ) {
      'staging' => const StagingEnvironment(),
      'production' || 'prod' => const ProductionEnvironment(),
      _ => const DevEnvironment(),
    };
  }
}

class DevEnvironment extends AppEnvironment {
  const DevEnvironment();
  @override String get appName => 'Clinical History (Dev)';
  @override
  String get host => const String.fromEnvironment('API_HOST', defaultValue: 'localhost');
  @override int get port => 5111;
  @override bool get isProduction => false;
  @override List<String> get pinnedCertificates => const [];
  @override Locale get defaultLocale => const Locale('es');
}

class StagingEnvironment extends AppEnvironment {
  const StagingEnvironment();
  @override String get appName => 'Clinical History (Staging)';
  @override String get host => 'staging.example.com';
  @override int get port => 443;
  @override bool get isProduction => false;
  @override
  List<String> get pinnedCertificates => AppEnvironment._readPinnedCertificates();
  @override Locale get defaultLocale => const Locale('es');
}

class ProductionEnvironment extends AppEnvironment {
  const ProductionEnvironment();
  @override String get appName => 'Clinical History';
  @override String get host => 'api.example.com';
  @override int get port => 443;
  @override bool get isProduction => true;
  @override
  List<String> get pinnedCertificates => AppEnvironment._readPinnedCertificates();
  @override Locale get defaultLocale => const Locale('es');
}
