import 'package:cv_maker/features/cv/domain/dates/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/entries/cv_experience.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const experience = CvExperience(
    id: 'exp-1',
    position: 'Développeuse Front-End',
    company: 'Nexora',
    location: 'Lyon, France',
    period: CvDateRange(start: CvMonthYear(2023, 9), isCurrent: true),
    description: 'Refonte du portail client.',
  );

  test('seul l’identifiant est obligatoire', () {
    const minimal = CvExperience(id: 'exp-0');
    expect(minimal.position, isEmpty);
    expect(minimal.period, const CvDateRange());
  });

  test('aller-retour JSON sans perte', () {
    expect(CvExperience.fromJson(experience.toJson()), experience);
  });

  test('copyWith produit une nouvelle valeur sans toucher l’originale', () {
    final renamed = experience.copyWith(company: 'Atelier Kipli');
    expect(renamed.company, 'Atelier Kipli');
    expect(experience.company, 'Nexora');
    expect(renamed, isNot(experience));
  });
}
