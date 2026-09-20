import 'package:freezed_annotation/freezed_annotation.dart';

import '../dates/cv_date_range.dart';
import 'cv_entry.dart';

part 'cv_custom_section.freezed.dart';
part 'cv_custom_section.g.dart';

/// Forme du contenu d'une section personnalisée, figée à sa création.
enum CvCustomSectionType {
  /// Un paragraphe unique, rendu comme le profil professionnel.
  freeText,

  /// Titre, sous-titre, période et description, rendus comme les expériences.
  datedList,

  /// Titre et description courte, rendus comme les certifications.
  simpleList;

  bool get hasItems => this != freeText;
}

/// Un élément d'une section personnalisée de type liste.
///
/// Une liste simple n'utilise que [title] et [description] : les autres champs
/// restent vides. Un seul modèle pour les deux listes évite de dupliquer la
/// sérialisation et les opérations.
@freezed
abstract class CvCustomItem with _$CvCustomItem implements CvEntry {
  const factory CvCustomItem({
    required String id,
    @Default('') String title,
    @Default('') String subtitle,
    @Default(CvDateRange()) CvDateRange period,
    @Default('') String description,
  }) = _CvCustomItem;

  factory CvCustomItem.fromJson(Map<String, dynamic> json) =>
      _$CvCustomItemFromJson(json);
}

/// Une section créée par l'utilisateur : publications, bénévolat, distinctions.
///
/// Son ordre est sa position dans `CvDocument.customSections`, après les
/// sections standard. Selon [type], le contenu est [text] ou [items] ; l'autre
/// reste vide.
@freezed
abstract class CvCustomSection with _$CvCustomSection implements CvEntry {
  const factory CvCustomSection({
    required String id,
    required String name,
    required CvCustomSectionType type,
    @Default(true) bool visible,
    @Default('') String text,
    @Default(<CvCustomItem>[]) List<CvCustomItem> items,
  }) = _CvCustomSection;

  const CvCustomSection._();

  factory CvCustomSection.fromJson(Map<String, dynamic> json) =>
      _$CvCustomSectionFromJson(json);

  /// Longueur maximale du nom d'une section.
  static const maxNameLength = 40;

  /// Une section remplie apparaît dans le CV si elle est visible.
  bool get hasContent =>
      type.hasItems ? items.isNotEmpty : text.trim().isNotEmpty;

  /// Nombre d'éléments perdus si la section est supprimée.
  ///
  /// Un texte libre compte pour un élément dès qu'il n'est pas vide.
  int get itemCount => type.hasItems ? items.length : (hasContent ? 1 : 0);
}
