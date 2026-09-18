import 'package:cv_maker/shared/formatting/modified_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 18, 16, 30);

  test('aujourd’hui : l’heure seule, sur deux chiffres', () {
    expect(
      modifiedLabel(DateTime(2026, 9, 18, 9, 5), now: now),
      'Modifié aujourd’hui à 09:05',
    );
  });

  test('hier : le mot et l’heure', () {
    expect(
      modifiedLabel(DateTime(2026, 9, 17, 23, 59), now: now),
      'Modifié hier à 23:59',
    );
  });

  test('avant : la date complète, mois en toutes lettres', () {
    expect(
      modifiedLabel(DateTime(2026, 8, 12, 10), now: now),
      'Modifié le 12 août 2026',
    );
    expect(
      modifiedLabel(DateTime(2025, 12, 1), now: now),
      'Modifié le 1er décembre 2025',
    );
  });

  test('une date UTC est affichée en heure locale', () {
    final utc = DateTime.utc(2026, 9, 18, 12);
    final local = utc.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');

    expect(modifiedLabel(utc, now: local), 'Modifié aujourd’hui à $hour:00');
  });
}
