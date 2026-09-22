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

  /// La photo du CV, hors du document JSON.
  ///
  /// Une colonne à part parce que la sauvegarde automatique réécrit le
  /// document à chaque salve de frappe : une image dans le JSON serait
  /// réécrite avec lui, à chaque fois. Ici, elle n'est écrite que lorsqu'elle
  /// change.
  BlobColumn get photo => blob().nullable()();

  /// L'aperçu de la première page, en PNG, pour la liste d'accueil.
  ///
  /// Un aperçu se calcule en composant le PDF du CV puis en le rasterisant :
  /// beaucoup trop cher pour être refait à chaque affichage de la liste. Il
  /// est donc rangé avec le CV, comme la photo, et recalculé seulement quand
  /// le CV a changé depuis.
  BlobColumn get thumbnail => blob().nullable()();

  /// La valeur de [updatedAt] au moment où [thumbnail] a été rendu.
  ///
  /// C'est ce qui dit si l'aperçu est à jour : égale à [updatedAt], il montre
  /// bien le CV enregistré ; plus ancienne, il montre une version dépassée et
  /// demande à être refait. Nulle lorsqu'aucun aperçu n'a encore été rendu.
  DateTimeColumn get thumbnailUpdatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Dernière révision importée de chaque modèle, indépendante des CV.
class TemplateRecords extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CvRecords, TemplateRecords])
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Les étapes s'enchaînent de version en version : une base en version 1
    // ouverte par la version 4 reçoit aussi le stockage des modèles importés.
    onUpgrade: (m, from, to) async {
      if (from < 4) await m.createTable(templateRecords);
      // 1 → 2 : la photo rejoint le CV. Les lignes déjà enregistrées la
      // reçoivent vide, ce qui décrit bien leur état : la photo vivait alors
      // le temps de la session.
      if (from < 2) await m.addColumn(cvRecords, cvRecords.photo);
      // 2 → 3 : l'aperçu de la liste d'accueil est enregistré avec le CV.
      // Les lignes déjà enregistrées le reçoivent vide ; il sera rendu au
      // premier affichage, puis conservé.
      if (from < 3) {
        await m.addColumn(cvRecords, cvRecords.thumbnail);
        await m.addColumn(cvRecords, cvRecords.thumbnailUpdatedAt);
      }
    },
  );
}
