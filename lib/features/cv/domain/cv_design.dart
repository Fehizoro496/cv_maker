/// Built-in layouts rendered locally with the bundled fonts.
enum CvDesign {
  professional('Professionnel'),
  modern('Moderne'),
  minimal('Minimaliste');

  const CvDesign(this.label);
  final String label;

  /// Identifiant stable enregistré avec le CV, indépendant du libellé affiché.
  String get id => name;

  /// Le modèle d'identifiant [id], ou le modèle professionnel par défaut.
  ///
  /// Un CV enregistré avec un modèle qui n'existe plus reste ainsi lisible.
  static CvDesign fromId(String id) => values.firstWhere(
    (design) => design.id == id,
    orElse: () => professional,
  );
}
