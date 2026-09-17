import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_entry.dart';

part 'cv_note.freezed.dart';
part 'cv_note.g.dart';

/// Entrée libre en deux parties : un intitulé et un détail facultatif.
///
/// Sert aux centres d'intérêt et aux références ou informations
/// complémentaires, qui partagent la même forme.
@freezed
abstract class CvNote with _$CvNote implements CvEntry {
  const factory CvNote({
    required String id,
    @Default('') String label,
    @Default('') String description,
  }) = _CvNote;

  factory CvNote.fromJson(Map<String, dynamic> json) => _$CvNoteFromJson(json);
}
