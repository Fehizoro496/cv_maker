import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_document.dart';

part 'cv_session.freezed.dart';

/// État complet de l'édition d'un CV : ce qui est enregistré et ce qui ne
/// l'est pas.
///
/// La photo n'est pas persistée pour le MVP ; elle n'appartient donc pas à
/// [CvDocument], qui est sérialisé tel quel. Les réunir dans une seule valeur
/// immuable permet à l'historique d'annulation de n'empiler qu'un objet et de
/// restaurer le document et la photo ensemble, sans risque de les désynchroniser.
///
/// [CvSession] n'est volontairement pas sérialisable : seul [document] est
/// enregistré.
@freezed
abstract class CvSession with _$CvSession {
  const factory CvSession({
    required CvDocument document,

    /// Photo choisie pendant la session, absente après un redémarrage.
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
