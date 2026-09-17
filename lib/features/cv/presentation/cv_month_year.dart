/// Date de CV : une année, éventuellement précisée par un mois.
///
/// Se lit et s'écrit au format affiché dans le CV : « sept. 2023 » ou « 2019 ».
class CvMonthYear {
  const CvMonthYear(this.year, [this.month])
    : assert(month == null || (month >= 1 && month <= 12));

  static const monthLabels = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];

  final int year;

  /// Mois de 1 à 12, ou `null` pour une année seule.
  final int? month;

  /// Retourne `null` si [text] n'est pas une date de CV reconnue.
  static CvMonthYear? tryParse(String text) {
    final parts = text.trim().split(RegExp(r'\s+'));
    final year = int.tryParse(parts.last);
    if (year == null || parts.last.length != 4) return null;
    if (parts.length == 1) return CvMonthYear(year);
    if (parts.length != 2) return null;
    final index = monthLabels.indexOf(parts.first.toLowerCase());
    return index < 0 ? null : CvMonthYear(year, index + 1);
  }

  String format() =>
      month == null ? '$year' : '${monthLabels[month! - 1]} $year';

  @override
  bool operator ==(Object other) =>
      other is CvMonthYear && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => format();
}
