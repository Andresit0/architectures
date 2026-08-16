import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/shared/error/_error.lib.dart';
import '../../../../l10n/app_localizations.dart';

import '../notifiers/auth_state.dart';
import '../notifiers/auth_notifier.dart';

class ClinicalHistoryPlaceholderScreen extends ConsumerWidget {
  const ClinicalHistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                localizeError(next.error, AppLocalizations.of(context)!),
              ),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });
    final state = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clinicalHistory),
        actions: [
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
      body: Center(
        child: switch (state) {
          AuthLoaded(:final patient) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.clinicalHistory),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.welcomeUser(patient.name)),
            ],
          ),
          _ => Text(AppLocalizations.of(context)!.clinicalHistory),
        },
      ),
    );
  }
}
