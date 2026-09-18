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

  test('une section standard est une référence de section', () {
    const CvSectionRef ref = CvSection.skills;
    expect(ref, CvSection.skills);
  });

  test('deux références personnalisées de même identifiant sont égales', () {
    expect(const CvCustomSectionRef('a'), const CvCustomSectionRef('a'));
    expect(
      const CvCustomSectionRef('a').hashCode,
      const CvCustomSectionRef('a').hashCode,
    );
    expect(const CvCustomSectionRef('a'), isNot(const CvCustomSectionRef('b')));
    // Construites séparément, sans `const`, pour ne pas partager l'instance.
    expect({CvCustomSectionRef('a'), CvCustomSectionRef('a')}, hasLength(1));
  });

  test('un switch sur une référence distingue les deux sortes', () {
    String kind(CvSectionRef ref) => switch (ref) {
      CvSection() => 'standard',
      CvCustomSectionRef() => 'custom',
    };
    expect(kind(CvSection.profile), 'standard');
    expect(kind(const CvCustomSectionRef('x')), 'custom');
  });
}
