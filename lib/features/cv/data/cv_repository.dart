import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/document/cv_document.dart';
import '../domain/document/cv_summary.dart';
import 'cv_database.dart';

/// Le stockage local des CV.
///
/// La photo a ses propres opérations : [save] ne l'écrit ni ne l'efface
/// jamais. Une sauvegarde de document, déclenchée à chaque salve de frappe,
/// ne réécrit donc pas l'image, et ne peut pas la perdre.
abstract interface class CvRepository {
  /// Les CV enregistrés, du plus récemment modifié au plus ancien.
  Future<List<CvSummary>> list();

  /// Le CV d'identifiant [id], ou `null` s'il n'existe pas.
  Future<CvDocument?> read(String id);

  /// Crée le CV ou remplace sa version enregistrée.
  ///
  /// Une version plus ancienne que celle déjà enregistrée, d'après
  /// [CvDocument.updatedAt], est ignorée : une écriture retardée ne peut pas
  /// effacer une modification plus récente.
  Future<void> save(CvDocument document);

  /// Supprime le CV d'identifiant [id] ; sans effet s'il n'existe pas.
  Future<void> delete(String id);

  /// La photo du CV [id], ou `null` s'il n'en a pas.
  Future<Uint8List?> readPhoto(String id);

  /// Remplace la photo du CV [id] ; [photo] à `null` la retire.
  ///
  /// Sans effet si le CV n'existe pas : une photo n'existe pas seule.
  Future<void> savePhoto(String id, Uint8List? photo);

  /// L'aperçu enregistré du CV [id], à jour ou non.
  ///
  /// Retourne `null` si le CV n'existe pas ou n'a pas encore d'aperçu. La
  /// date est celle du CV au moment du rendu : l'appelant la compare à
  /// [CvSummary.updatedAt] pour savoir si l'aperçu est encore valable.
  Future<CvThumbnail?> readThumbnail(String id);

  /// Enregistre l'aperçu du CV [id], rendu à partir de sa version [updatedAt].
  ///
  /// Sans effet si le CV n'existe pas, ou s'il a été modifié depuis : un
  /// rendu lent ne peut donc pas remplacer un aperçu plus récent.
  Future<void> saveThumbnail(String id, Uint8List png, DateTime updatedAt);
}

/// Un aperçu enregistré et la version du CV qu'il montre.
class CvThumbnail {
  const CvThumbnail(this.png, this.updatedAt);

  final Uint8List png;

  /// La valeur de `CvDocument.updatedAt` au moment du rendu.
  final DateTime updatedAt;
}

/// Le stockage SQLite, via drift.
class DriftCvRepository implements CvRepository {
  DriftCvRepository(this._db);

  /// Version du format JSON produit par [CvDocument.toJson].
  ///
  /// À incrémenter lorsqu'un changement du document ne peut plus être relu
  /// par `CvDocument.fromJson` tel quel, en ajoutant l'étape correspondante
  /// dans [_migrate]. Un champ ajouté avec une valeur par défaut n'en demande
  /// pas : la clé absente prend cette valeur.
  static const formatVersion = 1;

  final CvDatabase _db;

  @override
  Future<List<CvSummary>> list() async {
    final records = _db.cvRecords;
    final query = _db.selectOnly(records)
      ..addColumns([records.id, records.name, records.updatedAt])
      ..orderBy([
        OrderingTerm.desc(records.updatedAt),
        OrderingTerm.asc(records.id),
      ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        CvSummary(
          id: row.read(records.id)!,
          name: row.read(records.name)!,
          updatedAt: row.read(records.updatedAt)!,
        ),
    ];
  }

  @override
  Future<CvDocument?> read(String id) async {
    final record = await (_db.select(
      _db.cvRecords,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (record == null) return null;
    final json = jsonDecode(record.document) as Map<String, dynamic>;
    return CvDocument.fromJson(_migrate(json, from: record.formatVersion));
  }

  @override
  Future<void> save(CvDocument document) async {
    final companion = CvRecordsCompanion.insert(
      id: document.id,
      name: document.name,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
      formatVersion: formatVersion,
      document: jsonEncode(document.toJson()),
    );
    await _db
        .into(_db.cvRecords)
        .insert(
          companion,
          onConflict: DoUpdate(
            (_) => companion,
            where: (old) =>
                old.updatedAt.isSmallerOrEqualValue(document.updatedAt),
          ),
        );
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.cvRecords)..where((r) => r.id.equals(id))).go();

  @override
  Future<Uint8List?> readPhoto(String id) async {
    final records = _db.cvRecords;
    final query = _db.selectOnly(records)
      ..addColumns([records.photo])
      ..where(records.id.equals(id));
    final row = await query.getSingleOrNull();
    return row?.read(records.photo);
  }

  @override
  Future<void> savePhoto(String id, Uint8List? photo) async {
    await (_db.update(_db.cvRecords)..where((r) => r.id.equals(id))).write(
      CvRecordsCompanion(photo: Value(photo)),
    );
  }

  @override
  Future<CvThumbnail?> readThumbnail(String id) async {
    final records = _db.cvRecords;
    final query = _db.selectOnly(records)
      ..addColumns([records.thumbnail, records.thumbnailUpdatedAt])
      ..where(records.id.equals(id));
    final row = await query.getSingleOrNull();
    final png = row?.read(records.thumbnail);
    final updatedAt = row?.read(records.thumbnailUpdatedAt);
    if (png == null || updatedAt == null) return null;
    return CvThumbnail(png, updatedAt);
  }

  @override
  Future<void> saveThumbnail(
    String id,
    Uint8List png,
    DateTime updatedAt,
  ) async {
    await (_db.update(
      _db.cvRecords,
    )..where((r) => r.id.equals(id) & r.updatedAt.equals(updatedAt))).write(
      CvRecordsCompanion(
        thumbnail: Value(png),
        thumbnailUpdatedAt: Value(updatedAt),
      ),
    );
  }

  /// Amène un document écrit au format [from] au format courant.
  static Map<String, dynamic> _migrate(
    Map<String, dynamic> json, {
    required int from,
  }) {
    if (from > formatVersion) {
      throw FormatException(
        'CV enregistré au format $from, plus récent que celui de '
        'l’application ($formatVersion).',
      );
    }
    // Les étapes s'enchaîneront ici : `if (from < 2) json = _v1ToV2(json);`.
    return json;
  }
}
