import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/pdf/pdf_fonts.dart';
import '../../domain/cv_design_spec.dart';
import '../../domain/cv_section.dart';
import '../cv_section_presentation.dart';
import '../editor_draft_provider.dart';

/// The preview and export share these exact bytes, with bundled offline fonts.
///
/// Toutes les décisions de mise en forme viennent de [spec] : cette fonction ne
/// connaît pas l'identité du modèle et ne contient aucune couleur ni aucune
/// taille en dur. Ajouter un modèle consiste à écrire une nouvelle
/// `CvDesignSpec`.
Future<Uint8List> buildDraftPdf(
  EditorDraft draft,
  Map<CvSection, bool> visibility,
  CvDesignSpec spec,
) async {
  final fonts = await PdfFonts.load();
  final document = pw.Document(theme: fonts.theme);
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

  /// Les lignes de description, préfixées comme le demande le modèle.
  Iterable<pw.Widget> descriptionLines(String description) => description
      .split('\n')
      .map((line) => pw.Text('${style.bulletPrefix}$line'));

  final blocks = <pw.Widget>[];
  final profile = draft.fields['Profil professionnel'] ?? '';
  if (profile.isNotEmpty) {
    final lines = profile.split('\n');
    // Le titre voyage avec sa première ligne : il ne peut pas rester seul en
    // bas de page.
    blocks.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [heading('Profil professionnel'), pw.Text(lines.first)],
      ),
    );
    blocks.addAll(lines.skip(1).map(pw.Text.new));
  }
  for (final section in CvSection.values.skip(2)) {
    final entries = draft.entries[section] ?? [];
    if (visibility[section] == false || entries.isEmpty) continue;
    if (section == CvSection.skills || section == CvSection.languages) {
      final text = entries
          .map(
            (entry) => section == CvSection.skills
                ? entry['Nom'] ?? ''
                : '${entry['Langue'] ?? ''}${(entry['Niveau'] ?? '').isEmpty ? '' : ' (${entry['Niveau']})'}',
          )
          .where((v) => v.isNotEmpty)
          .join(separator);
      blocks.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [heading(section.label), pw.Text(text)],
        ),
      );
      continue;
    }
    var first = true;
    for (final entry in entries) {
      final values = entry.entries
          .where(
            (e) =>
                !['id', 'En cours', 'Début', 'Fin', 'Lieu'].contains(e.key) &&
                e.value.isNotEmpty,
          )
          .toList();
      if (values.isEmpty) continue;
      final titleValues = values
          .where((e) => !e.key.startsWith('Description'))
          .map((e) => e.value)
          .toList();
      final description = values
          .where((e) => e.key.startsWith('Description'))
          .map((e) => e.value)
          .join('\n');
      final dates = [
        entry['Début'] ?? '',
        entry['En cours'] == 'true' ? "aujourd'hui" : entry['Fin'] ?? '',
      ].where((v) => v.isNotEmpty).join(' – ');
      blocks.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (first)
              heading(section.label)
            else
              pw.SizedBox(height: tokens.entryGap),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    titleValues.join(separator),
                    style: pw.TextStyle(
                      fontSize: scale.entryTitle,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(tokens.titleColor),
                    ),
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  pw.SizedBox(width: 8),
                  pw.Text(
                    dates,
                    style: pw.TextStyle(fontSize: scale.meta, color: muted),
                  ),
                ],
              ],
            ),
            if ((entry['Lieu'] ?? '').isNotEmpty)
              pw.Text(
                entry['Lieu']!,
                style: pw.TextStyle(
                  fontSize: scale.meta,
                  fontStyle: pw.FontStyle.italic,
                  color: muted,
                ),
              ),
          ],
        ),
      );
      if (description.isNotEmpty) blocks.addAll(descriptionLines(description));
      first = false;
    }
  }

  final banner = spec.header.fullWidthBanner;
  final headerTextColor = PdfColor.fromInt(
    banner ? tokens.onAccentColor : tokens.titleColor,
  );
  final headlineColor = banner ? PdfColor.fromInt(tokens.onAccentColor) : accent;
  final headerMutedColor = banner
      ? PdfColor.fromInt(tokens.onAccentColor)
      : muted;
  final centered = spec.header.alignment == CvHeaderAlignment.center;
  final photo = spec.header.showPhoto ? draft.photo : null;
  final photoSide = spec.header.photoDiameterMm * PdfPageFormat.mm;

  document.addPage(
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
              if (photo != null) ...[
                switch (spec.header.photoShape) {
                  CvPhotoShape.circle => pw.ClipOval(
                    child: pw.Image(
                      pw.MemoryImage(photo),
                      width: photoSide,
                      height: photoSide,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                  CvPhotoShape.square => pw.Image(
                    pw.MemoryImage(photo),
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
                      draft.name.isEmpty ? 'Votre nom' : draft.name,
                      style: pw.TextStyle(
                        fontSize: scale.name,
                        color: headerTextColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      draft.fields['Titre professionnel'] ?? '',
                      style: pw.TextStyle(
                        fontSize: scale.headline,
                        fontWeight: pw.FontWeight.bold,
                        color: headlineColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      [
                            'Localisation',
                            'Téléphone',
                            'E-mail',
                            'Site / portfolio',
                          ]
                          .map((key) => draft.fields[key] ?? '')
                          .where((v) => v.isNotEmpty)
                          .join(separator),
                      textAlign: centered
                          ? pw.TextAlign.center
                          : pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: scale.meta,
                        color: headerMutedColor,
                      ),
                    ),
                    for (final link
                        in draft.entries[CvSection.personalInfo] ??
                            <Map<String, String>>[])
                      pw.Text(
                        link['URL'] ?? '',
                        style: pw.TextStyle(
                          fontSize: scale.meta,
                          color: headerMutedColor,
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
  return document.save();
}
