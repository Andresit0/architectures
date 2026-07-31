import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'app/app_initializer.dart';
import 'app/di/router/router_provider.dart';
import 'core/config/app_environment.dart';
import 'core/services/_services.lib.dart';
import 'l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'features/auth/presentation/notifiers/auth_notifier.dart';

void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitializer.configurePlatform();
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
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
         defaultTargetPlatform == TargetPlatform.iOS)) {
      await AppInitializer.checkJailbreak(
        detection: ref.read(flutterJailbreakDetectionProvider),
      );
    }
    await ref.read(authProvider.notifier).restoreSession();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: LoadingIndicator()),
      );
    }

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppEnvironment.current.appName,
      debugShowCheckedModeBanner: false,
      locale: AppEnvironment.current.defaultLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.material3,
      routerConfig: router,
    );
  }
}
