part of '_widgets.lib.dart';

class CustomAuthWidgets {
  static EmailFormField createEmailFormField({
    TextEditingController? controller,
    String? hintText,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    return EmailFormField(
      controller: controller,
      hintText: hintText,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }

  static PasswordFormField createPasswordFormField({
    TextEditingController? controller,
    String? hintText,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    return PasswordFormField(
      controller: controller,
      hintText: hintText,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }

  static LoginButton createLoginButton({
    void Function()? onPressed,
    required String text,
  }) {
    return LoginButton(onPressed: onPressed, text: text);
  }
}
