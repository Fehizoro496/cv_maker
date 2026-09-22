import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les modèles intégrés conservent toutes leurs propriétés en JSON', () {
    for (final design in CvDesign.values) {
      final template = CvTemplate.of(design);
      expect(
        CvTemplate.fromJson(template.toJson()).toJson(),
        template.toJson(),
      );
    }
  });
}
