import 'package:cv_maker/features/cv/domain/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/cv_project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seul l’identifiant est obligatoire', () {
    const project = CvProject(id: 'proj-0');
    expect(project.name, isEmpty);
    expect(project.url, isEmpty);
    expect(project.period.isEmpty, isTrue);
  });

  test('aller-retour JSON sans perte', () {
    const project = CvProject(
      id: 'proj-1',
      name: 'Atlas',
      role: 'Conception et développement',
      url: 'github.com/camillemoreau/atlas',
      period: CvDateRange(start: CvMonthYear(2024, 2)),
      description: 'Bibliothèque de composants Flutter accessibles.',
    );
    expect(CvProject.fromJson(project.toJson()), project);
  });
}
