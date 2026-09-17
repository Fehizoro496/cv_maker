import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les sections suivent l\'ordre du cahier des charges', () {
    expect(CvSection.values, [
      CvSection.personalInfo,
      CvSection.profile,
      CvSection.experiences,
      CvSection.education,
      CvSection.skills,
      CvSection.languages,
      CvSection.certifications,
      CvSection.projects,
      CvSection.interests,
      CvSection.references,
    ]);
  });

  test('seules les sections complémentaires sont facultatives', () {
    expect(CvSection.values.where((section) => section.isOptional), [
      CvSection.certifications,
      CvSection.projects,
      CvSection.interests,
      CvSection.references,
    ]);
  });
}
