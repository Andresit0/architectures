import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
ICpDio httpService(Ref ref) => CustomFunction.dio;
