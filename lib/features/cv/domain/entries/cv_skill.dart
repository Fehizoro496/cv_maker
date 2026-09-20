import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_entry.dart';

part 'cv_skill.freezed.dart';
part 'cv_skill.g.dart';

/// Une compétence, éventuellement rangée dans une catégorie et graduée.
@freezed
abstract class CvSkill with _$CvSkill implements CvEntry {
  const factory CvSkill({
    required String id,
    @Default('') String name,
    @Default('') String category,
    @Default('') String level,
  }) = _CvSkill;

  factory CvSkill.fromJson(Map<String, dynamic> json) =>
      _$CvSkillFromJson(json);
}
