import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deux appels donnent le même CV', () {
    expect(exampleCvDocument(), exampleCvDocument());
  });

  test('toutes les sections sont remplies, facultatives comprises', () {
    final document = exampleCvDocument();
    for (final section in CvSection.values) {
      expect(
        document.hasContent(section),
        isTrue,
        reason: 'section ${section.name} vide',
      );
    }
  });

  test('les identifiants des éléments sont uniques dans chaque section', () {
    final document = exampleCvDocument();
    for (final section in CvSection.values) {
      final ids = document.entriesOf(section).map((entry) => entry.id);
      expect(ids.toSet().length, ids.length, reason: section.name);
    }
  });

  test('aller-retour JSON sans perte', () {
    final document = exampleCvDocument();
    expect(CvDocument.fromJson(document.toJson()), document);
  });
}
