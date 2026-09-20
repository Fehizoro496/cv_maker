import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_month_year.dart';

part 'cv_date_range.freezed.dart';
part 'cv_date_range.g.dart';

/// Période d'une expérience, d'une formation ou d'un projet.
///
/// Les deux bornes sont facultatives : un CV mentionne souvent une année de
/// début sans date de fin précise.
@freezed
abstract class CvDateRange with _$CvDateRange {
  const factory CvDateRange({
    CvMonthYear? start,
    CvMonthYear? end,
    @Default(false) bool isCurrent,
  }) = _CvDateRange;

  const CvDateRange._();

  factory CvDateRange.fromJson(Map<String, dynamic> json) =>
      _$CvDateRangeFromJson(json);

  /// Une période en cours n'a pas de date de fin, quelle que soit la valeur
  /// saisie auparavant : c'est [isCurrent] qui fait foi.
  CvMonthYear? get effectiveEnd => isCurrent ? null : end;

  bool get isEmpty => start == null && end == null && !isCurrent;
}
