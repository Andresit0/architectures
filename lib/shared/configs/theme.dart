part of '_configs.lib.dart';

class AppTheme {
  ThemeData get material3 => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: CustomConfigs.appColors.primary,
    ),
    useMaterial3: true,
  );
}
