import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import 'package:clean_architecture_sdd_harness/core/network/_network.lib.dart';
import 'package:clean_architecture_sdd_harness/main.dart';

class _NoopAuthInterceptor implements IAuthInterceptorProvider {
  @override
  void setupAuthInterceptor(IDioWrapper dioWrapper) {}
}

Future<List<Object>> _bootAndCaptureErrors(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  final unhandled = <Object>[];
  await runZonedGuarded(() async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const TudesarrolladorApp()),
    );
    await tester.pump();
  }, (error, stackTrace) => unhandled.add(error));
  return unhandled;
}

void main() {
  testWidgets('boot fails fast when authInterceptorProvider is not bound', (
    tester,
  ) async {
    final unhandled = await _bootAndCaptureErrors(tester);

    expect(unhandled, isNotEmpty);
    expect(
      unhandled.first.toString(),
      contains('authInterceptorProvider must be overridden'),
    );
  });

  testWidgets('boot fails fast when appNavigatorProvider is not bound', (
    tester,
  ) async {
    final unhandled = await _bootAndCaptureErrors(
      tester,
      overrides: [
        authInterceptorProvider.overrideWith((ref) => _NoopAuthInterceptor()),
      ],
    );

    expect(unhandled, isNotEmpty);
    expect(
      unhandled.first.toString(),
      contains('appNavigatorProvider must be overridden'),
    );
  });
}
