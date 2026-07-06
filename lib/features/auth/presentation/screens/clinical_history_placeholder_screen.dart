import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/configs/_configs.lib.dart';

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
              content: Text(next.message),
              backgroundColor: CustomConfigs.appColors.red,
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });
    final state = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical History'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: switch (state) {
          AuthLoaded(:final patient) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Clinical History'),
              const SizedBox(height: 16),
              Text('Welcome, ${patient.name}'),
            ],
          ),
          _ => const Text('Clinical History'),
        },
      ),
    );
  }
}
