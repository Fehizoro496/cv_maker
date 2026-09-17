import 'dart:typed_data';

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
    editor.setDesign(CvDesign.modern);
    expect(editor.document.design, CvDesign.modern);
    editor.undo();
    expect(editor.document.design, CvDesign.professional);
  });

  test('changer de modèle ne touche ni au contenu ni à la visibilité', () {
    final before = editor.document;
    editor.setSectionVisible(CvSection.projects, false);
    final hidden = editor.document;
    editor.setDesign(CvDesign.minimal);
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
      editor.setDesign(i.isEven ? CvDesign.modern : CvDesign.minimal);
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
    editor.setDesign(CvDesign.modern);
    editor.undo();
    expect(editor.canRedo, isTrue);
    editor.setDesign(CvDesign.minimal);
    expect(editor.canRedo, isFalse);
  });

  test('cvSectionFormOf ne décrit pas la section profil', () {
    expect(cvSectionFormOf(CvSection.profile), isNull);
    expect(cvSectionFormOf(CvSection.experiences), isNotNull);
  });
}
