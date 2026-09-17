import 'package:flutter/material.dart';

const appSeedColor = Color(0xFF2F5D8C);

/// Couleurs de l'interface.
///
/// Dérivées du design de référence (`design_handoff_cv_maker/README.md`) avec
/// des contrastes adoucis : fond neutre, panneaux blancs et bordures légères.
abstract final class AppColors {
  static const primary = Color(0xFF2F5D8C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryTint = Color(0xFFEAF1F8);
  static const secondaryContainer = Color(0xFFE3ECF6);
  static const onSecondaryContainer = Color(0xFF1D4670);

  /// Fond de la fenêtre, derrière les panneaux.
  static const canvas = Color(0xFFF2F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF7F8FB);
  static const surfaceContainer = Color(0xFFEEF1F6);
  static const onSurface = Color(0xFF1B1F24);
  static const onSurfaceVariant = Color(0xFF5B6270);
  static const outline = Color(0xFF8A919C);
  static const outlineVariant = Color(0xFFE6E9EF);
  static const divider = Color(0xFFEEF0F4);
  static const cardBorder = Color(0xFFE3E7ED);
  static const hover = Color(0xFFE8EBF1);
  static const disabled = Color(0xFFA3A9B3);
  static const disabledBorder = Color(0xFFCBD0D8);
  static const disabledFill = Color(0xFFF3F4F7);
  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFFDECEA);
  static const successContainer = Color(0xFFE6F4EA);
  static const onSuccessContainer = Color(0xFF1E6B3A);
  static const pageShadow = Color(0x1A101828);
  static const softShadow = Color(0x0F101828);
}

/// Rayons communs de l'interface.
abstract final class AppRadii {
  static const field = 10.0;
  static const control = 10.0;
  static const card = 14.0;
  static const panel = 18.0;
  static const dialog = 22.0;
}

/// Ombre douce des surfaces posées sur le fond.
const appSoftShadow = [
  BoxShadow(color: AppColors.softShadow, offset: Offset(0, 1), blurRadius: 2),
  BoxShadow(color: AppColors.softShadow, offset: Offset(0, 6), blurRadius: 18),
];

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: appSeedColor).copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    surface: AppColors.surface,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.error,
  );

  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.control),
  );
  OutlineInputBorder fieldBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.field)),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    colorScheme: colorScheme,
    fontFamily: 'Segoe UI',
    visualDensity: VisualDensity.compact,
    scaffoldBackgroundColor: AppColors.canvas,
    splashFactory: InkSparkle.splashFactory,
    hoverColor: AppColors.hover,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.66,
        color: AppColors.outline,
      ),
    ).apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      space: 1,
      thickness: 1,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        disabledForegroundColor: AppColors.disabledBorder,
        minimumSize: const Size.square(32),
        fixedSize: const Size.square(32),
        iconSize: 19,
        padding: EdgeInsets.zero,
        shape: controlShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: controlShape,
        elevation: 0,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        disabledBackgroundColor: AppColors.surfaceContainer,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: controlShape,
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.cardBorder),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: controlShape,
        foregroundColor: AppColors.onSurfaceVariant,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      hoverColor: AppColors.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      labelStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.onSurfaceVariant,
      ),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.focused)
              ? AppColors.primary
              : states.contains(WidgetState.disabled)
              ? AppColors.disabled
              : AppColors.onSurfaceVariant,
        ),
      ),
      suffixIconColor: AppColors.outline,
      border: fieldBorder(AppColors.cardBorder),
      enabledBorder: fieldBorder(AppColors.cardBorder),
      focusedBorder: fieldBorder(AppColors.primary, 1.5),
      disabledBorder: fieldBorder(AppColors.outlineVariant),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      side: const BorderSide(color: AppColors.outline, width: 1.5),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerHeight: 0,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      indicator: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control - 2),
        boxShadow: appSoftShadow,
      ),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 13),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dialog),
      ),
      barrierColor: const Color(0x3D101828),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(
        AppColors.outline.withValues(alpha: 0.35),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primaryTint,
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      decoration: BoxDecoration(
        color: const Color(0xE61B1F24),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
