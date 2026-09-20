import 'dart:typed_data';

import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/document/cv_document.dart';
import 'package:cv_maker/features/cv/domain/document/cv_summary.dart';

/// Un stockage en mémoire, pour les tests d'interface.
///
/// Il suit le contrat de [CvRepository], écriture périmée ignorée comprise,
/// et peut simuler des échecs d'écriture avec [failWrites].
class MemoryCvRepository implements CvRepository {
  MemoryCvRepository([Iterable<CvDocument> documents = const []]) {
    for (final document in documents) {
      this.documents[document.id] = document;
    }
  }

  final documents = <String, CvDocument>{};

  /// Les photos enregistrées, par identifiant de CV.
  final photos = <String, Uint8List>{};

  /// Les documents reçus par [save], dans l'ordre, y compris ceux ignorés.
  final saves = <CvDocument>[];

  /// Fait échouer les écritures tant qu'il vaut `true`.
  bool failWrites = false;

  /// Identifiants dont la lecture échoue, comme un JSON corrompu.
  final unreadable = <String>{};

  /// Fait échouer [list], comme une base verrouillée ou endommagée.
  bool failList = false;

  /// Durée simulée d'une écriture, pour agir pendant qu'elle a lieu.
  Duration writeDelay = Duration.zero;

  @override
  Future<List<CvSummary>> list() async {
    if (failList) throw StateError('base illisible');
    return documents.values.map(CvSummary.of).toList()..sortByRecency();
  }

  @override
  Future<CvDocument?> read(String id) async {
    if (unreadable.contains(id)) throw const FormatException('illisible');
    return documents[id];
  }

  @override
  Future<void> save(CvDocument document) async {
    saves.add(document);
    if (writeDelay > Duration.zero) await Future<void>.delayed(writeDelay);
    if (failWrites) throw StateError('écriture refusée');
    final stored = documents[document.id];
    if (stored != null && stored.updatedAt.isAfter(document.updatedAt)) return;
    documents[document.id] = document;
  }

  @override
  Future<void> delete(String id) async {
    if (failWrites) throw StateError('écriture refusée');
    documents.remove(id);
    photos.remove(id);
  }

  @override
  Future<Uint8List?> readPhoto(String id) async {
    if (unreadable.contains(id)) throw const FormatException('illisible');
    return photos[id];
  }

  @override
  Future<void> savePhoto(String id, Uint8List? photo) async {
    if (writeDelay > Duration.zero) await Future<void>.delayed(writeDelay);
    if (failWrites) throw StateError('écriture refusée');
    // Comme en base : une photo n'existe pas sans son CV.
    if (!documents.containsKey(id)) return;
    if (photo == null) {
      photos.remove(id);
    } else {
      photos[id] = photo;
    }
  }
}
