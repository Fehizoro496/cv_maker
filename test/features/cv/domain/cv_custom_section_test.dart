import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_date_range.dart';
import 'package:cv_maker/features/cv/domain/cv_month_year.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = CvCustomItem(
    id: 'pub-1',
    title: 'Accessibilité et Flutter',
    subtitle: 'Revue Dev',
    period: CvDateRange(start: CvMonthYear(2024, 3), isCurrent: true),
    description: 'Article de fond.',
  );

  test('seul le texte libre n’a pas d’éléments', () {
    expect(CvCustomSectionType.freeText.hasItems, isFalse);
    expect(CvCustomSectionType.datedList.hasItems, isTrue);
    expect(CvCustomSectionType.simpleList.hasItems, isTrue);
  });

  test('une nouvelle section est visible et vide', () {
    const section = CvCustomSection(
      id: 's1',
      name: 'Publications',
      type: CvCustomSectionType.datedList,
    );
    expect(section.visible, isTrue);
    expect(section.items, isEmpty);
    expect(section.text, isEmpty);
    expect(section.hasContent, isFalse);
    expect(section.itemCount, 0);
  });

  test('une liste a du contenu dès qu’elle a un élément', () {
    const section = CvCustomSection(
      id: 's1',
      name: 'Publications',
      type: CvCustomSectionType.datedList,
      items: [
        item,
        CvCustomItem(id: 'pub-2'),
      ],
    );
    expect(section.hasContent, isTrue);
    expect(section.itemCount, 2);
  });

  test('un texte libre n’a de contenu que s’il n’est pas blanc', () {
    const blank = CvCustomSection(
      id: 's1',
      name: 'Motivation',
      type: CvCustomSectionType.freeText,
      text: '  \n ',
    );
    expect(blank.hasContent, isFalse);
    expect(blank.itemCount, 0);
    final filled = blank.copyWith(text: 'Un paragraphe.');
    expect(filled.hasContent, isTrue);
    expect(filled.itemCount, 1);
  });

  test('un texte libre ignore les éléments, une liste ignore le texte', () {
    const text = CvCustomSection(
      id: 's1',
      name: 'Motivation',
      type: CvCustomSectionType.freeText,
      items: [item],
    );
    expect(text.hasContent, isFalse);
    const list = CvCustomSection(
      id: 's2',
      name: 'Distinctions',
      type: CvCustomSectionType.simpleList,
      text: 'Ignoré',
    );
    expect(list.hasContent, isFalse);
  });

  test('l’aller-retour JSON est sans perte', () {
    const section = CvCustomSection(
      id: 's1',
      name: 'Publications',
      type: CvCustomSectionType.datedList,
      visible: false,
      text: 'conservé',
      items: [item],
    );
    expect(CvCustomSection.fromJson(section.toJson()), section);
    expect(CvCustomItem.fromJson(item.toJson()), item);
    expect(section.toJson()['type'], 'datedList');
  });

  test('un élément relu sans ses champs facultatifs reste valide', () {
    final read = CvCustomItem.fromJson({'id': 'x'});
    expect(read, const CvCustomItem(id: 'x'));
    final section = CvCustomSection.fromJson({
      'id': 's',
      'name': 'Bénévolat',
      'type': 'simpleList',
    });
    expect(section.visible, isTrue);
    expect(section.items, isEmpty);
  });

  test('le nom est limité à 40 caractères', () {
    expect(CvCustomSection.maxNameLength, 40);
  });
}
