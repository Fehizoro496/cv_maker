import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_entry.dart';

part 'cv_personal_info.freezed.dart';
part 'cv_personal_info.g.dart';

/// Lien vers un profil ou un site : LinkedIn, GitHub, portfolio…
@freezed
abstract class CvLink with _$CvLink implements CvEntry {
  const factory CvLink({
    required String id,
    @Default('') String label,
    @Default('') String url,
  }) = _CvLink;

  factory CvLink.fromJson(Map<String, dynamic> json) => _$CvLinkFromJson(json);
}

/// En-tête du CV : identité et moyens de contact.
///
/// La photo n'est pas ici : elle n'est pas persistée et vit dans l'état de
/// session, voir `CvSession`.
@freezed
abstract class CvPersonalInfo with _$CvPersonalInfo {
  const factory CvPersonalInfo({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String headline,
    @Default('') String location,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String website,
    @Default(<CvLink>[]) List<CvLink> links,
  }) = _CvPersonalInfo;

  const CvPersonalInfo._();

  factory CvPersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$CvPersonalInfoFromJson(json);

  /// Prénom et nom, sans espace superflu si l'un des deux manque.
  String get fullName =>
      [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
}
