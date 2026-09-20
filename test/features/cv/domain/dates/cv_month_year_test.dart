import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lit un mois et une année au format du CV', () {
    expect(CvMonthYear.tryParse('sept. 2023'), const CvMonthYear(2023, 9));
    expect(CvMonthYear.tryParse('août 2023'), const CvMonthYear(2023, 8));
    expect(CvMonthYear.tryParse(' Janv.  2021 '), const CvMonthYear(2021, 1));
  });

  test('lit une année seule', () {
    expect(CvMonthYear.tryParse('2019'), const CvMonthYear(2019));
  });

  test('refuse les textes qui ne sont pas des dates de CV', () {
    for (final text in ['', 'bientôt', '19', 'sept 2023', 'mars 2023 x']) {
      expect(CvMonthYear.tryParse(text), isNull, reason: text);
    }
  });

  test('formate un mois et une année, ou une année seule', () {
    expect(const CvMonthYear(2020, 12).format(), 'déc. 2020');
    expect(const CvMonthYear(2024, 5).format(), 'mai 2024');
    expect(const CvMonthYear(2016).format(), '2016');
  });

  test('chaque mois se relit après formatage', () {
    for (var month = 1; month <= 12; month++) {
      final date = CvMonthYear(2022, month);
      expect(CvMonthYear.tryParse(date.format()), date);
    }
  });
}
