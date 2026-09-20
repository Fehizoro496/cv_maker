/// Désigne une section du CV, standard ou personnalisée.
///
/// La navigation, le formulaire et l'historique manipulent les deux sortes de
/// sections de la même façon ; seul le rendu les distingue. Le type est scellé :
/// un `switch` sur une référence couvre donc tous les cas.
sealed class CvSectionRef {
  const CvSectionRef();
}

/// Sections éditables d'un CV, dans leur ordre de navigation par défaut.
enum CvSection implements CvSectionRef {
  personalInfo(isOptional: false),
  profile(isOptional: false),
  experiences(isOptional: false),
  education(isOptional: false),
  skills(isOptional: false),
  languages(isOptional: false),
  certifications(isOptional: true),
  projects(isOptional: true),
  interests(isOptional: true),
  references(isOptional: true);

  const CvSection({required this.isOptional});

  /// Une section facultative peut être masquée dans le CV.
  final bool isOptional;
}

/// Une section créée par l'utilisateur, désignée par son identifiant.
final class CvCustomSectionRef extends CvSectionRef {
  const CvCustomSectionRef(this.id);

  final String id;

  @override
  bool operator ==(Object other) =>
      other is CvCustomSectionRef && other.id == id;

  @override
  int get hashCode => Object.hash(CvCustomSectionRef, id);

  @override
  String toString() => 'CvCustomSectionRef($id)';
}
