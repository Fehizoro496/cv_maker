import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Panneau arrondi posé sur le fond de la fenêtre, avec une ombre douce.
class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.margin = const EdgeInsets.all(6),
  });

  static const radius = AppRadii.panel;

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: appSoftShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 1),
          child: child,
        ),
      ),
    );
  }
}
