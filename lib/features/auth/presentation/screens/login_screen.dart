import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/configs/_configs.lib.dart';
import '../../../../shared/widgets/_widgets.lib.dart' show LoadingIndicator;

import '../notifiers/auth_state.dart';
import '../notifiers/auth_notifier.dart';
import '../widgets/_widgets.lib.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

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
  bool _rememberMe = false;

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
    ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
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
                Icon(
                  Icons.account_circle,
                  size: 72,
                  color: CustomConfigs.appColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  CustomConfigs.vars.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CustomConfigs.appColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your credentials to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CustomConfigs.appColors.gray,
                  ),
                ),
                const SizedBox(height: 40),
                CustomAuthWidgets.createEmailFormField(
                  controller: _emailController,
                  hintText: 'Email',
                  focusNode: _emailFocus,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                CustomAuthWidgets.createPasswordFormField(
                  controller: _passwordController,
                  hintText: 'Password',
                  focusNode: _passwordFocus,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _rememberMe = v ?? false),
                    ),
                    const Text('Remember me'),
                  ],
                ),
                const SizedBox(height: 24),
                CustomAuthWidgets.createLoginButton(
                  text: 'Login',
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
