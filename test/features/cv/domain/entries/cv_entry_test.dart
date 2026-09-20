import 'package:cv_maker/features/cv/domain/entries/cv_entry.dart';
import 'package:cv_maker/features/cv/domain/entries/cv_skill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final a = const CvSkill(id: 'a', name: 'Flutter');
  final b = const CvSkill(id: 'b', name: 'Dart');
  final c = const CvSkill(id: 'c', name: 'Git');
  final list = [a, b, c];

  test('added ajoute à la fin sans modifier la liste d’origine', () {
    final d = const CvSkill(id: 'd');
    expect(list.added(d), [a, b, c, d]);
    expect(list, [a, b, c]);
  });

  test('updated remplace l’élément de même identifiant', () {
    final renamed = b.copyWith(name: 'Dart 3');
    expect(list.updated(renamed), [a, renamed, c]);
    expect(list, [a, b, c]);
  });

  test('updated laisse la liste inchangée si l’identifiant est absent', () {
    expect(list.updated(const CvSkill(id: 'z')), [a, b, c]);
  });

  test('removed retire l’élément demandé', () {
    expect(list.removed('b'), [a, c]);
    expect(list.removed('z'), [a, b, c]);
    expect(list, [a, b, c]);
  });

  test('reordered déplace un élément', () {
    expect(list.reordered(0, 2), [b, c, a]);
    expect(list.reordered(2, 0), [c, a, b]);
    expect(list, [a, b, c]);
  });

  test('reordered ignore les index hors limites ou identiques', () {
    expect(list.reordered(1, 1), [a, b, c]);
    expect(list.reordered(-1, 1), [a, b, c]);
    expect(list.reordered(0, 3), [a, b, c]);
    expect(<CvSkill>[].reordered(0, 0), isEmpty);
  });

  test('byId retrouve un élément ou renvoie null', () {
    expect(list.byId('c'), c);
    expect(list.byId('z'), isNull);
  });
}
