import 'dart:io';
import 'dart:convert';

import 'package:cv_maker/features/cv/data/cv_database.dart';
import 'package:cv_maker/features/cv/data/template_repository.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'un catalogue local V1 est refusé',
    () async {
      final db = CvDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final payload = jsonEncode({
        'format': 'cv-maker-template',
        'schemaVersion': 1,
        'template': {
          'id': 'legacy',
          'label': 'Ancien',
          'revision': 1,
          'description': '',
          'spec': {},
        },
      });
      await db.customStatement(
        'INSERT INTO template_records (id, payload) VALUES (?, ?)',
        ['legacy', payload],
      );
      final repository = DriftTemplateRepository(db);
      await expectLater(repository.list(), throwsFormatException);
    },
  );
  test(
    'les imports et leur dernière révision survivent à une réouverture',
    () async {
      final dir = await Directory.systemTemp.createTemp('template_repository');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/catalog.sqlite');
      var db = CvDatabase(NativeDatabase(file));
      final repository = DriftTemplateRepository(db);
      for (final revision in [1, 2]) {
        await repository.save(
          CvTemplate(
            id: 'custom',
            label: 'Création',
            description: '',
            revision: revision,
            spec: bannerDesignSpec,
          ),
        );
      }
      await db.close();
      db = CvDatabase(NativeDatabase(file));
      final templates = await DriftTemplateRepository(db).list();
      expect(templates.single.id, 'custom');
      expect(templates.single.revision, 2);
      expect(templates.single.spec.toJson(), bannerDesignSpec.toJson());
      await db.close();
    },
  );
}
