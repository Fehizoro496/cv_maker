import 'package:freezed_annotation/freezed_annotation.dart';

import '../dates/cv_date_range.dart';
import 'cv_entry.dart';

part 'cv_experience.freezed.dart';
part 'cv_experience.g.dart';

/// Une expérience professionnelle.
@freezed
abstract class CvExperience with _$CvExperience implements CvEntry {
  const factory CvExperience({
    required String id,
    @Default('') String position,
    @Default('') String company,
    @Default('') String location,
    @Default(CvDateRange()) CvDateRange period,
    @Default('') String description,
  }) = _CvExperience;

  factory CvExperience.fromJson(Map<String, dynamic> json) =>
      _$CvExperienceFromJson(json);
}
