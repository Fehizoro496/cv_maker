import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in designs have distinct French labels', () {
    expect(CvDesign.values.map((design) => design.label).toSet(), {
      'Classique',
      'Sobre',
      'En-tête coloré',
      'Compact',
      'Académique',
    });
  });

  test('chaque modèle a une description distincte', () {
    final descriptions = CvDesign.values.map((design) => design.description);
    expect(descriptions.toSet(), hasLength(CvDesign.values.length));
    expect(descriptions.every((text) => text.isNotEmpty), isTrue);
  });

  test('la palette d’accents est fermée et retrouvée par identifiant', () {
    expect(CvAccent.values, hasLength(5));
    for (final accent in CvAccent.values) {
      expect(CvAccent.fromId(accent.id), accent);
      expect(accent.label, isNotEmpty);
    }
  });

  test('une couleur d’accent inconnue retombe sur le bleu', () {
    expect(CvAccent.fromId('fuchsia'), CvAccent.blue);
    expect(CvAccent.fromId(''), CvAccent.blue);
  });

  test('fromId retrouve le modèle enregistré', () {
    for (final design in CvDesign.values) {
      expect(CvDesign.fromId(design.id), design);
    }
  });

  test('fromId retombe sur le classique si l’identifiant est inconnu', () {
    expect(CvDesign.fromId('supprimé'), CvDesign.classic);
    expect(CvDesign.fromId(''), CvDesign.classic);
    expect(CvDesign.fallback, CvDesign.classic);
  });
}
