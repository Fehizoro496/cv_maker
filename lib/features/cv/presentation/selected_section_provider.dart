import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_section.dart';
import 'cv_session_provider.dart';

final selectedSectionProvider =
    NotifierProvider<SelectedSectionNotifier, CvSectionRef>(
      SelectedSectionNotifier.new,
    );

class SelectedSectionNotifier extends Notifier<CvSectionRef> {
  @override
  CvSectionRef build() {
    // Une section personnalisée supprimée, ou dont la création est annulée,
    // ne peut pas rester sélectionnée : le formulaire n'aurait rien à montrer.
    ref.listen(cvSessionProvider.select((session) => session.document), (
      _,
      document,
    ) {
      final selected = state;
      if (selected is CvCustomSectionRef &&
          document.customSectionById(selected.id) == null) {
        state = CvSection.personalInfo;
      }
    });
    return CvSection.personalInfo;
  }

  void select(CvSectionRef section) => state = section;
}
