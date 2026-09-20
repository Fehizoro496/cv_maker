import 'package:cv_maker/features/cv/domain/dates/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('une période neuve est vide', () {
    const period = CvDateRange();
    expect(period.isEmpty, isTrue);
    expect(period.isCurrent, isFalse);
    expect(period.effectiveEnd, isNull);
  });

  test('une période en cours ignore la date de fin saisie', () {
    const period = CvDateRange(
      start: CvMonthYear(2023, 9),
      end: CvMonthYear(2024, 1),
      isCurrent: true,
    );
    expect(period.effectiveEnd, isNull);
    expect(period.end, const CvMonthYear(2024, 1));
    expect(period.copyWith(isCurrent: false).effectiveEnd, isNotNull);
  });

  test('aller-retour JSON sans perte', () {
    const period = CvDateRange(
      start: CvMonthYear(2019),
      end: CvMonthYear(2021, 6),
    );
    expect(CvDateRange.fromJson(period.toJson()), period);
  });

  test('une période en cours survit à l’aller-retour JSON', () {
    const period = CvDateRange(start: CvMonthYear(2023, 9), isCurrent: true);
    expect(CvDateRange.fromJson(period.toJson()), period);
  });
}
