import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque section a un libellé français unique', () {
    final labels = CvSection.values.map((section) => section.label).toList();

    expect(labels.toSet(), hasLength(CvSection.values.length));
    expect(labels, everyElement(isNotEmpty));
    expect(CvSection.experiences.label, 'Expériences');
    expect(CvSection.interests.label, "Centres d'intérêt");
  });

  test('chaque section a un texte d\'aide', () {
    expect(
      CvSection.values.map((section) => section.helpText),
      everyElement(isNotEmpty),
    );
    expect(
      CvSection.personalInfo.helpText,
      'Ces informations apparaissent en haut de votre CV.',
    );
  });

  test('chaque section a une icône unique', () {
    final icons = CvSection.values.map((section) => section.icon).toSet();

    expect(icons, hasLength(CvSection.values.length));
    expect(CvSection.skills.icon, Icons.bolt);
  });
}
