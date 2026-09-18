import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../shared/notifications/app_toast.dart';
import 'cv_workspace.dart';

/// L'écran du premier lancement, tant qu'aucun CV n'est enregistré.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _creating = false;

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      await ref.read(cvWorkspaceProvider).create();
    } catch (_) {
      ref
          .read(appToastsProvider.notifier)
          .show(
            kind: AppToastKind.error,
            title: 'Création impossible',
            message: 'Le CV n’a pas pu être enregistré sur cet ordinateur.',
            actionLabel: 'Réessayer',
            actionIcon: Icons.refresh,
            onAction: _create,
          );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.note_add_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenue dans CV Maker',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const Text(
                  'Remplissez vos informations section par section : le CV en '
                  'PDF se met à jour à côté de vous. Tout reste sur votre '
                  'ordinateur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _creating ? null : _create,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Créer mon CV'),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 16,
                    color: AppColors.outline,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Fonctionne hors ligne, sans compte',
                    style: TextStyle(fontSize: 12, color: AppColors.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
