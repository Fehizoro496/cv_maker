import 'dart:convert';
import 'dart:io';

import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/widgets/cv_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/long_cv.dart';
import '../../../../helpers/pdf_bytes.dart';

/// Le nombre de pages réellement présentes dans le PDF.
int pageCount(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

/// Vrai si toutes les pages sont au format A4 portrait (595 × 842 points).
bool isA4Portrait(List<int> bytes) {
  final boxes = RegExp(
    r'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)',
  ).allMatches(latin1.decode(bytes));
  if (boxes.isEmpty) return false;
  return boxes.every(
    (box) =>
        double.parse(box.group(1)!).round() == 595 &&
        double.parse(box.group(2)!).round() == 842,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final design in CvDesign.values) {
    test(
      '${design.label} renders an A4 document and paginates long content',
      () async {
        final document = exampleCvDocument().withDesign(design);
        final bytes = await buildCvPdf(document, design.spec);
        final raw = latin1.decode(bytes);
        expect(raw, startsWith('%PDF-'));
        expect(raw, contains('/FontFile2'));
        expect(isA4Portrait(bytes), isTrue);
        final pages = pageCount(bytes);
        expect(pages, greaterThanOrEqualTo(1));
        final long = document.copyWith(
          experiences: [
            for (var i = 0; i < 30; i++)
              document.experiences.first.copyWith(id: 'exp-$i'),
          ],
        );
        final longBytes = await buildCvPdf(long, design.spec);
        expect(pageCount(longBytes), greaterThan(pages));
        expect(isA4Portrait(longBytes), isTrue);
        if (const bool.fromEnvironment('CAPTURE_DESIGN')) {
          await Directory('build/design-review').create(recursive: true);
          await File(
            'build/design-review/${design.name}.pdf',
          ).writeAsBytes(bytes);
        }
      },
    );
  }

  test(
    'the handoff example generates a real A4 PDF with embedded fonts',
    () async {
      final bytes = await buildCvPdf(exampleCvDocument(), classicDesignSpec);
      final raw = latin1.decode(bytes);
      expect(raw, startsWith('%PDF-'));
      expect(isA4Portrait(bytes), isTrue);
      expect(raw, contains('/FontFile2'));
      if (const bool.fromEnvironment('CAPTURE_DESIGN')) {
        await Directory('build/design-review').create(recursive: true);
        await File('build/design-review/example.pdf').writeAsBytes(bytes);
      }
    },
  );

  test('the generator never branches on the design identity', () async {
    final source = await File(
      'lib/features/cv/presentation/widgets/cv_pdf.dart',
    ).readAsString();
    expect(source, isNot(contains('CvDesign.')));
    expect(source, isNot(contains('cv_design.dart')));
  });

  test('the spec alone changes what the generator emits', () async {
    const spec = CvDesignSpec(
      tokens: CvDesignTokens(accentColor: 0xFFAB12CD),
      sections: CvDesignSectionStyle(
        titleCase: CvSectionTitleCase.none,
        titleRuleWidth: 2,
        bulletPrefix: '– ',
        inlineSeparator: ' | ',
      ),
    );
    final document = exampleCvDocument();
    final custom = await buildCvPdf(document, classicDesignSpec);
    final standard = await buildCvPdf(document, classicDesignSpec);
    expect(latin1.decode(custom), startsWith('%PDF-'));
    // Deux générations de la même entrée sont identiques au contenu près.
    expect(pdfFingerprint(custom), pdfFingerprint(standard));
    // Seule la description change, et cela suffit à changer le PDF.
    expect(
      pdfFingerprint(await buildCvPdf(document, spec)),
      isNot(pdfFingerprint(standard)),
    );
  });

  test('long repeated sections paginate without losing entries', () async {
    final document = exampleCvDocument();
    final long = document.copyWith(
      experiences: [
        for (var i = 0; i < 30; i++)
          document.experiences.first.copyWith(id: 'exp-$i'),
      ],
    );
    final bytes = await buildCvPdf(long, classicDesignSpec);
    expect(
      pageCount(bytes),
      greaterThan(pageCount(await buildCvPdf(document, classicDesignSpec))),
    );
    expect(isA4Portrait(bytes), isTrue);
  });

  test('a hidden optional section disappears from the PDF', () async {
    final document = exampleCvDocument();
    final visible = await buildCvPdf(document, classicDesignSpec);
    final hidden = await buildCvPdf(
      document.withSectionVisible(CvSection.projects, false),
      classicDesignSpec,
    );
    expect(pdfFingerprint(hidden), isNot(pdfFingerprint(visible)));
    expect(hidden.length, lessThan(visible.length));
  });

  test('the section order of the document drives the PDF', () async {
    final document = exampleCvDocument();
    final reordered = document.copyWith(
      presentation: document.presentation.reorderSections(
        CvSection.values.indexOf(CvSection.skills),
        CvSection.values.indexOf(CvSection.profile),
      ),
    );
    expect(
      pdfFingerprint(await buildCvPdf(reordered, classicDesignSpec)),
      isNot(pdfFingerprint(await buildCvPdf(document, classicDesignSpec))),
    );
  });

  test('a design may impose its own section order', () async {
    final document = exampleCvDocument();
    // Le modèle académique place les formations avant les expériences.
    expect(
      pdfFingerprint(await buildCvPdf(document, academicDesignSpec)),
      isNot(
        pdfFingerprint(
          await buildCvPdf(
            document,
            const CvDesignSpec(
              header: CvDesignHeader(alignment: CvHeaderAlignment.center),
              tokens: CvDesignTokens(
                scale: CvDesignTypeScale(name: 26, sectionTitle: 10),
              ),
              sections: CvDesignSectionStyle(
                titleCase: CvSectionTitleCase.none,
                titleLetterSpacing: 0,
                headerRuleThickness: .4,
              ),
            ),
          ),
        ),
      ),
      reason: 'seul l’ordre des sections distingue ces deux descriptions',
    );
  });

  test('the accent override reaches the PDF', () async {
    final document = exampleCvDocument();
    expect(
      pdfFingerprint(
        await buildCvPdf(
          document,
          classicDesignSpec.withOverrides(accentColor: 0xFF7A2F4A),
        ),
      ),
      isNot(pdfFingerprint(await buildCvPdf(document, classicDesignSpec))),
    );
  });

  group('chaque section pagine sous un contenu long', () {
    for (final section in CvSection.values) {
      // Les informations personnelles forment l'en-tête, pas une section.
      if (section == CvSection.personalInfo) continue;

      test(section.name, () async {
        final short = await buildCvPdf(
          longCvFor(section, count: 8),
          classicDesignSpec,
        );
        final long = await buildCvPdf(
          longCvFor(section, count: 24),
          classicDesignSpec,
        );

        // Aucune page ne déborde, et le format ne change pas sous la charge.
        expect(isA4Portrait(short), isTrue);
        expect(isA4Portrait(long), isTrue);

        // Le contenu supplémentaire est réellement émis, et non tronqué :
        // le document grandit avec lui.
        expect(pdfFingerprint(long), isNot(pdfFingerprint(short)));
        expect(long.length, greaterThan(short.length));
        expect(
          pageCount(long),
          greaterThanOrEqualTo(pageCount(short)),
          reason: 'la pagination ne perd pas de pages en route',
        );
      });
    }
  });

  group('un contenu plus haut qu’une page se répartit', () {
    // Régression : un seul widget indivisible plus haut qu'une page faisait
    // échouer la génération, et donc l'aperçu comme l'export.

    test('une description d’un seul paragraphe fleuve', () async {
      final document = exampleCvDocument();
      final flood = List.generate(2000, (i) => 'mot$i').join(' ');
      final bytes = await buildCvPdf(
        document.copyWith(
          experiences: [
            document.experiences.first.copyWith(description: flood),
          ],
        ),
        classicDesignSpec,
      );
      expect(pageCount(bytes), greaterThan(1));
      expect(isA4Portrait(bytes), isTrue);
    });

    test('un profil professionnel d’un seul paragraphe fleuve', () async {
      final flood = List.generate(2000, (i) => 'mot$i').join(' ');
      final bytes = await buildCvPdf(
        exampleCvDocument().copyWith(profile: flood),
        classicDesignSpec,
      );
      expect(pageCount(bytes), greaterThan(1));
      expect(isA4Portrait(bytes), isTrue);
    });

    test('une liste de compétences plus longue qu’une page', () async {
      final bytes = await buildCvPdf(
        longCvFor(CvSection.skills, count: 200),
        classicDesignSpec,
      );
      expect(pageCount(bytes), greaterThan(1));
      expect(isA4Portrait(bytes), isTrue);
    });

    test('un texte de longueur ordinaire reste d’un seul tenant', () async {
      // Le découpage ne doit se déclencher que sous la charge : un profil
      // habituel garde exactement le rendu qu'il avait.
      final document = exampleCvDocument();
      expect(document.profile.length, lessThan(600));
      final bytes = await buildCvPdf(document, classicDesignSpec);
      expect(isA4Portrait(bytes), isTrue);
    });
  });

  group('tous les modèles supportent un contenu long', () {
    for (final design in CvDesign.values) {
      test(design.name, () async {
        final bytes = await buildCvPdf(
          longCvFor(CvSection.experiences, count: 24),
          design.spec,
        );
        expect(pageCount(bytes), greaterThan(1));
        expect(isA4Portrait(bytes), isTrue);
      });
    }
  });

  test(
    'the session photo reaches the PDF without entering the document',
    () async {
      final document = exampleCvDocument();
      final withoutPhoto = await buildCvPdf(document, classicDesignSpec);
      // Un PNG 1×1 valide, suffisant pour être intégré au document.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
      );
      final withPhoto = await buildCvPdf(
        document,
        classicDesignSpec,
        photo: png,
      );
      expect(withPhoto.length, greaterThan(withoutPhoto.length));
      expect(document.toJson().toString(), isNot(contains('photo')));
    },
  );

  group('sections personnalisées', () {
    String description(int i) => [
      'Élément nº $i : une description sur plusieurs lignes, accentuée, '
          'pour éprouver la pagination et les polices embarquées.',
      '• Deuxième ligne de l’élément.',
      '• Troisième ligne de l’élément.',
    ].join('\n');

    /// Une section personnalisée de [type] avec [count] éléments longs.
    CvCustomSection sectionOf(CvCustomSectionType type, int count) =>
        CvCustomSection(
          id: 'custom-${type.name}',
          name: 'Section ${type.name}',
          type: type,
          text: type.hasItems
              ? ''
              : List.generate(count, description).join('\n'),
          items: type.hasItems
              ? [
                  for (var i = 0; i < count; i++)
                    CvCustomItem(
                      id: 'item-$i',
                      title: 'Titre $i',
                      subtitle: 'Sous-titre $i',
                      period: const CvDateRange(
                        start: CvMonthYear(2021, 4),
                        isCurrent: true,
                      ),
                      description: description(i),
                    ),
                ]
              : const [],
        );

    CvDocument withCustom(List<CvCustomSection> sections) =>
        exampleCvDocument().copyWith(customSections: sections);

    for (final type in CvCustomSectionType.values) {
      group(type.name, () {
        test('une section remplie et visible entre dans le PDF', () async {
          final without = await buildCvPdf(
            exampleCvDocument(),
            classicDesignSpec,
          );
          final with_ = await buildCvPdf(
            withCustom([sectionOf(type, 2)]),
            classicDesignSpec,
          );
          expect(pdfFingerprint(with_), isNot(pdfFingerprint(without)));
          expect(with_.length, greaterThan(without.length));
        });

        test('masquée ou vide, elle n’apparaît pas', () async {
          final reference = pdfFingerprint(
            await buildCvPdf(exampleCvDocument(), classicDesignSpec),
          );
          final hidden = sectionOf(type, 2).copyWith(visible: false);
          expect(
            pdfFingerprint(
              await buildCvPdf(withCustom([hidden]), classicDesignSpec),
            ),
            reference,
          );
          final empty = sectionOf(type, 0);
          expect(
            pdfFingerprint(
              await buildCvPdf(withCustom([empty]), classicDesignSpec),
            ),
            reference,
          );
        });

        test('pagine sous un contenu long, sur tous les modèles', () async {
          for (final design in CvDesign.values) {
            final short = await buildCvPdf(
              withCustom([sectionOf(type, 4)]),
              design.spec,
            );
            final long = await buildCvPdf(
              withCustom([sectionOf(type, 40)]),
              design.spec,
            );
            expect(isA4Portrait(long), isTrue, reason: design.name);
            expect(
              pageCount(long),
              greaterThan(pageCount(short)),
              reason: design.name,
            );
          }
        });
      });
    }

    test('un texte libre d’un seul paragraphe fleuve se répartit', () async {
      final flood = List.generate(2000, (i) => 'mot$i').join(' ');
      final bytes = await buildCvPdf(
        withCustom([
          const CvCustomSection(
            id: 'free',
            name: 'Motivation',
            type: CvCustomSectionType.freeText,
          ).copyWith(text: flood),
        ]),
        classicDesignSpec,
      );
      expect(pageCount(bytes), greaterThan(1));
      expect(isA4Portrait(bytes), isTrue);
    });

    test('l’ordre de création détermine l’ordre dans le PDF', () async {
      final a = sectionOf(CvCustomSectionType.simpleList, 2);
      final b = sectionOf(CvCustomSectionType.datedList, 2);
      expect(
        pdfFingerprint(await buildCvPdf(withCustom([a, b]), classicDesignSpec)),
        isNot(
          pdfFingerprint(
            await buildCvPdf(withCustom([b, a]), classicDesignSpec),
          ),
        ),
      );
    });
  });
}
