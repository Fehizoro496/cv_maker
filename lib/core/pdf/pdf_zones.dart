import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Un bloc que la pagination ne coupe jamais.
///
/// `MultiPage` scinde une `Column` entre ses enfants dès qu'elle ne tient pas
/// dans la place restante : un titre de section groupé avec son premier
/// élément pouvait ainsi rester seul en bas d'une page. Ce bloc passe tout
/// entier sur la page suivante. Il doit donc rester plus petit qu'une page.
class KeepTogether extends pw.SingleChildWidget {
  KeepTogether({required pw.Widget child}) : super(child: child);

  @override
  bool get canSpan => false;

  @override
  void paint(pw.Context context) {
    super.paint(context);
    paintChild(context);
  }
}

/// Une zone d'un [ZonedFlow] : une bande verticale de la page et ses blocs.
class PdfZone {
  PdfZone({required this.left, required this.width, required this.children});

  /// Position de la bande depuis le bord gauche de la zone de contenu.
  final double left;

  final double width;

  /// Les blocs de la zone, de haut en bas.
  ///
  /// Un bloc capable de se répartir sur plusieurs pages — un texte en
  /// `TextOverflow.span`, éventuellement dans un `Padding` — est coupé en bas
  /// de page ; les autres passent entiers sur la page suivante, et doivent
  /// donc rester plus petits qu'une page.
  final List<pw.Widget> children;
}

/// Plusieurs zones côte à côte, chacune se poursuivant de page en page.
///
/// C'est le moteur des modèles à colonne latérale : chaque zone remplit sa
/// bande de la page, puis reprend sur la page suivante là où elle s'était
/// arrêtée, indépendamment des autres.
///
/// Les zones sont **peintes dans l'ordre de la liste**, quelle que soit leur
/// position : sur chaque page, le texte de la première zone est émis en
/// entier avant celui de la deuxième. Placer le corps en premier garantit à
/// un logiciel de tri des candidatures, qui lit le PDF de façon linéaire,
/// que la colonne latérale forme un bloc distinct placé après lui.
class ZonedFlow extends pw.Widget with pw.SpanningWidget {
  ZonedFlow({required this.zones})
    : _initial = [
        for (final zone in zones)
          [
            for (final child in zone.children)
              child is pw.SpanningWidget && child.canSpan
                  ? child.cloneContext()
                  : null,
          ],
      ],
      _context = _ZonedFlowContext(zones.length),
      _placed = [for (final _ in zones) <_Placed>[]];

  final List<PdfZone> zones;

  /// L'état de départ de chaque bloc divisible, `null` pour un bloc entier.
  final List<List<pw.WidgetContext?>> _initial;

  final _ZonedFlowContext _context;

  /// Les blocs posés sur la page en cours, par zone.
  final List<List<_Placed>> _placed;

  @override
  bool get canSpan => true;

  @override
  bool get hasMoreWidgets {
    for (var z = 0; z < zones.length; z++) {
      if (_context.end[z].index < zones[z].children.length) return true;
    }
    return false;
  }

  @override
  void layout(
    pw.Context context,
    pw.BoxConstraints constraints, {
    bool parentUsesSize = false,
  }) {
    final available = constraints.maxHeight;
    var height = 0.0;
    for (var z = 0; z < zones.length; z++) {
      final zone = zones[z];
      final start = _context.start[z];
      final placed = _placed[z]..clear();
      var used = 0.0;
      var index = start.index;
      pw.WidgetContext? resumeAt;

      // Ramène un bloc divisible à son début, ou à l'endroit où la page
      // précédente l'a laissé.
      void rewind(int i) {
        final initial = _initial[z][i];
        if (initial == null) return;
        final child = zone.children[i] as pw.SpanningWidget;
        child.applyContext(initial);
        if (i == start.index && start.inner != null) {
          child.restoreContext(start.inner!);
        }
      }

      while (index < zone.children.length) {
        final child = zone.children[index];
        rewind(index);
        child.layout(context, pw.BoxConstraints(maxWidth: zone.width));
        if (used + child.box!.height <= available) {
          placed.add(_Placed(child, used));
          used += child.box!.height;
          index++;
          continue;
        }
        if (_initial[z][index] != null) {
          // Le bloc se coupe : il remplit le reste de la page et reprendra
          // sur la suivante.
          rewind(index);
          child.layout(
            context,
            pw.BoxConstraints(
              maxWidth: zone.width,
              maxHeight: math.max(0, available - used),
            ),
          );
          placed.add(_Placed(child, used));
          used += child.box!.height;
          resumeAt = (child as pw.SpanningWidget).cloneContext();
        }
        break;
      }

      _context.end[z]
        ..index = index
        ..inner = resumeAt;
      height = math.max(height, used);
    }
    box = PdfRect(0, 0, constraints.maxWidth, height);
  }

  @override
  void paint(pw.Context context) {
    super.paint(context);
    for (var z = 0; z < zones.length; z++) {
      for (final placed in _placed[z]) {
        final child = placed.child;
        final size = child.box!;
        child.box = PdfRect(
          box!.left + zones[z].left,
          box!.top - placed.top - size.height,
          size.width,
          size.height,
        );
        child.paint(context);
      }
    }
  }

  @override
  pw.WidgetContext saveContext() => _context;

  @override
  void restoreContext(pw.WidgetContext context) {
    final previous = context as _ZonedFlowContext;
    for (var z = 0; z < zones.length; z++) {
      _context.start[z].copyFrom(previous.end[z]);
    }
  }
}

/// Un bloc posé sur la page, à [top] points du haut du flux.
class _Placed {
  _Placed(this.child, this.top);

  final pw.Widget child;
  final double top;
}

/// La position d'une zone dans ses blocs.
class _Cursor {
  /// Le premier bloc de la page, ou le premier qui n'y tient pas.
  int index = 0;

  /// Où reprendre le bloc [index] s'il a été coupé, `null` sinon.
  pw.WidgetContext? inner;

  void copyFrom(_Cursor other) {
    index = other.index;
    inner = other.inner?.clone();
  }
}

/// L'état de pagination d'un [ZonedFlow] : début et fin de chaque zone sur la
/// page en cours.
class _ZonedFlowContext extends pw.WidgetContext {
  _ZonedFlowContext(int zones)
    : start = [for (var z = 0; z < zones; z++) _Cursor()],
      end = [for (var z = 0; z < zones; z++) _Cursor()];

  final List<_Cursor> start;
  final List<_Cursor> end;

  @override
  void apply(_ZonedFlowContext other) {
    for (var z = 0; z < start.length; z++) {
      start[z].copyFrom(other.start[z]);
      end[z].copyFrom(other.end[z]);
    }
  }

  @override
  pw.WidgetContext clone() => _ZonedFlowContext(start.length)..apply(this);
}
