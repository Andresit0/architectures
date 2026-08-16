// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clinical History';

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
  String get clinicalHistoryEmpty => 'No clinical history records yet.';

  @override
  String get clinicalHistoryRetry => 'Retry';

  @override
  String clinicalHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: 'No records',
    );
    return '$_temp0';
  }

  @override
  String get clinicalHistoryDetailsProfessional => 'Professional';

  @override
  String get clinicalHistoryDetailsExpand => 'Show encounter details';

  @override
  String get clinicalHistoryDetailsCollapse => 'Hide encounter details';

  @override
  String get clinicalHistoryDetailsSummary => 'Summary';

  @override
  String get clinicalHistoryDetailsDescription => 'Description';

  @override
  String get clinicalHistoryDetailsDiagnosis => 'Diagnosis';

  @override
  String get clinicalHistoryDetailsObservations => 'Observations';

  @override
  String get clinicalHistoryDetailsAttachments => 'Attachments';

  @override
  String get logout => 'Logout';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get routeNotFoundGoHome => 'Go to start';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorTimeout => 'The server took too long to respond';

  @override
  String get errorServer => 'Server is under maintenance';

  @override
  String get errorDeviceSecurity =>
      'This device is not supported for security reasons';

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

  @override
  String get offlineBanner => 'No internet connection — showing saved data';

  @override
  String get deviceSecurityTitle => 'Unsupported device';

  @override
  String get deviceSecurityMessage =>
      'Your device has been modified. For security reasons, this app cannot be used on jailbroken or rooted devices.';
}
