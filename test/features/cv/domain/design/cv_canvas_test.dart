import 'package:cv_maker/features/cv/domain/design/cv_canvas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> source() => const CvCanvas(
    pages: [
      CvCanvasPage(
        elements: [
          CvCanvasElement(
            id: 'name',
            type: CvCanvasElementType.text,
            x: 12,
            y: 15,
            width: 150,
            height: 20,
            binding: 'personalInfo.fullName',
            fontSize: 30,
          ),
        ],
      ),
    ],
  ).toJson();
  test('le canvas conserve dimensions, styles et liaisons en JSON', () {
    final json = source();
    expect(CvCanvas.fromJson(json).toJson(), json);
  });
  test(
    'refuse cadres hors page, dimensions invalides et identifiants dupliqués',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (e) => e['x'] = 209,
        (e) => e['height'] = -1,
        (e) => e['fontSize'] = 0,
        (e) => e['padding'] = 12,
        (e) => e['color'] = 2.5,
        (e) => e['binding'] = 'invalid.name',
        (e) => e['text'] = 'ambiguous',
        (e) => e['type'] = 'unsupported',
      ]) {
        final json = source();
        mutate(json['pages'][0]['elements'][0] as Map<String, dynamic>);
        expect(() => CvCanvas.fromJson(json), throwsA(isA<Exception>()));
      }
      final json = source();
      (json['pages'][0]['elements'] as List).add(
        json['pages'][0]['elements'][0],
      );
      expect(() => CvCanvas.fromJson(json), throwsFormatException);
      expect(() => const CvCanvas(pages: []).validate(), throwsFormatException);
    },
  );
}
