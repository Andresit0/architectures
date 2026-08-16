import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

class DeviceSecurityBlockedScreen extends StatelessWidget {
  const DeviceSecurityBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.gpp_bad_outlined,
                size: 48,
                color: AppColors.red,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deviceSecurityTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deviceSecurityMessage,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
