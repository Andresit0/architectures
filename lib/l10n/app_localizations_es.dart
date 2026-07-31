// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Arquitectura Limpia';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginTitle => 'Ingresa tus credenciales para continuar';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get clinicalHistory => 'Historial Clínico';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado';

  @override
  String get errorNetwork => 'Sin conexión a internet';

  @override
  String get errorServer => 'El servidor está en mantenimiento';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña inválidos';

  @override
  String get errorInvalidEmail => 'Ingresa un correo válido';

  @override
  String get errorPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get errorEmptyEmail => 'El correo es requerido';

  @override
  String get errorEmptyPassword => 'La contraseña es requerida';
}
