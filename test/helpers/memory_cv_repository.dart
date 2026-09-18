import 'package:cv_maker/features/cv/data/cv_repository.dart';
import 'package:cv_maker/features/cv/domain/cv_document.dart';
import 'package:cv_maker/features/cv/domain/cv_summary.dart';

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

  /// Les documents reçus par [save], dans l'ordre, y compris ceux ignorés.
  final saves = <CvDocument>[];

  /// Fait échouer les écritures tant qu'il vaut `true`.
  bool failWrites = false;

  /// Identifiants dont la lecture échoue, comme un JSON corrompu.
  final unreadable = <String>{};

  /// Durée simulée d'une écriture, pour agir pendant qu'elle a lieu.
  Duration writeDelay = Duration.zero;

  @override
  Future<List<CvSummary>> list() async =>
      documents.values.map(CvSummary.of).toList()..sortByRecency();

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
  }
}
