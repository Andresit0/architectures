import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/shared/interfaces/_interfaces.lib.dart';

import 'dev_logger.dart';

final loggerProvider = Provider<ILogger>((ref) => const DevLogger());
