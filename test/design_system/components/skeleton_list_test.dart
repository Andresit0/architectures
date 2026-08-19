import 'package:clean_architecture_sdd_harness/design_system/components/skeleton_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _skeletonItems() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith('skeletonItem'),
);

void main() {
  group('SkeletonList', () {
    testWidgets('renders the requested number of skeleton items', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonList(itemCount: 4))),
      );
      await tester.pump();

      expect(_skeletonItems(), findsNWidgets(4));
    });

    testWidgets('defaults to four skeleton items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonList())),
      );
      await tester.pump();

      expect(_skeletonItems(), findsNWidgets(4));
    });
  });
}
