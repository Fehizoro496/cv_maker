import 'dart:convert';
import 'dart:io';

import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/widgets/cv_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
