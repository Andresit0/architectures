import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/shared/exceptions/_exceptions.lib.dart';
import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

final appNavigatorProvider = Provider<IAppNavigator>(
  (ref) => throw SeamNotBoundException(
    'appNavigatorProvider must be overridden in the composition root '
    '(app/di/router/router_overrides.dart)',
  ),
);
