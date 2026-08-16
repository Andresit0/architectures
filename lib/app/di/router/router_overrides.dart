import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import 'package:clean_architecture_sdd_harness/app/di/router/go_router_navigator.dart';
import 'package:clean_architecture_sdd_harness/app/di/router/router_provider.dart';
import 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';

List<Override> routerOverrides() => [
  appNavigatorProvider.overrideWith(
    (ref) => GoRouterNavigator(ref.watch(goRouterProvider)),
  ),
];
