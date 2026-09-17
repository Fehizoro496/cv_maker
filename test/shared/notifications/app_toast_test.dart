import 'package:cv_maker/shared/notifications/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late AppToastsNotifier toasts;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    toasts = container.read(appToastsProvider.notifier);
  });

  test('aucune notification au départ', () {
    expect(container.read(appToastsProvider), isEmpty);
  });

  test('une notification porte son titre et sa nature', () {
    toasts.show(
      kind: AppToastKind.success,
      title: 'PDF exporté',
      message: 'C:/CV.pdf',
    );
    final toast = container.read(appToastsProvider).single;
    expect(toast.title, 'PDF exporté');
    expect(toast.message, 'C:/CV.pdf');
    expect(toast.kind, AppToastKind.success);
    expect(toast.hasAction, isFalse);
  });

  test('les identifiants sont uniques', () {
    final first = toasts.show(kind: AppToastKind.info, title: 'A');
    final second = toasts.show(kind: AppToastKind.info, title: 'B');
    expect(first, isNot(second));
  });

  test('la plus récente est en dernier', () {
    toasts.show(kind: AppToastKind.info, title: 'Première');
    toasts.show(kind: AppToastKind.info, title: 'Seconde');
    expect(container.read(appToastsProvider).map((toast) => toast.title), [
      'Première',
      'Seconde',
    ]);
  });

  test('au-delà de trois, la plus ancienne cède la place', () {
    for (final title in ['A', 'B', 'C', 'D', 'E']) {
      toasts.show(kind: AppToastKind.info, title: title);
    }
    expect(container.read(appToastsProvider).map((toast) => toast.title), [
      'C',
      'D',
      'E',
    ]);
  });

  test('fermer une notification retire uniquement celle-ci', () {
    final first = toasts.show(kind: AppToastKind.info, title: 'A');
    toasts.show(kind: AppToastKind.info, title: 'B');
    toasts.dismiss(first);
    expect(container.read(appToastsProvider).map((toast) => toast.title), [
      'B',
    ]);
  });

  test('fermer une notification inconnue ne change rien', () {
    toasts.show(kind: AppToastKind.info, title: 'A');
    toasts.dismiss('toast-inconnu');
    expect(container.read(appToastsProvider), hasLength(1));
  });

  test('tout fermer vide la pile', () {
    toasts.show(kind: AppToastKind.info, title: 'A');
    toasts.show(kind: AppToastKind.info, title: 'B');
    toasts.dismissAll();
    expect(container.read(appToastsProvider), isEmpty);
  });

  test('une notification porteuse d’une action reste plus longtemps', () {
    toasts.show(
      kind: AppToastKind.error,
      title: 'Échec',
      actionLabel: 'Réessayer',
      actionIcon: Icons.refresh,
      onAction: () {},
    );
    final toast = container.read(appToastsProvider).single;
    expect(toast.hasAction, isTrue);
    expect(toast.duration, const Duration(seconds: 6));
  });

  test('une notification sans action dure quatre secondes', () {
    toasts.show(kind: AppToastKind.info, title: 'A');
    expect(
      container.read(appToastsProvider).single.duration,
      const Duration(seconds: 4),
    );
  });

  test('une action sans libellé n’en est pas une', () {
    toasts.show(kind: AppToastKind.info, title: 'A', onAction: () {});
    expect(container.read(appToastsProvider).single.hasAction, isFalse);
  });

  testWidgets('une notification disparaît d’elle-même', (tester) async {
    toasts.show(kind: AppToastKind.success, title: 'PDF exporté');
    await tester.pump(const Duration(seconds: 3));
    expect(container.read(appToastsProvider), hasLength(1));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(appToastsProvider), isEmpty);
  });

  testWidgets('une notification d’attente ne disparaît pas seule', (
    tester,
  ) async {
    final id = toasts.show(
      kind: AppToastKind.progress,
      title: 'Mise à jour du PDF…',
    );
    await tester.pump(const Duration(seconds: 10));
    expect(container.read(appToastsProvider), hasLength(1));
    toasts.dismiss(id);
    expect(container.read(appToastsProvider), isEmpty);
  });

  testWidgets('fermer à la main annule le minuteur', (tester) async {
    final id = toasts.show(kind: AppToastKind.info, title: 'A');
    toasts.dismiss(id);
    toasts.show(kind: AppToastKind.info, title: 'B');
    await tester.pump(const Duration(seconds: 3));
    // Le minuteur de la première ne doit pas emporter la seconde.
    expect(container.read(appToastsProvider).map((toast) => toast.title), [
      'B',
    ]);
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(appToastsProvider), isEmpty);
  });
}
