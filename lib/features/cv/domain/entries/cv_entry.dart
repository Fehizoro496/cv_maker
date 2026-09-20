/// Élément répétable d'un CV, identifié de façon stable.
///
/// L'ordre d'affichage est celui de la liste qui contient l'élément : il n'est
/// pas stocké dans l'élément lui-même, ce qui évite d'avoir à renuméroter la
/// liste entière à chaque réorganisation.
abstract interface class CvEntry {
  String get id;
}

/// Opérations pures sur une liste d'éléments répétables.
///
/// Chaque opération renvoie une nouvelle liste : la liste d'origine n'est
/// jamais modifiée, ce qui permet de conserver les états précédents dans
/// l'historique.
extension CvEntryList<T extends CvEntry> on List<T> {
  /// Ajoute [entry] à la fin.
  List<T> added(T entry) => [...this, entry];

  /// Remplace l'élément portant l'identifiant de [entry].
  ///
  /// Sans correspondance, la liste est renvoyée inchangée.
  List<T> updated(T entry) => [
    for (final current in this) current.id == entry.id ? entry : current,
  ];

  /// Retire l'élément d'identifiant [id], s'il existe.
  List<T> removed(String id) => [
    for (final current in this)
      if (current.id != id) current,
  ];

  /// Déplace l'élément de [oldIndex] vers [newIndex].
  ///
  /// Les index hors limites laissent la liste inchangée.
  List<T> reordered(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= length ||
        newIndex < 0 ||
        newIndex >= length ||
        oldIndex == newIndex) {
      return [...this];
    }
    final moved = [...this];
    moved.insert(newIndex, moved.removeAt(oldIndex));
    return moved;
  }

  /// L'élément d'identifiant [id], ou `null`.
  T? byId(String id) {
    for (final current in this) {
      if (current.id == id) return current;
    }
    return null;
  }
}
