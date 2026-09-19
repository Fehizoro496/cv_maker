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

  group('structure', () {
    test('seuls les deux modèles latéraux ont une colonne latérale', () {
      final withSidebar = {
        for (final design in CvDesign.values)
          if (!design.spec.structure.isSingleColumn) design,
      };
      expect(withSidebar, {CvDesign.sidebar, CvDesign.lightSidebar});
    });

    test('le bandeau latéral occupe 34 % de la page, à gauche', () {
      final sidebar = sidebarDesignSpec.structure.sidebar!;
      expect(sidebar.position, CvSidebarPosition.left);
      expect(sidebar.width, .34);
      expect(sidebar.holdsPhoto, isTrue);
      expect(sidebar.holdsContact, isTrue);
      expect(sidebar.sections, [CvSection.skills, CvSection.languages]);
    });

    test('le latéral clair occupe 32 % de la page, à droite', () {
      final sidebar = lightSidebarDesignSpec.structure.sidebar!;
      expect(sidebar.position, CvSidebarPosition.right);
      expect(sidebar.width, .32);
      expect(sidebar.holdsPhoto, isFalse);
      expect(sidebar.holdsContact, isTrue);
      expect(sidebar.sections, [CvSection.languages, CvSection.interests]);
    });

    test('une section est dans la colonne seulement si le modèle l’y met', () {
      final structure = sidebarDesignSpec.structure;
      expect(structure.inSidebar(CvSection.skills), isTrue);
      expect(structure.inSidebar(CvSection.experiences), isFalse);
      expect(classicDesignSpec.structure.inSidebar(CvSection.skills), isFalse);
    });

    test('seul le modèle contraste place ses titres en marge', () {
      for (final design in CvDesign.values) {
        expect(
          design.spec.structure.titleMargin,
          design == CvDesign.contrast ? .26 : 0,
          reason: design.name,
        );
      }
    });
  });

  test('la colonne latérale retombe sur l’aplat d’accent', () {
    const tokens = CvDesignTokens(
      accentColor: 0xFF123456,
      onAccentColor: 0xFFFEFEFE,
    );
    expect(tokens.effectiveSidebarSurfaceColor, 0xFF123456);
    expect(tokens.effectiveSidebarHeadingColor, 0xFFFEFEFE);
    expect(tokens.effectiveSidebarTextColor, 0xFFFEFEFE);
    final light = lightSidebarDesignSpec.tokens;
    expect(light.effectiveSidebarSurfaceColor, 0xFFEDF0F5);
    expect(light.effectiveSidebarHeadingColor, light.accentColor);
  });

  test(
    'la couleur d’accent colore le bandeau latéral, pas le latéral clair',
    () {
      expect(
        sidebarDesignSpec
            .withOverrides(accentColor: 0xFF7A2F4A)
            .tokens
            .effectiveSidebarSurfaceColor,
        0xFF7A2F4A,
      );
      expect(
        lightSidebarDesignSpec
            .withOverrides(accentColor: 0xFF7A2F4A)
            .tokens
            .effectiveSidebarSurfaceColor,
        0xFFEDF0F5,
      );
    },
  );

  test('le modèle contraste écrit son en-tête en capitales', () {
    final header = contrastDesignSpec.header;
    expect(header.nameUppercase, isTrue);
    expect(header.headlineUppercase, isTrue);
    expect(contrastDesignSpec.tokens.scale.name, 30);
    expect(contrastDesignSpec.sections.headerRuleLength, isNotNull);
    // La surcharge de la photo conserve ces propriétés.
    expect(
      contrastDesignSpec.withOverrides(showPhoto: false).header.nameUppercase,
      isTrue,
    );
    expect(classicDesignSpec.header.nameUppercase, isFalse);
    expect(classicDesignSpec.sections.headerRuleLength, isNull);
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

  test(
    'tous les titres colorés et leurs surfaces suivent le nouvel accent',
    () {
      for (final design in CvDesign.values) {
        final original = design.spec.tokens;
        final tokens = design.spec
            .withOverrides(accentColor: 0xFF7A2F4A)
            .tokens;
        if (tokens.ignoresAccent) {
          expect(tokens.effectiveHeadingColor, original.effectiveHeadingColor);
          continue;
        }
        expect(tokens.effectiveHeadingColor, 0xFF7A2F4A);
        if (design.spec.structure.sidebar != null) {
          expect(
            tokens.effectiveSidebarHeadingColor,
            tokens.sidebarSurfaceColor == null
                ? tokens.onAccentColor
                : 0xFF7A2F4A,
          );
        }
        if (tokens.tintHeadingSurface) {
          expect(
            tokens.effectiveHeadingSurfaceColor,
            isNot(original.effectiveHeadingSurfaceColor),
          );
          expect(tokens.effectiveHeadingSurfaceColor, 0xFFF4EEF1);
        }
      }
    },
  );

  test('les réglages conservent la mise en page des modèles modernes', () {
    for (final design in [
      CvDesign.sidebar,
      CvDesign.lightSidebar,
      CvDesign.contrast,
    ]) {
      final original = design.spec;
      final changed = original.withOverrides(
        accentColor: 0xFF7A2F4A,
        showPhoto: false,
      );
      expect(changed.sections.stackEntryMeta, isTrue);
      expect(changed.header.headlineGap, original.header.headlineGap);
      expect(changed.tokens.scale, same(original.tokens.scale));
      expect(changed.structure, same(original.structure));
      final sidebar = changed.structure.sidebar;
      if (sidebar != null) {
        expect(sidebar.gutter, greaterThan(sidebar.surfaceInset));
        expect(sidebar.cornerRadius, greaterThan(0));
      }
    }
  });

  group('les quatre groupes de propriétés sont indépendants', () {
    test(
      'le modèle à bandeau ne diffère que par son en-tête et ses titres',
      () {
        expect(bannerDesignSpec.header.fullWidthBanner, isTrue);
        expect(bannerDesignSpec.sections.titleRuleWidth, greaterThan(0));
        expect(bannerDesignSpec.sections.headerRuleThickness, isNull);
        expect(bannerDesignSpec.structure.isSingleColumn, isTrue);
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
