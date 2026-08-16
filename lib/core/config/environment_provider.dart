import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_architecture_sdd_harness/core/config/app_environment.dart';

final environmentProvider = Provider<AppEnvironment>(
  (ref) => AppEnvironment.current,
);
