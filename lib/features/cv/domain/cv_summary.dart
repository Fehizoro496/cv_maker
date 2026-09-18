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
}
