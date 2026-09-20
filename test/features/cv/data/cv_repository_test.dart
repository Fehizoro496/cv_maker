import 'dart:convert';

import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/cv_custom_section.dart';
import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_example.dart';
import 'package:cv_maker/features/cv/domain/cv_section.dart';
import 'package:cv_maker/features/cv/domain/cv_summary.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CvDatabase db;
  late DriftCvRepository repository;

  setUp(() {
    db = CvDatabase(NativeDatabase.memory());
    repository = DriftCvRepository(db);
  });

  tearDown(() => db.close());

  CvDocument cv(String id, DateTime at, {String name = 'CV'}) =>
      CvDocument.empty(id: id, now: at, name: name);

  test('une base neuve ne contient aucun CV', () async {
    expect(await repository.list(), isEmpty);
    expect(await repository.read('absent'), isNull);
  });

  test('relit le CV d’exemple complet sans perte', () async {
    final document = exampleCvDocument();

    await repository.save(document);

    expect(await repository.read(document.id), document);
  });

  test('conserve les sections personnalisées, leur ordre, leur visibilité '
      'et les réglages du modèle', () async {
    final base = exampleCvDocument();
    final document = base.copyWith(
      customSections: const [
        CvCustomSection(
          id: 'pub',
          name: 'Publications',
          type: CvCustomSectionType.datedList,
          items: [CvCustomItem(id: 'p1', title: 'Article')],
        ),
        CvCustomSection(
          id: 'txt',
          name: 'Mot de la fin',
          type: CvCustomSectionType.freeText,
          text: 'Merci.',
          visible: false,
        ),
      ],
      presentation: base.presentation
          .withTemplate(
            design: CvDesign.academic,
            accentArgb: 0xFF8C1D18,
            showPhoto: false,
          )
          .withSectionVisible(CvSection.projects, false),
    );

    await repository.save(document);
    final reread = await repository.read(document.id);

    expect(reread, document);
    expect(reread!.customSections.map((s) => s.id), ['pub', 'txt']);
    expect(reread.isVisible(const CvCustomSectionRef('txt')), isFalse);
    expect(reread.design, CvDesign.academic);
    expect(reread.presentation.accentColor, 0xFF8C1D18);
    expect(reread.presentation.showPhoto, isFalse);
  });

  test('liste les CV du plus récemment modifié au plus ancien', () async {
    await repository.save(cv('a', DateTime.utc(2026, 1, 1), name: 'Ancien'));
    await repository.save(cv('c', DateTime.utc(2026, 3, 1), name: 'Récent'));
    await repository.save(cv('b', DateTime.utc(2026, 2, 1), name: 'Moyen'));

    expect(await repository.list(), [
      CvSummary(id: 'c', name: 'Récent', updatedAt: DateTime.utc(2026, 3)),
      CvSummary(id: 'b', name: 'Moyen', updatedAt: DateTime.utc(2026, 2)),
      CvSummary(id: 'a', name: 'Ancien', updatedAt: DateTime.utc(2026)),
    ]);
  });

  test('met à jour un CV existant et son résumé', () async {
    final first = cv('a', DateTime.utc(2026, 1, 1), name: 'Avant');
    await repository.save(first);

    final next = first
        .copyWith(name: 'Après', profile: 'Nouveau profil')
        .touched(DateTime.utc(2026, 1, 2));
    await repository.save(next);

    expect(await repository.read('a'), next);
    expect((await repository.list()).single.name, 'Après');
  });

  test('ignore une version plus ancienne que celle déjà enregistrée', () async {
    final recent = cv(
      'a',
      DateTime.utc(2026, 1, 1),
    ).copyWith(profile: 'récent').touched(DateTime.utc(2026, 1, 1, 12, 0, 1));
    final stale = recent
        .copyWith(profile: 'ancien')
        .touched(DateTime.utc(2026, 1, 1, 12));

    await repository.save(recent);
    await repository.save(stale);

    expect((await repository.read('a'))!.profile, 'récent');
  });

  test('distingue deux sauvegardes à quelques millisecondes d’écart', () async {
    final at = DateTime.utc(2026, 1, 1, 12);
    final first = cv('a', at).copyWith(profile: 'premier');
    final second = first
        .copyWith(profile: 'second')
        .touched(at.add(const Duration(milliseconds: 5)));

    await repository.save(second);
    await repository.save(first);

    expect((await repository.read('a'))!.profile, 'second');
  });

  test(
    'compare les dates UTC et locales par l’instant qu’elles désignent',
    () async {
      final utc = DateTime.utc(2026, 1, 1, 12);
      await repository.save(cv('a', utc).copyWith(profile: 'utc'));

      // Une heure après en temps universel, quel que soit le fuseau local.
      final later = utc.add(const Duration(hours: 1)).toLocal();
      await repository.save(cv('a', later).copyWith(profile: 'local'));
      final earlier = utc.subtract(const Duration(hours: 1)).toLocal();
      await repository.save(cv('a', earlier).copyWith(profile: 'périmé'));

      expect((await repository.read('a'))!.profile, 'local');
    },
  );

  test('supprime un CV sans toucher aux autres', () async {
    await repository.save(cv('a', DateTime.utc(2026)));
    await repository.save(cv('b', DateTime.utc(2026)));

    await repository.delete('a');
    await repository.delete('absent');

    expect(await repository.read('a'), isNull);
    expect((await repository.list()).map((s) => s.id), ['b']);
  });

  test('enregistre le format du document avec le JSON', () async {
    final document = exampleCvDocument();
    await repository.save(document);

    final record = await db.select(db.cvRecords).getSingle();

    expect(record.formatVersion, DriftCvRepository.formatVersion);
    expect(jsonDecode(record.document), document.toJson());
    expect(record.name, document.name);
  });

  test('refuse un document écrit par une version plus récente', () async {
    await repository.save(exampleCvDocument());
    await db
        .update(db.cvRecords)
        .write(
          const CvRecordsCompanion(
            formatVersion: Value(DriftCvRepository.formatVersion + 1),
          ),
        );

    expect(repository.read('example'), throwsFormatException);
  });

  test('relit un document sans les clés ajoutées depuis', () async {
    final json = exampleCvDocument().toJson()..remove('customSections');
    await db
        .into(db.cvRecords)
        .insert(
          CvRecordsCompanion.insert(
            id: 'example',
            name: 'Ancien',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
            formatVersion: 1,
            document: jsonEncode(json),
          ),
        );

    expect((await repository.read('example'))!.customSections, isEmpty);
  });

  group('photo', () {
    final photo = Uint8List.fromList(List.filled(32, 0xAB));

    test('un CV sans photo n’en rend aucune', () async {
      await repository.save(cv('a', DateTime.utc(2026, 9, 20)));

      expect(await repository.readPhoto('a'), isNull);
      expect(await repository.readPhoto('absent'), isNull);
    });

    test('enregistre puis relit la photo d’un CV', () async {
      await repository.save(cv('a', DateTime.utc(2026, 9, 20)));

      await repository.savePhoto('a', photo);

      expect(await repository.readPhoto('a'), photo);
    });

    test('`null` retire la photo enregistrée', () async {
      await repository.save(cv('a', DateTime.utc(2026, 9, 20)));
      await repository.savePhoto('a', photo);

      await repository.savePhoto('a', null);

      expect(await repository.readPhoto('a'), isNull);
    });

    test('enregistrer le document ne touche pas à la photo', () async {
      final at = DateTime.utc(2026, 9, 20);
      await repository.save(cv('a', at));
      await repository.savePhoto('a', photo);

      // C'est l'écriture que déclenche chaque salve de frappe.
      await repository.save(
        cv('a', at.add(const Duration(minutes: 1)), name: 'Renommé'),
      );

      expect(await repository.readPhoto('a'), photo);
      expect((await repository.read('a'))!.name, 'Renommé');
    });

    test('la photo disparaît avec son CV', () async {
      await repository.save(cv('a', DateTime.utc(2026, 9, 20)));
      await repository.savePhoto('a', photo);

      await repository.delete('a');

      expect(await repository.readPhoto('a'), isNull);
    });

    test('une photo sans CV n’est pas enregistrée', () async {
      await repository.savePhoto('absent', photo);

      expect(await repository.readPhoto('absent'), isNull);
    });
  });
}
