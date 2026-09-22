import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/pdf/pdf_fonts.dart';
import '../../../../../core/pdf/pdf_links.dart';
import '../../../../../core/pdf/pdf_zones.dart';
import '../../../domain/entries/cv_certification.dart';
import '../../../domain/entries/cv_custom_section.dart';
import '../../../domain/dates/cv_date_range.dart';
import '../../../domain/design/cv_design_spec.dart';
import '../../../domain/design/cv_canvas.dart';
import '../../../domain/document/cv_document.dart';
import '../../../domain/entries/cv_education.dart';
import '../../../domain/entries/cv_experience.dart';
import '../../../domain/entries/cv_language.dart';
import '../../../domain/entries/cv_note.dart';
import '../../../domain/document/cv_personal_info.dart';
import '../../../domain/entries/cv_project.dart';
import '../../../domain/document/cv_section.dart';
import '../../../domain/entries/cv_skill.dart';
import '../../editor/cv_section_presentation.dart';

/// Génère le PDF d'un CV : une fonction pure, sans état ni accès réseau.
///
/// L'aperçu et l'export partagent ces octets exacts, avec les polices livrées
/// dans les assets. Le contenu, son ordre et la visibilité des sections
/// viennent de [document] ; toutes les décisions de mise en forme viennent de
/// [spec]. Cette fonction ne connaît pas l'identité du modèle et ne contient
/// aucune couleur ni aucune taille en dur.
///
/// Le texte est toujours émis dans l'ordre de lecture attendu par un humain,
/// que lisent aussi les logiciels de tri des candidatures : un modèle à
/// colonne latérale émet, sur chaque page, tout le corps avant la colonne ;
/// un modèle à titres en marge émet chaque titre juste avant son contenu.
///
/// [photo] est passée à part : elle n'est pas persistée et n'appartient donc
/// pas au document.
Future<Uint8List> buildCvPdf(
  CvDocument document,
  CvDesignSpec spec, {
  Uint8List? photo,
}) async {
  final canvas = spec.canvas;
  canvas.validate();
  final fonts = await PdfFonts.load();
  final pdf = pw.Document(theme: fonts.theme);
  const mm = PdfPageFormat.mm;
  for (final page in canvas.pages) {
    final children = <pw.Widget>[];
    final zones = <PdfZone>[];
    for (final e in page.elements) {
      final color = PdfColor.fromInt(e.color);
      pw.Widget content;
      switch (e.type) {
        case CvCanvasElementType.flow:
          zones.add(
            PdfZone(
              left: (e.x + e.padding) * mm,
              top: (e.y + e.padding) * mm,
              width: (e.width - 2 * e.padding) * mm,
              height: (e.height - 2 * e.padding) * mm,
              children: _canvasFlow(e, page, document, spec, photo, fonts, pdf),
              overflowError: CanvasLayoutException(e.id),
            ),
          );
          content = pw.SizedBox();
        case CvCanvasElementType.rectangle:
          content = pw.SizedBox();
        case CvCanvasElementType.photo:
          if (photo == null || !spec.header.showPhoto) continue;
          content = pw.ClipRRect(
            horizontalRadius: e.radius * mm,
            verticalRadius: e.radius * mm,
            child: pw.Image(
              pw.MemoryImage(photo),
              fit: pw.BoxFit.cover,
              width: (e.width - 2 * e.padding) * mm,
              height: (e.height - 2 * e.padding) * mm,
            ),
          );
        case CvCanvasElementType.text:
          final text = e.binding == null
              ? e.text
              : _canvasBinding(document, e.binding!);
          content = _CanvasFit(
            e.id,
            child: pw.Text(
              text,
              textAlign: switch (e.align) {
                CvCanvasTextAlign.left => pw.TextAlign.left,
                CvCanvasTextAlign.center => pw.TextAlign.center,
                CvCanvasTextAlign.right => pw.TextAlign.right,
                CvCanvasTextAlign.justify => pw.TextAlign.justify,
              },
              style: pw.TextStyle(
                fontSize: e.fontSize,
                color: color,
                fontWeight: e.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontStyle: e.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
              ),
            ),
          );
        case CvCanvasElementType.section:
          final section = e.section!;
          if (!document.isVisible(section) || !document.hasContent(section)) {
            continue;
          }
          final sectionSpec = CvDesignSpec(
            canvas: spec.canvas,
            tokens: CvDesignTokens.fromJson({
              ...spec.tokens.toJson(),
              'scale': {...spec.tokens.scale.toJson(), 'body': e.fontSize},
            }),
            sections: spec.sections,
          );
          final renderer = _SectionRenderer(
            sectionSpec,
            width: (e.width - 2 * e.padding) * mm,
            palette: _Palette(
              heading: color,
              title: color,
              body: color,
              muted: color,
            ),
          );
          content = _CanvasFit(
            e.id,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: renderer.standardSection(section, document).toList(),
            ),
          );
      }
      children.add(
        pw.Positioned(
          left: e.x * mm,
          top: e.y * mm,
          child: pw.Container(
            width: e.width * mm,
            height: e.height * mm,
            padding: pw.EdgeInsets.all(e.padding * mm),
            decoration: pw.BoxDecoration(
              color: e.palette == CvCanvasPalette.sidebar
                  ? PdfColor.fromInt(
                      e.background ?? spec.tokens.effectiveSidebarSurfaceColor,
                    )
                  : e.background == null
                  ? null
                  : PdfColor.fromInt(e.background!),
              border: e.borderWidth == 0
                  ? null
                  : pw.Border.all(
                      color: PdfColor.fromInt(e.borderColor),
                      width: e.borderWidth * mm,
                    ),
              borderRadius: pw.BorderRadius.circular(e.radius * mm),
            ),
            child: content,
          ),
        ),
      );
    }
    pw.Widget decorations() => pw.Container(
      width: 210 * mm,
      height: 297 * mm,
      color: PdfColor.fromInt(page.background),
      child: pw.Stack(children: children),
    );
    if (zones.isEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => decorations(),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          maxPages: 200,
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            theme: fonts.theme.copyWith(
              defaultTextStyle: pw.TextStyle(
                fontSize: spec.tokens.scale.body,
                lineSpacing: spec.tokens.bodyLineSpacing,
                color: PdfColor.fromInt(spec.tokens.bodyColor),
              ),
            ),
            buildBackground: (_) =>
                pw.FullPage(ignoreMargins: true, child: decorations()),
          ),
          footer: page.showPageNumber
              ? (context) => pw.Container(
                  height: 10 * mm,
                  alignment: pw.Alignment.centerRight,
                  padding: pw.EdgeInsets.only(right: 15 * mm),
                  child: pw.Text(
                    '${context.pageNumber} / ${context.pagesCount}',
                    style: pw.TextStyle(
                      fontSize: spec.tokens.scale.footer,
                      color: PdfColor.fromInt(spec.tokens.footerColor),
                    ),
                  ),
                )
              : null,
          build: (_) => [ZonedFlow(zones: zones)],
        ),
      );
    }
  }
  return pdf.save();
}

