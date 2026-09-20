import 'package:freezed_annotation/freezed_annotation.dart';

import '../dates/cv_date_range.dart';
import 'cv_entry.dart';

part 'cv_project.freezed.dart';
part 'cv_project.g.dart';

/// Un projet mis en avant dans le CV.
@freezed
abstract class CvProject with _$CvProject implements CvEntry {
  const factory CvProject({
    required String id,
    @Default('') String name,
    @Default('') String role,
    @Default('') String url,
    @Default(CvDateRange()) CvDateRange period,
    @Default('') String description,
  }) = _CvProject;

  factory CvProject.fromJson(Map<String, dynamic> json) =>
      _$CvProjectFromJson(json);
}
