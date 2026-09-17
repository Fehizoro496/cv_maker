import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque modèle intégré a sa description', () {
    for (final design in CvDesign.values) {
      expect(design.spec, isNotNull);
    }
  });

  test('les trois descriptions intégrées diffèrent deux à deux', () {
    final specs = CvDesign.values.map((design) => design.spec).toList();
    expect(specs.toSet(), hasLength(CvDesign.values.length));
  });

  test('un identifiant inconnu retombe sur le modèle professionnel', () {
    expect(CvDesign.fromId('inexistant').spec, same(professionalDesignSpec));
  });

  test('tous les modèles du MVP tiennent en une seule colonne', () {
    for (final design in CvDesign.values) {
      expect(design.spec.structure.isSingleColumn, isTrue);
      expect(design.spec.structure.sidebarPosition, isNull);
      expect(design.spec.structure.sidebarSections, isEmpty);
    }
  });

  test('la couleur des titres retombe sur la couleur d’accent', () {
    const tokens = CvDesignTokens(accentColor: 0xFF123456);
    expect(tokens.effectiveHeadingColor, 0xFF123456);
    expect(
      const CvDesignTokens(
        accentColor: 0xFF123456,
        headingColor: 0xFF654321,
      ).effectiveHeadingColor,
      0xFF654321,
    );
  });

  group('les quatre groupes de propriétés sont indépendants', () {
    test('le modèle moderne ne diffère que par son en-tête et ses titres', () {
      expect(modernDesignSpec.header.fullWidthBanner, isTrue);
      expect(modernDesignSpec.sections.titleRuleWidth, greaterThan(0));
      expect(modernDesignSpec.sections.headerRuleThickness, isNull);
      // La structure reste celle du modèle par défaut.
      expect(
        modernDesignSpec.structure.columns,
        professionalDesignSpec.structure.columns,
      );
    });

    test('le modèle minimaliste ne touche ni au bandeau ni aux puces', () {
      expect(minimalDesignSpec.header.alignment, CvHeaderAlignment.center);
      expect(minimalDesignSpec.header.fullWidthBanner, isFalse);
      expect(minimalDesignSpec.sections.titleCase, CvSectionTitleCase.none);
      expect(
        minimalDesignSpec.sections.bulletPrefix,
        professionalDesignSpec.sections.bulletPrefix,
      );
    });

    test('changer un jeton visuel ne change aucune forme', () {
      const recoloured = CvDesignSpec(
        tokens: CvDesignTokens(accentColor: 0xFF00FF00),
      );
      expect(recoloured.tokens.accentColor, 0xFF00FF00);
      expect(recoloured.header.fullWidthBanner, isFalse);
      expect(recoloured.structure.isSingleColumn, isTrue);
      expect(recoloured.sections.titleCase, CvSectionTitleCase.upper);
    });
  });

  test('le modèle professionnel conserve les valeurs par défaut', () {
    expect(professionalDesignSpec.tokens.pageMarginMm, 18);
    expect(professionalDesignSpec.tokens.scale.body, 9.5);
    expect(professionalDesignSpec.sections.headerRuleThickness, 1);
    expect(professionalDesignSpec.header.photoShape, CvPhotoShape.circle);
    expect(professionalDesignSpec.header.showPhoto, isTrue);
  });
}
