import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sélectionne les informations personnelles par défaut', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedSectionProvider), CvSection.personalInfo);
  });

  test('select change la section sélectionnée', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(selectedSectionProvider.notifier).select(CvSection.skills);

    expect(container.read(selectedSectionProvider), CvSection.skills);
  });
}
