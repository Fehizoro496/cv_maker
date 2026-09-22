import '../domain/design/cv_template.dart';
import '../domain/design/template_file.dart';
import 'cv_database.dart';

abstract interface class TemplateRepository {
  Future<List<CvTemplate>> list();
  Future<void> save(CvTemplate template);
}

class DriftTemplateRepository implements TemplateRepository {
  DriftTemplateRepository(this.db);
  final CvDatabase db;

  @override
  Future<List<CvTemplate>> list() async => [
    for (final row in await db.select(db.templateRecords).get())
      TemplateFile.decode(row.payload),
  ];

  @override
  Future<void> save(CvTemplate template) => db
      .into(db.templateRecords)
      .insertOnConflictUpdate(
        TemplateRecordsCompanion.insert(
          id: template.id,
          payload: TemplateFile.encode(template),
        ),
      )
      .then((_) {});
}
