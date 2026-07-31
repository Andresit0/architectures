import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 4,
        color: AppColors.primary,
      ),
    );
  }
}
