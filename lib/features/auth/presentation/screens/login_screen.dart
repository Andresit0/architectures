import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clean_architecture_sdd_harness/design_system/theme/app_colors.dart';
import 'package:clean_architecture_sdd_harness/design_system/_design.lib.dart';
import '../../../../l10n/app_localizations.dart';

import '../notifiers/auth_notifier.dart';
import '../notifiers/remember_me_provider.dart';
import '../notifiers/auth_state.dart';
import '../widgets/email_form_field.dart';
import '../widgets/login_button.dart';
import '../widgets/password_form_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    if (state is AuthLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _LoginForm()),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .login(
          _emailController.text.trim(),
          _passwordController.text,
          rememberMe: ref.read(rememberMeProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider) is AuthLoading;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.account_circle, size: 72, color: AppColors.primary),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.loginTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                ),
                const SizedBox(height: 40),
                EmailFormField(
                  controller: _emailController,
                  hintText: AppLocalizations.of(context)!.emailHint,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                PasswordFormField(
                  controller: _passwordController,
                  hintText: AppLocalizations.of(context)!.passwordHint,
                  focusNode: _passwordFocus,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: ref.watch(rememberMeProvider),
                      onChanged: isLoading
                          ? null
                          : (v) => ref
                                .read(rememberMeProvider.notifier)
                                .set(v ?? false),
                    ),
                    Text(AppLocalizations.of(context)!.rememberMe),
                  ],
                ),
                const SizedBox(height: 24),
                LoginButton(
                  text: AppLocalizations.of(context)!.loginButton,
                  onPressed: isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
