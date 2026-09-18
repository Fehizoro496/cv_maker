import 'dart:io';

import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le schéma est en version 1', () {
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 1);
  });

  test('une base neuve crée la table des CV et note sa version', () async {
    final db = CvDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(await db.select(db.cvRecords).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 1);
  });

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
