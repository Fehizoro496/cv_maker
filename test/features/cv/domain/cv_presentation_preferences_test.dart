import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_presentation_preferences.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = CvPresentationPreferences();

  test('le modèle classique est choisi par défaut', () {
    expect(defaults.design, CvDesign.classic);
    expect(defaults.accentColor, CvAccent.defaultColor);
    expect(defaults.showPhoto, isTrue);
  });

  group('format de la photo', () {
    test('sans réglage, le modèle décide', () {
      expect(defaults.photoShape, isNull);
      expect(defaults.photoSizeMm, isNull);
    });

    test('la taille reste dans ses bornes', () {
      expect(
        defaults.withPhotoFormat(shape: null, sizeMm: 5).photoSizeMm,
        CvPresentationPreferences.minPhotoSizeMm,
      );
      expect(
        defaults.withPhotoFormat(shape: null, sizeMm: 99).photoSizeMm,
        CvPresentationPreferences.maxPhotoSizeMm,
      );
    });

    test('le réglage survit à un aller-retour JSON et au changement de '
        'modèle', () {
      final prefs = defaults
          .withPhotoFormat(shape: CvPhotoShape.rounded, sizeMm: 30)
          .withDesign(CvDesign.sidebar);
      final reread = CvPresentationPreferences.fromJson(prefs.toJson());
      expect(reread.photoShape, CvPhotoShape.rounded);
      expect(reread.photoSizeMm, 30);
    });
  });

  test('un identifiant de modèle inconnu retombe sur le classique', () {
    expect(
      const CvPresentationPreferences(designId: 'supprimé').design,
      CvDesign.classic,
    );
  });

  test('une couleur enregistrée sans opacité reste imprimable', () {
    // Le PDF ne rend pas la transparence : l'opacité est forcée à la lecture.
    expect(
      const CvPresentationPreferences(accentArgb: 0x00AB12CD).accentColor,
      0xFFAB12CD,
    );
  });

  test('la couleur d’accent est libre, hors de la palette', () {
    const custom = CvPresentationPreferences(accentArgb: 0xFF123456);
    expect(custom.accentColor, 0xFF123456);
    expect(CvAccent.palette, isNot(contains(0xFF123456)));
  });

  test('withDesign enregistre l’identifiant, pas le libellé', () {
    final banner = defaults.withDesign(CvDesign.banner);
    expect(banner.designId, 'banner');
    expect(banner.design, CvDesign.banner);
  });

  test('withAccent enregistre la couleur choisie', () {
    final custom = defaults.withAccent(0xFF7A2F4A);
    expect(custom.accentColor, 0xFF7A2F4A);
    // Une couleur sans opacité est corrigée à l'écriture.
    expect(defaults.withAccent(0x00123456).accentColor, 0xFF123456);
  });

  test('withTemplate applique les trois choix du catalogue', () {
    final applied = defaults.withTemplate(
      design: CvDesign.compact,
      accentArgb: CvAccent.brown.color,
      showPhoto: false,
    );
    expect(applied.design, CvDesign.compact);
    expect(applied.accentColor, CvAccent.brown.color);
    expect(applied.showPhoto, isFalse);
    // L'ordre et la visibilité des sections ne bougent pas.
    expect(applied.sectionOrder, defaults.sectionOrder);
    expect(applied.hiddenSections, defaults.hiddenSections);
  });

  test('sans ordre enregistré, les sections gardent leur ordre déclaré', () {
    expect(defaults.orderedSections, CvSection.values);
  });

  test('une section absente de l’ordre enregistré est ajoutée à la fin', () {
    const partial = CvPresentationPreferences(
      sectionOrder: [CvSection.education, CvSection.experiences],
    );
    expect(partial.orderedSections.take(2), [
      CvSection.education,
      CvSection.experiences,
    ]);
    expect(partial.orderedSections.toSet(), CvSection.values.toSet());
  });

  test('toutes les sections sont visibles par défaut', () {
    for (final section in CvSection.values) {
      expect(defaults.isVisible(section), isTrue, reason: section.name);
    }
  });

  test('une section facultative peut être masquée puis réaffichée', () {
    final hidden = defaults.withSectionVisible(CvSection.projects, false);
    expect(hidden.isVisible(CvSection.projects), isFalse);
    expect(hidden.hiddenSections, [CvSection.projects]);

    final shown = hidden.withSectionVisible(CvSection.projects, true);
    expect(shown.isVisible(CvSection.projects), isTrue);
    expect(shown.hiddenSections, isEmpty);
  });

  test('une section obligatoire ne peut pas être masquée', () {
    final unchanged = defaults.withSectionVisible(CvSection.experiences, false);
    expect(unchanged, same(defaults));
    expect(unchanged.isVisible(CvSection.experiences), isTrue);
  });

  test('reorderSections déplace une section et fixe l’ordre complet', () {
    final moved = defaults.reorderSections(0, 2);
    expect(moved.orderedSections.first, CvSection.profile);
    expect(moved.orderedSections[2], CvSection.personalInfo);
    expect(moved.sectionOrder.toSet(), CvSection.values.toSet());
  });

  test('reorderSections ignore les index hors limites', () {
    expect(defaults.reorderSections(0, 99), same(defaults));
    expect(defaults.reorderSections(-1, 0), same(defaults));
    expect(defaults.reorderSections(1, 1), same(defaults));
  });

  test('aller-retour JSON sans perte', () {
    final preferences = defaults
        .withDesign(CvDesign.academic)
        .withSectionVisible(CvSection.interests, false)
        .reorderSections(0, 3);
    expect(
      CvPresentationPreferences.fromJson(preferences.toJson()),
      preferences,
    );
  });
}
