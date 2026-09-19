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

  group('recherche', () {
    final list = [
      summary('dev', 3, name: 'CV Développeuse Front-End'),
      summary('design', 2, name: 'Portfolio design'),
      summary('coeur', 1, name: 'Lettre de Cœur'),
    ];

    List<String> idsFor(String query) =>
        list.matching(query).map((s) => s.id).toList();

    test('une recherche vide garde tout, dans le même ordre', () {
      expect(idsFor(''), ['dev', 'design', 'coeur']);
      expect(idsFor('   '), ['dev', 'design', 'coeur']);
    });

    test('ignore la casse et les accents, dans les deux sens', () {
      expect(idsFor('developpeuse'), ['dev']);
      expect(idsFor('DÉVELOPPEUSE'), ['dev']);
      expect(idsFor('coeur'), ['coeur']);
    });

    test('chaque mot doit apparaître, dans n’importe quel ordre', () {
      expect(idsFor('front cv'), ['dev']);
      expect(idsFor('cv design'), isEmpty);
    });

    test('une partie de mot suffit', () {
      expect(idsFor('port'), ['design']);
      expect(idsFor('absent'), isEmpty);
    });
  });

  test('trie par nom, accents et casse ignorés', () {
    final sorted = [
      summary('z', 1, name: 'zèbre'),
      summary('e', 1, name: 'Écologie'),
      summary('a', 1, name: 'arbre'),
      summary('e2', 2, name: 'ecologie'),
    ].sortedByName();

    expect(sorted.map((s) => s.id), ['a', 'e2', 'e', 'z']);
  });

  test('foldForSearch retire accents et ligatures', () {
    expect(foldForSearch('Œuvre Ça Ärger Ñandú'), 'oeuvre ca arger nandu');
  });
}
