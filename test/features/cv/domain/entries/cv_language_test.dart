import 'package:cv_maker/features/cv/domain/entries/cv_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le niveau est un texte libre', () {
    const maternelle = CvLanguage(
      id: 'lang-1',
      name: 'Français',
      level: 'langue maternelle',
    );
    const cadre = CvLanguage(id: 'lang-2', name: 'Anglais', level: 'C1');
    expect(maternelle.level, 'langue maternelle');
    expect(cadre.level, 'C1');
  });

  test('aller-retour JSON sans perte, accents compris', () {
    const language = CvLanguage(
      id: 'lang-1',
      name: 'Français',
      level: 'langue maternelle',
    );
    expect(CvLanguage.fromJson(language.toJson()), language);
  });
}
