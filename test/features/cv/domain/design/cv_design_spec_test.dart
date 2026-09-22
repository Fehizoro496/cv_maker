import 'package:cv_maker/features/cv/domain/design/cv_canvas.dart';
import 'package:cv_maker/features/cv/domain/design/builtin_canvases.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/document/cv_section.dart';
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

  group('canvas', () {
    test('seuls les deux modeles lateraux ont deux cadres de contenu', () {
      expect(
        {
          for (final design in CvDesign.values)
            if (flows(design.spec).length == 2) design,
        },
        {CvDesign.sidebar, CvDesign.lightSidebar},
      );
    });
    test('les cadres lateraux portent leurs sections et leurs coordonnees', () {
      final left = flows(sidebarDesignSpec).last;
      final right = flows(lightSidebarDesignSpec).last;
      expect(left.x, lessThan(flows(sidebarDesignSpec).first.x));
      expect(right.x, greaterThan(flows(lightSidebarDesignSpec).first.x));
      expect(left.showPhoto, isTrue);
      expect(right.showPhoto, isFalse);
      expect(left.showContacts, isTrue);
      expect(right.showContacts, isTrue);
      expect(left.sectionOrder, [CvSection.skills, CvSection.languages]);
      expect(right.sectionOrder, [CvSection.languages, CvSection.interests]);
    });
    test('seul contraste reserve une marge aux titres', () {
      for (final design in CvDesign.values) {
        expect(
          flows(design.spec).first.titleMargin,
          design == CvDesign.contrast ? .26 : 0,
        );
      }
    });
    test(
      'le canvas est obligatoire et les anciennes proprietes sont refusees',
      () {
        expect(() => CvDesignSpec.fromJson({}), throwsA(isA<Exception>()));
        expect(
          () => CvDesignSpec.fromJson({
            ...classicDesignSpec.toJson(),
            'structure': {},
          }),
          throwsA(isA<Exception>()),
        );
      },
    );
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
        if (flows(design.spec).length == 2) {
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
      expect(changed.canvas, same(original.canvas));
    }
  });

  group('les quatre groupes de propriétés sont indépendants', () {
    test(
      'le modèle à bandeau ne diffère que par son en-tête et ses titres',
      () {
        expect(bannerDesignSpec.header.fullWidthBanner, isTrue);
        expect(bannerDesignSpec.sections.titleRuleWidth, greaterThan(0));
        expect(bannerDesignSpec.sections.headerRuleThickness, isNull);
        expect(flows(bannerDesignSpec).length == 1, isTrue);
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
        canvas: classicCanvas,
        tokens: CvDesignTokens(accentColor: 0xFF00FF00),
      );
      expect(recoloured.tokens.accentColor, 0xFF00FF00);
      expect(recoloured.header.fullWidthBanner, isFalse);
      expect(flows(recoloured).length == 1, isTrue);
      expect(recoloured.sections.titleCase, CvSectionTitleCase.upper);
    });
  });

  test('le modèle classique conserve les valeurs par défaut', () {
    expect(flows(classicDesignSpec).first.x, 18);
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

    test('la forme et la taille de la photo se surchargent', () {
      final spec = sidebarDesignSpec.withOverrides(
        photoShape: CvPhotoShape.rounded,
        photoSizeMm: 32,
      );
      expect(spec.header.photoShape, CvPhotoShape.rounded);
      expect(spec.header.photoDiameterMm, 32);
      // Le reste de l'en-tête reste celui du modèle.
      expect(spec.header.photoGap, sidebarDesignSpec.header.photoGap);
      expect(spec.header.showPhoto, sidebarDesignSpec.header.showPhoto);
    });

    test('sans réglage, la description reste inchangée', () {
      final spec = bannerDesignSpec.withOverrides();
      expect(spec.tokens.accentColor, bannerDesignSpec.tokens.accentColor);
      expect(spec.header.showPhoto, bannerDesignSpec.header.showPhoto);
    });
  });

  test('le canvas academique place les formations avant les experiences', () {
    expect(flows(academicDesignSpec).first.sectionOrder, [
      CvSection.profile,
      CvSection.education,
      CvSection.experiences,
    ]);
    expect(flows(academicDesignSpec).first.includeRemaining, isTrue);
  });
}

List<CvCanvasElement> flows(CvDesignSpec spec) => [
  for (final page in spec.canvas.pages)
    for (final element in page.elements)
      if (element.type == CvCanvasElementType.flow) element,
];
