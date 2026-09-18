const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// « Modifié aujourd'hui à 14:02 », « Modifié hier à 09:30 » ou « Modifié le
/// 12 septembre 2026 », en heure locale.
String modifiedLabel(DateTime at, {required DateTime now}) {
  final local = at.toLocal();
  final reference = now.toLocal();
  final today = DateTime(reference.year, reference.month, reference.day);
  final day = DateTime(local.year, local.month, local.day);
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  return switch (today.difference(day).inHours) {
    0 => 'Modifié aujourd’hui à $time',
    // Le changement d'heure donne des jours de 23 ou 25 heures.
    >= 23 && <= 25 => 'Modifié hier à $time',
    _ =>
      'Modifié le ${_dayLabel(local)} ${_months[local.month - 1]} '
          '${local.year}',
  };
}

String _dayLabel(DateTime date) => date.day == 1 ? '1er' : '${date.day}';
