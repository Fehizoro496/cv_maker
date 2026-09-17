import 'package:cv_maker/features/cv/domain/cv_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('built-in designs have distinct French labels', () {
    expect(CvDesign.values.map((design) => design.label).toSet(), {
      'Professionnel',
      'Moderne',
      'Minimaliste',
    });
  });
}
