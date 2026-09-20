import 'package:freezed_annotation/freezed_annotation.dart';

import '../dates/cv_date_range.dart';
import 'cv_entry.dart';

part 'cv_education.freezed.dart';
part 'cv_education.g.dart';

/// Une formation : diplôme, établissement et période.
@freezed
abstract class CvEducation with _$CvEducation implements CvEntry {
  const factory CvEducation({
    required String id,
    @Default('') String degree,
    @Default('') String school,
    @Default('') String location,
    @Default(CvDateRange()) CvDateRange period,
    @Default('') String description,
  }) = _CvEducation;

  factory CvEducation.fromJson(Map<String, dynamic> json) =>
      _$CvEducationFromJson(json);
}
