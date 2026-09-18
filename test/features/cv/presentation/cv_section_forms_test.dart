import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final document = exampleCvDocument();

  group('les champs du document', () {
    test('chaque champ relit ce qu’il vient d’écrire', () {
      for (final field in CvDocumentFields.all) {
        final written = field.write(document, 'valeur ${field.label}');
        expect(
          field.read(written),
          'valeur ${field.label}',
          reason: field.label,
        );
      }
    });

    test('écrire un champ ne touche à aucun autre', () {
      final written = CvDocumentFields.firstName.write(document, 'Alice');
      for (final field in CvDocumentFields.all) {
        if (field == CvDocumentFields.firstName) continue;
        expect(field.read(written), field.read(document), reason: field.label);
      }
    });

    test('les libellés sont uniques', () {
      final labels = CvDocumentFields.all.map((field) => field.label);
      expect(labels.toSet(), hasLength(CvDocumentFields.all.length));
    });
  });

  group('les formulaires de section', () {
    test('couvrent toutes les sections à éléments répétables', () {
      for (final section in CvSection.values) {
        if (section == CvSection.profile) {
          expect(cvSectionForms[section], isNull);
          continue;
        }
        expect(cvSectionForms[section], isNotNull, reason: section.name);
      }
    });

    test('chaque champ relit ce qu’il vient d’écrire', () {
      for (final entry in cvSectionForms.entries) {
        final form = entry.value;
        final created = form.create('test-id');
        for (final field in form.fields) {
          switch (field) {
            case CvEntryTextField():
              final written = field.write(created, 'texte');
              expect(field.read(written), 'texte', reason: field.label);
            case CvEntryMonthYearField():
              const value = CvMonthYear(2024, 6);
              final written = field.write(created, value);
              expect(field.read(written), value, reason: field.label);
              expect(field.read(field.write(written, null)), isNull);
            case CvEntryFlagField():
              expect(field.read(field.write(created, true)), isTrue);
              expect(field.read(field.write(created, false)), isFalse);
          }
        }
      }
    });

    test('un élément créé porte l’identifiant demandé', () {
      for (final form in cvSectionForms.values) {
        expect(form.create('abc').id, 'abc');
      }
    });

    test('les libellés d’une même section sont uniques', () {
      for (final entry in cvSectionForms.entries) {
        final labels = entry.value.fields.map((field) => field.label);
        expect(
          labels.toSet(),
          hasLength(entry.value.fields.length),
          reason: entry.key.name,
        );
      }
    });

    test('ajouter, modifier, réordonner puis supprimer un élément', () {
      for (final entry in cvSectionForms.entries) {
        final section = entry.key;
        final form = entry.value;
        final before = form.read(document).length;

        final added = form.added(document, 'nouveau');
        expect(form.read(added), hasLength(before + 1));
        expect(form.read(added).last.id, 'nouveau');

        final textField = form.fields.whereType<CvEntryTextField>().first;
        final updated = form.updated(
          added,
          textField.write(form.read(added).last, 'modifié'),
        );
        expect(textField.read(form.read(updated).last), 'modifié');

        final reordered = form.reordered(updated, before, 0);
        expect(form.read(reordered).first.id, 'nouveau');

        final removed = form.removed(reordered, 'nouveau');
        expect(form.read(removed), hasLength(before));
        expect(
          form.read(removed).map((e) => e.id),
          isNot(contains('nouveau')),
          reason: section.name,
        );
      }
    });

    test(
      'le titre et le sous-titre du résumé viennent de la première rangée',
      () {
        final experiences = cvSectionForms[CvSection.experiences]!;
        expect(experiences.titleField.label, 'Poste');
        expect(experiences.subtitleField?.label, 'Entreprise');
        final interests = cvSectionForms[CvSection.interests]!;
        expect(interests.titleField.label, 'Intitulé');
        // Une rangée d'un seul champ n'a pas de sous-titre.
        expect(interests.subtitleField, isNull);
      },
    );

    test('la date de fin d’une expérience en cours est désactivée', () {
      final form = cvSectionForms[CvSection.experiences]!;
      final end = form.fields.whereType<CvEntryMonthYearField>().last;
      final current = form.fields.whereType<CvEntryFlagField>().first;
      final entry = form.create('exp');
      expect(end.isEnabled?.call(entry), isTrue);
      expect(end.isEnabled?.call(current.write(entry, true)), isFalse);
    });

    test('écrire un élément préserve le reste du document', () {
      final form = cvSectionForms[CvSection.skills]!;
      final written = form.added(document, 'skill');
      expect(written.experiences, document.experiences);
      expect(written.personalInfo, document.personalInfo);
      expect(written.profile, document.profile);
      expect(written.presentation, document.presentation);
    });

    test('le CV d’exemple survit à un aller-retour JSON après écriture', () {
      final form = cvSectionForms[CvSection.experiences]!;
      final written = form.added(document, 'exp-neuve');
      expect(CvDocument.fromJson(written.toJson()), written);
    });
  });

  group('les formulaires des sections personnalisées', () {
    CvCustomSection section(CvCustomSectionType type) =>
        CvCustomSection(id: type.name, name: type.name, type: type);
    final withCustom = document.copyWith(
      customSections: [
        for (final type in CvCustomSectionType.values) section(type),
      ],
    );

    test('un texte libre n’a pas de formulaire de liste', () {
      expect(customSectionForm(section(CvCustomSectionType.freeText)), isNull);
    });

    test('une liste datée reprend la forme des expériences', () {
      final form = customSectionForm(section(CvCustomSectionType.datedList))!;
      expect(form.fields.map((f) => f.label), [
        'Titre',
        'Sous-titre',
        'Début',
        'Fin',
        'En cours',
        'Description',
      ]);
      final end = form.fields.whereType<CvEntryMonthYearField>().last;
      final current = form.fields.whereType<CvEntryFlagField>().single;
      final item = form.create('i');
      expect(end.isEnabled?.call(current.write(item, true)), isFalse);
    });

    test('une liste simple se limite au titre et à la description', () {
      final form = customSectionForm(section(CvCustomSectionType.simpleList))!;
      expect(form.fields.map((f) => f.label), ['Titre', 'Description courte']);
      expect(form.addLabel, 'Ajouter un élément');
    });

    test('chaque champ relit ce qu’il vient d’écrire', () {
      for (final type in [
        CvCustomSectionType.datedList,
        CvCustomSectionType.simpleList,
      ]) {
        final form = customSectionForm(section(type))!;
        final created = form.create('item');
        expect(created, isA<CvCustomItem>());
        for (final field in form.fields) {
          switch (field) {
            case CvEntryTextField():
              expect(field.read(field.write(created, 'x')), 'x');
            case CvEntryMonthYearField():
              const value = CvMonthYear(2025, 2);
              expect(field.read(field.write(created, value)), value);
            case CvEntryFlagField():
              expect(field.read(field.write(created, true)), isTrue);
          }
        }
      }
    });

    test('les opérations n’écrivent que dans la section visée', () {
      final form = customSectionForm(section(CvCustomSectionType.datedList))!;
      final added = form.added(withCustom, 'a');
      final twice = form.added(added, 'b');
      expect(form.read(twice).map((e) => e.id), ['a', 'b']);
      expect(
        twice.customSectionById('simpleList')!.items,
        isEmpty,
        reason: 'une autre section personnalisée reste intacte',
      );
      expect(twice.experiences, document.experiences);
      final reordered = form.reordered(twice, 1, 0);
      expect(form.read(reordered).map((e) => e.id), ['b', 'a']);
      expect(form.read(form.removed(reordered, 'b')).map((e) => e.id), ['a']);
    });

    test('cvSectionFormOf résout les deux sortes de sections', () {
      expect(cvSectionFormOf(CvSection.profile, withCustom), isNull);
      expect(
        cvSectionFormOf(CvSection.experiences, withCustom),
        same(cvSectionForms[CvSection.experiences]),
      );
      expect(
        cvSectionFormOf(const CvCustomSectionRef('datedList'), withCustom),
        isNotNull,
      );
      expect(
        cvSectionFormOf(const CvCustomSectionRef('freeText'), withCustom),
        isNull,
      );
      expect(
        cvSectionFormOf(const CvCustomSectionRef('inconnue'), withCustom),
        isNull,
      );
    });
  });
}
