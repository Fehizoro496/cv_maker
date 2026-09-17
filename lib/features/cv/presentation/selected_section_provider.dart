import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cv_section.dart';

final selectedSectionProvider =
    NotifierProvider<SelectedSectionNotifier, CvSection>(
      SelectedSectionNotifier.new,
    );

class SelectedSectionNotifier extends Notifier<CvSection> {
  @override
  CvSection build() => CvSection.personalInfo;

  void select(CvSection section) => state = section;
}
