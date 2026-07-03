part of '_widgets.lib.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const PasswordFormField({
    super.key,
    this.controller,
    this.hintText,
    this.onFieldSubmitted,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  final StreamController<bool> _showPassword = StreamController.broadcast();

  @override
  void dispose() {
    _showPassword.close();
    super.dispose();
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _showPassword.stream,
      builder: (context, visible) {
        return TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: !visible.data!,
          keyboardType: TextInputType.visiblePassword,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: _validate,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                visible.data! ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => _showPassword.add(!visible.data!),
            ),
            filled: true,
            fillColor: CustomConfigs.appColors.grayBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: CustomConfigs.appColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: CustomConfigs.appColors.red,
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