List<pw.Widget> _canvasFlow(
  CvCanvasElement frame,
  CvCanvasPage page,
  CvDocument document,
  CvDesignSpec spec,
  Uint8List? photo,
  PdfFonts fonts,
  pw.Document pdf,
) {
  const mm = PdfPageFormat.mm;
  final width = (frame.width - 2 * frame.padding) * mm;
  final tokens = spec.tokens;
  final side = frame.palette == CvCanvasPalette.sidebar;
  final custom = frame.palette == CvCanvasPalette.custom;
  final textColor = PdfColor.fromInt(
    custom
        ? frame.color
        : side
        ? tokens.effectiveSidebarTextColor
        : tokens.bodyColor,
  );
  final renderer = _SectionRenderer(
    custom
        ? CvDesignSpec(
            canvas: spec.canvas,
            tokens: CvDesignTokens.fromJson({
              ...tokens.toJson(),
              'scale': {...tokens.scale.toJson(), 'body': frame.fontSize},
            }),
            sections: spec.sections,
          )
        : spec,
    width: width,
    titleMargin: frame.titleMargin,
    stackInline: side,
    palette: _Palette(
      heading: PdfColor.fromInt(
        custom
            ? frame.color
            : side
            ? tokens.effectiveSidebarHeadingColor
            : tokens.effectiveHeadingColor,
      ),
      title: side || custom ? textColor : PdfColor.fromInt(tokens.titleColor),
      body: textColor,
      muted: side || custom ? textColor : PdfColor.fromInt(tokens.mutedColor),
      headingSurface:
          !side && !custom && tokens.effectiveHeadingSurfaceColor != null
          ? PdfColor.fromInt(tokens.effectiveHeadingSurfaceColor!)
          : null,
      headingRule: !side && !custom && spec.sections.titleRuleWidth > 0
          ? PdfColor.fromInt(tokens.accentColor)
          : null,
    ),
  );
  final info = document.personalInfo;
  final contact = [
    if (info.location.isNotEmpty) _Contact(info.location, flows: true),
    if (info.phone.isNotEmpty)
      _Contact(info.phone, target: phoneTarget(info.phone)),
    if (info.email.isNotEmpty)
      _Contact(info.email.trim(), target: emailTarget(info.email)),
    if (info.website.isNotEmpty) _Contact.url(info.website),
  ];
  final links = [
    for (final link in info.links)
      if (link.url.isNotEmpty) _Contact.url(link.url),
  ];
  final contactFrame = page.elements
      .where((e) => e.type == CvCanvasElementType.flow && e.showContacts)
      .firstOrNull;
  final photoInFlow = page.elements.any(
    (e) => e.type == CvCanvasElementType.flow && e.showPhoto,
  );
  final hasHeader = page.elements.any(
    (e) => e.type == CvCanvasElementType.flow && e.showHeader,
  );
  final font = fonts.regular.getFont(pw.Context(document: pdf.document));
  bool tooWide(_Contact value) =>
      contactFrame != null &&
      !value.flows &&
      font.stringMetrics(value.text).advanceWidth * tokens.minContactFontSize >
          (contactFrame.width - 2 * contactFrame.padding) * mm;
  final showPhoto = spec.header.showPhoto ? photo : null;
  final photoSide = math.min(spec.header.photoDiameterMm * mm, width);
  pw.Widget portrait(Uint8List bytes) {
    final image = pw.Image(
      pw.MemoryImage(bytes),
      width: photoSide,
      height: photoSide,
      fit: pw.BoxFit.cover,
    );
    return switch (spec.header.photoShape) {
      CvPhotoShape.circle => pw.ClipOval(child: image),
      CvPhotoShape.rounded => pw.ClipRRect(
        horizontalRadius: photoSide * CvPhotoShape.roundedCornerRatio,
        verticalRadius: photoSide * CvPhotoShape.roundedCornerRatio,
        child: image,
      ),
      CvPhotoShape.square => image,
    };
  }

  final blocks = <pw.Widget>[
    if (frame.showPhoto && showPhoto != null)
      pw.Center(child: portrait(showPhoto)),
    if (frame.showContacts)
      ...renderer._contactSection([
        ...[
          ...contact,
          ...links,
        ].where((value) => !hasHeader || !tooWide(value)),
      ]),
    if (frame.showHeader)
      ..._header(
        spec,
        info,
        photo: photoInFlow ? null : showPhoto,
        photoWidget: portrait,
        contact: contact
            .where((value) => contactFrame == null || tooWide(value))
            .toList(),
        links: links
            .where((value) => contactFrame == null || tooWide(value))
            .toList(),
      ),
  ];
  final order = <CvSection>[
    ...frame.sectionOrder,
    if (frame.includeRemaining)
      ...document.presentation.orderedSections.where(
        (s) => !frame.sectionOrder.contains(s),
      ),
  ];
  for (final section in order) {
    if (section == CvSection.personalInfo ||
        frame.excludedSections.contains(section) ||
        !document.isVisible(section) ||
        !document.hasContent(section)) {
      continue;
    }
    blocks.addAll(renderer.standardSection(section, document));
  }
  if (frame.includeCustom) {
    for (final section in document.customSections) {
      if (section.visible && section.hasContent) {
        blocks.addAll(renderer.customSection(section));
      }
    }
  }
  return blocks;
}

