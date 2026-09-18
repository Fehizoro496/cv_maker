import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'cv_database.g.dart';

/// Les CV enregistrés : une ligne par CV, son contenu en JSON.
///
/// Le document complet est stocké tel que le produit `CvDocument.toJson` ;
/// les autres colonnes en dupliquent les métadonnées pour lister les CV sans
/// décoder chaque document.
@DataClassName('CvRecord')
class CvRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Version du format JSON de [document], distincte de celle du schéma SQL :
  /// le document peut évoluer sans que la table change.
  IntColumn get formatVersion => integer()();
  TextColumn get document => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CvRecords])
class CvDatabase extends _$CvDatabase {
  CvDatabase(super.executor);

  /// La base de l'application, dans son dossier de données.
  ///
  /// Le fichier est ouvert à la première requête, et non à l'appel.
  factory CvDatabase.open() => CvDatabase(
    driftDatabase(
      name: 'cv_maker',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  /// Version du schéma SQL. Toute modification de table l'incrémente et
  /// ajoute l'étape correspondante dans [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Les étapes s'enchaîneront de version en version : une base en
    // version 1 ouverte par la version 3 passera par 1 → 2 puis 2 → 3.
    // Aucune n'existe encore.
    onUpgrade: (m, from, to) async {},
  );
}
