/// Sections éditables d'un CV, dans leur ordre de navigation par défaut.
enum CvSection {
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
