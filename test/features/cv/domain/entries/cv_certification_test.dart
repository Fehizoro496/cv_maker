import 'package:cv_maker/features/cv/domain/entries/cv_certification.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la date est facultative', () {
    const certification = CvCertification(id: 'cert-1', name: 'Opquast');
    expect(certification.date, isNull);
    expect(CvCertification.fromJson(certification.toJson()), certification);
  });

  test('aller-retour JSON sans perte', () {
    const certification = CvCertification(
      id: 'cert-1',
      name: 'Opquast — Maîtrise de la qualité web',
      issuer: 'Opquast',
      date: CvMonthYear(2022, 6),
      description: 'Score 820.',
    );
    expect(CvCertification.fromJson(certification.toJson()), certification);
  });
}
