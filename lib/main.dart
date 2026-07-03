import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'shared/configs/_configs.lib.dart';
import 'shared/functions/_function.lib.dart';
import 'shared/providers/_providers.lib.dart';
import 'shared/interceptors/_interceptors.lib.dart';
import 'shared/widgets/_widgets.lib.dart';
import 'features/auth/presentation/notifiers/auth_notifier.dart';

void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ProviderScope(overrides: overrides, child: const TudesarrolladorApp()),
  );
}

class TudesarrolladorApp extends ConsumerStatefulWidget {
  const TudesarrolladorApp({super.key});

  @override
  ConsumerState<TudesarrolladorApp> createState() => _TudesarrolladorAppState();
}

class _TudesarrolladorAppState extends ConsumerState<TudesarrolladorApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    AuthInterceptor.onForceLogout = () {
      ref.read(CustomProviders.goRouter).update(false);
    };
    await ref.read(authProvider.notifier).restoreSession();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: CustomWidgets.createLoadingIndicator),
      );
    }

    return MaterialApp.router(
      title: CustomConfigs.vars.appName,
      debugShowCheckedModeBanner: false,
      theme: CustomConfigs.theme.material3,
      routerConfig: CpGoRouter.create(
        routes: CustomConfigs.routes.goRouter,
        refreshListenable: ref.read(CustomProviders.goRouter),
      ),
    );
  }
}
