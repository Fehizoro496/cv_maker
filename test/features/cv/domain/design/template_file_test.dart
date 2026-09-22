import 'dart:convert';
import 'dart:io';

import 'package:cv_maker/features/cv/domain/design/cv_design.dart';
import 'package:cv_maker/features/cv/domain/design/cv_template.dart';
import 'package:cv_maker/features/cv/domain/design/template_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> source() =>
      jsonDecode(TemplateFile.encode(CvTemplate.of(CvDesign.sidebar)))
          as Map<String, dynamic>;

  test('l’exemple documenté est importable et conserve le filet absent', () {
    final template = TemplateFile.decode(
      File('docs/examples/epure.cv-template.json').readAsStringSync(),
    );
    expect(template.id, 'atelier.epure');
    expect(template.spec.sections.headerRuleThickness, isNull);
    expect(
      TemplateFile.decode(TemplateFile.encode(template)).toJson(),
      template.toJson(),
    );
  });

  test(
    'le V2 conserve le canvas, sa version et ses cadres lors des échanges',
    () {
      final template = TemplateFile.decode(
        File('docs/examples/canvas.cv-template.json').readAsStringSync(),
      );
      expect(template.spec.canvas.pages, hasLength(2));
      final encoded = TemplateFile.encode(template);
      expect(jsonDecode(encoded)['schemaVersion'], 2);
      expect(TemplateFile.decode(encoded).toJson(), template.toJson());
      final downgraded = jsonDecode(encoded) as Map<String, dynamic>;
      downgraded['schemaVersion'] = 1;
      expect(
        () => TemplateFile.decode(jsonEncode(downgraded)),
        throwsFormatException,
      );
      downgraded['schemaVersion'] = 99;
      expect(
        () => TemplateFile.decode(jsonEncode(downgraded)),
        throwsFormatException,
      );
    },
  );

  test('aller-retour de tous les modèles y compris les valeurs nulles', () {
    for (final design in CvDesign.values) {
      final template = CvTemplate.of(design);
      expect(
        TemplateFile.decode(TemplateFile.encode(template)).toJson(),
        template.toJson(),
      );
    }
  });

  test('refuse les définitions sans canvas et les anciennes propriétés', () {
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (spec) => spec.remove('canvas'),
      (spec) => spec['canvas'] = null,
      (spec) => spec['structure'] = {},
      (spec) => spec['tokens']['pageMarginMm'] = 18,
    ]) {
      final json = source();
      mutate(json['template']['spec'] as Map<String, dynamic>);
      expect(
        () => TemplateFile.decode(jsonEncode(json)),
        throwsFormatException,
      );
    }
  });

  test(
    'rejette les formats inconnus, fichiers incomplets et surdimensionnés',
    () {
      for (final value in [
        '',
        '{}',
        '[]',
        'x' * (TemplateFile.maxBytes + 1),
        jsonEncode(source()..['schemaVersion'] = 99),
      ]) {
        expect(() => TemplateFile.decode(value), throwsFormatException);
      }
    },
  );

  test(
    'rejette les données de rendu invalides et les révisions fractionnaires',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (m) => m['revision'] = 1.5,
        (m) => m['id'] = '../invalid',
        (m) => m['label'] = ' ',
        (m) => m['spec']['tokens']['pageMarginMm'] = 100,
        (m) => m['spec']['tokens']['bodyColor'] = 1.5,
        (m) => m['spec']['tokens']['scale']['body'] = 0,
        (m) => m['spec']['canvas']['pages'][0]['elements'][0]['width'] = 300,
        (m) => m['spec']['header']['alignment'] = 'unknown',
        (m) => m['spec']['unknown'] = true,
      ]) {
        final json = source();
        mutate(json['template'] as Map<String, dynamic>);
        expect(
          () => TemplateFile.decode(jsonEncode(json)),
          throwsFormatException,
        );
      }
    },
  );
}
