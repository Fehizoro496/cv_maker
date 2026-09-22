import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/presentation/preview/template_file_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'l’export mobile signale clairement la plateforme non prise en charge',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await expectLater(
        writeTemplateFile(CvTemplate.of(CvDesign.classic)),
        throwsUnsupportedError,
      );
    },
  );
}
