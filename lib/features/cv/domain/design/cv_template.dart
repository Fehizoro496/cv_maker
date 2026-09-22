import 'package:json_annotation/json_annotation.dart';

import 'cv_design.dart';
import 'cv_design_spec.dart';

part 'cv_template.g.dart';

/// Un modèle de CV proposé au catalogue : une identité et un rendu.
///
/// Cette description est volontairement plate et sans comportement : elle est
/// ce qu'un modèle a besoin d'être pour que le catalogue l'affiche et que le
/// générateur le rende. Les modèles intégrés viennent aujourd'hui de l'enum
/// [CvDesign], mais rien ici n'en dépend : un modèle lu dans un fichier ou
/// dans la base se décrit avec le même type, pourvu qu'il porte un [id]
/// stable — c'est cet identifiant, et non l'enum, que le CV enregistre.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class CvTemplate {
  factory CvTemplate.fromJson(Map<String, dynamic> json) =>
      _$CvTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$CvTemplateToJson(this);

  const CvTemplate({
    required this.id,
    required this.label,
    required this.description,
    required this.spec,
    this.revision = 1,
  });

  /// Le modèle décrit par une valeur de l'enum intégré.
  CvTemplate.of(CvDesign design)
    : revision = 1,
      id = design.id,
      label = design.label,
      description = design.description,
      spec = design.spec;

  /// Identifiant stable, enregistré avec le CV et clé des aperçus.
  final String id;

  /// Révision immuable, incrémentée par l’application de création.
  final int revision;

  /// Nom affiché dans le catalogue.
  final String label;

  /// Courte description affichée sous la vignette.
  final String description;

  /// La mise en forme, seule chose que le générateur lit.
  final CvDesignSpec spec;
}
