import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demande où enregistrer un fichier ; `null` si l'utilisateur renonce.
typedef PickSaveLocation =
    Future<String?> Function({required String suggestedName});

/// Le dialogue d'enregistrement du système.
///
/// Passe par un provider pour que les tests désignent un fichier temporaire
/// au lieu d'ouvrir une fenêtre native, que rien ne pourrait refermer.
final saveLocationProvider = Provider<PickSaveLocation>(
  (ref) => pickPdfSaveLocation,
);

/// Écrit [bytes] dans le fichier [path], ou lève si l'écriture échoue.
typedef SaveBytes = Future<void> Function(String path, Uint8List bytes);

/// L'écriture du fichier exporté.
///
/// Séparée du dialogue pour la même raison, et parce qu'une écriture réelle
/// ne se termine pas sous le temps simulé d'un test de widgets.
final saveBytesProvider = Provider<SaveBytes>((ref) => savePdfBytes);

/// Enregistre le PDF [bytes] sous [path].
Future<void> savePdfBytes(String path, Uint8List bytes) =>
    XFile.fromData(bytes, mimeType: 'application/pdf').saveTo(path);

/// Le dialogue « Enregistrer sous », filtré sur les PDF.
Future<String?> pickPdfSaveLocation({required String suggestedName}) async {
  final location = await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: [
      const XTypeGroup(label: 'PDF', extensions: ['pdf']),
    ],
  );
  return location?.path;
}
