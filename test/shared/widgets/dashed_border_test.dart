import 'package:cv_maker/shared/widgets/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const painter = DashedBorderPainter(color: Colors.grey, radius: 12);

  test('ne se redessine que si la couleur ou le rayon change', () {
    expect(painter.shouldRepaint(painter), isFalse);
    expect(
      painter.shouldRepaint(
        const DashedBorderPainter(color: Colors.grey, radius: 12),
      ),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        const DashedBorderPainter(color: Colors.red, radius: 12),
      ),
      isTrue,
    );
    expect(
      painter.shouldRepaint(
        const DashedBorderPainter(color: Colors.grey, radius: 4),
      ),
      isTrue,
    );
  });

  testWidgets('trace des tirets le long du contour', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: CustomPaint(size: Size(120, 40), foregroundPainter: painter),
      ),
    );

    final box = find.byType(CustomPaint).last;
    // Une bordure continue ferait un seul tracé ; les tirets en font un par
    // segment.
    expect(
      box,
      paints
        ..path()
        ..path()
        ..path(),
    );
  });
}
