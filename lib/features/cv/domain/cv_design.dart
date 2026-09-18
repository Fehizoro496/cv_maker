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

/// Couleurs d'accent proposées en raccourci par le sélecteur de couleur.
///
/// Ce ne sont que des suggestions : l'utilisateur reste libre de choisir
/// n'importe quelle couleur. Le CV enregistre donc la couleur elle-même, et
/// non le nom d'une de ces valeurs.
enum CvAccent {
  blue('Bleu', 0xFF2F5D8C),
  green('Vert', 0xFF1E5233),
  brown('Brun', 0xFF6B4E2E),
  burgundy('Bordeaux', 0xFF7A2F4A),
  graphite('Graphite', 0xFF3E4046);

  const CvAccent(this.label, this.color);

  /// Nom affiché dans l'infobulle de la pastille.
  final String label;

  /// Couleur ARGB suggérée.
  final int color;

  /// La couleur d'accent d'un CV qui n'en a pas choisi d'autre.
  static const defaultColor = 0xFF2F5D8C;

  /// Les couleurs suggérées, dans l'ordre d'affichage.
  static List<int> get palette => values.map((accent) => accent.color).toList();
}
