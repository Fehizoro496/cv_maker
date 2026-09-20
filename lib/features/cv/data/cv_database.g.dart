// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_database.dart';

// ignore_for_file: type=lint
class $CvRecordsTable extends CvRecords
    with TableInfo<$CvRecordsTable, CvRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CvRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatVersionMeta = const VerificationMeta(
    'formatVersion',
  );
  @override
  late final GeneratedColumn<int> formatVersion = GeneratedColumn<int>(
    'format_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentMeta = const VerificationMeta(
    'document',
  );
  @override
  late final GeneratedColumn<String> document = GeneratedColumn<String>(
    'document',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbnail = GeneratedColumn<Uint8List>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUpdatedAtMeta =
      const VerificationMeta('thumbnailUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> thumbnailUpdatedAt =
      GeneratedColumn<DateTime>(
        'thumbnail_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    formatVersion,
    document,
    photo,
    thumbnail,
    thumbnailUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cv_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CvRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('format_version')) {
      context.handle(
        _formatVersionMeta,
        formatVersion.isAcceptableOrUnknown(
          data['format_version']!,
          _formatVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatVersionMeta);
    }
    if (data.containsKey('document')) {
      context.handle(
        _documentMeta,
        document.isAcceptableOrUnknown(data['document']!, _documentMeta),
      );
    } else if (isInserting) {
      context.missing(_documentMeta);
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('thumbnail_updated_at')) {
      context.handle(
        _thumbnailUpdatedAtMeta,
        thumbnailUpdatedAt.isAcceptableOrUnknown(
          data['thumbnail_updated_at']!,
          _thumbnailUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CvRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CvRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      formatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}format_version'],
      )!,
      document: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document'],
      )!,
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}photo'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumbnail'],
      ),
      thumbnailUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}thumbnail_updated_at'],
      ),
    );
  }

  @override
  $CvRecordsTable createAlias(String alias) {
    return $CvRecordsTable(attachedDatabase, alias);
  }
}

