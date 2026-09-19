import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_fonts.dart';
import '../../../../core/pdf/pdf_links.dart';
import '../../../../core/pdf/pdf_zones.dart';
import '../../domain/cv_certification.dart';
import '../../domain/cv_custom_section.dart';
import '../../domain/cv_date_range.dart';
import '../../domain/cv_design_spec.dart';
import '../../domain/cv_document.dart';
import '../../domain/cv_education.dart';
import '../../domain/cv_experience.dart';
import '../../domain/cv_language.dart';
import '../../domain/cv_note.dart';
import '../../domain/cv_personal_info.dart';
import '../../domain/cv_project.dart';
import '../../domain/cv_section.dart';
import '../../domain/cv_skill.dart';
import '../cv_section_presentation.dart';

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
  final fonts = await PdfFonts.load();
  final pdf = pw.Document(theme: fonts.theme);
  final tokens = spec.tokens;
  final structure = spec.structure;
  final sidebar = structure.sidebar;
  final accent = PdfColor.fromInt(tokens.accentColor);
  final font = fonts.regular.getFont(pw.Context(document: pdf.document));

  // Les coordonnées, sous leur forme affichée. Une adresse de site perd son
  // protocole et son « www. » : le lien cliquable garde l'adresse complète.
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
  double widthAt(_Contact value, double fontSize) =>
      font.stringMetrics(value.text).advanceWidth * fontSize;

  // Les zones de la page, en points depuis le bord gauche du contenu. La
  // colonne latérale utilise son propre retrait [CvDesignSidebar.gutter]
  // de part et d'autre, plutôt que la marge du corps de la page.
  const format = PdfPageFormat.a4;
  final margin = tokens.pageMarginMm * PdfPageFormat.mm;
  final contentWidth = format.width - 2 * margin;
  var mainLeft = 0.0;
  var mainWidth = contentWidth;
  var asideLeft = 0.0;
  var asideWidth = 0.0;
  var band = 0.0;
  if (sidebar != null) {
    final gutter = sidebar.gutter;
    band = sidebar.width * format.width;
    // Une coordonnée trop large élargit d'abord la colonne, dans la limite
    // du modèle, avant d'être réduite puis, en dernier recours, renvoyée
    // dans l'en-tête.
    if (sidebar.holdsContact) {
      final widest = [
        for (final value in [...contact, ...links])
          if (!value.flows) widthAt(value, tokens.scale.body),
      ].fold(0.0, math.max);
      band += (widest - (band - 2 * gutter)).clamp(
        0.0,
        band * sidebar.maxGrowth,
      );
    }
    asideWidth = band - 2 * gutter;
    switch (sidebar.position) {
      case CvSidebarPosition.left:
        asideLeft = gutter - margin;
        mainLeft = band - margin + gutter;
        mainWidth = contentWidth - mainLeft;
      case CvSidebarPosition.right:
        final bandStart = format.width - band - margin;
        mainWidth = bandStart - gutter;
        asideLeft = bandStart + gutter;
    }
  }

  final main = _SectionRenderer(
    spec,
    width: mainWidth,
    titleMargin: structure.titleMargin,
    palette: _Palette(
      heading: PdfColor.fromInt(tokens.effectiveHeadingColor),
      title: PdfColor.fromInt(tokens.titleColor),
      body: PdfColor.fromInt(tokens.bodyColor),
      muted: PdfColor.fromInt(tokens.mutedColor),
      headingSurface: tokens.effectiveHeadingSurfaceColor == null
          ? null
          : PdfColor.fromInt(tokens.effectiveHeadingSurfaceColor!),
      headingRule: spec.sections.titleRuleWidth == 0 ? null : accent,
    ),
  );
  final asideText = PdfColor.fromInt(tokens.effectiveSidebarTextColor);
  final aside = _SectionRenderer(
    spec,
    width: asideWidth,
    stackInline: true,
    palette: _Palette(
      heading: PdfColor.fromInt(tokens.effectiveSidebarHeadingColor),
      title: asideText,
      body: asideText,
      muted: asideText,
    ),
  );

  final mainBlocks = <pw.Widget>[];
  final asideBlocks = <pw.Widget>[];
  // Le modèle peut imposer son ordre sans toucher à celui du CV.
  final sectionOrder = structure.orderedSections(
    document.presentation.orderedSections,
  );
  for (final section in sectionOrder) {
    // Les informations personnelles constituent l'en-tête, rendu à part.
    if (section == CvSection.personalInfo) continue;
    if (!document.isVisible(section) || !document.hasContent(section)) continue;
    if (structure.inSidebar(section)) {
      asideBlocks.addAll(aside.standardSection(section, document));
    } else {
      mainBlocks.addAll(main.standardSection(section, document));
    }
  }
  // Les sections personnalisées suivent les sections standard, dans leur ordre
  // de création, avec les composants des sections dont elles prennent la forme.
  for (final custom in document.customSections) {
    if (!custom.visible || !custom.hasContent) continue;
    mainBlocks.addAll(main.customSection(custom));
  }

  final showPhoto = spec.header.showPhoto ? photo : null;
  final contactInHeader = !(sidebar?.holdsContact ?? false);
  final wideContacts = {
    if (!contactInHeader)
      for (final value in [...contact, ...links])
        if (!value.flows &&
            widthAt(value, tokens.minContactFontSize) > asideWidth)
          value,
  };
  // Dans la colonne latérale, la photo ne dépasse pas la largeur du texte.
  final photoSide = math.min(
    spec.header.photoDiameterMm * PdfPageFormat.mm,
    sidebar?.holdsPhoto ?? false ? asideWidth : double.infinity,
  );

  pw.Widget photoWidget(Uint8List bytes) {
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

  if (sidebar != null) {
    final sidebarContact = [
      ...contact,
      ...links,
    ].where((value) => !wideContacts.contains(value)).toList();
    // La colonne s'ouvre sur la photo puis les coordonnées qu'elle reprend à
    // l'en-tête.
    asideBlocks.insertAll(0, [
      if (sidebar.holdsPhoto && showPhoto != null)
        pw.Center(child: photoWidget(showPhoto)),
      if (sidebar.holdsContact && sidebarContact.isNotEmpty)
        ...aside._contactSection(sidebarContact),
    ]);
  }

  final headerBlocks = _header(
    spec,
    info,
    photo: sidebar?.holdsPhoto ?? false ? null : showPhoto,
    contact: contact
        .where((value) => contactInHeader || wideContacts.contains(value))
        .toList(),
    links: links
        .where((value) => contactInHeader || wideContacts.contains(value))
        .toList(),
    photoWidget: photoWidget,
  );

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: pw.EdgeInsets.all(margin),
        theme: fonts.theme.copyWith(
          defaultTextStyle: pw.TextStyle(
            fontSize: tokens.scale.body,
            lineSpacing: tokens.bodyLineSpacing,
            color: PdfColor.fromInt(tokens.bodyColor),
          ),
        ),
        // Le fond de la colonne, avec son retrait et son arrondi. Il ne
        // porte aucun texte.
        buildBackground: sidebar == null
            ? null
            : (context) => pw.FullPage(
                ignoreMargins: true,
                child: pw.Align(
                  alignment: sidebar.position == CvSidebarPosition.left
                      ? pw.Alignment.topLeft
                      : pw.Alignment.topRight,
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(sidebar.surfaceInset),
                    child: pw.Container(
                      width: band - 2 * sidebar.surfaceInset,
                      height: format.height - 2 * sidebar.surfaceInset,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(
                          tokens.effectiveSidebarSurfaceColor,
                        ),
                        borderRadius: pw.BorderRadius.circular(
                          sidebar.cornerRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: tokens.scale.footer,
            color: PdfColor.fromInt(tokens.footerColor),
          ),
        ),
      ),
      build: (context) => sidebar == null
          ? [...headerBlocks, ...mainBlocks]
          : [
              // Le corps d'abord : c'est l'ordre dans lequel les zones sont
              // émises sur chaque page.
              ZonedFlow(
                zones: [
                  PdfZone(
                    left: mainLeft,
                    width: mainWidth,
                    children: [...headerBlocks, ...mainBlocks],
                  ),
                  PdfZone(
                    left: asideLeft,
                    width: asideWidth,
                    children: asideBlocks,
                  ),
                ],
              ),
            ],
    ),
  );
  return pdf.save();
}

/// Une coordonnée telle qu'elle est posée sur la page.
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
