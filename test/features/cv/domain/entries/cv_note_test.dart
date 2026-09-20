import 'package:cv_maker/features/cv/domain/entries/cv_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le détail est facultatif', () {
    const note = CvNote(id: 'int-1', label: 'Escalade');
    expect(note.description, isEmpty);
  });

  test('aller-retour JSON sans perte', () {
    const note = CvNote(
      id: 'int-2',
      label: 'Typographie',
      description: 'Collection de spécimens imprimés.',
    );
    expect(CvNote.fromJson(note.toJson()), note);
  });
}
