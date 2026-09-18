import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:cv_maker/features/cv/presentation/selected_section_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('sélectionne les informations personnelles par défaut', () {
    expect(container.read(selectedSectionProvider), CvSection.personalInfo);
  });

  test('select change la section sélectionnée', () {
    container.read(selectedSectionProvider.notifier).select(CvSection.skills);

    expect(container.read(selectedSectionProvider), CvSection.skills);
  });

  group('une section personnalisée sélectionnée', () {
    late CvCustomSectionRef custom;

    setUp(() {
      final id = container
          .read(cvSessionProvider.notifier)
          .addCustomSection('Publications', CvCustomSectionType.datedList);
      custom = CvCustomSectionRef(id);
      container.read(selectedSectionProvider.notifier).select(custom);
    });

    test('reste sélectionnée tant qu’elle existe', () {
      container
          .read(cvSessionProvider.notifier)
          .renameCustomSection(custom.id, 'Articles');
      expect(container.read(selectedSectionProvider), custom);
    });

    test('cède la place à l’en-tête quand elle est supprimée', () {
      container.read(cvSessionProvider.notifier).removeCustomSection(custom.id);
      expect(container.read(selectedSectionProvider), CvSection.personalInfo);
    });

    test('cède la place à l’en-tête quand sa création est annulée', () {
      container.read(cvSessionProvider.notifier).undo();
      expect(container.read(selectedSectionProvider), CvSection.personalInfo);
    });
  });

  test('une section standard reste sélectionnée quoi qu’il arrive', () {
    container.read(selectedSectionProvider.notifier).select(CvSection.projects);
    container.read(cvSessionProvider.notifier).removeCustomSection('x');
    container
        .read(cvSessionProvider.notifier)
        .setSectionVisible(CvSection.projects, false);
    expect(container.read(selectedSectionProvider), CvSection.projects);
  });
}
