import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads a real font so golden tests render deterministically across
/// platforms (Linux CI and macOS local). Without this, text rendering
/// differs per OS and golden comparisons fail on one of the two.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontBytes = File('test/assets/Roboto-Regular.ttf').readAsBytesSync();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
  await loader.load();

  await testMain();
}
