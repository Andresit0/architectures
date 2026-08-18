import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// App title shown in the login screen and OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'Clinical History'**
  String get appTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @clinicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Clinical History'**
  String get clinicalHistory;

  /// No description provided for @clinicalHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clinical history records yet.'**
  String get clinicalHistoryEmpty;

  /// No description provided for @clinicalHistoryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get clinicalHistoryRetry;

  /// Number of clinical history records shown in the list header.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No records} =1{1 record} other{{count} records}}'**
  String clinicalHistoryCount(int count);

  /// No description provided for @clinicalHistoryDetailsProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get clinicalHistoryDetailsProfessional;

  /// No description provided for @clinicalHistoryDetailsExpand.
  ///
  /// In en, this message translates to:
  /// **'Show encounter details'**
  String get clinicalHistoryDetailsExpand;

  /// No description provided for @clinicalHistoryDetailsCollapse.
  ///
  /// In en, this message translates to:
  /// **'Hide encounter details'**
  String get clinicalHistoryDetailsCollapse;

  /// No description provided for @clinicalHistoryDetailsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get clinicalHistoryDetailsSummary;

  /// No description provided for @clinicalHistoryDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get clinicalHistoryDetailsDescription;

  /// No description provided for @clinicalHistoryDetailsDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get clinicalHistoryDetailsDiagnosis;

  /// No description provided for @clinicalHistoryDetailsObservations.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get clinicalHistoryDetailsObservations;

  /// No description provided for @clinicalHistoryDetailsAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get clinicalHistoryDetailsAttachments;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFound;

  /// No description provided for @routeNotFoundGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to start'**
  String get routeNotFoundGoHome;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnknown;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server is under maintenance'**
  String get errorServer;

  /// No description provided for @errorDeviceSecurity.
  ///
  /// In en, this message translates to:
  /// **'This device is not supported for security reasons'**
  String get errorDeviceSecurity;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get errorEmptyEmail;

  /// No description provided for @errorEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorEmptyPassword;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection — showing saved data'**
  String get offlineBanner;

  /// No description provided for @deviceSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsupported device'**
  String get deviceSecurityTitle;

  /// No description provided for @deviceSecurityMessage.
  ///
  /// In en, this message translates to:
  /// **'Your device has been modified. For security reasons, this app cannot be used on jailbroken or rooted devices.'**
  String get deviceSecurityMessage;

  /// No description provided for @labResults.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get labResults;

  /// No description provided for @labResultsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lab results.'**
  String get labResultsEmpty;

  /// No description provided for @labResultsPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get labResultsPeriodLabel;

  /// No description provided for @labResultsPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labResultsPeriodAll;

  /// No description provided for @labResultsPeriod3Months.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get labResultsPeriod3Months;

  /// No description provided for @labResultsPeriod6Months.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get labResultsPeriod6Months;

  /// No description provided for @labResultsPeriod1Year.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get labResultsPeriod1Year;

  /// No description provided for @labResultsStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get labResultsStatusNormal;

  /// No description provided for @labResultsStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get labResultsStatusHigh;

  /// No description provided for @labResultsStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get labResultsStatusLow;

  /// No description provided for @labResultsStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labResultsStatusUnknown;

  /// No description provided for @labResultsChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get labResultsChartTitle;

  /// No description provided for @labResultsOtherTests.
  ///
  /// In en, this message translates to:
  /// **'Other results'**
  String get labResultsOtherTests;

  /// No description provided for @labResultsSelectTest.
  ///
  /// In en, this message translates to:
  /// **'Select a test'**
  String get labResultsSelectTest;

  /// No description provided for @labResultsLatestValue.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get labResultsLatestValue;

  /// No description provided for @labResultsReferenceRange.
  ///
  /// In en, this message translates to:
  /// **'Reference range'**
  String get labResultsReferenceRange;

  /// No description provided for @labResultsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh results'**
  String get labResultsRefresh;

  /// No description provided for @clinicalHistoryLabResults.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get clinicalHistoryLabResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
