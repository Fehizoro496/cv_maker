import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_entry.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_experience.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 3, 4);

  test('un CV vide n’a que son identité', () {
    final document = CvDocument.empty(id: 'cv-1', now: now);
    expect(document.id, 'cv-1');
    expect(document.createdAt, now);
    expect(document.updatedAt, now);
    expect(document.profile, isEmpty);
    expect(document.experiences, isEmpty);
    expect(document.design, CvDesign.professional);
  });

  test('touched ne change que la date de modification', () {
    final document = CvDocument.empty(id: 'cv-1', now: now);
    final later = document.touched(now.add(const Duration(hours: 2)));
    expect(later.updatedAt, isNot(document.updatedAt));
    expect(later.createdAt, document.createdAt);
    expect(later.copyWith(updatedAt: document.updatedAt), document);
  });

  group('opérations sur les éléments répétables', () {
    final document = exampleCvDocument();

    test('ajouter une expérience', () {
      const added = CvExperience(id: 'exp-new', position: 'Stage');
      final next = document.copyWith(
        experiences: document.experiences.added(added),
      );
      expect(next.experiences.last, added);
      expect(document.experiences.length, 3);
    });

    test('modifier une expérience', () {
      final edited = document.experiences.first.copyWith(company: 'Autre');
      final next = document.copyWith(
        experiences: document.experiences.updated(edited),
      );
      expect(next.experiences.first.company, 'Autre');
      expect(document.experiences.first.company, 'Nexora');
    });

    test('supprimer une expérience', () {
      final next = document.copyWith(
        experiences: document.experiences.removed('exp-kipli'),
      );
      expect(next.experiences.map((e) => e.id), ['exp-nexora', 'exp-vertige']);
    });

    test('réordonner les expériences', () {
      final next = document.copyWith(
        experiences: document.experiences.reordered(0, 2),
      );
      expect(next.experiences.map((e) => e.id), [
        'exp-kipli',
        'exp-vertige',
        'exp-nexora',
      ]);
    });
  });

  group('visibilité des sections', () {
    final document = exampleCvDocument();

    test('masquer puis réafficher une section facultative', () {
      final hidden = document.withSectionVisible(CvSection.interests, false);
      expect(hidden.isVisible(CvSection.interests), isFalse);
      expect(document.isVisible(CvSection.interests), isTrue);
      expect(
        hidden
            .withSectionVisible(CvSection.interests, true)
            .isVisible(CvSection.interests),
        isTrue,
      );
    });

    test('masquer une section ne supprime pas son contenu', () {
      final hidden = document.withSectionVisible(CvSection.projects, false);
      expect(hidden.projects, document.projects);
    });

    test('une section obligatoire reste visible', () {
      final unchanged = document.withSectionVisible(CvSection.skills, false);
      expect(unchanged.isVisible(CvSection.skills), isTrue);
    });
  });

  test('entriesOf donne les éléments de chaque section', () {
    final document = exampleCvDocument();
    expect(document.entriesOf(CvSection.experiences), document.experiences);
    expect(
      document.entriesOf(CvSection.personalInfo),
      document.personalInfo.links,
    );
    expect(document.entriesOf(CvSection.profile), isEmpty);
    for (final section in CvSection.values) {
      expect(document.entriesOf(section), isNotNull, reason: section.name);
    }
  });

  test('hasContent distingue le profil, qui n’est pas une liste', () {
    final document = CvDocument.empty(id: 'cv-1', now: now);
    expect(document.hasContent(CvSection.profile), isFalse);
    expect(
      document.copyWith(profile: '   ').hasContent(CvSection.profile),
      isFalse,
    );
    expect(
      document.copyWith(profile: 'Bonjour').hasContent(CvSection.profile),
      isTrue,
    );
    expect(document.hasContent(CvSection.experiences), isFalse);
    expect(exampleCvDocument().hasContent(CvSection.experiences), isTrue);
  });

  test('withDesign change le modèle sans toucher au contenu', () {
    final document = exampleCvDocument();
    final modern = document.withDesign(CvDesign.modern);
    expect(modern.design, CvDesign.modern);
    expect(modern.copyWith(presentation: document.presentation), document);
  });

  test('aller-retour JSON sans perte sur un CV complet', () {
    final document = exampleCvDocument()
        .withDesign(CvDesign.minimal)
        .withSectionVisible(CvSection.references, false);
    expect(CvDocument.fromJson(document.toJson()), document);
  });

  test('le JSON ne contient pas de photo', () {
    expect(exampleCvDocument().toJson().keys, isNot(contains('photo')));
  });
}
