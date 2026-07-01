import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part 'token_provider.g.dart';

@Riverpod(keepAlive: true)
ITokenService tokenService(Ref ref) => CustomFunction.tokenService;
