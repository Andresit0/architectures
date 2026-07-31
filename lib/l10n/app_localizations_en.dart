// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clean Architecture App';

  @override
  String get loginButton => 'Login';

  @override
  String get loginTitle => 'Enter your credentials to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get clinicalHistory => 'Clinical History';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get logout => 'Logout';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorServer => 'Server is under maintenance';

  @override
  String get errorInvalidCredentials => 'Invalid email or password';

  @override
  String get errorInvalidEmail => 'Please enter a valid email';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorEmptyEmail => 'Email is required';

  @override
  String get errorEmptyPassword => 'Password is required';
}
