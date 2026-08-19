// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Historial Clínico';

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
  String get clinicalHistoryEmpty =>
      'Aún no hay registros de historial clínico.';

  @override
  String get clinicalHistoryRetry => 'Reintentar';

  @override
  String clinicalHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '1 registro',
      zero: 'Sin registros',
    );
    return '$_temp0';
  }

  @override
  String get clinicalHistoryDetailsProfessional => 'Profesional';

  @override
  String get clinicalHistoryDetailsExpand => 'Mostrar detalles de la atención';

  @override
  String get clinicalHistoryDetailsCollapse =>
      'Ocultar detalles de la atención';

  @override
  String get clinicalHistoryDetailsSummary => 'Resumen';

  @override
  String get clinicalHistoryDetailsDescription => 'Descripción';

  @override
  String get clinicalHistoryDetailsDiagnosis => 'Diagnóstico';

  @override
  String get clinicalHistoryDetailsObservations => 'Observaciones';

  @override
  String get clinicalHistoryDetailsAttachments => 'Adjuntos';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get routeNotFound => 'Página no encontrada';

  @override
  String get routeNotFoundGoHome => 'Ir al inicio';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado';

  @override
  String get errorNetwork => 'Sin conexión a internet';

  @override
  String get errorTimeout => 'El servidor tardó demasiado en responder';

  @override
  String get errorServer => 'El servidor está en mantenimiento';

  @override
  String get errorDeviceSecurity =>
      'Este dispositivo no es compatible por motivos de seguridad';

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

  @override
  String get offlineBanner =>
      'Sin conexión a internet — mostrando datos guardados';

  @override
  String get deviceSecurityTitle => 'Dispositivo no soportado';

  @override
  String get deviceSecurityMessage =>
      'Tu dispositivo ha sido modificado. Por motivos de seguridad, esta aplicación no puede usarse en dispositivos con jailbreak o root.';

  @override
  String get labResults => 'Resultados de laboratorio';

  @override
  String get labResultsEmpty => 'No hay resultados de laboratorio';

  @override
  String get labResultsPeriodLabel => 'Periodo';

  @override
  String get labResultsPeriodAll => 'Todo';

  @override
  String get labResultsPeriod3Months => '3 meses';

  @override
  String get labResultsPeriod6Months => '6 meses';

  @override
  String get labResultsPeriod1Year => '1 año';

  @override
  String get labResultsStatusNormal => 'Normal';

  @override
  String get labResultsStatusHigh => 'Alto';

  @override
  String get labResultsStatusLow => 'Bajo';

  @override
  String get labResultsStatusUnknown => 'Desconocido';

  @override
  String get labResultsChartTitle => 'Tendencia';

  @override
  String get labResultsOtherTests => 'Otros resultados';

  @override
  String get labResultsSelectTest => 'Selecciona un análisis';

  @override
  String get labResultsLatestValue => 'Último';

  @override
  String get labResultsReferenceRange => 'Rango de referencia';

  @override
  String get labResultsRefresh => 'Actualizar resultados';

  @override
  String get clinicalHistoryLabResults => 'Resultados de laboratorio';
}
