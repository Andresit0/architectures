import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

abstract interface class ICertificatePinner {
  void apply(Dio dio);
}

class CertificatePinner implements ICertificatePinner {
  final List<String> pinnedCertificates;
  final bool isReleaseMode;
  final bool enforcePinning;

  const CertificatePinner({
    this.pinnedCertificates = const [],
    this.isReleaseMode = kReleaseMode,
    this.enforcePinning = false,
  });

  @override
  void apply(Dio dio) {
    if (isReleaseMode && enforcePinning && pinnedCertificates.isEmpty) {
      throw StateError(
        'Certificate pinning requires pinned certificates. '
        'Add SHA-256 hashes to the active environment pinnedCertificates '
        'before deploying to production.',
      );
    }
    try {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.validateCertificate = (cert, host, port) {
          if (!isReleaseMode && pinnedCertificates.isEmpty) return true;
          if (cert == null) return false;
          final sha = sha256.convert(cert.der);
          return pinnedCertificates.contains(sha.toString());
        };
      }
    } catch (_) {}
  }
}
