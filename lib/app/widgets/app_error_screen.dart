import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/core/router/app_navigator_provider.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';
import 'package:clean_architecture_sdd_harness/shared/router/app_route.dart';

class AppErrorScreen extends ConsumerWidget {
  const AppErrorScreen({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.routeNotFound,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (error != null && kDebugMode)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SelectableText(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.gray),
                  ),
                ),
              TextButton(
                onPressed: () =>
                    ref.read(appNavigatorProvider).go(AppRoute.login),
                child: Text(l10n.routeNotFoundGoHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
