import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_presentation_preferences.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = CvPresentationPreferences();

  test('le modèle classique est choisi par défaut', () {
    expect(defaults.design, CvDesign.classic);
    expect(defaults.accent, CvAccent.blue);
    expect(defaults.showPhoto, isTrue);
  });

  test('un identifiant de modèle inconnu retombe sur le classique', () {
    expect(
      const CvPresentationPreferences(designId: 'supprimé').design,
      CvDesign.classic,
    );
  });

  test('une couleur d’accent inconnue retombe sur le bleu', () {
    expect(
      const CvPresentationPreferences(accentId: 'fuchsia').accent,
      CvAccent.blue,
    );
  });

  test('withDesign enregistre l’identifiant, pas le libellé', () {
    final banner = defaults.withDesign(CvDesign.banner);
    expect(banner.designId, 'banner');
    expect(banner.design, CvDesign.banner);
  });

  test('withAccent enregistre le nom de la couleur, pas son code', () {
    final green = defaults.withAccent(CvAccent.green);
    expect(green.accentId, 'green');
    expect(green.accent, CvAccent.green);
  });

  test('withTemplate applique les trois choix du catalogue', () {
    final applied = defaults.withTemplate(
      design: CvDesign.compact,
      accent: CvAccent.brown,
      showPhoto: false,
    );
    expect(applied.design, CvDesign.compact);
    expect(applied.accent, CvAccent.brown);
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
