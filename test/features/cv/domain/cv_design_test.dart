import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in designs have distinct French labels', () {
    expect(CvDesign.values.map((design) => design.label).toSet(), {
      'Professionnel',
      'Moderne',
      'Minimaliste',
    });
  });

  test('fromId retrouve le modèle enregistré', () {
    for (final design in CvDesign.values) {
      expect(CvDesign.fromId(design.id), design);
    }
  });

  test('fromId retombe sur le professionnel si l’identifiant est inconnu', () {
    expect(CvDesign.fromId('supprimé'), CvDesign.professional);
    expect(CvDesign.fromId(''), CvDesign.professional);
  });
}
