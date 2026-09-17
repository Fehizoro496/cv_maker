import 'package:cv_maker/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final theme = buildAppTheme();

  test("le thème applique les couleurs adoucies de l'application", () {
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.secondaryContainer, AppColors.secondaryContainer);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.colorScheme.outlineVariant, AppColors.outlineVariant);
    expect(theme.colorScheme.error, AppColors.error);
  });

  test('le thème est compact et utilise Segoe UI', () {
    expect(theme.visualDensity, VisualDensity.compact);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Segoe UI');
  });

  test('la typographie suit les tokens du design', () {
    expect(theme.textTheme.titleLarge?.fontSize, 18);
    expect(theme.textTheme.titleLarge?.fontWeight, FontWeight.w600);
    expect(theme.textTheme.bodyMedium?.fontSize, 13);
    expect(theme.textTheme.labelSmall?.fontSize, 11);
  });

  test('les champs sont remplis, arrondis et soulignés au focus', () {
    final focused =
        theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;

    expect(focused.borderRadius, BorderRadius.circular(AppRadii.field));
    expect(focused.borderSide.width, 1.5);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(focused.borderSide.color, AppColors.primary);
  });
}
