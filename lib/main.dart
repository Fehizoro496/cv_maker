import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'features/cv/data/cv_database.dart';
import 'features/cv/data/cv_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runCvMaker(DriftCvRepository(CvDatabase.open()));
}

/// Lance l'application sur les CV de [repository].
Future<void> runCvMaker(CvRepository repository) async =>
    runApp(await bootstrap(repository));
