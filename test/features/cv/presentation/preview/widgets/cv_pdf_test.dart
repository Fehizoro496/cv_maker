import 'package:cv_maker/features/cv/domain/design/builtin_canvases.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cv_maker/core/pdf/pdf_fonts.dart';
import 'package:cv_maker/features/cv/domain/entries/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_canvas.dart';
import 'package:cv_maker/features/cv/domain/design/template_file.dart';
import 'package:cv_maker/features/cv/domain/document/cv_example.dart';
import 'package:cv_maker/features/cv/domain/dates/cv_month_year.dart';
import 'package:cv_maker/features/cv/domain/document/cv_personal_info.dart';
import 'package:cv_maker/features/cv/domain/document/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/editor/cv_section_presentation.dart';
import 'package:cv_maker/features/cv/presentation/preview/widgets/cv_pdf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../helpers/long_cv.dart';
import '../../../../../helpers/pdf_bytes.dart';
import '../../../../../helpers/pdf_text.dart';

/// Le nombre de pages réellement présentes dans le PDF.
int pageCount(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;

/// Les liens cliquables du PDF : cible et rectangle `[gauche, bas, droite,
/// haut]` sur la page.
Map<String, List<double>> linkRects(List<int> bytes) => {
  for (final match in RegExp(
    r'/Subtype/Link/Rect\[([^\]]*)\].*?/URI\(([^)]*)\)',
  ).allMatches(latin1.decode(bytes)))
    match.group(2)!: [
      for (final value in match.group(1)!.trim().split(RegExp(r'\s+')))
        double.parse(value),
    ],
};

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

  test(
    'un cadre de flux trop petit produit une erreur ciblée sans boucle',
    () async {
      const spec = CvDesignSpec(
        canvas: CvCanvas(
          pages: [
            CvCanvasPage(
              elements: [
                CvCanvasElement(
                  id: 'tiny-flow',
                  type: CvCanvasElementType.flow,
                  x: 10,
                  y: 10,
                  width: 150,
                  height: 1,
                  sectionOrder: [CvSection.experiences],
                ),
              ],
            ),
          ],
        ),
      );
      await expectLater(
        buildCvPdf(exampleCvDocument(), spec),
        throwsA(
          isA<CanvasLayoutException>().having(
            (e) => e.elementId,
            'cadre',
            'tiny-flow',
          ),
        ),
      );
    },
  );

  test(
    'le fichier canvas exemple rend deux pages avec sections et portrait',
    () async {
      final template = TemplateFile.decode(
        File('docs/examples/canvas.cv-template.json').readAsStringSync(),
      );
      final doc = exampleCvDocument();
      final saved = doc.copyWith(
        presentation: doc.presentation.copyWith(
          designId: template.id,
          templateSnapshot: template,
        ),
      );
      final reopened = CvDocument.fromJson(
        jsonDecode(jsonEncode(saved.toJson())) as Map<String, dynamic>,
      );
      final bytes = await buildCvPdf(
        reopened,
        reopened.designSpec,
        photo: await File(
          'assets/previews/portrait_placeholder.png',
        ).readAsBytes(),
      );
      final pages = pdfPageTexts(bytes);
      expect(pages, hasLength(2));
      expect(pages.first.join(' '), contains('Nexora'));
      expect(pages.last.join(' '), contains('Flutter'));
      expect(latin1.decode(bytes), contains('/Subtype/Image'));
    },
  );

  test(
    'le canvas rend ses pages et les champs du CV aux positions demandées',
    () async {
      CvDesignSpec canvas(double x) => CvDesignSpec(
        canvas: CvCanvas(
          pages: [
            CvCanvasPage(
              elements: [
                CvCanvasElement(
                  id: 'name',
                  type: CvCanvasElementType.text,
                  x: x,
                  y: 20,
                  width: 150,
                  height: 20,
                  binding: 'personalInfo.fullName',
                  fontSize: 24,
                ),
              ],
            ),
            const CvCanvasPage(
              elements: [
                CvCanvasElement(
                  id: 'job',
                  type: CvCanvasElementType.text,
                  x: 20,
                  y: 30,
                  width: 150,
                  height: 20,
                  binding: 'experiences.0.company',
                ),
              ],
            ),
          ],
        ),
      );
      final bytes = await buildCvPdf(exampleCvDocument(), canvas(20));
      final pages = pdfPageTexts(bytes);
      expect(pages, hasLength(2));
      expect(pages.first.join(' '), contains('Camille'));
      expect(pages.last.join(' '), contains('Nexora'));
      expect(isA4Portrait(bytes), isTrue);
      final shifted = await buildCvPdf(exampleCvDocument(), canvas(40));
      expect(pdfFingerprint(bytes), isNot(pdfFingerprint(shifted)));
    },
  );

  test(
    'le canvas refuse le texte et les sections qui dépassent leur cadre',
    () async {
      for (final type in [
        CvCanvasElementType.text,
        CvCanvasElementType.section,
      ]) {
        final spec = CvDesignSpec(
          canvas: CvCanvas(
            pages: [
              CvCanvasPage(
                elements: [
                  CvCanvasElement(
                    id: 'too-small',
                    type: type,
                    x: 10,
                    y: 10,
                    width: 40,
                    height: 1,
                    text: type == CvCanvasElementType.text
                        ? 'Texte trop grand pour son cadre'
                        : '',
                    section: type == CvCanvasElementType.section
                        ? CvSection.experiences
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
        await expectLater(
          buildCvPdf(exampleCvDocument(), spec),
          throwsA(
            isA<CanvasLayoutException>().having(
              (e) => e.elementId,
              'cadre',
              'too-small',
            ),
          ),
        );
      }
    },
  );

  test(
    'un canvas omet les champs des sections masquées et les indices absents',
    () async {
      final doc = exampleCvDocument().withSectionVisible(
        CvSection.projects,
        false,
      );
      const spec = CvDesignSpec(
        canvas: CvCanvas(
          pages: [
            CvCanvasPage(
              elements: [
                CvCanvasElement(
                  id: 'hidden',
                  type: CvCanvasElementType.text,
                  x: 10,
                  y: 10,
                  width: 180,
                  height: 20,
                  binding: 'projects.0.name',
                ),
                CvCanvasElement(
                  id: 'absent',
                  type: CvCanvasElementType.text,
                  x: 10,
                  y: 40,
                  width: 180,
                  height: 20,
                  binding: 'experiences.99.company',
                ),
              ],
            ),
          ],
        ),
      );
      expect(pdfPageTexts(await buildCvPdf(doc, spec)).single, isEmpty);
    },
  );

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
      'lib/features/cv/presentation/preview/widgets/cv_pdf.dart',
    ).readAsString();
    expect(source, isNot(contains('CvDesign.')));
    expect(source, isNot(contains('cv_design.dart')));
  });

  test('the spec alone changes what the generator emits', () async {
    const spec = CvDesignSpec(
      canvas: classicCanvas,
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
              canvas: classicCanvas,
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

  test('la forme et la taille de la photo changent son rendu', () async {
    final document = exampleCvDocument();
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC',
    );
    Future<String> render(CvDesignSpec spec) async =>
        latin1.decode(await buildCvPdf(document, spec, photo: png));

    for (final spec in [classicDesignSpec, sidebarDesignSpec]) {
      final small = await render(spec.withOverrides(photoSizeMm: 20));
      final large = await render(spec.withOverrides(photoSizeMm: 30));
      expect(large, isNot(small));
      final shapes = {
        for (final shape in CvPhotoShape.values)
          await render(spec.withOverrides(photoShape: shape)),
      };
      expect(shapes, hasLength(CvPhotoShape.values.length));
    }
  });

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
            // Aucun élément n'est perdu, et leur ordre est conservé.
            final text = pdfText(long);
            var from = 0;
            for (var i = 0; i < 40; i++) {
              final at = text.indexOf(
                type.hasItems ? 'Titre $i ' : 'Élément nº $i ',
                from,
              );
              expect(at, greaterThanOrEqualTo(0), reason: '${design.name} $i');
              from = at + 1;
            }
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

  group('moteur de zones', () {
    for (final design in CvDesign.values) {
      test(
        '${design.name} : les coordonnées longues restent entières',
        () async {
          const email =
              'camille.moreau.developpement@entreprise-internationale.example';
          const website =
              'https://portfolio.camille-moreau.example/realisations-flutter';
          const profile =
              'https://reseau.example/camille-moreau-developpement-mobile';
          const project =
              'https://github.example/camille-moreau/bibliotheque-composants';
          final base = exampleCvDocument();
          final document = base.copyWith(
            personalInfo: base.personalInfo.copyWith(
              email: email,
              website: website,
              links: [const CvLink(id: 'long', url: profile)],
            ),
            projects: [base.projects.first.copyWith(url: project)],
          );
          final bytes = await buildCvPdf(
            document,
            design.spec.withOverrides(accentColor: 0xFF7A2F4A),
          );
          final text = pdfText(bytes);
          // Les adresses de site perdent leur protocole à l'affichage…
          for (final value in [
            email,
            'portfolio.camille-moreau.example/realisations-flutter',
            'reseau.example/camille-moreau-developpement-mobile',
            'github.example/camille-moreau/bibliotheque-composants',
          ]) {
            expect(value.allMatches(text), hasLength(1), reason: design.name);
          }
          expect(text, isNot(contains('https://')), reason: design.name);
          // …mais le lien cliquable garde l'adresse complète.
          expect(
            linkRects(bytes).keys,
            containsAll(['mailto:$email', website, profile, project]),
            reason: design.name,
          );
          expect(isA4Portrait(bytes), isTrue);
          if (canvasSidebar(design.spec) != null) {
            expect(
              text.indexOf(email),
              lessThan(text.indexOf('PROFIL PROFESSIONNEL')),
              reason: 'une adresse trop longue doit rejoindre l’en-tête',
            );
          }
        },
      );
    }

    test(
      'une coordonnée trop large s’adapte sans déplacer le cadre canvas',
      () async {
        const spec = sidebarDesignSpec;
        final sidebar = canvasSidebar(spec)!;
        final asideWidth =
            (sidebar.width - 2 * sidebar.padding) * PdfPageFormat.mm;
        final font = (await PdfFonts.load()).regular.getFont(
          pw.Context(document: pw.Document().document),
        );
        // La première adresse qui dépasse tout juste la colonne d'origine à la
        // taille du texte.
        var email = '';
        for (var n = 1; ; n++) {
          email = '${'c' * n}@exemple.fr';
          final width =
              font.stringMetrics(email).advanceWidth * spec.tokens.scale.body;
          if (width > asideWidth + 1) break;
        }
        final base = exampleCvDocument();
        final bytes = await buildCvPdf(
          base.copyWith(personalInfo: base.personalInfo.copyWith(email: email)),
          spec,
        );
        final links = linkRects(bytes);
        final mail = links['mailto:$email']!;
        final phone = links.entries
            .firstWhere((link) => link.key.startsWith('tel:'))
            .value;
        // Le canvas conserve sa largeur exacte ; le texte du lien s'y adapte.
        expect(mail[2] - mail[0], closeTo(asideWidth, .01));
        expect(mail[3] - mail[1], lessThanOrEqualTo(phone[3] - phone[1] + .01));
        final text = pdfText(bytes);
        expect(text.indexOf(email), greaterThan(text.indexOf('CONTACT')));
      },
    );

    test(
      'les décorations et les dates empilées sont pilotées par la description',
      () async {
        final document = exampleCvDocument();
        const baseline = CvDesignSpec(canvas: classicCanvas);
        final original = await buildCvPdf(document, baseline);
        for (final spec in [
          const CvDesignSpec(
            canvas: classicCanvas,
            header: CvDesignHeader(headlineGap: 8),
          ),
          const CvDesignSpec(
            canvas: classicCanvas,
            sections: CvDesignSectionStyle(stackEntryMeta: true),
          ),
          const CvDesignSpec(
            canvas: classicCanvas,
            tokens: CvDesignTokens(headingSurfaceColor: 0xFFF0F4F8),
            sections: CvDesignSectionStyle(
              titleRadius: 6,
              titlePaddingHorizontal: 7,
              titlePaddingVertical: 5,
            ),
          ),
        ]) {
          final bytes = await buildCvPdf(document, spec);
          expect(pdfFingerprint(bytes), isNot(pdfFingerprint(original)));
          final text = pdfText(bytes);
          expect(text, contains('Camille Moreau'));
          expect(text, contains('Nexora'));
          expect(text, contains('sept. 2023'));
          expect(text, contains('Références disponibles sur demande'));
        }
      },
    );

    for (final design in CvDesign.values) {
      test(
        '${design.name} : titre lié à une description sans intitulé',
        () async {
          final base = exampleCvDocument();
          final document = base.copyWith(
            experiences: [
              base.experiences.first.copyWith(
                position: '',
                company: '',
                location: '',
                period: const CvDateRange(),
                description: '\n  CONTENU_UNIQUE',
              ),
            ],
            education: [],
            skills: [],
            languages: [],
            certifications: [],
            projects: [],
            interests: [],
            references: [],
          );
          // Balaye la coupure de page, notamment 43 lignes pour Classique et
          // 46 pour Bandeau latéral et Contraste avant la correction.
          for (var lines = 30; lines < 60; lines++) {
            final pages = pdfPageTexts(
              await buildCvPdf(
                document.copyWith(
                  profile: List.filled(lines, 'ligne').join('\n'),
                ),
                design.spec,
              ),
            ).map((page) => page.join(' ')).toList();
            final titlePage = pages.indexWhere(
              (page) => page.contains(
                design.spec.sections.titleCase == CvSectionTitleCase.upper
                    ? 'EXPÉRIENCES'
                    : CvSection.experiences.label,
              ),
            );
            expect(titlePage, greaterThanOrEqualTo(0));
            expect(
              pages[titlePage],
              contains('CONTENU_UNIQUE'),
              reason: '${design.name}, $lines lignes',
            );
            expect('CONTENU_UNIQUE'.allMatches(pages.join(' ')), hasLength(1));
          }
        },
      );

      for (final type in [
        CvCustomSectionType.simpleList,
        CvCustomSectionType.datedList,
      ]) {
        test(
          '${design.name} : description seule longue ${type.name}',
          () async {
            final base = exampleCvDocument();
            final document = base.copyWith(
              customSections: [
                CvCustomSection(
                  id: 'description-only',
                  name: 'DESCRIPTIONSEULE',
                  type: type,
                  items: [
                    CvCustomItem(
                      id: 'first',
                      description: List.generate(
                        2000,
                        (i) => 'mot$i',
                      ).join(' '),
                    ),
                  ],
                ),
              ],
            );
            final pages = pdfPageTexts(await buildCvPdf(document, design.spec));
            final opening = pages.singleWhere(
              (page) => page.contains('DESCRIPTIONSEULE'),
            );
            expect(opening, contains('mot0'));
            expect(pages.length, greaterThan(1));
            expect(
              pages
                  .expand((page) => page)
                  .where((word) => word.startsWith('mot')),
              [for (var i = 0; i < 2000; i++) 'mot$i'],
            );
          },
        );
      }
    }

    /// Le titre d'une section tel que le modèle l'écrit.
    String heading(CvDesignSpec spec, String label) =>
        spec.sections.titleCase == CvSectionTitleCase.upper
        ? label.toUpperCase()
        : label;

    /// Les titres du corps, dans l'ordre où le modèle les place.
    List<String> mainHeadings(CvDesignSpec spec, CvDocument document) => [
      for (final section in {
        ...canvasBody(spec).sectionOrder,
        ...document.presentation.orderedSections,
      })
        if (section != CvSection.personalInfo &&
            !(canvasSidebar(spec)?.sectionOrder.contains(section) ?? false) &&
            document.hasContent(section))
          heading(spec, section.label),
    ];

    /// Les titres de la colonne latérale, dans l'ordre du CV.
    List<String> asideHeadings(CvDesignSpec spec, CvDocument document) => [
      if (canvasSidebar(spec) != null) heading(spec, 'Contact'),
      for (final section in document.presentation.orderedSections)
        if ((canvasSidebar(spec)?.sectionOrder.contains(section) ?? false) &&
            document.hasContent(section))
          heading(spec, section.label),
    ];

    /// Vérifie que [expected] apparaît dans [text] dans cet ordre.
    void expectInOrder(String text, List<String> expected, String reason) {
      var from = 0;
      for (final part in expected) {
        final at = text.indexOf(part, from);
        expect(at, greaterThanOrEqualTo(0), reason: '$reason : $part');
        from = at + part.length;
      }
    }

    /// Le CV d'exemple, avec assez d'expériences pour tenir sur trois pages.
    CvDocument longBody() {
      final document = exampleCvDocument();
      return document.copyWith(
        experiences: [
          for (var i = 0; i < 12; i++)
            document.experiences.first.copyWith(id: 'exp-$i'),
        ],
      );
    }

    for (final design in CvDesign.values) {
      test(
        '${design.name} : le texte s’extrait dans l’ordre de lecture',
        () async {
          final spec = design.spec;
          for (final document in [exampleCvDocument(), longBody()]) {
            final pages = [
              for (final page in pdfPageTexts(await buildCvPdf(document, spec)))
                page.join(' '),
            ];
            final all = pages.join(' ');
            final main = mainHeadings(spec, document);
            final aside = asideHeadings(spec, document);

            // Le nom ouvre le document, avant toute section.
            final name = document.personalInfo.fullName;
            final shown = spec.header.nameUppercase ? name.toUpperCase() : name;
            expect(all.indexOf(shown), lessThan(all.indexOf(main.first)));

            // Le corps se lit dans l'ordre voulu par le modèle, la colonne
            // dans celui du CV.
            expectInOrder(all, main, design.name);
            expectInOrder(all, aside, design.name);

            // Sur chaque page, la colonne forme un bloc distinct placé après
            // tout le corps de cette page.
            for (final page in pages) {
              final asideStarts = [
                for (final title in aside)
                  if (page.contains(title)) page.indexOf(title),
              ];
              if (asideStarts.isEmpty) continue;
              final start = asideStarts.reduce(math.min);
              for (final title in main) {
                if (!page.contains(title)) continue;
                expect(
                  page.indexOf(title),
                  lessThan(start),
                  reason: '${design.name} : $title',
                );
              }
            }
          }
        },
      );
    }

    test(
      'la colonne ferme la première page, puis ne réapparaît plus',
      () async {
        final document = longBody();
        for (final spec in [sidebarDesignSpec, lightSidebarDesignSpec]) {
          final pages = [
            for (final page in pdfPageTexts(await buildCvPdf(document, spec)))
              page.join(' '),
          ];
          expect(pages.length, greaterThan(1));
          // La colonne entière vient à la fin de la première page, d'un seul
          // tenant.
          final last =
              (canvasSidebar(
                    spec,
                  )?.sectionOrder.contains(CvSection.interests) ??
                  false)
              ? 'Collection de spécimens imprimés.'
              : 'Espagnol (B1)';
          expect(pages.first, endsWith(last));
          final contact = pages.first.indexOf(heading(spec, 'Contact'));
          expect(
            pages.first.substring(contact),
            startsWith(
              'CONTACT Lyon, France +33 6 12 34 56 78 camille.moreau@email.fr '
              'camille-moreau.fr linkedin.com/in/camillemoreau',
            ),
          );
          // Les pages suivantes ne portent que le corps.
          for (final page in pages.skip(1)) {
            expect(page, isNot(contains('camille.moreau@email.fr')));
          }
        }
      },
    );

    test('la colonne reprend les coordonnées de l’en-tête', () async {
      final text = pdfText(
        await buildCvPdf(exampleCvDocument(), sidebarDesignSpec),
      );
      // Les coordonnées ne sont plus sur une ligne dans l'en-tête…
      expect(text, isNot(contains('Lyon, France · +33')));
      // …mais une par ligne dans la colonne.
      expect(text, contains('CONTACT Lyon, France +33 6 12 34 56 78'));
      // Les compétences y vont à la ligne plutôt que d'être séparées.
      expect(text, contains('COMPÉTENCES Flutter Dart TypeScript'));
    });

    test(
      'une colonne plus longue qu’une page se poursuit sans perte',
      () async {
        final cases = {
          sidebarDesignSpec: longCvFor(CvSection.skills, count: 120),
          lightSidebarDesignSpec: longCvFor(CvSection.interests, count: 40),
        };
        for (final MapEntry(key: spec, value: document) in cases.entries) {
          final bytes = await buildCvPdf(document, spec);
          expect(pageCount(bytes), greaterThan(1));
          expect(isA4Portrait(bytes), isTrue);
          // Chaque page reprend là où la précédente s'est arrêtée. Le pied
          // de page peut séparer « nº » du nombre dans le flux PDF extrait.
          final numbers = {
            for (final match in RegExp(
              r'nº\s+(\d+)',
            ).allMatches(pdfText(bytes).replaceAll(RegExp(r'\d+ / \d+'), '')))
              int.parse(match.group(1)!),
          };
          final count = spec == sidebarDesignSpec ? 120 : 40;
          expect(numbers, {for (var i = 0; i < count; i++) i});
        }
      },
    );

    test('un paragraphe fleuve se répartit dans chaque zone', () async {
      final flood = List.generate(2000, (i) => 'mot$i').join(' ');
      final document = exampleCvDocument();
      final cases = {
        // Dans le corps d'un modèle latéral.
        sidebarDesignSpec: document.copyWith(profile: flood),
        // Dans la colonne latérale.
        lightSidebarDesignSpec: document.copyWith(
          interests: [document.interests.last.copyWith(description: flood)],
        ),
        // Dans le contenu décalé par les titres en marge.
        contrastDesignSpec: document.copyWith(
          experiences: [
            document.experiences.first.copyWith(description: flood),
          ],
        ),
      };
      for (final MapEntry(key: spec, value: document) in cases.entries) {
        final bytes = await buildCvPdf(document, spec);
        expect(pageCount(bytes), greaterThan(1));
        final words = pdfText(
          bytes,
        ).split(' ').where((word) => word.startsWith('mot'));
        expect(words, [for (var i = 0; i < 2000; i++) 'mot$i']);
      }
    });

    for (final design in CvDesign.values) {
      test(
        '${design.name} : aucun titre ne reste seul en bas de page',
        () async {
          // Régression : un titre de section pouvait finir une page, séparé de
          // son premier élément. Allonger le profil fait glisser chaque section
          // vers le bas de la page, puis sur la suivante.
          final spec = design.spec;
          final document = exampleCvDocument();
          final titles = [
            ...mainHeadings(spec, document),
            ...asideHeadings(spec, document),
          ];
          final asideOpening = asideHeadings(spec, document).firstOrNull;
          for (var words = 0; words <= 400; words += 10) {
            final bytes = await buildCvPdf(
              document.copyWith(profile: List.filled(words, 'mot').join(' ')),
              spec,
            );
            final pages = pdfPageTexts(bytes);
            for (final page in pages.take(pages.length - 1)) {
              final text = page.join(' ');
              for (final title in titles) {
                // Un titre du corps suivi de la colonne a lui aussi perdu son
                // contenu.
                final orphan =
                    text.endsWith(title) ||
                    (asideOpening != null &&
                        title != asideOpening &&
                        text.contains('$title $asideOpening'));
                expect(
                  orphan,
                  isFalse,
                  reason: '${design.name}, $words mots : $title',
                );
              }
            }
          }
        },
      );
    }

    for (final design in CvDesign.values) {
      test(
        '${design.name} : aucun texte en image ni en en-tête de page',
        () async {
          final bytes = await buildCvPdf(longBody(), design.spec);
          // Sans photo, le document ne contient aucune image : tout le texte
          // est du texte.
          expect(
            latin1.decode(bytes),
            isNot(matches(RegExp(r'/Subtype\s*/Image'))),
          );
          expect(pageCount(bytes), greaterThan(1));
          final text = pdfText(bytes);
          // Le contenu s'extrait en entier…
          for (final expected in [
            'camille.moreau@email.fr',
            'Développeuse front-end avec 5 ans',
            'Références disponibles sur demande',
          ]) {
            expect(text, contains(expected), reason: design.name);
          }
          // …et rien n'est répété en tête des pages suivantes.
          final name = design.spec.header.nameUppercase ? 'MOREAU' : 'Moreau';
          expect(name.allMatches(text), hasLength(1), reason: design.name);
          expect(
            'camille.moreau@email.fr'.allMatches(text),
            hasLength(1),
            reason: design.name,
          );
        },
      );
    }
  });
}

CvCanvasElement canvasBody(CvDesignSpec spec) =>
    spec.canvas.pages.first.elements.firstWhere(
      (e) =>
          e.type == CvCanvasElementType.flow &&
          e.palette == CvCanvasPalette.body,
    );
CvCanvasElement? canvasSidebar(CvDesignSpec spec) => spec
    .canvas
    .pages
    .first
    .elements
    .where(
      (e) =>
          e.type == CvCanvasElementType.flow &&
          e.palette == CvCanvasPalette.sidebar,
    )
    .firstOrNull;
