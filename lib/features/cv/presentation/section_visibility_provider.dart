import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_section.dart';

/// Visibilité des sections facultatives dans le CV.
///
/// Provisoire : cet état rejoindra les préférences de présentation du
/// `CvDocument` au jalon J1.
final sectionVisibilityProvider =
    NotifierProvider<SectionVisibilityNotifier, Map<CvSection, bool>>(
      SectionVisibilityNotifier.new,
    );

class SectionVisibilityNotifier extends Notifier<Map<CvSection, bool>> {
  @override
  Map<CvSection, bool> build() => {
    for (final section in CvSection.values)
      if (section.isOptional)
        section:
            section != CvSection.interests && section != CvSection.references,
  };

  void toggle(CvSection section) {
    if (!section.isOptional) {
      throw ArgumentError.value(section, 'section', 'Section non facultative');
    }
    state = {...state, section: !(state[section] ?? true)};
  }
}