class CvRecord extends DataClass implements Insertable<CvRecord> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Version du format JSON de [document], distincte de celle du schéma SQL :
  /// le document peut évoluer sans que la table change.
  final int formatVersion;
  final String document;

  /// La photo du CV, hors du document JSON.
  ///
  /// Une colonne à part parce que la sauvegarde automatique réécrit le
  /// document à chaque salve de frappe : une image dans le JSON serait
  /// réécrite avec lui, à chaque fois. Ici, elle n'est écrite que lorsqu'elle
  /// change.
  final Uint8List? photo;

  /// L'aperçu de la première page, en PNG, pour la liste d'accueil.
  ///
  /// Un aperçu se calcule en composant le PDF du CV puis en le rasterisant :
  /// beaucoup trop cher pour être refait à chaque affichage de la liste. Il
  /// est donc rangé avec le CV, comme la photo, et recalculé seulement quand
  /// le CV a changé depuis.
  final Uint8List? thumbnail;

  /// La valeur de [updatedAt] au moment où [thumbnail] a été rendu.
  ///
  /// C'est ce qui dit si l'aperçu est à jour : égale à [updatedAt], il montre
  /// bien le CV enregistré ; plus ancienne, il montre une version dépassée et
  /// demande à être refait. Nulle lorsqu'aucun aperçu n'a encore été rendu.
  final DateTime? thumbnailUpdatedAt;
  const CvRecord({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.formatVersion,
    required this.document,
    this.photo,
    this.thumbnail,
    this.thumbnailUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['format_version'] = Variable<int>(formatVersion);
    map['document'] = Variable<String>(document);
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail);
    }
    if (!nullToAbsent || thumbnailUpdatedAt != null) {
      map['thumbnail_updated_at'] = Variable<DateTime>(thumbnailUpdatedAt);
    }
    return map;
  }

  CvRecordsCompanion toCompanion(bool nullToAbsent) {
    return CvRecordsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      formatVersion: Value(formatVersion),
      document: Value(document),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      thumbnailUpdatedAt: thumbnailUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUpdatedAt),
    );
  }

  factory CvRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CvRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      formatVersion: serializer.fromJson<int>(json['formatVersion']),
      document: serializer.fromJson<String>(json['document']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      thumbnail: serializer.fromJson<Uint8List?>(json['thumbnail']),
      thumbnailUpdatedAt: serializer.fromJson<DateTime?>(
        json['thumbnailUpdatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'formatVersion': serializer.toJson<int>(formatVersion),
      'document': serializer.toJson<String>(document),
      'photo': serializer.toJson<Uint8List?>(photo),
      'thumbnail': serializer.toJson<Uint8List?>(thumbnail),
      'thumbnailUpdatedAt': serializer.toJson<DateTime?>(thumbnailUpdatedAt),
    };
  }

  CvRecord copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? formatVersion,
    String? document,
    Value<Uint8List?> photo = const Value.absent(),
    Value<Uint8List?> thumbnail = const Value.absent(),
    Value<DateTime?> thumbnailUpdatedAt = const Value.absent(),
  }) => CvRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    formatVersion: formatVersion ?? this.formatVersion,
    document: document ?? this.document,
    photo: photo.present ? photo.value : this.photo,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    thumbnailUpdatedAt: thumbnailUpdatedAt.present
        ? thumbnailUpdatedAt.value
        : this.thumbnailUpdatedAt,
  );
  CvRecord copyWithCompanion(CvRecordsCompanion data) {
    return CvRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      formatVersion: data.formatVersion.present
          ? data.formatVersion.value
          : this.formatVersion,
      document: data.document.present ? data.document.value : this.document,
      photo: data.photo.present ? data.photo.value : this.photo,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      thumbnailUpdatedAt: data.thumbnailUpdatedAt.present
          ? data.thumbnailUpdatedAt.value
          : this.thumbnailUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CvRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('document: $document, ')
          ..write('photo: $photo, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('thumbnailUpdatedAt: $thumbnailUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    updatedAt,
    formatVersion,
    document,
    $driftBlobEquality.hash(photo),
    $driftBlobEquality.hash(thumbnail),
    thumbnailUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CvRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.formatVersion == this.formatVersion &&
          other.document == this.document &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          $driftBlobEquality.equals(other.thumbnail, this.thumbnail) &&
          other.thumbnailUpdatedAt == this.thumbnailUpdatedAt);
}

class CvRecordsCompanion extends UpdateCompanion<CvRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> formatVersion;
  final Value<String> document;
  final Value<Uint8List?> photo;
  final Value<Uint8List?> thumbnail;
  final Value<DateTime?> thumbnailUpdatedAt;
  final Value<int> rowid;
  const CvRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.formatVersion = const Value.absent(),
    this.document = const Value.absent(),
    this.photo = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.thumbnailUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CvRecordsCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int formatVersion,
    required String document,
    this.photo = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.thumbnailUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       formatVersion = Value(formatVersion),
       document = Value(document);
  static Insertable<CvRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? formatVersion,
    Expression<String>? document,
    Expression<Uint8List>? photo,
    Expression<Uint8List>? thumbnail,
    Expression<DateTime>? thumbnailUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (formatVersion != null) 'format_version': formatVersion,
      if (document != null) 'document': document,
      if (photo != null) 'photo': photo,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (thumbnailUpdatedAt != null)
        'thumbnail_updated_at': thumbnailUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CvRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? formatVersion,
    Value<String>? document,
    Value<Uint8List?>? photo,
    Value<Uint8List?>? thumbnail,
    Value<DateTime?>? thumbnailUpdatedAt,
    Value<int>? rowid,
  }) {
    return CvRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      formatVersion: formatVersion ?? this.formatVersion,
      document: document ?? this.document,
      photo: photo ?? this.photo,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailUpdatedAt: thumbnailUpdatedAt ?? this.thumbnailUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (formatVersion.present) {
      map['format_version'] = Variable<int>(formatVersion.value);
    }
    if (document.present) {
      map['document'] = Variable<String>(document.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail.value);
    }
    if (thumbnailUpdatedAt.present) {
      map['thumbnail_updated_at'] = Variable<DateTime>(
        thumbnailUpdatedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CvRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('document: $document, ')
          ..write('photo: $photo, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('thumbnailUpdatedAt: $thumbnailUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CvDatabase extends GeneratedDatabase {
  _$CvDatabase(QueryExecutor e) : super(e);
  $CvDatabaseManager get managers => $CvDatabaseManager(this);
  late final $CvRecordsTable cvRecords = $CvRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cvRecords];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CvRecordsTableCreateCompanionBuilder =
    CvRecordsCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      required int formatVersion,
      required String document,
      Value<Uint8List?> photo,
      Value<Uint8List?> thumbnail,
      Value<DateTime?> thumbnailUpdatedAt,
      Value<int> rowid,
    });
typedef $$CvRecordsTableUpdateCompanionBuilder =
    CvRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> formatVersion,
      Value<String> document,
      Value<Uint8List?> photo,
      Value<Uint8List?> thumbnail,
      Value<DateTime?> thumbnailUpdatedAt,
      Value<int> rowid,
    });

