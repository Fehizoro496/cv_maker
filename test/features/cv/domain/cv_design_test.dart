import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in designs have distinct French labels', () {
    expect(CvDesign.values.map((design) => design.label).toSet(), {
      'Classique',
      'Sobre',
      'Bandeau latéral',
      'Latéral clair',
      'En-tête coloré',
      'Compact',
      'Académique',
      'Contraste',
    });
  });

  test('le catalogue suit l’ordre du handoff', () {
    expect(CvDesign.values, [
      CvDesign.classic,
      CvDesign.plain,
      CvDesign.sidebar,
      CvDesign.lightSidebar,
      CvDesign.banner,
      CvDesign.compact,
      CvDesign.academic,
      CvDesign.contrast,
    ]);
  });

  test('chaque modèle a une description distincte', () {
    final descriptions = CvDesign.values.map((design) => design.description);
    expect(descriptions.toSet(), hasLength(CvDesign.values.length));
    expect(descriptions.every((text) => text.isNotEmpty), isTrue);
  });

  test('la palette propose cinq couleurs nommées et distinctes', () {
    expect(CvAccent.values, hasLength(5));
    expect(CvAccent.values.map((accent) => accent.color).toSet(), hasLength(5));
    for (final accent in CvAccent.values) {
      expect(accent.label, isNotEmpty);
      // Une couleur opaque : le PDF ne rend pas la transparence.
      expect(accent.color & 0xFF000000, 0xFF000000);
    }
  });

  test('la palette sert de suggestions au sélecteur de couleur', () {
    expect(CvAccent.palette, CvAccent.values.map((a) => a.color).toList());
    expect(CvAccent.palette, contains(CvAccent.defaultColor));
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
