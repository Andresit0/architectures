import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'app/app_initializer.dart';
import 'app/di/network/dio_overrides.dart';
import 'app/di/router/router_overrides.dart';
import 'app/di/router/router_provider.dart';
import 'app/widgets/device_security_blocked_screen.dart';
import 'core/config/environment_provider.dart';
import 'core/network/dio/dio_providers.dart';
import 'core/router/app_navigator_provider.dart';
import 'core/services/_services.lib.dart';
import 'l10n/app_localizations.dart';
import 'l10n/error_localizer.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_theme.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import 'package:clean_architecture_sdd_harness/app/widgets/connectivity_banner.dart';
import 'features/auth/presentation/notifiers/auth_notifier.dart';
import 'features/auth/presentation/notifiers/auth_state.dart';

void main({List<Override> overrides = const []}) {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitializer.configurePlatform();
  runApp(
    ProviderScope(
      overrides: [...dioOverrides(), ...routerOverrides(), ...overrides],
      child: const TudesarrolladorApp(),
    ),
  );
}

class TudesarrolladorApp extends ConsumerStatefulWidget {
  const TudesarrolladorApp({super.key});

  @override
  ConsumerState<TudesarrolladorApp> createState() => _TudesarrolladorAppState();
}

class _TudesarrolladorAppState extends ConsumerState<TudesarrolladorApp> {
  bool _initialized = false;
  bool _securityBlocked = false;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _assertDiSeamsBound();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      final result = await AppInitializer.checkJailbreak(
        detection: ref.read(flutterJailbreakDetectionProvider),
      );
      await result.fold<Future<void>>(
        onSuccess: (_) async {},
        onFailure: (error) async {
          ref
              .read(loggerProvider)
              .error(
                '[app] security check failed',
                technicalMessage: error.technicalMessage,
                stackTrace: error.stackTrace,
              );
          if (error is DeviceSecurityError && mounted) {
            setState(() => _securityBlocked = true);
          }
        },
      );
      if (_securityBlocked) return;
    }
    try {
      await ref.read(authProvider.notifier).restoreSession();
    } catch (e, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            '[app] boot failed',
            technicalMessage: e.toString(),
            stackTrace: stackTrace,
          );
    }
    if (mounted) setState(() => _initialized = true);
  }

  void _assertDiSeamsBound() {
    ref.read(authInterceptorProvider);
    ref.read(appNavigatorProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_securityBlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DeviceSecurityBlockedScreen(),
      );
    }

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthFailure) {
        final messenger = _scaffoldMessengerKey.currentState;
        if (messenger == null) return;
        final l10n = AppLocalizations.of(messenger.context)!;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(localizeError(next.error, l10n)),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: LoadingIndicator()),
      );
    }

    final router = ref.watch(goRouterProvider);
    final env = ref.watch(environmentProvider);

    return MaterialApp.router(
      title: lookupAppLocalizations(env.defaultLocale).appTitle,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      locale: env.defaultLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.material3,
      routerConfig: router,
      builder: (context, child) => Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: child!),
        ],
      ),
    );
  }
}
