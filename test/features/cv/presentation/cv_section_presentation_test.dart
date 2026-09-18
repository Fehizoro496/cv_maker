import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque section a un libellé français unique', () {
    final labels = CvSection.values.map((section) => section.label).toList();

    expect(labels.toSet(), hasLength(CvSection.values.length));
    expect(labels, everyElement(isNotEmpty));
    expect(CvSection.experiences.label, 'Expériences');
    expect(CvSection.interests.label, "Centres d'intérêt");
  });

  test('chaque section a un texte d\'aide', () {
    expect(
      CvSection.values.map((section) => section.helpText),
      everyElement(isNotEmpty),
    );
    expect(
      CvSection.personalInfo.helpText,
      'Ces informations apparaissent en haut de votre CV.',
    );
  });

  test('chaque section a une icône unique', () {
    final icons = CvSection.values.map((section) => section.icon).toSet();

    expect(icons, hasLength(CvSection.values.length));
    expect(CvSection.skills.icon, Icons.bolt);
  });

  group('sections personnalisées', () {
    const publications = CvCustomSection(
      id: 'pubs',
      name: 'Publications',
      type: CvCustomSectionType.datedList,
      items: [
        CvCustomItem(id: 'a'),
        CvCustomItem(id: 'b'),
      ],
    );
    final document = exampleCvDocument().copyWith(
      customSections: const [publications],
    );
    const ref = CvCustomSectionRef('pubs');

    test('une référence se présente selon sa sorte', () {
      const CvSectionRef skills = CvSection.skills;
      const CvSectionRef profile = CvSection.profile;
      expect(skills.labelIn(document), 'Compétences');
      expect(profile.helpTextIn(document), CvSection.profile.helpText);
      expect(skills.icon, Icons.bolt);
      expect(ref.labelIn(document), 'Publications');
      expect(ref.helpTextIn(document), 'Liste datée · 2 éléments');
      expect(ref.icon, customSectionIcon);
      expect(const CvCustomSectionRef('x').labelIn(document), isEmpty);
    });

    test('chaque type a un libellé, une explication et une icône', () {
      for (final type in CvCustomSectionType.values) {
        expect(type.label, isNotEmpty);
        expect(type.explanation, isNotEmpty);
      }
      expect(
        CvCustomSectionType.values.map((t) => t.icon).toSet(),
        hasLength(3),
      );
    });

    test('le résumé compte les éléments, sauf pour un texte libre', () {
      expect(
        publications.copyWith(items: const []).summary,
        'Liste datée · 0 élément',
      );
      expect(
        publications.copyWith(items: const [CvCustomItem(id: 'a')]).summary,
        'Liste datée · 1 élément',
      );
      expect(
        publications.copyWith(type: CvCustomSectionType.freeText).summary,
        'Texte libre',
      );
    });

    group('validation du nom', () {
      test('un nom libre est accepté', () {
        expect(customSectionNameError('Bénévolat', document), isNull);
      });

      test('un nom vide ou blanc est refusé', () {
        expect(customSectionNameError('', document), isNotNull);
        expect(customSectionNameError('   ', document), isNotNull);
      });

      test('au-delà de 40 caractères, le nom est refusé', () {
        expect(customSectionNameError('a' * 40, document), isNull);
        expect(customSectionNameError('a' * 41, document), isNotNull);
      });

      test('les doublons sont refusés, casse et espaces ignorés', () {
        const duplicate = 'Une section porte déjà ce nom.';
        expect(customSectionNameError(' publications ', document), duplicate);
        expect(customSectionNameError('EXPÉRIENCES', document), duplicate);
        expect(
          customSectionNameError("Centres d'intérêt", document),
          duplicate,
        );
      });

      test('une section renommée ne se heurte pas à son propre nom', () {
        expect(
          customSectionNameError('Publications', document, exceptId: 'pubs'),
          isNull,
        );
      });
    });
  });
}