String _canvasBinding(CvDocument document, String binding) {
  if (binding == 'personalInfo.fullName') return document.personalInfo.fullName;
  final parts = binding.split('.');
  final section = CvSection.values
      .where((s) => s.name == parts.first)
      .firstOrNull;
  if (section != null && !document.isVisible(section)) return '';
  Object? value = document.toJson();
  for (final part in parts) {
    if (value == null) return '';
    if (value is Map<String, dynamic>) {
      if (!value.containsKey(part)) {
        // Les champs optionnels nulls sont omis par le sérialiseur du CV.
        if (['start', 'end', 'month', 'date'].contains(part)) return '';
        throw FormatException('Champ du CV inconnu : $binding');
      }
      value = value[part];
    } else if (value is List) {
      final index = int.tryParse(part);
      if (index == null) {
        throw FormatException('Indice de liste invalide : $binding');
      }
      if (index >= value.length) return '';
      value = value[index];
      if (value is Map && value['visible'] == false) return '';
    } else {
      throw FormatException('Liaison de données invalide : $binding');
    }
  }
  if (value == null) return '';
  if (value is String || value is num || value is bool) return value.toString();
  throw FormatException(
    'La liaison doit désigner une valeur simple : $binding',
  );
}

/// Mesure le contenu sans limite verticale avant de vérifier le cadre.
/// Une erreur empêche aussi l'export : aucun texte n'est tronqué en silence.
class _CanvasFit extends pw.SingleChildWidget {
  _CanvasFit(this.id, {required pw.Widget child}) : super(child: child);
  final String id;
  @override
  bool get canSpan => false;
  @override
  void layout(
    pw.Context context,
    pw.BoxConstraints constraints, {
    bool parentUsesSize = false,
  }) {
    child!.layout(context, pw.BoxConstraints(maxWidth: constraints.maxWidth));
    final size = child!.box!;
    if (size.height > constraints.maxHeight + .01 ||
        size.width > constraints.maxWidth + .01) {
      throw CanvasLayoutException(id);
    }
    // Le haut du contenu reste aligné au haut du cadre positionné.
    child!.box = PdfRect(
      0,
      constraints.maxHeight - size.height,
      size.width,
      size.height,
    );
    box = PdfRect(0, 0, constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(pw.Context context) {
    super.paint(context);
    paintChild(context);
  }
}

class _Contact {
  const _Contact(this.text, {this.target, this.flows = false});

  /// Une adresse de site, affichée sans protocole ni « www. ».
  _Contact.url(String url) : this(displayUrl(url), target: urlTarget(url));

  final String text;

  /// La cible du lien cliquable, `null` pour un texte simple.
  final String? target;

  /// Un texte ordinaire, comme une ville, qui peut passer à la ligne. Les
  /// autres coordonnées restent sur une seule ligne.
  final bool flows;
}

/// Une coordonnée technique reste entière et sélectionnable, sans troncature.
/// Le texte est mesuré sans contrainte puis réduit seulement s'il déborde.
pw.Widget _singleLine(String text, pw.TextStyle style) => pw.FittedBox(
  fit: pw.BoxFit.scaleDown,
  alignment: pw.Alignment.centerLeft,
  child: pw.Text(text, style: style, softWrap: false),
);

/// Une coordonnée, cliquable si elle a une cible, suivie de [suffix].
pw.Widget _contactLine(
  _Contact contact,
  pw.TextStyle style, {
  String suffix = '',
}) {
  final text = '${contact.text}$suffix';
  if (contact.flows) return pw.Text(text, style: style);
  final line = _singleLine(text, style);
  return contact.target == null
      ? line
      : pw.UrlLink(destination: contact.target!, child: line);
}

/// L'en-tête du CV : nom, titre professionnel et, s'ils ne sont pas déplacés
/// dans la colonne latérale, la photo, les coordonnées et les liens.
List<pw.Widget> _header(
  CvDesignSpec spec,
  CvPersonalInfo info, {
  required Uint8List? photo,
  required List<_Contact> contact,
  required List<_Contact> links,
  required pw.Widget Function(Uint8List bytes) photoWidget,
}) {
  final tokens = spec.tokens;
  final scale = tokens.scale;
  final header = spec.header;
  final rule = spec.sections;
  final accent = PdfColor.fromInt(tokens.accentColor);
  final banner = header.fullWidthBanner;
  final onBanner = PdfColor.fromInt(tokens.onAccentColor);
  final muted = PdfColor.fromInt(tokens.mutedColor);
  final contactColor = banner ? onBanner : muted;
  final centered = header.alignment == CvHeaderAlignment.center;
  final name = info.fullName.isEmpty ? 'Votre nom' : info.fullName;

  return [
    pw.Container(
      padding: pw.EdgeInsets.all(banner ? header.bannerPadding : 0),
      color: banner ? accent : null,
      child: pw.Row(
        children: [
          if (photo != null) ...[
            photoWidget(photo),
            pw.SizedBox(width: header.photoGap),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: centered
                  ? pw.CrossAxisAlignment.center
                  : pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  header.nameUppercase ? name.toUpperCase() : name,
                  style: pw.TextStyle(
                    fontSize: scale.name,
                    color: banner
                        ? onBanner
                        : PdfColor.fromInt(tokens.titleColor),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (header.headlineGap > 0)
                  pw.SizedBox(height: header.headlineGap),
                pw.Text(
                  header.headlineUppercase
                      ? info.headline.toUpperCase()
                      : info.headline,
                  style: pw.TextStyle(
                    fontSize: scale.headline,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: header.headlineLetterSpacing,
                    color: banner ? onBanner : accent,
                  ),
                ),
                // Les coordonnées tiennent sur une ligne, les liens chacun sur
                // la sienne.
                if (contact.isNotEmpty || links.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    alignment: centered
                        ? pw.WrapAlignment.center
                        : pw.WrapAlignment.start,
                    children: [
                      for (var i = 0; i < contact.length; i++)
                        _contactLine(
                          contact[i],
                          pw.TextStyle(
                            fontSize: scale.meta,
                            color: contactColor,
                          ),
                          suffix: i + 1 < contact.length
                              ? rule.inlineSeparator
                              : '',
                        ),
                    ],
                  ),
                  for (final link in links)
                    _contactLine(
                      link,
                      pw.TextStyle(fontSize: scale.meta, color: contactColor),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    pw.SizedBox(height: tokens.headerGap),
    if (rule.headerRuleThickness != null)
      if (rule.headerRuleLength == null)
        pw.Divider(color: accent, thickness: rule.headerRuleThickness)
      else
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Align(
            alignment: centered ? pw.Alignment.center : pw.Alignment.centerLeft,
            child: pw.Container(
              width: rule.headerRuleLength,
              height: rule.headerRuleThickness,
              color: accent,
            ),
          ),
        ),
  ];
}

/// Les couleurs d'une zone de la page.
class _Palette {
  const _Palette({
    required this.heading,
    required this.title,
    required this.body,
    required this.muted,
    this.headingSurface,
    this.headingRule,
  });

  /// Titres de section.
  final PdfColor heading;

  /// Intitulés d'éléments.
  final PdfColor title;

  /// Corps de texte.
  final PdfColor body;

  /// Dates, lieux et compléments.
  final PdfColor muted;

  /// Fond des titres de section, s'il y en a un.
  final PdfColor? headingSurface;

  /// Filet à gauche des titres de section, s'il y en a un.
  final PdfColor? headingRule;
}

/// Le rendu des sections dans une zone de la page.
///
/// Chaque méthode renvoie une suite de blocs que la pagination peut séparer
/// les uns des autres. Le premier bloc d'une section porte toujours son titre
/// avec le début de son contenu, dans un bloc insécable : un titre ne reste
/// donc jamais seul en bas d'une page. Tout contenu de hauteur non bornée est
/// émis comme bloc suivant, jamais dans ce premier bloc.
class _SectionRenderer {
  _SectionRenderer(
    this.spec, {
    required this.width,
    required this.palette,
    this.titleMargin = 0,
    this.stackInline = false,
  });

  final CvDesignSpec spec;

  /// Largeur de la zone.
  final double width;

  final _Palette palette;

  /// Part de [width] réservée aux titres placés en marge ; `0` pour des
  /// titres au-dessus de leur contenu.
  final double titleMargin;

  /// Les compétences et les langues vont à la ligne plutôt que d'être
  /// séparées sur une seule ligne : c'est le rendu d'une colonne étroite.
  final bool stackInline;

  /// Espace entre un titre en marge et son contenu.
  static const _marginGap = 12.0;

  CvDesignTokens get tokens => spec.tokens;
  CvDesignTypeScale get scale => tokens.scale;
  CvDesignSectionStyle get style => spec.sections;

  /// Retrait du contenu quand les titres sont en marge.
  double get _indent => width * titleMargin;

  /// Le titre d'une section, avec ses éventuelles décorations.
  pw.Widget _title(String label) => pw.Container(
    padding: pw.EdgeInsets.symmetric(
      horizontal: style.titlePaddingHorizontal,
      vertical: style.titlePaddingVertical,
    ),
    decoration: palette.headingSurface == null && palette.headingRule == null
        ? null
        : pw.BoxDecoration(
            color: palette.headingSurface,
            borderRadius: style.titleRadius > 0 && palette.headingRule == null
                ? pw.BorderRadius.circular(style.titleRadius)
                : null,
            border: palette.headingRule == null
                ? null
                : pw.Border(
                    left: pw.BorderSide(
                      color: palette.headingRule!,
                      width: style.titleRuleWidth,
                    ),
                  ),
          ),
    child: pw.Text(
      switch (style.titleCase) {
        CvSectionTitleCase.upper => label.toUpperCase(),
        CvSectionTitleCase.none => label,
      },
      style: pw.TextStyle(
        fontSize: scale.sectionTitle,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: style.titleLetterSpacing,
        color: palette.heading,
      ),
    ),
  );

  /// Le premier bloc d'une section : son titre et le début de son contenu.
  ///
  /// Le titre est placé au-dessus de [first], ou dans la marge à sa gauche.
  /// Il est émis avant lui dans les deux cas : l'ordre de lecture est
  /// préservé.
  pw.Widget _opening(String label, pw.Widget first) {
    if (titleMargin == 0) {
      return KeepTogether(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.only(
                top: tokens.sectionTitleGapAbove,
                bottom: tokens.sectionTitleGapBelow,
              ),
              child: _title(label),
            ),
            first,
          ],
        ),
      );
    }
    return KeepTogether(
      child: pw.Padding(
        padding: pw.EdgeInsets.only(top: tokens.sectionTitleGapAbove),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(width: _indent - _marginGap, child: _title(label)),
            pw.SizedBox(width: _marginGap),
            pw.Expanded(child: first),
          ],
        ),
      ),
    );
  }

  /// Un bloc qui suit le premier, aligné sur le contenu et non sur le titre.
  pw.Widget _following(pw.Widget block) => titleMargin == 0
      ? block
      : pw.Padding(
          padding: pw.EdgeInsets.only(left: _indent),
          child: block,
        );

  /// Un texte qui accepte d'être coupé entre deux pages.
  ///
  /// Sans cela, un paragraphe plus haut qu'une page bloque la génération :
  /// `MultiPage` scinde une colonne entre ses enfants, mais pas un enfant
  /// indivisible. Une description fleuve ou une longue liste de compétences
  /// faisait ainsi échouer l'aperçu.
  pw.Widget _flowingText(String text) => pw.Text(
    text,
    style: pw.TextStyle(color: palette.body),
    overflow: pw.TextOverflow.span,
  );

  /// Les lignes d'une description, préfixées comme le demande le modèle.
  Iterable<pw.Widget> _descriptionLines(String description) => description
      .split('\n')
      .map((line) => _following(_flowingText('${style.bulletPrefix}$line')));

  /// Un titre de section suivi de son texte, coupable entre deux pages.
  ///
  /// Seul un fragment borné accompagne le titre dans le premier bloc : le
  /// reste suit comme blocs frères et se répartit librement sur les pages
  /// suivantes.
  Iterable<pw.Widget> titledText(String sectionLabel, String text) {
    final lines = text.split('\n');
    final first = lines.first;
    // Environ sept lignes : de quoi tenir avec le titre sur n'importe quelle
    // page, sans couper les textes de longueur ordinaire.
    const maxWithTitle = 600;
    var head = first;
    var tail = '';
    if (first.length > maxWithTitle) {
      final cut = first.lastIndexOf(' ', maxWithTitle);
      final at = cut <= 0 ? maxWithTitle : cut;
      head = first.substring(0, at);
      tail = first.substring(at).trimLeft();
    }
    return [
      _opening(sectionLabel, _flowingText(head)),
      if (tail.isNotEmpty) _following(_flowingText(tail)),
      ...lines.skip(1).map((line) => _following(_flowingText(line))),
    ];
  }

  /// Les coordonnées reprises par la colonne latérale, une par ligne.
  Iterable<pw.Widget> _contactSection(List<_Contact> values) {
    if (values.isEmpty) return const [];
    pw.Widget line(_Contact value) => value.flows
        ? _flowingText(value.text)
        : _contactLine(
            value,
            pw.TextStyle(fontSize: scale.body, color: palette.body),
          );
    return [
      if (values.first.flows)
        ...titledText('Contact', values.first.text)
      else
        _opening('Contact', line(values.first)),
      ...values.skip(1).map(line),
    ];
  }

  /// Le libellé d'une période : « sept. 2023 – aujourd'hui ».
  String _periodLabel(CvDateRange period) => [
    period.start?.format() ?? '',
    period.isCurrent ? "aujourd'hui" : period.end?.format() ?? '',
  ].where((part) => part.isNotEmpty).join(' – ');

  /// L'intitulé d'un élément, sa période et son complément, insécables.
  pw.Widget _entryHeader({
    required bool first,
    required String title,
    String meta = '',
    String subtitle = '',
    bool subtitleIsUrl = false,
  }) => KeepTogether(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (!first) pw.SizedBox(height: tokens.entryGap),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: scale.entryTitle,
                  fontWeight: pw.FontWeight.bold,
                  color: palette.title,
                ),
              ),
            ),
            if (meta.isNotEmpty && !style.stackEntryMeta) ...[
              pw.SizedBox(width: 8),
              pw.Text(
                meta,
                style: pw.TextStyle(fontSize: scale.meta, color: palette.muted),
              ),
            ],
          ],
        ),
        if (meta.isNotEmpty && style.stackEntryMeta)
          pw.Text(
            meta,
            style: pw.TextStyle(fontSize: scale.meta, color: palette.muted),
          ),
        if (subtitle.isNotEmpty && subtitleIsUrl)
          _contactLine(
            _Contact.url(subtitle),
            pw.TextStyle(
              fontSize: scale.meta,
              color: palette.muted,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        if (subtitle.isNotEmpty && !subtitleIsUrl)
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: scale.meta,
              fontStyle: pw.FontStyle.italic,
              color: palette.muted,
            ),
          ),
      ],
    ),
  );

  /// Une section de valeurs courtes : compétences, langues.
  Iterable<pw.Widget> _inlineSection(
    String sectionLabel,
    Iterable<String> values,
  ) {
    final kept = values.where((value) => value.isNotEmpty);
    final text = kept.join(stackInline ? '\n' : style.inlineSeparator);
    if (text.isEmpty) return const [];
    return titledText(sectionLabel, text);
  }

  /// Les éléments d'une section, chacun avec son intitulé et sa description.
  Iterable<pw.Widget> _entrySection<T>(
    String sectionLabel,
    List<T> entries, {
    required String Function(T entry) title,
    String Function(T entry)? meta,
    String Function(T entry)? subtitle,
    String Function(T entry)? description,
    bool subtitleIsUrl = false,
  }) {
    final widgets = <pw.Widget>[];
    var first = true;
    for (final entry in entries) {
      final entryTitle = title(entry);
      final entryDescription = description?.call(entry) ?? '';
      if (entryTitle.isEmpty && entryDescription.isEmpty) continue;
      final entryMeta = meta?.call(entry) ?? '';
      final entrySubtitle = subtitle?.call(entry) ?? '';
      // Sans en-tête visible, le premier contenu est la description : son
      // début doit accompagner le titre, tout en laissant la suite paginer.
      if (first &&
          entryTitle.trim().isEmpty &&
          entryMeta.trim().isEmpty &&
          entrySubtitle.trim().isEmpty) {
        final text = entryDescription.trimLeft();
        if (text.isEmpty) continue;
        widgets.addAll(
          titledText(
            sectionLabel,
            text
                .split('\n')
                .map((line) => '${style.bulletPrefix}$line')
                .join('\n'),
          ),
        );
        first = false;
        continue;
      }
      final header = _entryHeader(
        first: first,
        title: entryTitle,
        meta: entryMeta,
        subtitle: entrySubtitle,
        subtitleIsUrl: subtitleIsUrl,
      );
      widgets.add(first ? _opening(sectionLabel, header) : _following(header));
      if (entryDescription.isNotEmpty) {
        widgets.addAll(_descriptionLines(entryDescription));
      }
      first = false;
    }
    return widgets;
  }

  String _joined(Iterable<String> parts) =>
      parts.where((part) => part.isNotEmpty).join(style.inlineSeparator);

  /// Les blocs d'une section standard.
  Iterable<pw.Widget> standardSection(CvSection section, CvDocument document) {
    final label = section.label;
    return switch (section) {
      CvSection.personalInfo => const <pw.Widget>[],
      CvSection.profile => titledText(label, document.profile),
      CvSection.experiences => _entrySection<CvExperience>(
        label,
        document.experiences,
        title: (e) => _joined([e.position, e.company]),
        meta: (e) => _periodLabel(e.period),
        subtitle: (e) => e.location,
        description: (e) => e.description,
      ),
      CvSection.education => _entrySection<CvEducation>(
        label,
        document.education,
        title: (e) => _joined([e.degree, e.school]),
        meta: (e) => _periodLabel(e.period),
        subtitle: (e) => e.location,
        description: (e) => e.description,
      ),
      CvSection.skills => _inlineSection(
        label,
        document.skills.map((CvSkill skill) => skill.name),
      ),
      CvSection.languages => _inlineSection(
        label,
        document.languages.map(
          (CvLanguage language) => language.level.isEmpty
              ? language.name
              : '${language.name} (${language.level})',
        ),
      ),
      CvSection.certifications => _entrySection<CvCertification>(
        label,
        document.certifications,
        title: (e) => _joined([e.name, e.issuer]),
        meta: (e) => e.date?.format() ?? '',
        description: (e) => e.description,
      ),
      CvSection.projects => _entrySection<CvProject>(
        label,
        document.projects,
        title: (e) => _joined([e.name, e.role]),
        meta: (e) => _periodLabel(e.period),
        subtitle: (e) => e.url,
        subtitleIsUrl: true,
        description: (e) => e.description,
      ),
      CvSection.interests => _entrySection<CvNote>(
        label,
        document.interests,
        title: (e) => e.label,
        description: (e) => e.description,
      ),
      CvSection.references => _entrySection<CvNote>(
        label,
        document.references,
        title: (e) => e.label,
        description: (e) => e.description,
      ),
    };
  }

  /// Les blocs d'une section personnalisée.
  Iterable<pw.Widget> customSection(CvCustomSection custom) =>
      switch (custom.type) {
        CvCustomSectionType.freeText => titledText(custom.name, custom.text),
        CvCustomSectionType.datedList => _entrySection<CvCustomItem>(
          custom.name,
          custom.items,
          title: (e) => _joined([e.title, e.subtitle]),
          meta: (e) => _periodLabel(e.period),
          description: (e) => e.description,
        ),
        CvCustomSectionType.simpleList => _entrySection<CvCustomItem>(
          custom.name,
          custom.items,
          title: (e) => e.title,
          description: (e) => e.description,
        ),
      };
}
