import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque modèle intégré a sa description', () {
    for (final design in CvDesign.values) {
      expect(design.spec, isNotNull);
    }
  });

  test('les descriptions intégrées diffèrent deux à deux', () {
    final specs = CvDesign.values.map((design) => design.spec).toList();
    expect(specs.toSet(), hasLength(CvDesign.values.length));
  });

  test('un identifiant inconnu retombe sur le modèle classique', () {
    expect(CvDesign.fromId('inexistant').spec, same(classicDesignSpec));
  });

  test('tous les modèles livrés tiennent en une seule colonne', () {
    // Les modèles à deux zones arrivent avec le moteur de zones du JZ.
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
    test(
      'le modèle à bandeau ne diffère que par son en-tête et ses titres',
      () {
        expect(bannerDesignSpec.header.fullWidthBanner, isTrue);
        expect(bannerDesignSpec.sections.titleRuleWidth, greaterThan(0));
        expect(bannerDesignSpec.sections.headerRuleThickness, isNull);
        expect(
          bannerDesignSpec.structure.columns,
          classicDesignSpec.structure.columns,
        );
      },
    );

    test('le modèle académique ne touche ni au bandeau ni aux puces', () {
      expect(academicDesignSpec.header.alignment, CvHeaderAlignment.center);
      expect(academicDesignSpec.header.fullWidthBanner, isFalse);
      expect(academicDesignSpec.sections.titleCase, CvSectionTitleCase.none);
      expect(
        academicDesignSpec.sections.bulletPrefix,
        classicDesignSpec.sections.bulletPrefix,
      );
    });

    test('le modèle compact ne change que ses jetons visuels', () {
      expect(
        compactDesignSpec.tokens.scale.body,
        lessThan(classicDesignSpec.tokens.scale.body),
      );
      expect(
        compactDesignSpec.tokens.entryGap,
        lessThan(classicDesignSpec.tokens.entryGap),
      );
      expect(compactDesignSpec.header, classicDesignSpec.header);
      expect(compactDesignSpec.sections, classicDesignSpec.sections);
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

  test('le modèle classique conserve les valeurs par défaut', () {
    expect(classicDesignSpec.tokens.pageMarginMm, 18);
    expect(classicDesignSpec.tokens.scale.body, 9.5);
    expect(classicDesignSpec.sections.headerRuleThickness, 1);
    expect(classicDesignSpec.header.photoShape, CvPhotoShape.circle);
    expect(classicDesignSpec.header.showPhoto, isTrue);
  });

  group('les réglages du CV surchargent la description', () {
    test('la couleur d’accent remplace celle du modèle', () {
      final spec = classicDesignSpec.withOverrides(accentColor: 0xFF7A2F4A);
      expect(spec.tokens.accentColor, 0xFF7A2F4A);
      // Le reste de la description reste intact.
      expect(spec.tokens.scale, classicDesignSpec.tokens.scale);
      expect(spec.header, classicDesignSpec.header);
      expect(spec.sections, classicDesignSpec.sections);
    });

    test('un modèle sans couleur refuse la surcharge', () {
      expect(plainDesignSpec.tokens.ignoresAccent, isTrue);
      final spec = plainDesignSpec.withOverrides(accentColor: 0xFF7A2F4A);
      expect(spec.tokens.accentColor, plainDesignSpec.tokens.accentColor);
    });

    test('l’affichage de la photo se surcharge pour tous les modèles', () {
      for (final design in CvDesign.values) {
        expect(
          design.spec.withOverrides(showPhoto: false).header.showPhoto,
          isFalse,
          reason: design.name,
        );
      }
    });

    test('sans réglage, la description reste inchangée', () {
      final spec = bannerDesignSpec.withOverrides();
      expect(spec.tokens.accentColor, bannerDesignSpec.tokens.accentColor);
      expect(spec.header.showPhoto, bannerDesignSpec.header.showPhoto);
    });
  });

  group('un modèle peut imposer son ordre de sections', () {
    const documentOrder = CvSection.values;

    test('sans ordre imposé, celui du CV est conservé', () {
      expect(
        classicDesignSpec.structure.orderedSections(documentOrder),
        documentOrder,
      );
    });

    test('le modèle académique place les formations avant les expériences', () {
      final order = academicDesignSpec.structure.orderedSections(documentOrder);
      expect(
        order.indexOf(CvSection.education),
        lessThan(order.indexOf(CvSection.experiences)),
      );
    });

    test('l’ordre imposé ne perd aucune section', () {
      final order = academicDesignSpec.structure.orderedSections(documentOrder);
      expect(order.toSet(), documentOrder.toSet());
      expect(order, hasLength(documentOrder.length));
    });

    test('une section absente du CV n’est pas réintroduite', () {
      final order = academicDesignSpec.structure.orderedSections([
        CvSection.personalInfo,
        CvSection.experiences,
      ]);
      expect(order, [CvSection.experiences, CvSection.personalInfo]);
    });
  });
}
