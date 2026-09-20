import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_document.dart';

part 'cv_session.freezed.dart';

/// État complet de l'édition d'un CV : son contenu et sa photo.
///
/// La photo est enregistrée, mais dans sa propre colonne, et non dans le JSON
/// du document : la sauvegarde automatique réécrit le document à chaque salve
/// de frappe, et y glisser une image la réécrirait avec lui. Elle reste donc
/// hors de [CvDocument], qui est sérialisé tel quel.
///
/// Les réunir dans une seule valeur immuable permet à l'historique
/// d'annulation de n'empiler qu'un objet et de restaurer le document et la
/// photo ensemble, sans risque de les désynchroniser.
@freezed
abstract class CvSession with _$CvSession {
  const factory CvSession({
    required CvDocument document,

    /// Photo du CV, retrouvée à la réouverture.
    ///
    /// L'égalité de [CvSession] compare les photos par référence : une même
    /// image rechargée depuis le disque produit une session différente. C'est
    /// suffisant pour l'historique, qui empile les états tels qu'ils ont été
    /// produits.
    Uint8List? photo,
  }) = _CvSession;

  const CvSession._();

  bool get hasPhoto => photo != null;

  CvSession withoutPhoto() => CvSession(document: document);
}
