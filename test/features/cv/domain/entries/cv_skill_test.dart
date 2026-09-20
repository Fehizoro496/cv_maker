import 'package:cv_maker/features/cv/domain/entries/cv_skill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la catégorie et le niveau sont facultatifs', () {
    const skill = CvSkill(id: 'skill-1', name: 'Flutter');
    expect(skill.category, isEmpty);
    expect(skill.level, isEmpty);
  });

  test('aller-retour JSON sans perte', () {
    const skill = CvSkill(
      id: 'skill-1',
      name: 'Flutter',
      category: 'Développement',
      level: 'avancé',
    );
    expect(CvSkill.fromJson(skill.toJson()), skill);
  });

  test('deux compétences identiques sont égales', () {
    expect(
      const CvSkill(id: 'skill-1', name: 'Dart'),
      const CvSkill(id: 'skill-1', name: 'Dart'),
    );
    expect(
      const CvSkill(id: 'skill-1', name: 'Dart'),
      isNot(const CvSkill(id: 'skill-2', name: 'Dart')),
    );
  });
}
