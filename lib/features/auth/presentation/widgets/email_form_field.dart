import 'package:flutter/material.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/features/auth/domain/value_objects/email.dart';
import 'package:clean_architecture_sdd_harness/l10n/app_localizations.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const EmailFormField({
    super.key,
    this.controller,
    this.hintText,
    this.onFieldSubmitted,
    this.onChanged,
    this.focusNode,
  });

  String? _validate(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.errorEmptyEmail;
    }
    if (!Email.result(value).isSuccess) {
      return l10n.errorInvalidEmail;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) => _validate(value, l10n),
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        hintText: hintText ?? l10n.emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: AppColors.grayBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}
