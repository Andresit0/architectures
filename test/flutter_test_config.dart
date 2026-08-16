import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont('Roboto', 'test/assets/Roboto-Regular.ttf');
  await _loadFont('Roboto', 'test/assets/Roboto-Medium.ttf');
  await _loadFont('Roboto', 'test/assets/Roboto-Bold.ttf');
  await _loadFont('MaterialIcons', 'test/assets/MaterialIcons-Regular.otf');

  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenFileComparator(
      comparator.basedir.resolve('golden_test.dart'),
      tolerance: _kMaxDiffPercent,
    );
  }

  await testMain();
}

const double _kMaxDiffPercent = 0.03;

Future<void> _loadFont(String family, String path) async {
  final fontBytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(fontBytes.buffer)));
  await loader.load();
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile, {required this.tolerance})
    : assert(tolerance >= 0 && tolerance <= 1);

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }

    final String error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