class $$CvRecordsTableFilterComposer
    extends Composer<_$CvDatabase, $CvRecordsTable> {
  $$CvRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get thumbnailUpdatedAt => $composableBuilder(
    column: $table.thumbnailUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CvRecordsTableOrderingComposer
    extends Composer<_$CvDatabase, $CvRecordsTable> {
  $$CvRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get document => $composableBuilder(
    column: $table.document,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get thumbnailUpdatedAt => $composableBuilder(
    column: $table.thumbnailUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CvRecordsTableAnnotationComposer
    extends Composer<_$CvDatabase, $CvRecordsTable> {
  $$CvRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get document =>
      $composableBuilder(column: $table.document, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<DateTime> get thumbnailUpdatedAt => $composableBuilder(
    column: $table.thumbnailUpdatedAt,
    builder: (column) => column,
  );
}

class $$CvRecordsTableTableManager
    extends
        RootTableManager<
          _$CvDatabase,
          $CvRecordsTable,
          CvRecord,
          $$CvRecordsTableFilterComposer,
          $$CvRecordsTableOrderingComposer,
          $$CvRecordsTableAnnotationComposer,
          $$CvRecordsTableCreateCompanionBuilder,
          $$CvRecordsTableUpdateCompanionBuilder,
          (CvRecord, BaseReferences<_$CvDatabase, $CvRecordsTable, CvRecord>),
          CvRecord,
          PrefetchHooks Function()
        > {
  $$CvRecordsTableTableManager(_$CvDatabase db, $CvRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CvRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CvRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CvRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> formatVersion = const Value.absent(),
                Value<String> document = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<Uint8List?> thumbnail = const Value.absent(),
                Value<DateTime?> thumbnailUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CvRecordsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                formatVersion: formatVersion,
                document: document,
                photo: photo,
                thumbnail: thumbnail,
                thumbnailUpdatedAt: thumbnailUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int formatVersion,
                required String document,
                Value<Uint8List?> photo = const Value.absent(),
                Value<Uint8List?> thumbnail = const Value.absent(),
                Value<DateTime?> thumbnailUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CvRecordsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                formatVersion: formatVersion,
                document: document,
                photo: photo,
                thumbnail: thumbnail,
                thumbnailUpdatedAt: thumbnailUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CvRecordsTable, CvRecord>(table),
                  BaseReferences<_$CvDatabase, $CvRecordsTable, CvRecord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CvRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CvDatabase,
      $CvRecordsTable,
      CvRecord,
      $$CvRecordsTableFilterComposer,
      $$CvRecordsTableOrderingComposer,
      $$CvRecordsTableAnnotationComposer,
      $$CvRecordsTableCreateCompanionBuilder,
      $$CvRecordsTableUpdateCompanionBuilder,
      (CvRecord, BaseReferences<_$CvDatabase, $CvRecordsTable, CvRecord>),
      CvRecord,
      PrefetchHooks Function()
    >;

class $CvDatabaseManager {
  final _$CvDatabase _db;
  $CvDatabaseManager(this._db);
  $$CvRecordsTableTableManager get cvRecords =>
      $$CvRecordsTableTableManager(_db, _db.cvRecords);
}
