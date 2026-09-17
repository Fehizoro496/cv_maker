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
}
