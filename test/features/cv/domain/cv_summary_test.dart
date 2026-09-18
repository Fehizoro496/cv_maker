import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CvSummary summary(String id, int day, {String name = 'CV'}) =>
      CvSummary(id: id, name: name, updatedAt: DateTime.utc(2026, 1, day));

  test('résume un document par son identifiant, son nom et sa date', () {
    final document = CvDocument.empty(
      id: 'a',
      now: DateTime.utc(2026, 1, 3),
      name: 'Mon CV',
    );

    expect(
      CvSummary.of(document),
      CvSummary(id: 'a', name: 'Mon CV', updatedAt: DateTime.utc(2026, 1, 3)),
    );
  });

  test('deux résumés égaux ont le même hashCode', () {
    expect(summary('a', 1), summary('a', 1));
    expect(summary('a', 1).hashCode, summary('a', 1).hashCode);
    expect(summary('a', 1), isNot(summary('a', 2)));
    expect(summary('a', 1), isNot(summary('a', 1, name: 'Autre')));
  });

  test('trie du plus récemment modifié au plus ancien', () {
    final list = [summary('a', 1), summary('c', 3), summary('b', 2)]
      ..sortByRecency();

    expect(list.map((s) => s.id), ['c', 'b', 'a']);
  });

  test('à date égale, l’identifiant départage', () {
    final list = [summary('b', 1), summary('a', 1)]..sortByRecency();

    expect(list.map((s) => s.id), ['a', 'b']);
  });

  test('upserted remplace un résumé existant et retrie', () {
    final list = [summary('b', 2), summary('a', 1)];

    final next = list.upserted(summary('a', 3, name: 'Renommé'));

    expect(next.map((s) => s.id), ['a', 'b']);
    expect(next.first.name, 'Renommé');
    expect(list.map((s) => s.id), ['b', 'a'], reason: 'liste d’origine');
  });

  test('upserted ajoute un résumé inconnu', () {
    final next = [summary('a', 1)].upserted(summary('b', 2));

    expect(next.map((s) => s.id), ['b', 'a']);
  });

  test('without retire un résumé', () {
    final next = [summary('a', 1), summary('b', 2)].without('a');

    expect(next.map((s) => s.id), ['b']);
  });
}
