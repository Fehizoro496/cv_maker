import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/section_visibility_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('toutes les sections facultatives sont affichées par défaut', () {
    expect(container.read(sectionVisibilityProvider), {
      CvSection.certifications: true,
      CvSection.projects: true,
      CvSection.interests: false,
      CvSection.references: false,
    });
  });

  test('toggle masque puis réaffiche une section facultative', () {
    final notifier = container.read(sectionVisibilityProvider.notifier);

    notifier.toggle(CvSection.projects);
    expect(
      container.read(sectionVisibilityProvider)[CvSection.projects],
      false,
    );

    notifier.toggle(CvSection.projects);
    expect(container.read(sectionVisibilityProvider)[CvSection.projects], true);
  });

  test('toggle refuse une section obligatoire', () {
    final notifier = container.read(sectionVisibilityProvider.notifier);

    expect(() => notifier.toggle(CvSection.experiences), throwsArgumentError);
  });
}
