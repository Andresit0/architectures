import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

final appNavigatorProvider = Provider<IAppNavigator>(
  (ref) => throw UnimplementedError(
    'appNavigatorProvider must be overridden in the composition root '
    '(app/di/router/router_overrides.dart)',
  ),
);
