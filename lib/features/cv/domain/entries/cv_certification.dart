import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_entry.dart';
import '../dates/cv_month_year.dart';

part 'cv_certification.freezed.dart';
part 'cv_certification.g.dart';

/// Une certification et l'organisme qui l'a délivrée.
@freezed
abstract class CvCertification with _$CvCertification implements CvEntry {
  const factory CvCertification({
    required String id,
    @Default('') String name,
    @Default('') String issuer,
    CvMonthYear? date,
    @Default('') String description,
  }) = _CvCertification;

  factory CvCertification.fromJson(Map<String, dynamic> json) =>
      _$CvCertificationFromJson(json);
}
