import 'package:json_annotation/json_annotation.dart';

import '../document/cv_section.dart';

part 'cv_canvas.g.dart';

/// Pages A4 et cadres absolus, en millimètres depuis le coin supérieur gauche.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class CvCanvas {
  const CvCanvas({required this.pages});
  factory CvCanvas.fromJson(Map<String, dynamic> json) {
    void checkColors(Object? value) {
      if (value is List) {
        for (final item in value) {
          checkColors(item);
        }
      }
      if (value is Map) {
        for (final entry in value.entries) {
          if (['color', 'background', 'borderColor'].contains(entry.key) &&
              entry.value != null &&
              entry.value is! int) {
            throw const FormatException(
              'Une couleur doit être un entier ARGB.',
            );
          }
          checkColors(entry.value);
        }
      }
    }

    checkColors(json);
    final canvas = _$CvCanvasFromJson(json);
    canvas.validate();
    return canvas;
  }
  Map<String, dynamic> toJson() => _$CvCanvasToJson(this);
  final List<CvCanvasPage> pages;

  void validate() {
    if (pages.isEmpty || pages.length > 20) {
      throw const FormatException(
        'Le canvas doit contenir entre 1 et 20 pages.',
      );
    }
    final ids = <String>{};
    var count = 0;
    for (final page in pages) {
      _color(page.background);
      for (final e in page.elements) {
        if (++count > 200 ||
            e.id.isEmpty ||
            e.id.length > 128 ||
            !ids.add(e.id)) {
          throw const FormatException(
            'Identifiant de cadre invalide, dupliqué ou trop de cadres (200 maximum).',
          );
        }
        _number(e.x, 0, 210);
        _number(e.y, 0, 297);
        _number(e.width, .1, 210);
        _number(e.height, .1, 297);
        if (e.x + e.width > 210.001 || e.y + e.height > 297.001) {
          throw FormatException('Le cadre ${e.id} dépasse la page A4.');
        }
        _number(e.fontSize, 6, 100);
        _number(e.padding, 0, 30);
        _number(e.borderWidth, 0, 10);
        _number(e.radius, 0, 100);
        _number(e.titleMargin, 0, .35);
        for (final sections in [e.sectionOrder, e.excludedSections]) {
          if (sections.toSet().length != sections.length) {
            throw const FormatException(
              'Une section est répétée dans un cadre de flux.',
            );
          }
        }
        if (e.padding * 2 >= e.width || e.padding * 2 >= e.height) {
          throw FormatException('Marges trop grandes dans le cadre ${e.id}.');
        }
        _color(e.color);
        _color(e.background);
        _color(e.borderColor);
        if (e.text.length > 10000 || (e.binding?.length ?? 0) > 128) {
          throw const FormatException('Texte ou liaison trop long.');
        }
        if (e.binding != null &&
            (!RegExp(
                  r'^(personalInfo|profile|experiences|education|skills|languages|certifications|projects|interests|references|customSections)(\.[a-zA-Z][a-zA-Z0-9]*|\.[0-9]+)*$',
                ).hasMatch(e.binding!) ||
                e.text.isNotEmpty ||
                e.type != CvCanvasElementType.text)) {
          throw const FormatException(
            'Liaison de données invalide : choisir du texte fixe ou un champ du CV.',
          );
        }
        if (e.type == CvCanvasElementType.section && e.section == null) {
          throw const FormatException(
            'Un cadre de section doit désigner une section.',
          );
        }
        if (e.section == CvSection.personalInfo) {
          throw const FormatException(
            'Utiliser des cadres texte pour les informations personnelles.',
          );
        }
      }
    }
  }

  static void _number(double value, double min, double max) {
    if (!value.isFinite || value < min || value > max) {
      throw const FormatException('Dimension du canvas hors limites.');
    }
  }

  static void _color(int? value) {
    if (value != null && (value < 0 || value > 0xFFFFFFFF)) {
      throw const FormatException('Couleur ARGB invalide.');
    }
  }
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class CvCanvasPage {
  const CvCanvasPage({
    required this.elements,
    this.background = 0xFFFFFFFF,
    this.showPageNumber = false,
  });
  factory CvCanvasPage.fromJson(Map<String, dynamic> json) =>
      _$CvCanvasPageFromJson(json);
  Map<String, dynamic> toJson() => _$CvCanvasPageToJson(this);
  final int background;
  final bool showPageNumber;

  /// Ordre de dessin : les derniers éléments recouvrent les premiers.
  final List<CvCanvasElement> elements;
}

enum CvCanvasElementType { text, section, photo, rectangle, flow }

enum CvCanvasPalette { custom, body, sidebar }

extension CvCanvasCapabilities on CvCanvas {
  bool get isFixed => !pages.any(
    (page) => page.elements.any((e) => e.type == CvCanvasElementType.flow),
  );
}

enum CvCanvasTextAlign { left, center, right, justify }

class CanvasLayoutException implements Exception {
  const CanvasLayoutException(this.elementId);
  final String elementId;
  @override
  String toString() =>
      'Le contenu dépasse le cadre « $elementId ». Agrandissez le cadre ou réduisez sa taille de texte.';
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class CvCanvasElement {
  const CvCanvasElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.text = '',
    this.binding,
    this.section,
    this.fontSize = 10,
    this.bold = false,
    this.italic = false,
    this.color = 0xFF202B38,
    this.background,
    this.borderColor = 0xFF202B38,
    this.borderWidth = 0,
    this.radius = 0,
    this.padding = 0,
    this.align = CvCanvasTextAlign.left,
    this.palette = CvCanvasPalette.custom,
    this.sectionOrder = const [],
    this.excludedSections = const [],
    this.includeRemaining = false,
    this.includeCustom = false,
    this.showHeader = false,
    this.showContacts = false,
    this.showPhoto = false,
    this.titleMargin = 0,
  });
  factory CvCanvasElement.fromJson(Map<String, dynamic> json) =>
      _$CvCanvasElementFromJson(json);
  Map<String, dynamic> toJson() => _$CvCanvasElementToJson(this);
  final String id;
  final CvCanvasElementType type;
  final double x, y, width, height;
  final String text;
  final String? binding;
  final CvSection? section;
  final double fontSize;
  final bool bold, italic;
  final int color;
  final int? background;
  final int borderColor;
  final double borderWidth, radius, padding;
  final CvCanvasTextAlign align;
  final CvCanvasPalette palette;
  final List<CvSection> sectionOrder, excludedSections;
  final bool includeRemaining,
      includeCustom,
      showHeader,
      showContacts,
      showPhoto;
  final double titleMargin;
}
