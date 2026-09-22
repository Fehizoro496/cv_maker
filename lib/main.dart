import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'features/cv/data/cv_database.dart';
import 'features/cv/data/cv_repository.dart';
import 'features/cv/data/template_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = CvDatabase.open();
  await runCvMaker(
    DriftCvRepository(database),
    templates: DriftTemplateRepository(database),
  );
}

/// Lance l'application sur les CV de [repository].
Future<void> runCvMaker(
  CvRepository repository, {
  TemplateRepository? templates,
}) async => runApp(await bootstrap(repository, templates: templates));
