import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part 'sembast_provider.g.dart';

@Riverpod(keepAlive: true)
ICpSembast sembast(Ref ref) => CustomFunction.sembast;
