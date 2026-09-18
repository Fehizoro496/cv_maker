import 'dart:typed_data';

import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/presentation/cv_section_forms.dart';
import 'package:cv_maker/features/cv/presentation/cv_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late CvSessionNotifier editor;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    editor = container.read(cvSessionProvider.notifier);
  });

  test('la session part du CV d’exemple, sans photo ni historique', () {
    expect(container.read(cvSessionProvider).document.id, 'example');
    expect(container.read(cvSessionProvider).photo, isNull);
    expect(editor.canUndo, isFalse);
    expect(editor.canRedo, isFalse);
  });

  test('écrire un champ du document alimente l’historique', () {
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    expect(editor.document.personalInfo.firstName, 'Alice');
    expect(editor.canUndo, isTrue);
    editor.undo();
    expect(editor.document.personalInfo.firstName, 'Camille');
    expect(editor.canRedo, isTrue);
    editor.redo();
    expect(editor.document.personalInfo.firstName, 'Alice');
  });

  test('écrire la même valeur ne crée pas d’étape', () {
    editor.setDocumentField(CvDocumentFields.firstName, 'Camille');
    expect(editor.canUndo, isFalse);
  });

  test('les frappes d’un même champ ne forment qu’une étape', () {
    editor.setDocumentField(CvDocumentFields.firstName, 'A');
    editor.setDocumentField(CvDocumentFields.firstName, 'Al');
    editor.setDocumentField(CvDocumentFields.firstName, 'Ali');
    editor.undo();
    expect(editor.document.personalInfo.firstName, 'Camille');
    expect(editor.canUndo, isFalse);
  });

  test('deux champs différents forment deux étapes', () {
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    editor.setDocumentField(CvDocumentFields.lastName, 'Martin');
    editor.undo();
    expect(editor.document.personalInfo.lastName, 'Moreau');
    expect(editor.document.personalInfo.firstName, 'Alice');
  });

  test('ajouter un élément retourne un identifiant stable et unique', () {
    final first = editor.addEntry(CvSection.skills);
    final second = editor.addEntry(CvSection.skills);
    expect(first, isNot(second));
    expect(editor.entriesOf(CvSection.skills).map((e) => e.id), [
      ...editor.entriesOf(CvSection.skills).map((e) => e.id),
    ]);
    expect(
      editor.entriesOf(CvSection.skills).where((e) => e.id == first),
      hasLength(1),
    );
  });

  test('modifier un élément passe par son type', () {
    final experience = editor.document.experiences.first;
    editor.updateEntry(
      CvSection.experiences,
      experience.copyWith(position: 'Architecte'),
    );
    expect(editor.document.experiences.first.position, 'Architecte');
    editor.undo();
    expect(editor.document.experiences.first.position, experience.position);
  });

  test('modifier un élément absent ne change rien', () {
    final experience = editor.document.experiences.first;
    editor.updateEntry(
      CvSection.experiences,
      experience.copyWith(id: 'inconnu', position: 'Fantôme'),
    );
    expect(editor.canUndo, isFalse);
  });

  test('supprimer puis réordonner des éléments s’annule', () {
    final before = editor.document.experiences.map((e) => e.id).toList();
    editor.removeEntry(CvSection.experiences, before.first);
    expect(editor.document.experiences.map((e) => e.id), before.skip(1));
    editor.undo();
    expect(editor.document.experiences.map((e) => e.id), before);
    editor.reorderEntries(CvSection.experiences, 0, 1);
    expect(editor.document.experiences.first.id, before[1]);
    editor.undo();
    expect(editor.document.experiences.map((e) => e.id), before);
  });

  test('supprimer un élément absent ne change rien', () {
    editor.removeEntry(CvSection.experiences, 'inconnu');
    expect(editor.canUndo, isFalse);
  });

  test('la visibilité d’une section facultative entre dans l’historique', () {
    expect(editor.document.isVisible(CvSection.projects), isTrue);
    editor.setSectionVisible(CvSection.projects, false);
    expect(editor.document.isVisible(CvSection.projects), isFalse);
    editor.undo();
    expect(editor.document.isVisible(CvSection.projects), isTrue);
  });

  test('une section obligatoire ne se masque pas', () {
    editor.setSectionVisible(CvSection.experiences, false);
    expect(editor.document.isVisible(CvSection.experiences), isTrue);
    expect(editor.canUndo, isFalse);
  });

  test('changer de modèle entre dans l’historique', () {
    editor.setDesign(CvDesign.banner);
    expect(editor.document.design, CvDesign.banner);
    editor.undo();
    expect(editor.document.design, CvDesign.classic);
  });

  test('changer de modèle ne touche ni au contenu ni à la visibilité', () {
    final before = editor.document;
    editor.setSectionVisible(CvSection.projects, false);
    final hidden = editor.document;
    editor.setDesign(CvDesign.academic);
    final after = editor.document;
    expect(after.experiences, before.experiences);
    expect(after.personalInfo, before.personalInfo);
    expect(after.profile, before.profile);
    expect(
      after.presentation.orderedSections,
      hidden.presentation.orderedSections,
    );
    expect(
      after.presentation.hiddenSections,
      hidden.presentation.hiddenSections,
    );
  });

  test('la photo vit dans la session et non dans le document', () {
    final photo = Uint8List.fromList([1, 2, 3]);
    editor.setPhoto(photo);
    expect(container.read(cvSessionProvider).photo, photo);
    expect(editor.document.toJson().toString(), isNot(contains('photo')));
    editor.undo();
    expect(container.read(cvSessionProvider).photo, isNull);
    editor.redo();
    expect(container.read(cvSessionProvider).photo, photo);
  });

  test('retirer la photo conserve le document', () {
    final document = editor.document;
    editor.setPhoto(Uint8List.fromList([1]));
    editor.setPhoto(null);
    expect(container.read(cvSessionProvider).photo, isNull);
    expect(editor.document.personalInfo, document.personalInfo);
  });

  test('une modification date le document', () {
    final before = editor.document.updatedAt;
    editor.setDocumentField(CvDocumentFields.firstName, 'Alice');
    expect(
      editor.document.updatedAt.isAfter(before),
      isTrue,
      reason: 'updatedAt suit chaque modification',
    );
  });

  test('l’historique reste borné', () {
    for (var i = 0; i < 80; i++) {
      editor.setDesign(i.isEven ? CvDesign.banner : CvDesign.academic);
    }
    var undos = 0;
    while (editor.canUndo) {
      editor.undo();
      undos++;
      if (undos > 100) break;
    }
    expect(undos, lessThanOrEqualTo(50));
  });

  test('une nouvelle modification efface le futur', () {
    editor.setDesign(CvDesign.banner);
    editor.undo();
    expect(editor.canRedo, isTrue);
    editor.setDesign(CvDesign.academic);
    expect(editor.canRedo, isFalse);
  });

  group('sections personnalisées', () {
    int customCount() => editor.document.customSections.length;

    test('créer une section l’ajoute à la fin, visible, en une étape', () {
      final first = editor.addCustomSection(
        '  Publications ',
        CvCustomSectionType.datedList,
      );
      final second = editor.addCustomSection(
        'Motivation',
        CvCustomSectionType.freeText,
      );
      expect(editor.document.customSections.map((s) => s.id), [first, second]);
      final created = editor.document.customSectionById(first)!;
      expect(created.name, 'Publications');
      expect(created.type, CvCustomSectionType.datedList);
      expect(created.visible, isTrue);
      editor.undo();
      expect(customCount(), 1);
      editor.undo();
      expect(customCount(), 0);
      editor.redo();
      expect(editor.document.customSectionById(first), created);
    });

    test('renommer, masquer et supprimer passent par l’historique', () {
      final id = editor.addCustomSection(
        'Publications',
        CvCustomSectionType.simpleList,
      );
      final ref = CvCustomSectionRef(id);
      editor.addEntry(ref);

      editor.renameCustomSection(id, 'Articles');
      expect(editor.document.customSectionById(id)!.name, 'Articles');
      editor.undo();
      expect(editor.document.customSectionById(id)!.name, 'Publications');
      editor.redo();

      editor.setSectionVisible(ref, false);
      expect(editor.document.isVisible(ref), isFalse);
      editor.undo();
      expect(editor.document.isVisible(ref), isTrue);

      editor.removeCustomSection(id);
      expect(editor.document.customSectionById(id), isNull);
      editor.undo();
      final restored = editor.document.customSectionById(id)!;
      expect(restored.name, 'Articles');
      expect(restored.items, hasLength(1));
    });

    test('une opération sans effet ne crée pas d’étape', () {
      final id = editor.addCustomSection(
        'Publications',
        CvCustomSectionType.simpleList,
      );
      editor.renameCustomSection(id, ' Publications ');
      editor.renameCustomSection('inconnue', 'X');
      editor.removeCustomSection('inconnue');
      editor.setCustomSectionText('inconnue', 'X');
      editor.undo();
      expect(customCount(), 0, reason: 'seule la création était annulable');
      expect(editor.canUndo, isFalse);
    });

    test('la saisie d’un texte libre se regroupe en une étape', () {
      final id = editor.addCustomSection(
        'Motivation',
        CvCustomSectionType.freeText,
      );
      editor.setCustomSectionText(id, 'J');
      editor.setCustomSectionText(id, 'Je');
      editor.setCustomSectionText(id, 'Je veux');
      expect(editor.document.customSectionById(id)!.text, 'Je veux');
      editor.undo();
      expect(editor.document.customSectionById(id)!.text, isEmpty);
      expect(customCount(), 1);
    });

    test('les éléments d’une liste s’éditent comme ceux d’une section', () {
      final id = editor.addCustomSection(
        'Bénévolat',
        CvCustomSectionType.datedList,
      );
      final ref = CvCustomSectionRef(id);
      final first = editor.addEntry(ref);
      final second = editor.addEntry(ref);
      expect(editor.entriesOf(ref).map((e) => e.id), [first, second]);

      final item = editor.entriesOf(ref).first as CvCustomItem;
      editor.updateEntry(ref, item.copyWith(title: 'Restos du cœur'));
      expect(
        (editor.entriesOf(ref).first as CvCustomItem).title,
        'Restos du cœur',
      );

      editor.reorderEntries(ref, 0, 1);
      expect(editor.entriesOf(ref).map((e) => e.id), [second, first]);

      editor.removeEntry(ref, second);
      expect(editor.entriesOf(ref).map((e) => e.id), [first]);

      editor.undo();
      editor.undo();
      editor.undo();
      expect(
        (editor.entriesOf(ref).first as CvCustomItem).title,
        isEmpty,
        reason: 'retour avant la saisie du titre',
      );
    });

    test('un texte libre n’accepte pas d’éléments', () {
      final id = editor.addCustomSection(
        'Motivation',
        CvCustomSectionType.freeText,
      );
      editor.addEntry(CvCustomSectionRef(id));
      expect(editor.document.customSectionById(id)!.items, isEmpty);
    });

    test('une section standard obligatoire ne se masque pas', () {
      editor.setSectionVisible(CvSection.skills, false);
      expect(editor.canUndo, isFalse);
    });
  });
}
