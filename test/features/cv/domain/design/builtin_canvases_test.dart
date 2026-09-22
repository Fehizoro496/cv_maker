import 'dart:convert';
import 'package:cv_maker/features/cv/domain/design/cv_canvas.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_design_spec.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/domain/design/template_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les huit modèles exportent un canvas V2 avec un corps paginé', () {
    for (final design in CvDesign.values) {
      final canvas = design.spec.canvas;
      expect(
        canvas.pages.single.elements.any(
          (e) => e.type == CvCanvasElementType.flow && e.includeCustom,
        ),
        isTrue,
      );
      canvas.validate();
      final file = jsonDecode(TemplateFile.encode(CvTemplate.of(design)));
      expect(file['schemaVersion'], 2);
      expect(file['template']['spec']['canvas'], isA<Map>());
      expect(file['template']['spec'].containsKey('structure'), isFalse);
    }
  });
}
