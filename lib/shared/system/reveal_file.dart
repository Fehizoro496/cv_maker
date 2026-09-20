import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Montre un fichier enregistré dans l'explorateur de fichiers du système.
///
/// Retourne `false` si le dossier n'a pas pu être ouvert.
typedef RevealFile = Future<bool> Function(String path);

/// L'ouverture du dossier d'un fichier exporté.
///
/// Passe par un provider pour que les tests la remplacent : ouvrir une
/// fenêtre de l'explorateur pendant une suite de tests n'aurait aucun sens.
final revealFileProvider = Provider<RevealFile>((ref) => revealFile);

/// Ouvre le dossier contenant [path] dans l'explorateur.
///
/// C'est le dossier qui est ouvert, et non le fichier : demander l'ouverture
/// du PDF lui-même lancerait le lecteur associé, ce que la notification ne
/// promet pas.
Future<bool> revealFile(String path) async {
  final folder = File(path).parent;
  if (!folder.existsSync()) return false;
  return launchUrl(folder.uri);
}
