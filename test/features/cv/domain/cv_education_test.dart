import 'package:cv_maker/features/cv/domain/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/cv_education.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const education = CvEducation(
    id: 'edu-1',
    degree: 'Master Informatique',
    school: 'Université Lyon 1',
    location: 'Lyon',
    period: CvDateRange(start: CvMonthYear(2019), end: CvMonthYear(2021)),
    description: 'Spécialité génie logiciel.',
  );

  test('seul l’identifiant est obligatoire', () {
    const minimal = CvEducation(id: 'edu-0');
    expect(minimal.degree, isEmpty);
    expect(minimal.period.isEmpty, isTrue);
  });

  test('aller-retour JSON sans perte', () {
    expect(CvEducation.fromJson(education.toJson()), education);
  });

  test('une formation sans mois conserve ses années seules', () {
    final restored = CvEducation.fromJson(education.toJson());
    expect(restored.period.start, const CvMonthYear(2019));
    expect(restored.period.start!.month, isNull);
  });
}
