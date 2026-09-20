import 'dart:io';
import 'dart:typed_data';

import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le schéma est en version 3', () {
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 3);
  });

  test('une base neuve crée la table des CV et note sa version', () async {
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.select(db.cvRecords).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);
  });

  test(
    'une base en version 1 gagne la colonne photo sans perdre ses CV',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'cv_database_migration',
      );
      // Windows garde le fichier ouvert un instant après la fermeture de la
      // base : le ménage ne doit pas faire échouer le test.
      addTearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/cv.sqlite');
      final at = DateTime.utc(2026, 9, 18, 14);

      // Le schéma tel que la version 1 l'écrivait, photo absente. Ouvrir la
      // base la crée déjà dans sa forme courante : la table est donc
      // remplacée par sa forme d'origine, puis la version ramenée à 1.
      final legacy = CvDatabase(NativeDatabase(file));
      await legacy.customStatement('DROP TABLE IF EXISTS "cv_records"');
      await legacy.customStatement(
        'CREATE TABLE "cv_records" ("id" TEXT NOT NULL, '
        '"name" TEXT NOT NULL, "created_at" TEXT NOT NULL, '
        '"updated_at" TEXT NOT NULL, "format_version" INTEGER NOT NULL, '
        '"document" TEXT NOT NULL, PRIMARY KEY ("id"))',
      );
      await legacy.customStatement(
        'INSERT INTO "cv_records" VALUES (?, ?, ?, ?, ?, ?)',
        ['a', 'Mon CV', at.toIso8601String(), at.toIso8601String(), 1, '{}'],
      );
      await legacy.customStatement('PRAGMA user_version = 1');
      await legacy.close();

      final migrated = CvDatabase(NativeDatabase(file));
      addTearDown(migrated.close);
      final record = await migrated.select(migrated.cvRecords).getSingle();

      expect(record.name, 'Mon CV');
      expect(record.photo, isNull, reason: 'la photo vivait alors en session');
      expect(record.thumbnail, isNull);
      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 3);
    },
  );

  test(
    'une base en version 2 gagne les colonnes d’aperçu sans perdre sa photo',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'cv_database_migration_v2',
      );
      addTearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/cv.sqlite');
      final at = DateTime.utc(2026, 9, 18, 14);

      // Le schéma tel que la version 2 l'écrivait : la photo, sans l'aperçu.
      final legacy = CvDatabase(NativeDatabase(file));
      await legacy.customStatement('DROP TABLE IF EXISTS "cv_records"');
      await legacy.customStatement(
        'CREATE TABLE "cv_records" ("id" TEXT NOT NULL, '
        '"name" TEXT NOT NULL, "created_at" TEXT NOT NULL, '
        '"updated_at" TEXT NOT NULL, "format_version" INTEGER NOT NULL, '
        '"document" TEXT NOT NULL, "photo" BLOB, PRIMARY KEY ("id"))',
      );
      await legacy.customStatement(
        'INSERT INTO "cv_records" VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          'a',
          'Mon CV',
          at.toIso8601String(),
          at.toIso8601String(),
          1,
          '{}',
          Uint8List.fromList([7, 8, 9]),
        ],
      );
      await legacy.customStatement('PRAGMA user_version = 2');
      await legacy.close();

      final migrated = CvDatabase(NativeDatabase(file));
      addTearDown(migrated.close);
      final record = await migrated.select(migrated.cvRecords).getSingle();

      expect(record.photo, [7, 8, 9], reason: 'la photo est conservée');
      expect(record.thumbnail, isNull, reason: 'aucun aperçu rendu encore');
      expect(record.thumbnailUpdatedAt, isNull);
      final version = await migrated
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 3);
    },
  );

  test('les données survivent à la fermeture du fichier', () async {
    final dir = await Directory.systemTemp.createTemp('cv_database_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/cv.sqlite');
    final at = DateTime.utc(2026, 9, 18, 14, 2, 3, 456);

    final first = CvDatabase(NativeDatabase(file));
    await first
        .into(first.cvRecords)
        .insert(
          CvRecordsCompanion.insert(
            id: 'a',
            name: 'Mon CV',
            createdAt: at,
            updatedAt: at,
            formatVersion: 1,
            document: '{}',
          ),
        );
    await first.close();

    final reopened = CvDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final record = await reopened.select(reopened.cvRecords).getSingle();

    expect(record.name, 'Mon CV');
    expect(record.updatedAt, at, reason: 'millisecondes conservées');
  });
}
