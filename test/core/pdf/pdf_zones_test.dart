import 'package:cv_maker/core/pdf/pdf_fonts.dart';
import 'package:cv_maker/core/pdf/pdf_zones.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../helpers/pdf_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Les pages d'un document A4 sans marge, bâti par [build].
  Future<List<List<String>>> pages(List<pw.Widget> Function() build) async {
    final fonts = await PdfFonts.load();
    final pdf = pw.Document(theme: fonts.theme)
      ..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => build(),
        ),
      );
    return pdfPageTexts(await pdf.save());
  }

  List<pw.Widget> lines(String prefix, int count) => [
    for (var i = 0; i < count; i++) pw.Text('$prefix$i'),
  ];

  group('ZonedFlow', () {
    test(
      'les cadres avec décalage et hauteur fixe continuent sans perte',
      () async {
        final result = await pages(
          () => [
            ZonedFlow(
              zones: [
                PdfZone(
                  left: 20,
                  top: 100,
                  width: 200,
                  height: 70,
                  children: lines('item', 30),
                ),
              ],
            ),
          ],
        );
        expect(result.length, greaterThan(1));
        expect(result.expand((page) => page), [
          for (var i = 0; i < 30; i++) 'item$i',
        ]);
      },
    );
    test(
      'les zones sont émises dans l’ordre de la liste, pas de la page',
      () async {
        final result = await pages(
          () => [
            ZonedFlow(
              zones: [
                // La première zone est à droite : elle est pourtant lue d'abord.
                PdfZone(left: 300, width: 295, children: lines('corps', 3)),
                PdfZone(left: 0, width: 280, children: lines('colonne', 3)),
              ],
            ),
          ],
        );
        expect(result, [
          ['corps0', 'corps1', 'corps2', 'colonne0', 'colonne1', 'colonne2'],
        ]);
      },
    );

    test('chaque zone se poursuit sur la page suivante', () async {
      final result = await pages(
        () => [
          ZonedFlow(
            zones: [
              PdfZone(left: 0, width: 280, children: lines('corps', 3)),
              PdfZone(left: 300, width: 295, children: lines('colonne', 150)),
            ],
          ),
        ],
      );
      expect(result.length, greaterThan(1));
      // Le corps tient sur la première page, la colonne continue seule.
      expect(result.first.take(3), ['corps0', 'corps1', 'corps2']);
      expect(result.skip(1).expand((page) => page), isNot(contains('corps0')));
      // Rien n'est perdu ni répété, et l'ordre est conservé.
      expect(result.expand((page) => page).where((w) => w.startsWith('col')), [
        for (var i = 0; i < 150; i++) 'colonne$i',
      ]);
    });

    test('sur chaque page, la première zone précède la seconde', () async {
      final result = await pages(
        () => [
          ZonedFlow(
            zones: [
              PdfZone(left: 300, width: 295, children: lines('a', 120)),
              PdfZone(left: 0, width: 280, children: lines('b', 90)),
            ],
          ),
        ],
      );
      expect(result.length, greaterThan(1));
      for (final page in result) {
        final lastA = page.lastIndexWhere((w) => w.startsWith('a'));
        final firstB = page.indexWhere((w) => w.startsWith('b'));
        if (lastA >= 0 && firstB >= 0) expect(lastA, lessThan(firstB));
      }
    });

    test('un texte divisible se coupe en bas de page', () async {
      final flood = List.generate(3000, (i) => 'mot$i').join(' ');
      final result = await pages(
        () => [
          ZonedFlow(
            zones: [
              PdfZone(
                left: 0,
                width: 280,
                children: [pw.Text(flood, overflow: pw.TextOverflow.span)],
              ),
              PdfZone(left: 300, width: 295, children: lines('colonne', 2)),
            ],
          ),
        ],
      );
      expect(result.length, greaterThan(1));
      final words = result
          .expand((page) => page)
          .where((w) => w.startsWith('mot'));
      expect(words, [for (var i = 0; i < 3000; i++) 'mot$i']);
    });

    test('un bloc indivisible passe entier sur la page suivante', () async {
      final result = await pages(
        () => [
          ZonedFlow(
            zones: [
              PdfZone(
                left: 0,
                width: 595,
                children: [
                  pw.SizedBox(height: PdfPageFormat.a4.height - 20),
                  KeepTogether(
                    child: pw.Column(
                      children: [pw.Text('titre'), pw.Text('contenu')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      expect(result, [
        <String>[],
        ['titre', 'contenu'],
      ]);
    });

    test('une zone vide ne produit aucune page supplémentaire', () async {
      final result = await pages(
        () => [
          ZonedFlow(
            zones: [
              PdfZone(left: 0, width: 280, children: lines('corps', 2)),
              PdfZone(left: 300, width: 295, children: const []),
            ],
          ),
        ],
      );
      expect(result, [
        ['corps0', 'corps1'],
      ]);
    });
  });

  group('KeepTogether', () {
    Future<List<List<String>>> nearPageBottom(pw.Widget block) =>
        pages(() => [pw.SizedBox(height: PdfPageFormat.a4.height - 20), block]);

    test('une colonne ordinaire se coupe entre ses enfants', () async {
      // C'est le défaut que KeepTogether corrige : le titre reste seul.
      final result = await nearPageBottom(
        pw.Column(children: [pw.Text('titre'), pw.Text('contenu')]),
      );
      expect(result.first, ['titre']);
    });

    test('le bloc passe entier sur la page suivante', () async {
      final result = await nearPageBottom(
        KeepTogether(
          child: pw.Column(children: [pw.Text('titre'), pw.Text('contenu')]),
        ),
      );
      expect(result, [
        <String>[],
        ['titre', 'contenu'],
      ]);
    });
  });
}
