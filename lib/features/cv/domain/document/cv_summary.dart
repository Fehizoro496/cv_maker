import 'package:flutter/foundation.dart';

import 'cv_document.dart';

/// Ce qu'il faut savoir d'un CV enregistré pour le lister, sans le charger.
@immutable
class CvSummary {
  const CvSummary({
    required this.id,
    required this.name,
    required this.updatedAt,
  });

  factory CvSummary.of(CvDocument document) => CvSummary(
    id: document.id,
    name: document.name,
    updatedAt: document.updatedAt,
  );

  final String id;
  final String name;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      other is CvSummary &&
      other.id == id &&
      other.name == name &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, name, updatedAt);

  @override
  String toString() => 'CvSummary($id, $name, $updatedAt)';
}

/// Opérations pures sur une liste de résumés, triée du plus récemment
/// modifié au plus ancien.
extension CvSummaryList on List<CvSummary> {
  /// La liste où [summary] remplace le résumé de même identifiant, ou
  /// s'ajoute, puis retriée.
  List<CvSummary> upserted(CvSummary summary) => [
    for (final current in this)
      if (current.id != summary.id) current,
    summary,
  ]..sortByRecency();

  List<CvSummary> without(String id) => [
    for (final current in this)
      if (current.id != id) current,
  ];

  /// Trie en place, le plus récemment modifié en premier. À date égale,
  /// l'identifiant départage pour que l'ordre reste stable.
  void sortByRecency() => sort((a, b) {
    final byDate = b.updatedAt.compareTo(a.updatedAt);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  });

  /// Les résumés dont le nom contient chacun des mots de [query], sans tenir
  /// compte de la casse ni des accents. Une recherche vide garde tout.
  List<CvSummary> matching(String query) {
    final words = foldForSearch(
      query,
    ).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return [...this];
    return [
      for (final summary in this)
        if (words.every(foldForSearch(summary.name).contains)) summary,
    ];
  }

  /// Une copie triée par nom, dans l'ordre alphabétique français : casse et
  /// accents ignorés, puis la date départage.
  List<CvSummary> sortedByName() => [...this]
    ..sort((a, b) {
      final byName = foldForSearch(a.name).compareTo(foldForSearch(b.name));
      return byName != 0 ? byName : b.updatedAt.compareTo(a.updatedAt);
    });
}

// Chaque lettre accentuée et sa lettre de base, à la même position.
const _accented = 'àâäáãåçéèêëîïíìñôöóòõùûüúÿ';
const _unaccented = 'aaaaaaceeeeiiiinooooouuuuy';

/// [text] en minuscules et sans accents : « Développeuse » et
/// « developpeuse » se retrouvent l'un l'autre.
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    final index = _accented.indexOf(char);
    buffer.write(switch (char) {
      'æ' => 'ae',
      'œ' => 'oe',
      _ when index >= 0 => _unaccented[index],
      _ => char,
    });
  }
  return buffer.toString();
}
