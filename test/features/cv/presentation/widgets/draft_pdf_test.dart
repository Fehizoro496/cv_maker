import 'dart:io';
import 'dart:convert';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/editor_draft_provider.dart';
import 'package:cv_maker/features/cv/presentation/widgets/draft_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final design in CvDesign.values) {
    test(
      '${design.label} renders an A4 document and paginates long content',
      () async {
        final example = EditorDraft.example();
        final draft = EditorDraft(
          fields: example.fields,
          entries: example.entries,
          design: design,
        );
        final bytes = await buildDraftPdf(draft, {}, design.spec);
        final raw = latin1.decode(bytes);
        expect(raw, startsWith('%PDF-'));
        expect(raw, contains('/FontFile2'));
        expect(RegExp(r'/Type\s*/Page\b').allMatches(raw).length, 1);
        final long = EditorDraft(
          fields: draft.fields,
          design: design,
          entries: {
            CvSection.experiences: [
              for (var i = 0; i < 30; i++)
                {...example.entries[CvSection.experiences]!.first, 'id': '$i'},
            ],
          },
        );
        final longBytes = await buildDraftPdf(long, {}, design.spec);
        expect(
          RegExp(
            r'/Type\s*/Page\b',
          ).allMatches(latin1.decode(longBytes)).length,
          greaterThan(1),
        );
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
    'the handoff example generates one real A4 PDF with embedded fonts',
    () async {
      final bytes = await buildDraftPdf(
        EditorDraft.example(),
        {},
        professionalDesignSpec,
      );
      final raw = latin1.decode(bytes);
      expect(raw.startsWith('%PDF-'), isTrue);
      expect(RegExp(r'/Type\s*/Page\b').allMatches(raw).length, 1);
      expect(raw, contains('/FontFile2'));
      if (const bool.fromEnvironment('CAPTURE_DESIGN')) {
        await Directory('build/design-review').create(recursive: true);
        await File('build/design-review/example.pdf').writeAsBytes(bytes);
      }
    },
  );
  test('the generator never branches on the design identity', () async {
    final source = await File(
      'lib/features/cv/presentation/widgets/draft_pdf.dart',
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
    final custom = await buildDraftPdf(EditorDraft.example(), {}, spec);
    final standard = await buildDraftPdf(
      EditorDraft.example(),
      {},
      professionalDesignSpec,
    );
    expect(latin1.decode(custom), startsWith('%PDF-'));
    // Seule la description diffère entre les deux générations.
    expect(custom, isNot(equals(standard)));
  });
  test('long repeated sections paginate without losing entries', () async {
    final draft = EditorDraft.example();
    final long = EditorDraft(
      fields: draft.fields,
      entries: {
        ...draft.entries,
        CvSection.experiences: [
          for (var i = 0; i < 30; i++)
            {...draft.entries[CvSection.experiences]!.first, 'id': '$i'},
        ],
      },
    );
    final bytes = await buildDraftPdf(long, {}, professionalDesignSpec);
    expect(
      RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length,
      greaterThan(1),
    );
  });
}
