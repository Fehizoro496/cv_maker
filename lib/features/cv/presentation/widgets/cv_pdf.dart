import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_fonts.dart';
import '../../domain/cv_certification.dart';
import '../../domain/cv_date_range.dart';
import '../../domain/cv_design_spec.dart';
import '../../domain/cv_document.dart';
import '../../domain/cv_education.dart';
import '../../domain/cv_experience.dart';
import '../../domain/cv_language.dart';
import '../../domain/cv_note.dart';
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
  final scale = tokens.scale;
  final style = spec.sections;
  final accent = PdfColor.fromInt(tokens.accentColor);
  final muted = PdfColor.fromInt(tokens.mutedColor);
  final separator = style.inlineSeparator;

  pw.Widget heading(String title) => pw.Padding(
    padding: pw.EdgeInsets.only(
      top: tokens.sectionTitleGapAbove,
      bottom: tokens.sectionTitleGapBelow,
    ),
    child: pw.Container(
      padding: pw.EdgeInsets.symmetric(
        horizontal: style.titlePaddingHorizontal,
        vertical: style.titlePaddingVertical,
      ),
      decoration:
          tokens.headingSurfaceColor == null && style.titleRuleWidth == 0
          ? null
          : pw.BoxDecoration(
              color: tokens.headingSurfaceColor == null
                  ? null
                  : PdfColor.fromInt(tokens.headingSurfaceColor!),
              border: style.titleRuleWidth == 0
                  ? null
                  : pw.Border(
                      left: pw.BorderSide(
                        color: accent,
                        width: style.titleRuleWidth,
                      ),
                    ),
            ),
      child: pw.Text(
        switch (style.titleCase) {
          CvSectionTitleCase.upper => title.toUpperCase(),
          CvSectionTitleCase.none => title,
        },
        style: pw.TextStyle(
          fontSize: scale.sectionTitle,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: style.titleLetterSpacing,
          color: PdfColor.fromInt(tokens.effectiveHeadingColor),
        ),
      ),
    ),
  );

  /// Les lignes d'une description, préfixées comme le demande le modèle.
  Iterable<pw.Widget> descriptionLines(String description) => description
      .split('\n')
      .map((line) => pw.Text('${style.bulletPrefix}$line'));

  /// Le libellé d'une période : « sept. 2023 – aujourd'hui ».
  String periodLabel(CvDateRange period) => [
    period.start?.format() ?? '',
    period.isCurrent ? "aujourd'hui" : period.end?.format() ?? '',
  ].where((part) => part.isNotEmpty).join(' – ');

  /// L'intitulé d'un élément, sa période et son complément.
  ///
  /// Le titre de section voyage dans le même widget que le premier élément :
  /// il ne peut donc pas rester seul en bas d'une page.
  pw.Widget entryHeader({
    required bool first,
    required String sectionLabel,
    required String title,
    String meta = '',
    String subtitle = '',
  }) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (first)
        heading(sectionLabel)
      else
        pw.SizedBox(height: tokens.entryGap),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: scale.entryTitle,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(tokens.titleColor),
              ),
            ),
          ),
          if (meta.isNotEmpty) ...[
            pw.SizedBox(width: 8),
            pw.Text(
              meta,
              style: pw.TextStyle(fontSize: scale.meta, color: muted),
            ),
          ],
        ],
      ),
      if (subtitle.isNotEmpty)
        pw.Text(
          subtitle,
          style: pw.TextStyle(
            fontSize: scale.meta,
            fontStyle: pw.FontStyle.italic,
            color: muted,
          ),
        ),
    ],
  );

  /// Une section rendue sur une seule ligne : compétences, langues.
  Iterable<pw.Widget> inlineSection(
    String sectionLabel,
    Iterable<String> values,
  ) {
    final text = values.where((value) => value.isNotEmpty).join(separator);
    if (text.isEmpty) return const [];
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [heading(sectionLabel), pw.Text(text)],
      ),
    ];
  }

  /// Les éléments d'une section, chacun avec son intitulé et sa description.
  Iterable<pw.Widget> entrySection<T>(
    String sectionLabel,
    List<T> entries, {
    required String Function(T entry) title,
    String Function(T entry)? meta,
    String Function(T entry)? subtitle,
    String Function(T entry)? description,
  }) {
    final widgets = <pw.Widget>[];
    var first = true;
    for (final entry in entries) {
      final entryTitle = title(entry);
      final entryDescription = description?.call(entry) ?? '';
      if (entryTitle.isEmpty && entryDescription.isEmpty) continue;
      widgets.add(
        entryHeader(
          first: first,
          sectionLabel: sectionLabel,
          title: entryTitle,
          meta: meta?.call(entry) ?? '',
          subtitle: subtitle?.call(entry) ?? '',
        ),
      );
      if (entryDescription.isNotEmpty) {
        widgets.addAll(descriptionLines(entryDescription));
      }
      first = false;
    }
    return widgets;
  }

  /// Le profil professionnel : le titre reste avec sa première ligne.
  Iterable<pw.Widget> profileSection(String sectionLabel, String profile) {
    final lines = profile.split('\n');
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [heading(sectionLabel), pw.Text(lines.first)],
      ),
      ...lines.skip(1).map(pw.Text.new),
    ];
  }

  String joined(Iterable<String> parts) =>
      parts.where((part) => part.isNotEmpty).join(separator);

  final blocks = <pw.Widget>[];
  // Le modèle peut imposer son ordre sans toucher à celui du CV.
  final sectionOrder = spec.structure.orderedSections(
    document.presentation.orderedSections,
  );
  for (final section in sectionOrder) {
    // Les informations personnelles constituent l'en-tête, rendu à part.
    if (section == CvSection.personalInfo) continue;
    if (!document.isVisible(section) || !document.hasContent(section)) continue;
    final label = section.label;
    blocks.addAll(switch (section) {
      CvSection.personalInfo => const <pw.Widget>[],
      CvSection.profile => profileSection(label, document.profile),
      CvSection.experiences => entrySection<CvExperience>(
        label,
        document.experiences,
        title: (e) => joined([e.position, e.company]),
        meta: (e) => periodLabel(e.period),
        subtitle: (e) => e.location,
        description: (e) => e.description,
      ),
      CvSection.education => entrySection<CvEducation>(
        label,
        document.education,
        title: (e) => joined([e.degree, e.school]),
        meta: (e) => periodLabel(e.period),
        subtitle: (e) => e.location,
        description: (e) => e.description,
      ),
      CvSection.skills => inlineSection(
        label,
        document.skills.map((CvSkill skill) => skill.name),
      ),
      CvSection.languages => inlineSection(
        label,
        document.languages.map(
          (CvLanguage language) => language.level.isEmpty
              ? language.name
              : '${language.name} (${language.level})',
        ),
      ),
      CvSection.certifications => entrySection<CvCertification>(
        label,
        document.certifications,
        title: (e) => joined([e.name, e.issuer]),
        meta: (e) => e.date?.format() ?? '',
        description: (e) => e.description,
      ),
      CvSection.projects => entrySection<CvProject>(
        label,
        document.projects,
        title: (e) => joined([e.name, e.role]),
        meta: (e) => periodLabel(e.period),
        subtitle: (e) => e.url,
        description: (e) => e.description,
      ),
      CvSection.interests => entrySection<CvNote>(
        label,
        document.interests,
        title: (e) => e.label,
        description: (e) => e.description,
      ),
      CvSection.references => entrySection<CvNote>(
        label,
        document.references,
        title: (e) => e.label,
        description: (e) => e.description,
      ),
    });
  }

  final info = document.personalInfo;
  final banner = spec.header.fullWidthBanner;
  final onBanner = PdfColor.fromInt(tokens.onAccentColor);
  final nameColor = banner ? onBanner : PdfColor.fromInt(tokens.titleColor);
  final headlineColor = banner ? onBanner : accent;
  final contactColor = banner ? onBanner : muted;
  final centered = spec.header.alignment == CvHeaderAlignment.center;
  final headerPhoto = spec.header.showPhoto ? photo : null;
  final photoSide = spec.header.photoDiameterMm * PdfPageFormat.mm;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(tokens.pageMarginMm * PdfPageFormat.mm),
      theme: fonts.theme.copyWith(
        defaultTextStyle: pw.TextStyle(
          fontSize: scale.body,
          lineSpacing: tokens.bodyLineSpacing,
          color: PdfColor.fromInt(tokens.bodyColor),
        ),
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: pw.TextStyle(
            fontSize: scale.footer,
            color: PdfColor.fromInt(tokens.footerColor),
          ),
        ),
      ),
      build: (context) => [
        pw.Container(
          padding: pw.EdgeInsets.all(banner ? spec.header.bannerPadding : 0),
          color: banner ? accent : null,
          child: pw.Row(
            children: [
              if (headerPhoto != null) ...[
                switch (spec.header.photoShape) {
                  CvPhotoShape.circle => pw.ClipOval(
                    child: pw.Image(
                      pw.MemoryImage(headerPhoto),
                      width: photoSide,
                      height: photoSide,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                  CvPhotoShape.square => pw.Image(
                    pw.MemoryImage(headerPhoto),
                    width: photoSide,
                    height: photoSide,
                    fit: pw.BoxFit.cover,
                  ),
                },
                pw.SizedBox(width: spec.header.photoGap),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: centered
                      ? pw.CrossAxisAlignment.center
                      : pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      info.fullName.isEmpty ? 'Votre nom' : info.fullName,
                      style: pw.TextStyle(
                        fontSize: scale.name,
                        color: nameColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      info.headline,
                      style: pw.TextStyle(
                        fontSize: scale.headline,
                        fontWeight: pw.FontWeight.bold,
                        color: headlineColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      joined([
                        info.location,
                        info.phone,
                        info.email,
                        info.website,
                      ]),
                      textAlign: centered
                          ? pw.TextAlign.center
                          : pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: scale.meta,
                        color: contactColor,
                      ),
                    ),
                    for (final link in info.links)
                      pw.Text(
                        link.url,
                        style: pw.TextStyle(
                          fontSize: scale.meta,
                          color: contactColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: tokens.headerGap),
        if (style.headerRuleThickness != null)
          pw.Divider(color: accent, thickness: style.headerRuleThickness),
        ...blocks,
      ],
    ),
  );
  return pdf.save();
}
