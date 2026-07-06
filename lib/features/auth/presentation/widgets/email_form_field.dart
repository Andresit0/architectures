part of '_widgets.lib.dart';

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

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: _validate,
      decoration: InputDecoration(
        hintText: hintText ?? 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
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
  }
}
