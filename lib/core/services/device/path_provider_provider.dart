import 'package:clean_architecture_sdd_harness/core/services/_services.lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pathProviderProvider = Provider<IPathProviderWrapper>(
  (ref) => PathProviderWrapper(),
);
