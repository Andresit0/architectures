import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../functions/_function.lib.dart';

part 'share_plus_provider.g.dart';

@Riverpod(keepAlive: true)
ICpSharePlus sharePlusService(Ref ref) => CustomFunction.sharePlus;
