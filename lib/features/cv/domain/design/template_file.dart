import 'dart:convert';

import 'cv_template.dart';

/// Contrat d'échange commun à CV Maker et à l'éditeur de modèles.
class TemplateFile {
  static const format = 'cv-maker-template';
  static const schemaVersion = 2;
  static const maxBytes = 1024 * 1024;

  static String encode(CvTemplate template) =>
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'schemaVersion': schemaVersion,
        'template': template.toJson(),
      });

  static CvTemplate decode(String source) {
    try {
      if (utf8.encode(source).length > maxBytes) {
        throw const FormatException('Fichier trop volumineux (maximum 1 Mo).');
      }
      final envelope = jsonDecode(source);
      if (envelope is! Map<String, dynamic> ||
          envelope['format'] != format ||
          envelope['schemaVersion'] is! int ||
          envelope['schemaVersion'] != schemaVersion ||
          envelope.keys.any(
            (key) => !['format', 'schemaVersion', 'template'].contains(key),
          )) {
        throw const FormatException(
          'Format ou version de template non pris en charge.',
        );
      }
      final json = envelope['template'];
      if (json is! Map<String, dynamic> ||
          json['spec'] is! Map ||
          json['revision'] is! int ||
          (json['revision'] as int) < 1) {
        throw const FormatException('Template ou révision invalide.');
      }
      final spec = json['spec'] as Map;
      if (spec['canvas'] == null) {
        throw const FormatException('Le canvas exige le format V2.');
      }
      _validateNumbers({
        ...json,
        'spec': {...spec}..remove('canvas'),
      });
      final template = CvTemplate.fromJson(json);
      template.spec.canvas.validate();
      if (!RegExp(
            r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,127}$',
          ).hasMatch(template.id) ||
          template.label.trim().isEmpty ||
          template.label.length > 100 ||
          template.description.length > 500) {
        throw const FormatException(
          'Identifiant, nom ou description invalide.',
        );
      }
      return template;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Description du template invalide.');
    }
  }

  static void _validateNumbers(Map json, [String parent = '']) {
    for (final entry in json.entries) {
      final key = entry.key as String;
      final value = entry.value;
      if (value is Map) _validateNumbers(value, key);
      if (value is String && value.length > 500) {
        throw FormatException('Texte trop long : $key.');
      }
      if (value is! num) continue;
      final (min, max) = switch (key) {
        'revision' => (1.0, 2147483647.0),
        _ when key.endsWith('Color') => (0.0, 4294967295.0),
        'photoDiameterMm' => (16.0, 40.0),
        'headerRuleLength' => (0.0, 400.0),
        _ when parent == 'scale' => (6.0, 48.0),
        'minContactFontSize' => (5.0, 16.0),
        _ => (0.0, 40.0),
      };
      if (!value.isFinite ||
          value < min ||
          value > max ||
          (key.endsWith('Color') && value is! int)) {
        throw FormatException('Valeur hors limites : $key.');
      }
    }
  }
}
