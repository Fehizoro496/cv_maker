import 'package:flutter/material.dart';

import 'app_theme.dart';

/// L'application réduite à l'annonce d'un démarrage impossible.
///
/// Elle remplace le tableau de bord lorsque les CV enregistrés n'ont pas pu
/// être lus : base absente, verrouillée par une autre instance ou illisible.
/// Aucun `ProviderScope` ne l'entoure, puisque c'est précisément l'état de
/// départ qui manque.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key, required this.onRetry, this.details});

  /// Relance la lecture des CV, et donc l'application entière.
  final Future<void> Function() onRetry;

  /// La cause technique, affichée en petit sous le message.
  final String? details;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CV Maker',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: StartupFailureScreen(onRetry: onRetry, details: details),
  );
}

/// Le message d'un démarrage impossible, avec « Réessayer ».
class StartupFailureScreen extends StatelessWidget {
  const StartupFailureScreen({super.key, required this.onRetry, this.details});

  final Future<void> Function() onRetry;
  final String? details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.panel),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Les CV enregistrés n’ont pas pu être lus',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'La base de données de l’application est peut-être ouverte '
                  'par une autre fenêtre de CV Maker, ou son fichier est '
                  'endommagé. Fermez les autres fenêtres, puis réessayez.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadii.field),
                    ),
                    child: Text(
                      details!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => onRetry(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
