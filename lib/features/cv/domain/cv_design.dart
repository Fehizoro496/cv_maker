/// Modèles de CV intégrés, rendus localement avec les polices livrées.
///
/// Le libellé et la description sont affichés dans le catalogue ; la mise en
/// forme, elle, est décrite par `CvDesignSpec`.
///
/// Les trois modèles à deux zones du catalogue — bandeau latéral, latéral clair
/// et contraste — demandent le moteur de zones du jalon JZ et n'apparaissent
/// donc pas encore ici.
enum CvDesign {
  classic('Classique', 'Une colonne, filet d’accent.'),
  plain('Sobre', 'Noir et blanc, sans accent.'),
  banner('En-tête coloré', 'Bandeau pleine largeur.'),
  compact('Compact', 'Interlignes serrés, plus de contenu.'),
  academic('Académique', 'En-tête centré, formations en premier.');

  const CvDesign(this.label, this.description);

  /// Nom affiché dans le catalogue et la navigation.
  final String label;

  /// Courte description affichée sous la vignette du catalogue.
  final String description;

  /// Identifiant stable enregistré avec le CV, indépendant du libellé affiché.
  String get id => name;

  /// Le modèle par défaut, qui sert aussi de repli.
  static const fallback = classic;

  /// Le modèle d'identifiant [id], ou le modèle classique par défaut.
  ///
  /// Un CV enregistré avec un modèle qui n'existe plus reste ainsi lisible.
  static CvDesign fromId(String id) =>
      values.firstWhere((design) => design.id == id, orElse: () => fallback);
}

/// Couleurs d'accent proposées par le catalogue.
///
/// La palette est fermée : l'utilisateur choisit parmi ces cinq valeurs, et non
/// une couleur libre. L'identifiant enregistré est le nom de la valeur, pas le
/// code couleur, afin que la palette puisse être retouchée sans migrer les CV.
enum CvAccent {
  blue('Bleu', 0xFF2F5D8C),
  green('Vert', 0xFF1E5233),
  brown('Brun', 0xFF6B4E2E),
  burgundy('Bordeaux', 0xFF7A2F4A),
  graphite('Graphite', 0xFF3E4046);

  const CvAccent(this.label, this.color);

  /// Nom affiché dans l'infobulle de la pastille.
  final String label;

  /// Couleur ARGB appliquée à la description du modèle.
  final int color;

  String get id => name;

  static const fallback = blue;

  static CvAccent fromId(String id) =>
      values.firstWhere((accent) => accent.id == id, orElse: () => fallback);
}
