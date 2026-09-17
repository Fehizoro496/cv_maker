import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_entry.dart';

part 'cv_language.freezed.dart';
part 'cv_language.g.dart';

/// Une langue et son niveau de maîtrise.
///
/// Le niveau est un texte libre : l'utilisateur choisit dans une liste ou
/// saisit sa propre formulation (« C1 », « langue maternelle »…).
@freezed
abstract class CvLanguage with _$CvLanguage implements CvEntry {
  const factory CvLanguage({
    required String id,
    @Default('') String name,
    @Default('') String level,
  }) = _CvLanguage;

  factory CvLanguage.fromJson(Map<String, dynamic> json) =>
      _$CvLanguageFromJson(json);
}
