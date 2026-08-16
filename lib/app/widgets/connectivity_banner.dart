import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/core/network/connectivity/connectivity_providers.dart';
import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(internetStatusProvider).value ?? true;
    if (online) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.offline,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.offlineBorder)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off,
                size: 18,
                color: AppColors.offlineText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.offlineBanner,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.offlineText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
