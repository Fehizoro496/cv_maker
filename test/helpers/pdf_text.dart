import 'dart:convert';
import 'dart:io';

/// Le texte de chaque page d'un PDF produit par le paquet `pdf`, dans l'ordre
/// où il est émis.
///
/// C'est l'ordre que suit un logiciel de tri des candidatures (ATS) qui lit le
/// PDF de façon linéaire : il ne dépend pas de la position des mots sur la
/// page, mais de leur place dans le flux de contenu de la page.
///
/// Chaque élément de la liste renvoyée est la suite des fragments de texte
/// d'une page, dans l'ordre des pages. Le paquet `pdf` écrit chaque mot dans
/// un opérateur `TJ` distinct ; un fragment est donc en général un mot.
///
/// L'extracteur ne couvre que ce qu'écrit le paquet `pdf` : objets numérotés
/// en clair, flux compressés en `FlateDecode`, polices TrueType désignées par
/// `/F<numéro d'objet>` et décrites par une table `/ToUnicode` en `bfchar`.
/// Ce n'est pas un lecteur PDF général.
List<List<String>> pdfPageTexts(List<int> bytes) {
  final raw = latin1.decode(bytes);
  final objects = <int, String>{};
  for (final match in RegExp(
    r'(\d+) 0 obj(.*?)endobj',
    dotAll: true,
  ).allMatches(raw)) {
    objects[int.parse(match.group(1)!)] = match.group(2)!;
  }

  String dictOf(String object) {
    final at = object.indexOf('stream');
    return at < 0 ? object : object.substring(0, at);
  }

  String streamOf(String object) {
    final start = RegExp(r'stream\r?\n').firstMatch(object);
    if (start == null) return '';
    final end = object.lastIndexOf('endstream');
    var data = object.substring(start.end, end);
    if (data.endsWith('\n')) data = data.substring(0, data.length - 1);
    if (data.endsWith('\r')) data = data.substring(0, data.length - 1);
    final encoded = latin1.encode(data);
    if (!dictOf(object).contains('/FlateDecode')) return data;
    return latin1.decode(ZLibCodec().decode(encoded));
  }

  int? reference(String dict, String key) {
    final match = RegExp('$key\\s+(\\d+) 0 R').firstMatch(dict);
    return match == null ? null : int.parse(match.group(1)!);
  }

  final cmaps = <int, Map<int, String>>{};
  Map<int, String> cmapOfFont(int font) => cmaps.putIfAbsent(font, () {
    final toUnicode = reference(dictOf(objects[font] ?? ''), '/ToUnicode');
    if (toUnicode == null) return const {};
    final cmap = <int, String>{};
    for (final entry in RegExp(
      r'<([0-9A-Fa-f]{4})>\s*<([0-9A-Fa-f]{4})>',
    ).allMatches(streamOf(objects[toUnicode]!))) {
      cmap[int.parse(entry.group(1)!, radix: 16)] = String.fromCharCode(
        int.parse(entry.group(2)!, radix: 16),
      );
    }
    return cmap;
  });

  List<String> textOf(String content) {
    final fragments = <String>[];
    var font = 0;
    for (final token in RegExp(
      r'/F(\d+)\s+[\d.]+\s+Tf|\[<([0-9A-Fa-f]*)>\]\s*TJ',
    ).allMatches(content)) {
      if (token.group(1) != null) {
        font = int.parse(token.group(1)!);
        continue;
      }
      final hex = token.group(2)!;
      final cmap = cmapOfFont(font);
      final text = StringBuffer();
      for (var i = 0; i + 4 <= hex.length; i += 4) {
        text.write(cmap[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '');
      }
      if (text.isNotEmpty) fragments.add(text.toString());
    }
    return fragments;
  }

  final tree = objects.values.firstWhere(
    (object) => RegExp(r'/Type\s*/Pages\b').hasMatch(dictOf(object)),
  );
  final kids = RegExp(r'/Kids\s*\[([^\]]*)\]').firstMatch(dictOf(tree))!;
  return [
    for (final kid in RegExp(r'(\d+) 0 R').allMatches(kids.group(1)!))
      () {
        final page = dictOf(objects[int.parse(kid.group(1)!)]!);
        // Une page vide n'a pas de flux de contenu.
        final contents = RegExp(
          r'/Contents\s*(\[[^\]]*\]|\d+ 0 R)',
        ).firstMatch(page)?.group(1);
        return [
          for (final ref in RegExp(r'(\d+) 0 R').allMatches(contents ?? ''))
            ...textOf(streamOf(objects[int.parse(ref.group(1)!)]!)),
        ];
      }(),
  ];
}

/// Tout le texte d'un PDF, mots séparés par une espace, dans l'ordre émis.
String pdfText(List<int> bytes) =>
    pdfPageTexts(bytes).expand((page) => page).join(' ');
