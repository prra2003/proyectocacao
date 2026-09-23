// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AsociacionesTable extends Asociaciones
    with TableInfo<$AsociacionesTable, Asociacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AsociacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($AsociacionesTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _municipioMeta = const VerificationMeta(
    'municipio',
  );
  @override
  late final GeneratedColumn<String> municipio = GeneratedColumn<String>(
    'municipio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departamentoMeta = const VerificationMeta(
    'departamento',
  );
  @override
  late final GeneratedColumn<String> departamento = GeneratedColumn<String>(
    'departamento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    nombre,
    municipio,
    departamento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asociaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asociacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('municipio')) {
      context.handle(
        _municipioMeta,
        municipio.isAcceptableOrUnknown(data['municipio']!, _municipioMeta),
      );
    } else if (isInserting) {
      context.missing(_municipioMeta);
    }
    if (data.containsKey('departamento')) {
      context.handle(
        _departamentoMeta,
        departamento.isAcceptableOrUnknown(
          data['departamento']!,
          _departamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departamentoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asociacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asociacion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $AsociacionesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      municipio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}municipio'],
      )!,
      departamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departamento'],
      )!,
    );
  }

  @override
  $AsociacionesTable createAlias(String alias) {
    return $AsociacionesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class Asociacion extends DataClass implements Insertable<Asociacion> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String nombre;
  final String municipio;
  final String departamento;
  const Asociacion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.nombre,
    required this.municipio,
    required this.departamento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $AsociacionesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['nombre'] = Variable<String>(nombre);
    map['municipio'] = Variable<String>(municipio);
    map['departamento'] = Variable<String>(departamento);
    return map;
  }

  AsociacionesCompanion toCompanion(bool nullToAbsent) {
    return AsociacionesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      nombre: Value(nombre),
      municipio: Value(municipio),
      departamento: Value(departamento),
    );
  }

  factory Asociacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asociacion(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $AsociacionesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      nombre: serializer.fromJson<String>(json['nombre']),
      municipio: serializer.fromJson<String>(json['municipio']),
      departamento: serializer.fromJson<String>(json['departamento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $AsociacionesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'nombre': serializer.toJson<String>(nombre),
      'municipio': serializer.toJson<String>(municipio),
      'departamento': serializer.toJson<String>(departamento),
    };
  }

  Asociacion copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? nombre,
    String? municipio,
    String? departamento,
  }) => Asociacion(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    nombre: nombre ?? this.nombre,
    municipio: municipio ?? this.municipio,
    departamento: departamento ?? this.departamento,
  );
  Asociacion copyWithCompanion(AsociacionesCompanion data) {
    return Asociacion(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      municipio: data.municipio.present ? data.municipio.value : this.municipio,
      departamento: data.departamento.present
          ? data.departamento.value
          : this.departamento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asociacion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('nombre: $nombre, ')
          ..write('municipio: $municipio, ')
          ..write('departamento: $departamento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    nombre,
    municipio,
    departamento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asociacion &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.nombre == this.nombre &&
          other.municipio == this.municipio &&
          other.departamento == this.departamento);
}

class AsociacionesCompanion extends UpdateCompanion<Asociacion> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> nombre;
  final Value<String> municipio;
  final Value<String> departamento;
  final Value<int> rowid;
  const AsociacionesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.nombre = const Value.absent(),
    this.municipio = const Value.absent(),
    this.departamento = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AsociacionesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String nombre,
    required String municipio,
    required String departamento,
    this.rowid = const Value.absent(),
  }) : nombre = Value(nombre),
       municipio = Value(municipio),
       departamento = Value(departamento);
  static Insertable<Asociacion> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? nombre,
    Expression<String>? municipio,
    Expression<String>? departamento,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (nombre != null) 'nombre': nombre,
      if (municipio != null) 'municipio': municipio,
      if (departamento != null) 'departamento': departamento,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AsociacionesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? nombre,
    Value<String>? municipio,
    Value<String>? departamento,
    Value<int>? rowid,
  }) {
    return AsociacionesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      nombre: nombre ?? this.nombre,
      municipio: municipio ?? this.municipio,
      departamento: departamento ?? this.departamento,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $AsociacionesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (municipio.present) {
      map['municipio'] = Variable<String>(municipio.value);
    }
    if (departamento.present) {
      map['departamento'] = Variable<String>(departamento.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AsociacionesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('nombre: $nombre, ')
          ..write('municipio: $municipio, ')
          ..write('departamento: $departamento, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductoresTable extends Productores
    with TableInfo<$ProductoresTable, Productor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($ProductoresTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreCompletoMeta = const VerificationMeta(
    'nombreCompleto',
  );
  @override
  late final GeneratedColumn<String> nombreCompleto = GeneratedColumn<String>(
    'nombre_completo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _asociacionIdMeta = const VerificationMeta(
    'asociacionId',
  );
  @override
  late final GeneratedColumn<String> asociacionId = GeneratedColumn<String>(
    'asociacion_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asociaciones (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoDocumento?, String>
  tipoDocumento = GeneratedColumn<String>(
    'tipo_documento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<TipoDocumento?>($ProductoresTable.$convertertipoDocumenton);
  static const VerificationMeta _numeroDocumentoMeta = const VerificationMeta(
    'numeroDocumento',
  );
  @override
  late final GeneratedColumn<String> numeroDocumento = GeneratedColumn<String>(
    'numero_documento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    usuarioId,
    nombreCompleto,
    telefono,
    email,
    asociacionId,
    tipoDocumento,
    numeroDocumento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Productor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    }
    if (data.containsKey('nombre_completo')) {
      context.handle(
        _nombreCompletoMeta,
        nombreCompleto.isAcceptableOrUnknown(
          data['nombre_completo']!,
          _nombreCompletoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreCompletoMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('asociacion_id')) {
      context.handle(
        _asociacionIdMeta,
        asociacionId.isAcceptableOrUnknown(
          data['asociacion_id']!,
          _asociacionIdMeta,
        ),
      );
    }
    if (data.containsKey('numero_documento')) {
      context.handle(
        _numeroDocumentoMeta,
        numeroDocumento.isAcceptableOrUnknown(
          data['numero_documento']!,
          _numeroDocumentoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Productor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Productor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $ProductoresTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      ),
      nombreCompleto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_completo'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      asociacionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asociacion_id'],
      ),
      tipoDocumento: $ProductoresTable.$convertertipoDocumenton.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_documento'],
        ),
      ),
      numeroDocumento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_documento'],
      ),
    );
  }

  @override
  $ProductoresTable createAlias(String alias) {
    return $ProductoresTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<TipoDocumento, String, String>
  $convertertipoDocumento = const EnumNameConverter<TipoDocumento>(
    TipoDocumento.values,
  );
  static JsonTypeConverter2<TipoDocumento?, String?, String?>
  $convertertipoDocumenton = JsonTypeConverter2.asNullable(
    $convertertipoDocumento,
  );
}

class Productor extends DataClass implements Insertable<Productor> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;

  /// Dueño del registro: la identidad local de esta instalación (ver [Sesion]).
  /// Es lo que sustituye al viejo "toma el primer productor vivo" y lo que se
  /// traduce al identificador de la cuenta de Google al subir.
  final String? usuarioId;
  final String nombreCompleto;
  final String? telefono;
  final String? email;
  final String? asociacionId;

  /// Documento de identidad. Nullable a nivel de base para que la migración no
  /// rompa filas ya existentes; el formulario es quien lo exige.
  final TipoDocumento? tipoDocumento;
  final String? numeroDocumento;
  const Productor({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    this.usuarioId,
    required this.nombreCompleto,
    this.telefono,
    this.email,
    this.asociacionId,
    this.tipoDocumento,
    this.numeroDocumento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ProductoresTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || usuarioId != null) {
      map['usuario_id'] = Variable<String>(usuarioId);
    }
    map['nombre_completo'] = Variable<String>(nombreCompleto);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || asociacionId != null) {
      map['asociacion_id'] = Variable<String>(asociacionId);
    }
    if (!nullToAbsent || tipoDocumento != null) {
      map['tipo_documento'] = Variable<String>(
        $ProductoresTable.$convertertipoDocumenton.toSql(tipoDocumento),
      );
    }
    if (!nullToAbsent || numeroDocumento != null) {
      map['numero_documento'] = Variable<String>(numeroDocumento);
    }
    return map;
  }

  ProductoresCompanion toCompanion(bool nullToAbsent) {
    return ProductoresCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      usuarioId: usuarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioId),
      nombreCompleto: Value(nombreCompleto),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      asociacionId: asociacionId == null && nullToAbsent
          ? const Value.absent()
          : Value(asociacionId),
      tipoDocumento: tipoDocumento == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoDocumento),
      numeroDocumento: numeroDocumento == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroDocumento),
    );
  }

  factory Productor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Productor(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $ProductoresTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      usuarioId: serializer.fromJson<String?>(json['usuarioId']),
      nombreCompleto: serializer.fromJson<String>(json['nombreCompleto']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      asociacionId: serializer.fromJson<String?>(json['asociacionId']),
      tipoDocumento: $ProductoresTable.$convertertipoDocumenton.fromJson(
        serializer.fromJson<String?>(json['tipoDocumento']),
      ),
      numeroDocumento: serializer.fromJson<String?>(json['numeroDocumento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $ProductoresTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'usuarioId': serializer.toJson<String?>(usuarioId),
      'nombreCompleto': serializer.toJson<String>(nombreCompleto),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'asociacionId': serializer.toJson<String?>(asociacionId),
      'tipoDocumento': serializer.toJson<String?>(
        $ProductoresTable.$convertertipoDocumenton.toJson(tipoDocumento),
      ),
      'numeroDocumento': serializer.toJson<String?>(numeroDocumento),
    };
  }

  Productor copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    Value<String?> usuarioId = const Value.absent(),
    String? nombreCompleto,
    Value<String?> telefono = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> asociacionId = const Value.absent(),
    Value<TipoDocumento?> tipoDocumento = const Value.absent(),
    Value<String?> numeroDocumento = const Value.absent(),
  }) => Productor(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    usuarioId: usuarioId.present ? usuarioId.value : this.usuarioId,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    telefono: telefono.present ? telefono.value : this.telefono,
    email: email.present ? email.value : this.email,
    asociacionId: asociacionId.present ? asociacionId.value : this.asociacionId,
    tipoDocumento: tipoDocumento.present
        ? tipoDocumento.value
        : this.tipoDocumento,
    numeroDocumento: numeroDocumento.present
        ? numeroDocumento.value
        : this.numeroDocumento,
  );
  Productor copyWithCompanion(ProductoresCompanion data) {
    return Productor(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      nombreCompleto: data.nombreCompleto.present
          ? data.nombreCompleto.value
          : this.nombreCompleto,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      asociacionId: data.asociacionId.present
          ? data.asociacionId.value
          : this.asociacionId,
      tipoDocumento: data.tipoDocumento.present
          ? data.tipoDocumento.value
          : this.tipoDocumento,
      numeroDocumento: data.numeroDocumento.present
          ? data.numeroDocumento.value
          : this.numeroDocumento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Productor(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('asociacionId: $asociacionId, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('numeroDocumento: $numeroDocumento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    usuarioId,
    nombreCompleto,
    telefono,
    email,
    asociacionId,
    tipoDocumento,
    numeroDocumento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Productor &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.usuarioId == this.usuarioId &&
          other.nombreCompleto == this.nombreCompleto &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.asociacionId == this.asociacionId &&
          other.tipoDocumento == this.tipoDocumento &&
          other.numeroDocumento == this.numeroDocumento);
}

class ProductoresCompanion extends UpdateCompanion<Productor> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String?> usuarioId;
  final Value<String> nombreCompleto;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> asociacionId;
  final Value<TipoDocumento?> tipoDocumento;
  final Value<String?> numeroDocumento;
  final Value<int> rowid;
  const ProductoresCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.nombreCompleto = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.asociacionId = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.numeroDocumento = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductoresCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.usuarioId = const Value.absent(),
    required String nombreCompleto,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.asociacionId = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.numeroDocumento = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nombreCompleto = Value(nombreCompleto);
  static Insertable<Productor> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? usuarioId,
    Expression<String>? nombreCompleto,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? asociacionId,
    Expression<String>? tipoDocumento,
    Expression<String>? numeroDocumento,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (asociacionId != null) 'asociacion_id': asociacionId,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (numeroDocumento != null) 'numero_documento': numeroDocumento,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductoresCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String?>? usuarioId,
    Value<String>? nombreCompleto,
    Value<String?>? telefono,
    Value<String?>? email,
    Value<String?>? asociacionId,
    Value<TipoDocumento?>? tipoDocumento,
    Value<String?>? numeroDocumento,
    Value<int>? rowid,
  }) {
    return ProductoresCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      asociacionId: asociacionId ?? this.asociacionId,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $ProductoresTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (nombreCompleto.present) {
      map['nombre_completo'] = Variable<String>(nombreCompleto.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (asociacionId.present) {
      map['asociacion_id'] = Variable<String>(asociacionId.value);
    }
    if (tipoDocumento.present) {
      map['tipo_documento'] = Variable<String>(
        $ProductoresTable.$convertertipoDocumenton.toSql(tipoDocumento.value),
      );
    }
    if (numeroDocumento.present) {
      map['numero_documento'] = Variable<String>(numeroDocumento.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductoresCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('asociacionId: $asociacionId, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('numeroDocumento: $numeroDocumento, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FincasTable extends Fincas with TableInfo<$FincasTable, Finca> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FincasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($FincasTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productorIdMeta = const VerificationMeta(
    'productorId',
  );
  @override
  late final GeneratedColumn<String> productorId = GeneratedColumn<String>(
    'productor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productores (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _municipioMeta = const VerificationMeta(
    'municipio',
  );
  @override
  late final GeneratedColumn<String> municipio = GeneratedColumn<String>(
    'municipio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departamentoMeta = const VerificationMeta(
    'departamento',
  );
  @override
  late final GeneratedColumn<String> departamento = GeneratedColumn<String>(
    'departamento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    productorId,
    nombre,
    latitud,
    longitud,
    municipio,
    departamento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fincas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Finca> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('productor_id')) {
      context.handle(
        _productorIdMeta,
        productorId.isAcceptableOrUnknown(
          data['productor_id']!,
          _productorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productorIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    if (data.containsKey('municipio')) {
      context.handle(
        _municipioMeta,
        municipio.isAcceptableOrUnknown(data['municipio']!, _municipioMeta),
      );
    } else if (isInserting) {
      context.missing(_municipioMeta);
    }
    if (data.containsKey('departamento')) {
      context.handle(
        _departamentoMeta,
        departamento.isAcceptableOrUnknown(
          data['departamento']!,
          _departamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departamentoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Finca map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Finca(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $FincasTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      productorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}productor_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
      municipio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}municipio'],
      )!,
      departamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departamento'],
      )!,
    );
  }

  @override
  $FincasTable createAlias(String alias) {
    return $FincasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class Finca extends DataClass implements Insertable<Finca> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String productorId;
  final String nombre;
  final double? latitud;
  final double? longitud;

  /// Se guardan aparte de lat/long para poder pedir el clima por municipio sin
  /// tener que hacer geocoding inverso.
  final String municipio;
  final String departamento;
  const Finca({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.productorId,
    required this.nombre,
    this.latitud,
    this.longitud,
    required this.municipio,
    required this.departamento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $FincasTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['productor_id'] = Variable<String>(productorId);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    map['municipio'] = Variable<String>(municipio);
    map['departamento'] = Variable<String>(departamento);
    return map;
  }

  FincasCompanion toCompanion(bool nullToAbsent) {
    return FincasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      productorId: Value(productorId),
      nombre: Value(nombre),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
      municipio: Value(municipio),
      departamento: Value(departamento),
    );
  }

  factory Finca.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Finca(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $FincasTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      productorId: serializer.fromJson<String>(json['productorId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
      municipio: serializer.fromJson<String>(json['municipio']),
      departamento: serializer.fromJson<String>(json['departamento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $FincasTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'productorId': serializer.toJson<String>(productorId),
      'nombre': serializer.toJson<String>(nombre),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
      'municipio': serializer.toJson<String>(municipio),
      'departamento': serializer.toJson<String>(departamento),
    };
  }

  Finca copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? productorId,
    String? nombre,
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
    String? municipio,
    String? departamento,
  }) => Finca(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    productorId: productorId ?? this.productorId,
    nombre: nombre ?? this.nombre,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
    municipio: municipio ?? this.municipio,
    departamento: departamento ?? this.departamento,
  );
  Finca copyWithCompanion(FincasCompanion data) {
    return Finca(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      productorId: data.productorId.present
          ? data.productorId.value
          : this.productorId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      municipio: data.municipio.present ? data.municipio.value : this.municipio,
      departamento: data.departamento.present
          ? data.departamento.value
          : this.departamento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Finca(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('productorId: $productorId, ')
          ..write('nombre: $nombre, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('municipio: $municipio, ')
          ..write('departamento: $departamento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    productorId,
    nombre,
    latitud,
    longitud,
    municipio,
    departamento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Finca &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.productorId == this.productorId &&
          other.nombre == this.nombre &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.municipio == this.municipio &&
          other.departamento == this.departamento);
}

class FincasCompanion extends UpdateCompanion<Finca> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> productorId;
  final Value<String> nombre;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<String> municipio;
  final Value<String> departamento;
  final Value<int> rowid;
  const FincasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.productorId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.municipio = const Value.absent(),
    this.departamento = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FincasCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String productorId,
    required String nombre,
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    required String municipio,
    required String departamento,
    this.rowid = const Value.absent(),
  }) : productorId = Value(productorId),
       nombre = Value(nombre),
       municipio = Value(municipio),
       departamento = Value(departamento);
  static Insertable<Finca> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? productorId,
    Expression<String>? nombre,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<String>? municipio,
    Expression<String>? departamento,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (productorId != null) 'productor_id': productorId,
      if (nombre != null) 'nombre': nombre,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (municipio != null) 'municipio': municipio,
      if (departamento != null) 'departamento': departamento,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FincasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? productorId,
    Value<String>? nombre,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<String>? municipio,
    Value<String>? departamento,
    Value<int>? rowid,
  }) {
    return FincasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      productorId: productorId ?? this.productorId,
      nombre: nombre ?? this.nombre,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      municipio: municipio ?? this.municipio,
      departamento: departamento ?? this.departamento,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $FincasTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (productorId.present) {
      map['productor_id'] = Variable<String>(productorId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (municipio.present) {
      map['municipio'] = Variable<String>(municipio.value);
    }
    if (departamento.present) {
      map['departamento'] = Variable<String>(departamento.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FincasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('productorId: $productorId, ')
          ..write('nombre: $nombre, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('municipio: $municipio, ')
          ..write('departamento: $departamento, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesTable extends Lotes with TableInfo<$LotesTable, Lote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($LotesTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fincaIdMeta = const VerificationMeta(
    'fincaId',
  );
  @override
  late final GeneratedColumn<String> fincaId = GeneratedColumn<String>(
    'finca_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES fincas (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaSembradaHaMeta = const VerificationMeta(
    'areaSembradaHa',
  );
  @override
  late final GeneratedColumn<double> areaSembradaHa = GeneratedColumn<double>(
    'area_sembrada_ha',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _variedadCacaoMeta = const VerificationMeta(
    'variedadCacao',
  );
  @override
  late final GeneratedColumn<String> variedadCacao = GeneratedColumn<String>(
    'variedad_cacao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaSiembraMeta = const VerificationMeta(
    'fechaSiembra',
  );
  @override
  late final GeneratedColumn<DateTime> fechaSiembra = GeneratedColumn<DateTime>(
    'fecha_siembra',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    fincaId,
    nombre,
    areaSembradaHa,
    codigo,
    variedadCacao,
    fechaSiembra,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('finca_id')) {
      context.handle(
        _fincaIdMeta,
        fincaId.isAcceptableOrUnknown(data['finca_id']!, _fincaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fincaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('area_sembrada_ha')) {
      context.handle(
        _areaSembradaHaMeta,
        areaSembradaHa.isAcceptableOrUnknown(
          data['area_sembrada_ha']!,
          _areaSembradaHaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_areaSembradaHaMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('variedad_cacao')) {
      context.handle(
        _variedadCacaoMeta,
        variedadCacao.isAcceptableOrUnknown(
          data['variedad_cacao']!,
          _variedadCacaoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variedadCacaoMeta);
    }
    if (data.containsKey('fecha_siembra')) {
      context.handle(
        _fechaSiembraMeta,
        fechaSiembra.isAcceptableOrUnknown(
          data['fecha_siembra']!,
          _fechaSiembraMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaSiembraMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $LotesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      fincaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finca_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      areaSembradaHa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_sembrada_ha'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      variedadCacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variedad_cacao'],
      )!,
      fechaSiembra: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_siembra'],
      )!,
    );
  }

  @override
  $LotesTable createAlias(String alias) {
    return $LotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class Lote extends DataClass implements Insertable<Lote> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String fincaId;
  final String nombre;
  final double areaSembradaHa;

  /// Código corto del lote ("Lote 001"), aparte del nombre libre: el nombre
  /// puede cambiar o ser descriptivo, el código es la referencia que se usa en
  /// reportes e historiales.
  final String codigo;
  final String variedadCacao;

  /// Se guarda la fecha de siembra, no la edad: la edad se calcula en la app y
  /// así el dato no se desactualiza solo.
  final DateTime fechaSiembra;
  const Lote({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.fincaId,
    required this.nombre,
    required this.areaSembradaHa,
    required this.codigo,
    required this.variedadCacao,
    required this.fechaSiembra,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LotesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['finca_id'] = Variable<String>(fincaId);
    map['nombre'] = Variable<String>(nombre);
    map['area_sembrada_ha'] = Variable<double>(areaSembradaHa);
    map['codigo'] = Variable<String>(codigo);
    map['variedad_cacao'] = Variable<String>(variedadCacao);
    map['fecha_siembra'] = Variable<DateTime>(fechaSiembra);
    return map;
  }

  LotesCompanion toCompanion(bool nullToAbsent) {
    return LotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      fincaId: Value(fincaId),
      nombre: Value(nombre),
      areaSembradaHa: Value(areaSembradaHa),
      codigo: Value(codigo),
      variedadCacao: Value(variedadCacao),
      fechaSiembra: Value(fechaSiembra),
    );
  }

  factory Lote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lote(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $LotesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      fincaId: serializer.fromJson<String>(json['fincaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      areaSembradaHa: serializer.fromJson<double>(json['areaSembradaHa']),
      codigo: serializer.fromJson<String>(json['codigo']),
      variedadCacao: serializer.fromJson<String>(json['variedadCacao']),
      fechaSiembra: serializer.fromJson<DateTime>(json['fechaSiembra']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $LotesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'fincaId': serializer.toJson<String>(fincaId),
      'nombre': serializer.toJson<String>(nombre),
      'areaSembradaHa': serializer.toJson<double>(areaSembradaHa),
      'codigo': serializer.toJson<String>(codigo),
      'variedadCacao': serializer.toJson<String>(variedadCacao),
      'fechaSiembra': serializer.toJson<DateTime>(fechaSiembra),
    };
  }

  Lote copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? fincaId,
    String? nombre,
    double? areaSembradaHa,
    String? codigo,
    String? variedadCacao,
    DateTime? fechaSiembra,
  }) => Lote(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    fincaId: fincaId ?? this.fincaId,
    nombre: nombre ?? this.nombre,
    areaSembradaHa: areaSembradaHa ?? this.areaSembradaHa,
    codigo: codigo ?? this.codigo,
    variedadCacao: variedadCacao ?? this.variedadCacao,
    fechaSiembra: fechaSiembra ?? this.fechaSiembra,
  );
  Lote copyWithCompanion(LotesCompanion data) {
    return Lote(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      fincaId: data.fincaId.present ? data.fincaId.value : this.fincaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      areaSembradaHa: data.areaSembradaHa.present
          ? data.areaSembradaHa.value
          : this.areaSembradaHa,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      variedadCacao: data.variedadCacao.present
          ? data.variedadCacao.value
          : this.variedadCacao,
      fechaSiembra: data.fechaSiembra.present
          ? data.fechaSiembra.value
          : this.fechaSiembra,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lote(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('areaSembradaHa: $areaSembradaHa, ')
          ..write('codigo: $codigo, ')
          ..write('variedadCacao: $variedadCacao, ')
          ..write('fechaSiembra: $fechaSiembra')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    fincaId,
    nombre,
    areaSembradaHa,
    codigo,
    variedadCacao,
    fechaSiembra,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lote &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.fincaId == this.fincaId &&
          other.nombre == this.nombre &&
          other.areaSembradaHa == this.areaSembradaHa &&
          other.codigo == this.codigo &&
          other.variedadCacao == this.variedadCacao &&
          other.fechaSiembra == this.fechaSiembra);
}

class LotesCompanion extends UpdateCompanion<Lote> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> fincaId;
  final Value<String> nombre;
  final Value<double> areaSembradaHa;
  final Value<String> codigo;
  final Value<String> variedadCacao;
  final Value<DateTime> fechaSiembra;
  final Value<int> rowid;
  const LotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.fincaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.areaSembradaHa = const Value.absent(),
    this.codigo = const Value.absent(),
    this.variedadCacao = const Value.absent(),
    this.fechaSiembra = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String fincaId,
    required String nombre,
    required double areaSembradaHa,
    this.codigo = const Value.absent(),
    required String variedadCacao,
    required DateTime fechaSiembra,
    this.rowid = const Value.absent(),
  }) : fincaId = Value(fincaId),
       nombre = Value(nombre),
       areaSembradaHa = Value(areaSembradaHa),
       variedadCacao = Value(variedadCacao),
       fechaSiembra = Value(fechaSiembra);
  static Insertable<Lote> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? fincaId,
    Expression<String>? nombre,
    Expression<double>? areaSembradaHa,
    Expression<String>? codigo,
    Expression<String>? variedadCacao,
    Expression<DateTime>? fechaSiembra,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (fincaId != null) 'finca_id': fincaId,
      if (nombre != null) 'nombre': nombre,
      if (areaSembradaHa != null) 'area_sembrada_ha': areaSembradaHa,
      if (codigo != null) 'codigo': codigo,
      if (variedadCacao != null) 'variedad_cacao': variedadCacao,
      if (fechaSiembra != null) 'fecha_siembra': fechaSiembra,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? fincaId,
    Value<String>? nombre,
    Value<double>? areaSembradaHa,
    Value<String>? codigo,
    Value<String>? variedadCacao,
    Value<DateTime>? fechaSiembra,
    Value<int>? rowid,
  }) {
    return LotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      fincaId: fincaId ?? this.fincaId,
      nombre: nombre ?? this.nombre,
      areaSembradaHa: areaSembradaHa ?? this.areaSembradaHa,
      codigo: codigo ?? this.codigo,
      variedadCacao: variedadCacao ?? this.variedadCacao,
      fechaSiembra: fechaSiembra ?? this.fechaSiembra,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LotesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (fincaId.present) {
      map['finca_id'] = Variable<String>(fincaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (areaSembradaHa.present) {
      map['area_sembrada_ha'] = Variable<double>(areaSembradaHa.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (variedadCacao.present) {
      map['variedad_cacao'] = Variable<String>(variedadCacao.value);
    }
    if (fechaSiembra.present) {
      map['fecha_siembra'] = Variable<DateTime>(fechaSiembra.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('fincaId: $fincaId, ')
          ..write('nombre: $nombre, ')
          ..write('areaSembradaHa: $areaSembradaHa, ')
          ..write('codigo: $codigo, ')
          ..write('variedadCacao: $variedadCacao, ')
          ..write('fechaSiembra: $fechaSiembra, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActividadesAgricolasTable extends ActividadesAgricolas
    with TableInfo<$ActividadesAgricolasTable, ActividadAgricola> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActividadesAgricolasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>(
        $ActividadesAgricolasTable.$convertersyncStatus,
      );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lotes (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoActividad, String>
  tipoActividad =
      GeneratedColumn<String>(
        'tipo_actividad',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoActividad>(
        $ActividadesAgricolasTable.$convertertipoActividad,
      );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responsableMeta = const VerificationMeta(
    'responsable',
  );
  @override
  late final GeneratedColumn<String> responsable = GeneratedColumn<String>(
    'responsable',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<double> costo = GeneratedColumn<double>(
    'costo',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtipoLaborMeta = const VerificationMeta(
    'subtipoLabor',
  );
  @override
  late final GeneratedColumn<String> subtipoLabor = GeneratedColumn<String>(
    'subtipo_labor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cantidadAplicadaMeta = const VerificationMeta(
    'cantidadAplicada',
  );
  @override
  late final GeneratedColumn<String> cantidadAplicada = GeneratedColumn<String>(
    'cantidad_aplicada',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incidenciaMeta = const VerificationMeta(
    'incidencia',
  );
  @override
  late final GeneratedColumn<String> incidencia = GeneratedColumn<String>(
    'incidencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arbolesAfectadosMeta = const VerificationMeta(
    'arbolesAfectados',
  );
  @override
  late final GeneratedColumn<int> arbolesAfectados = GeneratedColumn<int>(
    'arboles_afectados',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _edadCultivoAniosMeta = const VerificationMeta(
    'edadCultivoAnios',
  );
  @override
  late final GeneratedColumn<int> edadCultivoAnios = GeneratedColumn<int>(
    'edad_cultivo_anios',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arbolesSembradosMeta = const VerificationMeta(
    'arbolesSembrados',
  );
  @override
  late final GeneratedColumn<int> arbolesSembrados = GeneratedColumn<int>(
    'arboles_sembrados',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _edadPlantulaMesesMeta = const VerificationMeta(
    'edadPlantulaMeses',
  );
  @override
  late final GeneratedColumn<int> edadPlantulaMeses = GeneratedColumn<int>(
    'edad_plantula_meses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insumosMeta = const VerificationMeta(
    'insumos',
  );
  @override
  late final GeneratedColumn<String> insumos = GeneratedColumn<String>(
    'insumos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultadoEsperadoMeta = const VerificationMeta(
    'resultadoEsperado',
  );
  @override
  late final GeneratedColumn<String> resultadoEsperado =
      GeneratedColumn<String>(
        'resultado_esperado',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    tipoActividad,
    fecha,
    observaciones,
    responsable,
    costo,
    fotoPath,
    subtipoLabor,
    producto,
    cantidadAplicada,
    incidencia,
    arbolesAfectados,
    edadCultivoAnios,
    arbolesSembrados,
    edadPlantulaMeses,
    insumos,
    resultadoEsperado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actividades_agricolas';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActividadAgricola> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('responsable')) {
      context.handle(
        _responsableMeta,
        responsable.isAcceptableOrUnknown(
          data['responsable']!,
          _responsableMeta,
        ),
      );
    }
    if (data.containsKey('costo')) {
      context.handle(
        _costoMeta,
        costo.isAcceptableOrUnknown(data['costo']!, _costoMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('subtipo_labor')) {
      context.handle(
        _subtipoLaborMeta,
        subtipoLabor.isAcceptableOrUnknown(
          data['subtipo_labor']!,
          _subtipoLaborMeta,
        ),
      );
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    }
    if (data.containsKey('cantidad_aplicada')) {
      context.handle(
        _cantidadAplicadaMeta,
        cantidadAplicada.isAcceptableOrUnknown(
          data['cantidad_aplicada']!,
          _cantidadAplicadaMeta,
        ),
      );
    }
    if (data.containsKey('incidencia')) {
      context.handle(
        _incidenciaMeta,
        incidencia.isAcceptableOrUnknown(data['incidencia']!, _incidenciaMeta),
      );
    }
    if (data.containsKey('arboles_afectados')) {
      context.handle(
        _arbolesAfectadosMeta,
        arbolesAfectados.isAcceptableOrUnknown(
          data['arboles_afectados']!,
          _arbolesAfectadosMeta,
        ),
      );
    }
    if (data.containsKey('edad_cultivo_anios')) {
      context.handle(
        _edadCultivoAniosMeta,
        edadCultivoAnios.isAcceptableOrUnknown(
          data['edad_cultivo_anios']!,
          _edadCultivoAniosMeta,
        ),
      );
    }
    if (data.containsKey('arboles_sembrados')) {
      context.handle(
        _arbolesSembradosMeta,
        arbolesSembrados.isAcceptableOrUnknown(
          data['arboles_sembrados']!,
          _arbolesSembradosMeta,
        ),
      );
    }
    if (data.containsKey('edad_plantula_meses')) {
      context.handle(
        _edadPlantulaMesesMeta,
        edadPlantulaMeses.isAcceptableOrUnknown(
          data['edad_plantula_meses']!,
          _edadPlantulaMesesMeta,
        ),
      );
    }
    if (data.containsKey('insumos')) {
      context.handle(
        _insumosMeta,
        insumos.isAcceptableOrUnknown(data['insumos']!, _insumosMeta),
      );
    }
    if (data.containsKey('resultado_esperado')) {
      context.handle(
        _resultadoEsperadoMeta,
        resultadoEsperado.isAcceptableOrUnknown(
          data['resultado_esperado']!,
          _resultadoEsperadoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActividadAgricola map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActividadAgricola(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $ActividadesAgricolasTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      tipoActividad: $ActividadesAgricolasTable.$convertertipoActividad.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_actividad'],
        )!,
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      responsable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responsable'],
      ),
      costo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      subtipoLabor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtipo_labor'],
      ),
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      ),
      cantidadAplicada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cantidad_aplicada'],
      ),
      incidencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incidencia'],
      ),
      arbolesAfectados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arboles_afectados'],
      ),
      edadCultivoAnios: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad_cultivo_anios'],
      ),
      arbolesSembrados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arboles_sembrados'],
      ),
      edadPlantulaMeses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad_plantula_meses'],
      ),
      insumos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insumos'],
      ),
      resultadoEsperado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resultado_esperado'],
      ),
    );
  }

  @override
  $ActividadesAgricolasTable createAlias(String alias) {
    return $ActividadesAgricolasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<TipoActividad, String, String>
  $convertertipoActividad = const EnumNameConverter<TipoActividad>(
    TipoActividad.values,
  );
}

class ActividadAgricola extends DataClass
    implements Insertable<ActividadAgricola> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String loteId;
  final TipoActividad tipoActividad;
  final DateTime fecha;
  final String? observaciones;

  /// Quién hizo la labor. El que ejecuta en campo no siempre es el que
  /// registra en la app: puede ser un jornalero o un técnico.
  final String? responsable;

  /// Lo gastado en esa labor (insumos, jornales), cuando aplica.
  final double? costo;

  /// Foto de la labor, guardada en el propio teléfono.
  final String? fotoPath;

  /// Subtipo, para las labores que lo tienen: poda de formación, de
  /// mantenimiento o de rehabilitación; fertilización química u orgánica.
  final String? subtipoLabor;

  /// Producto aplicado y cuánto, para fertilización y control fitosanitario.
  final String? producto;
  final String? cantidadAplicada;

  /// Qué tan extendido estaba el problema (control fitosanitario).
  final String? incidencia;

  /// Cuántos árboles tocó la labor y qué edad tenía el cultivo ese día.
  final int? arbolesAfectados;
  final int? edadCultivoAnios;

  /// Solo para la siembra.
  final int? arbolesSembrados;
  final int? edadPlantulaMeses;
  final String? insumos;
  final String? resultadoEsperado;
  const ActividadAgricola({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.loteId,
    required this.tipoActividad,
    required this.fecha,
    this.observaciones,
    this.responsable,
    this.costo,
    this.fotoPath,
    this.subtipoLabor,
    this.producto,
    this.cantidadAplicada,
    this.incidencia,
    this.arbolesAfectados,
    this.edadCultivoAnios,
    this.arbolesSembrados,
    this.edadPlantulaMeses,
    this.insumos,
    this.resultadoEsperado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ActividadesAgricolasTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['lote_id'] = Variable<String>(loteId);
    {
      map['tipo_actividad'] = Variable<String>(
        $ActividadesAgricolasTable.$convertertipoActividad.toSql(tipoActividad),
      );
    }
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    if (!nullToAbsent || responsable != null) {
      map['responsable'] = Variable<String>(responsable);
    }
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<double>(costo);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    if (!nullToAbsent || subtipoLabor != null) {
      map['subtipo_labor'] = Variable<String>(subtipoLabor);
    }
    if (!nullToAbsent || producto != null) {
      map['producto'] = Variable<String>(producto);
    }
    if (!nullToAbsent || cantidadAplicada != null) {
      map['cantidad_aplicada'] = Variable<String>(cantidadAplicada);
    }
    if (!nullToAbsent || incidencia != null) {
      map['incidencia'] = Variable<String>(incidencia);
    }
    if (!nullToAbsent || arbolesAfectados != null) {
      map['arboles_afectados'] = Variable<int>(arbolesAfectados);
    }
    if (!nullToAbsent || edadCultivoAnios != null) {
      map['edad_cultivo_anios'] = Variable<int>(edadCultivoAnios);
    }
    if (!nullToAbsent || arbolesSembrados != null) {
      map['arboles_sembrados'] = Variable<int>(arbolesSembrados);
    }
    if (!nullToAbsent || edadPlantulaMeses != null) {
      map['edad_plantula_meses'] = Variable<int>(edadPlantulaMeses);
    }
    if (!nullToAbsent || insumos != null) {
      map['insumos'] = Variable<String>(insumos);
    }
    if (!nullToAbsent || resultadoEsperado != null) {
      map['resultado_esperado'] = Variable<String>(resultadoEsperado);
    }
    return map;
  }

  ActividadesAgricolasCompanion toCompanion(bool nullToAbsent) {
    return ActividadesAgricolasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      loteId: Value(loteId),
      tipoActividad: Value(tipoActividad),
      fecha: Value(fecha),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      responsable: responsable == null && nullToAbsent
          ? const Value.absent()
          : Value(responsable),
      costo: costo == null && nullToAbsent
          ? const Value.absent()
          : Value(costo),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      subtipoLabor: subtipoLabor == null && nullToAbsent
          ? const Value.absent()
          : Value(subtipoLabor),
      producto: producto == null && nullToAbsent
          ? const Value.absent()
          : Value(producto),
      cantidadAplicada: cantidadAplicada == null && nullToAbsent
          ? const Value.absent()
          : Value(cantidadAplicada),
      incidencia: incidencia == null && nullToAbsent
          ? const Value.absent()
          : Value(incidencia),
      arbolesAfectados: arbolesAfectados == null && nullToAbsent
          ? const Value.absent()
          : Value(arbolesAfectados),
      edadCultivoAnios: edadCultivoAnios == null && nullToAbsent
          ? const Value.absent()
          : Value(edadCultivoAnios),
      arbolesSembrados: arbolesSembrados == null && nullToAbsent
          ? const Value.absent()
          : Value(arbolesSembrados),
      edadPlantulaMeses: edadPlantulaMeses == null && nullToAbsent
          ? const Value.absent()
          : Value(edadPlantulaMeses),
      insumos: insumos == null && nullToAbsent
          ? const Value.absent()
          : Value(insumos),
      resultadoEsperado: resultadoEsperado == null && nullToAbsent
          ? const Value.absent()
          : Value(resultadoEsperado),
    );
  }

  factory ActividadAgricola.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActividadAgricola(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $ActividadesAgricolasTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      loteId: serializer.fromJson<String>(json['loteId']),
      tipoActividad: $ActividadesAgricolasTable.$convertertipoActividad
          .fromJson(serializer.fromJson<String>(json['tipoActividad'])),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      responsable: serializer.fromJson<String?>(json['responsable']),
      costo: serializer.fromJson<double?>(json['costo']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      subtipoLabor: serializer.fromJson<String?>(json['subtipoLabor']),
      producto: serializer.fromJson<String?>(json['producto']),
      cantidadAplicada: serializer.fromJson<String?>(json['cantidadAplicada']),
      incidencia: serializer.fromJson<String?>(json['incidencia']),
      arbolesAfectados: serializer.fromJson<int?>(json['arbolesAfectados']),
      edadCultivoAnios: serializer.fromJson<int?>(json['edadCultivoAnios']),
      arbolesSembrados: serializer.fromJson<int?>(json['arbolesSembrados']),
      edadPlantulaMeses: serializer.fromJson<int?>(json['edadPlantulaMeses']),
      insumos: serializer.fromJson<String?>(json['insumos']),
      resultadoEsperado: serializer.fromJson<String?>(
        json['resultadoEsperado'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $ActividadesAgricolasTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'loteId': serializer.toJson<String>(loteId),
      'tipoActividad': serializer.toJson<String>(
        $ActividadesAgricolasTable.$convertertipoActividad.toJson(
          tipoActividad,
        ),
      ),
      'fecha': serializer.toJson<DateTime>(fecha),
      'observaciones': serializer.toJson<String?>(observaciones),
      'responsable': serializer.toJson<String?>(responsable),
      'costo': serializer.toJson<double?>(costo),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'subtipoLabor': serializer.toJson<String?>(subtipoLabor),
      'producto': serializer.toJson<String?>(producto),
      'cantidadAplicada': serializer.toJson<String?>(cantidadAplicada),
      'incidencia': serializer.toJson<String?>(incidencia),
      'arbolesAfectados': serializer.toJson<int?>(arbolesAfectados),
      'edadCultivoAnios': serializer.toJson<int?>(edadCultivoAnios),
      'arbolesSembrados': serializer.toJson<int?>(arbolesSembrados),
      'edadPlantulaMeses': serializer.toJson<int?>(edadPlantulaMeses),
      'insumos': serializer.toJson<String?>(insumos),
      'resultadoEsperado': serializer.toJson<String?>(resultadoEsperado),
    };
  }

  ActividadAgricola copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? loteId,
    TipoActividad? tipoActividad,
    DateTime? fecha,
    Value<String?> observaciones = const Value.absent(),
    Value<String?> responsable = const Value.absent(),
    Value<double?> costo = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
    Value<String?> subtipoLabor = const Value.absent(),
    Value<String?> producto = const Value.absent(),
    Value<String?> cantidadAplicada = const Value.absent(),
    Value<String?> incidencia = const Value.absent(),
    Value<int?> arbolesAfectados = const Value.absent(),
    Value<int?> edadCultivoAnios = const Value.absent(),
    Value<int?> arbolesSembrados = const Value.absent(),
    Value<int?> edadPlantulaMeses = const Value.absent(),
    Value<String?> insumos = const Value.absent(),
    Value<String?> resultadoEsperado = const Value.absent(),
  }) => ActividadAgricola(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    loteId: loteId ?? this.loteId,
    tipoActividad: tipoActividad ?? this.tipoActividad,
    fecha: fecha ?? this.fecha,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    responsable: responsable.present ? responsable.value : this.responsable,
    costo: costo.present ? costo.value : this.costo,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    subtipoLabor: subtipoLabor.present ? subtipoLabor.value : this.subtipoLabor,
    producto: producto.present ? producto.value : this.producto,
    cantidadAplicada: cantidadAplicada.present
        ? cantidadAplicada.value
        : this.cantidadAplicada,
    incidencia: incidencia.present ? incidencia.value : this.incidencia,
    arbolesAfectados: arbolesAfectados.present
        ? arbolesAfectados.value
        : this.arbolesAfectados,
    edadCultivoAnios: edadCultivoAnios.present
        ? edadCultivoAnios.value
        : this.edadCultivoAnios,
    arbolesSembrados: arbolesSembrados.present
        ? arbolesSembrados.value
        : this.arbolesSembrados,
    edadPlantulaMeses: edadPlantulaMeses.present
        ? edadPlantulaMeses.value
        : this.edadPlantulaMeses,
    insumos: insumos.present ? insumos.value : this.insumos,
    resultadoEsperado: resultadoEsperado.present
        ? resultadoEsperado.value
        : this.resultadoEsperado,
  );
  ActividadAgricola copyWithCompanion(ActividadesAgricolasCompanion data) {
    return ActividadAgricola(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      tipoActividad: data.tipoActividad.present
          ? data.tipoActividad.value
          : this.tipoActividad,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      responsable: data.responsable.present
          ? data.responsable.value
          : this.responsable,
      costo: data.costo.present ? data.costo.value : this.costo,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      subtipoLabor: data.subtipoLabor.present
          ? data.subtipoLabor.value
          : this.subtipoLabor,
      producto: data.producto.present ? data.producto.value : this.producto,
      cantidadAplicada: data.cantidadAplicada.present
          ? data.cantidadAplicada.value
          : this.cantidadAplicada,
      incidencia: data.incidencia.present
          ? data.incidencia.value
          : this.incidencia,
      arbolesAfectados: data.arbolesAfectados.present
          ? data.arbolesAfectados.value
          : this.arbolesAfectados,
      edadCultivoAnios: data.edadCultivoAnios.present
          ? data.edadCultivoAnios.value
          : this.edadCultivoAnios,
      arbolesSembrados: data.arbolesSembrados.present
          ? data.arbolesSembrados.value
          : this.arbolesSembrados,
      edadPlantulaMeses: data.edadPlantulaMeses.present
          ? data.edadPlantulaMeses.value
          : this.edadPlantulaMeses,
      insumos: data.insumos.present ? data.insumos.value : this.insumos,
      resultadoEsperado: data.resultadoEsperado.present
          ? data.resultadoEsperado.value
          : this.resultadoEsperado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActividadAgricola(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('tipoActividad: $tipoActividad, ')
          ..write('fecha: $fecha, ')
          ..write('observaciones: $observaciones, ')
          ..write('responsable: $responsable, ')
          ..write('costo: $costo, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('subtipoLabor: $subtipoLabor, ')
          ..write('producto: $producto, ')
          ..write('cantidadAplicada: $cantidadAplicada, ')
          ..write('incidencia: $incidencia, ')
          ..write('arbolesAfectados: $arbolesAfectados, ')
          ..write('edadCultivoAnios: $edadCultivoAnios, ')
          ..write('arbolesSembrados: $arbolesSembrados, ')
          ..write('edadPlantulaMeses: $edadPlantulaMeses, ')
          ..write('insumos: $insumos, ')
          ..write('resultadoEsperado: $resultadoEsperado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    tipoActividad,
    fecha,
    observaciones,
    responsable,
    costo,
    fotoPath,
    subtipoLabor,
    producto,
    cantidadAplicada,
    incidencia,
    arbolesAfectados,
    edadCultivoAnios,
    arbolesSembrados,
    edadPlantulaMeses,
    insumos,
    resultadoEsperado,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActividadAgricola &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.loteId == this.loteId &&
          other.tipoActividad == this.tipoActividad &&
          other.fecha == this.fecha &&
          other.observaciones == this.observaciones &&
          other.responsable == this.responsable &&
          other.costo == this.costo &&
          other.fotoPath == this.fotoPath &&
          other.subtipoLabor == this.subtipoLabor &&
          other.producto == this.producto &&
          other.cantidadAplicada == this.cantidadAplicada &&
          other.incidencia == this.incidencia &&
          other.arbolesAfectados == this.arbolesAfectados &&
          other.edadCultivoAnios == this.edadCultivoAnios &&
          other.arbolesSembrados == this.arbolesSembrados &&
          other.edadPlantulaMeses == this.edadPlantulaMeses &&
          other.insumos == this.insumos &&
          other.resultadoEsperado == this.resultadoEsperado);
}

class ActividadesAgricolasCompanion extends UpdateCompanion<ActividadAgricola> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> loteId;
  final Value<TipoActividad> tipoActividad;
  final Value<DateTime> fecha;
  final Value<String?> observaciones;
  final Value<String?> responsable;
  final Value<double?> costo;
  final Value<String?> fotoPath;
  final Value<String?> subtipoLabor;
  final Value<String?> producto;
  final Value<String?> cantidadAplicada;
  final Value<String?> incidencia;
  final Value<int?> arbolesAfectados;
  final Value<int?> edadCultivoAnios;
  final Value<int?> arbolesSembrados;
  final Value<int?> edadPlantulaMeses;
  final Value<String?> insumos;
  final Value<String?> resultadoEsperado;
  final Value<int> rowid;
  const ActividadesAgricolasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.loteId = const Value.absent(),
    this.tipoActividad = const Value.absent(),
    this.fecha = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.responsable = const Value.absent(),
    this.costo = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.subtipoLabor = const Value.absent(),
    this.producto = const Value.absent(),
    this.cantidadAplicada = const Value.absent(),
    this.incidencia = const Value.absent(),
    this.arbolesAfectados = const Value.absent(),
    this.edadCultivoAnios = const Value.absent(),
    this.arbolesSembrados = const Value.absent(),
    this.edadPlantulaMeses = const Value.absent(),
    this.insumos = const Value.absent(),
    this.resultadoEsperado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActividadesAgricolasCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String loteId,
    required TipoActividad tipoActividad,
    required DateTime fecha,
    this.observaciones = const Value.absent(),
    this.responsable = const Value.absent(),
    this.costo = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.subtipoLabor = const Value.absent(),
    this.producto = const Value.absent(),
    this.cantidadAplicada = const Value.absent(),
    this.incidencia = const Value.absent(),
    this.arbolesAfectados = const Value.absent(),
    this.edadCultivoAnios = const Value.absent(),
    this.arbolesSembrados = const Value.absent(),
    this.edadPlantulaMeses = const Value.absent(),
    this.insumos = const Value.absent(),
    this.resultadoEsperado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : loteId = Value(loteId),
       tipoActividad = Value(tipoActividad),
       fecha = Value(fecha);
  static Insertable<ActividadAgricola> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? loteId,
    Expression<String>? tipoActividad,
    Expression<DateTime>? fecha,
    Expression<String>? observaciones,
    Expression<String>? responsable,
    Expression<double>? costo,
    Expression<String>? fotoPath,
    Expression<String>? subtipoLabor,
    Expression<String>? producto,
    Expression<String>? cantidadAplicada,
    Expression<String>? incidencia,
    Expression<int>? arbolesAfectados,
    Expression<int>? edadCultivoAnios,
    Expression<int>? arbolesSembrados,
    Expression<int>? edadPlantulaMeses,
    Expression<String>? insumos,
    Expression<String>? resultadoEsperado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (loteId != null) 'lote_id': loteId,
      if (tipoActividad != null) 'tipo_actividad': tipoActividad,
      if (fecha != null) 'fecha': fecha,
      if (observaciones != null) 'observaciones': observaciones,
      if (responsable != null) 'responsable': responsable,
      if (costo != null) 'costo': costo,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (subtipoLabor != null) 'subtipo_labor': subtipoLabor,
      if (producto != null) 'producto': producto,
      if (cantidadAplicada != null) 'cantidad_aplicada': cantidadAplicada,
      if (incidencia != null) 'incidencia': incidencia,
      if (arbolesAfectados != null) 'arboles_afectados': arbolesAfectados,
      if (edadCultivoAnios != null) 'edad_cultivo_anios': edadCultivoAnios,
      if (arbolesSembrados != null) 'arboles_sembrados': arbolesSembrados,
      if (edadPlantulaMeses != null) 'edad_plantula_meses': edadPlantulaMeses,
      if (insumos != null) 'insumos': insumos,
      if (resultadoEsperado != null) 'resultado_esperado': resultadoEsperado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActividadesAgricolasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? loteId,
    Value<TipoActividad>? tipoActividad,
    Value<DateTime>? fecha,
    Value<String?>? observaciones,
    Value<String?>? responsable,
    Value<double?>? costo,
    Value<String?>? fotoPath,
    Value<String?>? subtipoLabor,
    Value<String?>? producto,
    Value<String?>? cantidadAplicada,
    Value<String?>? incidencia,
    Value<int?>? arbolesAfectados,
    Value<int?>? edadCultivoAnios,
    Value<int?>? arbolesSembrados,
    Value<int?>? edadPlantulaMeses,
    Value<String?>? insumos,
    Value<String?>? resultadoEsperado,
    Value<int>? rowid,
  }) {
    return ActividadesAgricolasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      loteId: loteId ?? this.loteId,
      tipoActividad: tipoActividad ?? this.tipoActividad,
      fecha: fecha ?? this.fecha,
      observaciones: observaciones ?? this.observaciones,
      responsable: responsable ?? this.responsable,
      costo: costo ?? this.costo,
      fotoPath: fotoPath ?? this.fotoPath,
      subtipoLabor: subtipoLabor ?? this.subtipoLabor,
      producto: producto ?? this.producto,
      cantidadAplicada: cantidadAplicada ?? this.cantidadAplicada,
      incidencia: incidencia ?? this.incidencia,
      arbolesAfectados: arbolesAfectados ?? this.arbolesAfectados,
      edadCultivoAnios: edadCultivoAnios ?? this.edadCultivoAnios,
      arbolesSembrados: arbolesSembrados ?? this.arbolesSembrados,
      edadPlantulaMeses: edadPlantulaMeses ?? this.edadPlantulaMeses,
      insumos: insumos ?? this.insumos,
      resultadoEsperado: resultadoEsperado ?? this.resultadoEsperado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $ActividadesAgricolasTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (tipoActividad.present) {
      map['tipo_actividad'] = Variable<String>(
        $ActividadesAgricolasTable.$convertertipoActividad.toSql(
          tipoActividad.value,
        ),
      );
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (responsable.present) {
      map['responsable'] = Variable<String>(responsable.value);
    }
    if (costo.present) {
      map['costo'] = Variable<double>(costo.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (subtipoLabor.present) {
      map['subtipo_labor'] = Variable<String>(subtipoLabor.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (cantidadAplicada.present) {
      map['cantidad_aplicada'] = Variable<String>(cantidadAplicada.value);
    }
    if (incidencia.present) {
      map['incidencia'] = Variable<String>(incidencia.value);
    }
    if (arbolesAfectados.present) {
      map['arboles_afectados'] = Variable<int>(arbolesAfectados.value);
    }
    if (edadCultivoAnios.present) {
      map['edad_cultivo_anios'] = Variable<int>(edadCultivoAnios.value);
    }
    if (arbolesSembrados.present) {
      map['arboles_sembrados'] = Variable<int>(arbolesSembrados.value);
    }
    if (edadPlantulaMeses.present) {
      map['edad_plantula_meses'] = Variable<int>(edadPlantulaMeses.value);
    }
    if (insumos.present) {
      map['insumos'] = Variable<String>(insumos.value);
    }
    if (resultadoEsperado.present) {
      map['resultado_esperado'] = Variable<String>(resultadoEsperado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActividadesAgricolasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('tipoActividad: $tipoActividad, ')
          ..write('fecha: $fecha, ')
          ..write('observaciones: $observaciones, ')
          ..write('responsable: $responsable, ')
          ..write('costo: $costo, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('subtipoLabor: $subtipoLabor, ')
          ..write('producto: $producto, ')
          ..write('cantidadAplicada: $cantidadAplicada, ')
          ..write('incidencia: $incidencia, ')
          ..write('arbolesAfectados: $arbolesAfectados, ')
          ..write('edadCultivoAnios: $edadCultivoAnios, ')
          ..write('arbolesSembrados: $arbolesSembrados, ')
          ..write('edadPlantulaMeses: $edadPlantulaMeses, ')
          ..write('insumos: $insumos, ')
          ..write('resultadoEsperado: $resultadoEsperado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CosechasTable extends Cosechas with TableInfo<$CosechasTable, Cosecha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CosechasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($CosechasTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lotes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadKgMeta = const VerificationMeta(
    'cantidadKg',
  );
  @override
  late final GeneratedColumn<double> cantidadKg = GeneratedColumn<double>(
    'cantidad_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoProductoMeta = const VerificationMeta(
    'tipoProducto',
  );
  @override
  late final GeneratedColumn<String> tipoProducto = GeneratedColumn<String>(
    'tipo_producto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    fecha,
    cantidadKg,
    observaciones,
    tipoProducto,
    fotoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cosechas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cosecha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('cantidad_kg')) {
      context.handle(
        _cantidadKgMeta,
        cantidadKg.isAcceptableOrUnknown(data['cantidad_kg']!, _cantidadKgMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadKgMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('tipo_producto')) {
      context.handle(
        _tipoProductoMeta,
        tipoProducto.isAcceptableOrUnknown(
          data['tipo_producto']!,
          _tipoProductoMeta,
        ),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cosecha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cosecha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $CosechasTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      cantidadKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad_kg'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      tipoProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_producto'],
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
    );
  }

  @override
  $CosechasTable createAlias(String alias) {
    return $CosechasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class Cosecha extends DataClass implements Insertable<Cosecha> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String loteId;
  final DateTime fecha;
  final double cantidadKg;
  final String? observaciones;

  /// En qué estado salió el cacao: en baba, fermentado o seco.
  final String? tipoProducto;

  /// Evidencia fotográfica de la entrega, en el propio teléfono.
  final String? fotoPath;
  const Cosecha({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.loteId,
    required this.fecha,
    required this.cantidadKg,
    this.observaciones,
    this.tipoProducto,
    this.fotoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $CosechasTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['cantidad_kg'] = Variable<double>(cantidadKg);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    if (!nullToAbsent || tipoProducto != null) {
      map['tipo_producto'] = Variable<String>(tipoProducto);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    return map;
  }

  CosechasCompanion toCompanion(bool nullToAbsent) {
    return CosechasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      loteId: Value(loteId),
      fecha: Value(fecha),
      cantidadKg: Value(cantidadKg),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      tipoProducto: tipoProducto == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoProducto),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
    );
  }

  factory Cosecha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cosecha(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $CosechasTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      loteId: serializer.fromJson<String>(json['loteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      cantidadKg: serializer.fromJson<double>(json['cantidadKg']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      tipoProducto: serializer.fromJson<String?>(json['tipoProducto']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $CosechasTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'loteId': serializer.toJson<String>(loteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'cantidadKg': serializer.toJson<double>(cantidadKg),
      'observaciones': serializer.toJson<String?>(observaciones),
      'tipoProducto': serializer.toJson<String?>(tipoProducto),
      'fotoPath': serializer.toJson<String?>(fotoPath),
    };
  }

  Cosecha copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? loteId,
    DateTime? fecha,
    double? cantidadKg,
    Value<String?> observaciones = const Value.absent(),
    Value<String?> tipoProducto = const Value.absent(),
    Value<String?> fotoPath = const Value.absent(),
  }) => Cosecha(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    loteId: loteId ?? this.loteId,
    fecha: fecha ?? this.fecha,
    cantidadKg: cantidadKg ?? this.cantidadKg,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    tipoProducto: tipoProducto.present ? tipoProducto.value : this.tipoProducto,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
  );
  Cosecha copyWithCompanion(CosechasCompanion data) {
    return Cosecha(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      cantidadKg: data.cantidadKg.present
          ? data.cantidadKg.value
          : this.cantidadKg,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      tipoProducto: data.tipoProducto.present
          ? data.tipoProducto.value
          : this.tipoProducto,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cosecha(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('fecha: $fecha, ')
          ..write('cantidadKg: $cantidadKg, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoProducto: $tipoProducto, ')
          ..write('fotoPath: $fotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    fecha,
    cantidadKg,
    observaciones,
    tipoProducto,
    fotoPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cosecha &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.loteId == this.loteId &&
          other.fecha == this.fecha &&
          other.cantidadKg == this.cantidadKg &&
          other.observaciones == this.observaciones &&
          other.tipoProducto == this.tipoProducto &&
          other.fotoPath == this.fotoPath);
}

class CosechasCompanion extends UpdateCompanion<Cosecha> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> loteId;
  final Value<DateTime> fecha;
  final Value<double> cantidadKg;
  final Value<String?> observaciones;
  final Value<String?> tipoProducto;
  final Value<String?> fotoPath;
  final Value<int> rowid;
  const CosechasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.loteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.cantidadKg = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.tipoProducto = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CosechasCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String loteId,
    required DateTime fecha,
    required double cantidadKg,
    this.observaciones = const Value.absent(),
    this.tipoProducto = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : loteId = Value(loteId),
       fecha = Value(fecha),
       cantidadKg = Value(cantidadKg);
  static Insertable<Cosecha> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? loteId,
    Expression<DateTime>? fecha,
    Expression<double>? cantidadKg,
    Expression<String>? observaciones,
    Expression<String>? tipoProducto,
    Expression<String>? fotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (loteId != null) 'lote_id': loteId,
      if (fecha != null) 'fecha': fecha,
      if (cantidadKg != null) 'cantidad_kg': cantidadKg,
      if (observaciones != null) 'observaciones': observaciones,
      if (tipoProducto != null) 'tipo_producto': tipoProducto,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CosechasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? loteId,
    Value<DateTime>? fecha,
    Value<double>? cantidadKg,
    Value<String?>? observaciones,
    Value<String?>? tipoProducto,
    Value<String?>? fotoPath,
    Value<int>? rowid,
  }) {
    return CosechasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      loteId: loteId ?? this.loteId,
      fecha: fecha ?? this.fecha,
      cantidadKg: cantidadKg ?? this.cantidadKg,
      observaciones: observaciones ?? this.observaciones,
      tipoProducto: tipoProducto ?? this.tipoProducto,
      fotoPath: fotoPath ?? this.fotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $CosechasTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (cantidadKg.present) {
      map['cantidad_kg'] = Variable<double>(cantidadKg.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (tipoProducto.present) {
      map['tipo_producto'] = Variable<String>(tipoProducto.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CosechasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('fecha: $fecha, ')
          ..write('cantidadKg: $cantidadKg, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoProducto: $tipoProducto, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticosTable extends Diagnosticos
    with TableInfo<$DiagnosticosTable, Diagnostico> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: nuevoId,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
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
    requiredDuringInsert: false,
    clientDefault: ahora,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>(
        'server_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<SyncStatus>($DiagnosticosTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
    'lote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lotes (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoFenologico, String>
  estadoFenologico =
      GeneratedColumn<String>(
        'estado_fenologico',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoFenologico>(
        $DiagnosticosTable.$converterestadoFenologico,
      );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    fecha,
    fotoPath,
    estadoFenologico,
    notas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnosticos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Diagnostico> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Diagnostico map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Diagnostico(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_updated_at'],
      ),
      syncStatus: $DiagnosticosTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      estadoFenologico: $DiagnosticosTable.$converterestadoFenologico.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado_fenologico'],
        )!,
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
    );
  }

  @override
  $DiagnosticosTable createAlias(String alias) {
    return $DiagnosticosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<EstadoFenologico, String, String>
  $converterestadoFenologico = const EnumNameConverter<EstadoFenologico>(
    EstadoFenologico.values,
  );
}

class Diagnostico extends DataClass implements Insertable<Diagnostico> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Sello que puso el servidor la ultima vez que vio esta fila. Es el unico
  /// reloj comparable entre dispositivos: [updatedAt] es el del telefono.
  final DateTime? serverUpdatedAt;
  final SyncStatus syncStatus;

  /// Motivo por el que la ultima subida fallo; null cuando no hay problema.
  final String? syncError;
  final String loteId;
  final DateTime fecha;
  final String? fotoPath;
  final EstadoFenologico estadoFenologico;
  final String? notas;
  const Diagnostico({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverUpdatedAt,
    required this.syncStatus,
    this.syncError,
    required this.loteId,
    required this.fecha,
    this.fotoPath,
    required this.estadoFenologico,
    this.notas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $DiagnosticosTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    {
      map['estado_fenologico'] = Variable<String>(
        $DiagnosticosTable.$converterestadoFenologico.toSql(estadoFenologico),
      );
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    return map;
  }

  DiagnosticosCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      loteId: Value(loteId),
      fecha: Value(fecha),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      estadoFenologico: Value(estadoFenologico),
      notas: notas == null && nullToAbsent
          ? const Value.absent()
          : Value(notas),
    );
  }

  factory Diagnostico.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Diagnostico(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      syncStatus: $DiagnosticosTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      loteId: serializer.fromJson<String>(json['loteId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      estadoFenologico: $DiagnosticosTable.$converterestadoFenologico.fromJson(
        serializer.fromJson<String>(json['estadoFenologico']),
      ),
      notas: serializer.fromJson<String?>(json['notas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'syncStatus': serializer.toJson<String>(
        $DiagnosticosTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'loteId': serializer.toJson<String>(loteId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'estadoFenologico': serializer.toJson<String>(
        $DiagnosticosTable.$converterestadoFenologico.toJson(estadoFenologico),
      ),
      'notas': serializer.toJson<String?>(notas),
    };
  }

  Diagnostico copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> serverUpdatedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    String? loteId,
    DateTime? fecha,
    Value<String?> fotoPath = const Value.absent(),
    EstadoFenologico? estadoFenologico,
    Value<String?> notas = const Value.absent(),
  }) => Diagnostico(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    loteId: loteId ?? this.loteId,
    fecha: fecha ?? this.fecha,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    estadoFenologico: estadoFenologico ?? this.estadoFenologico,
    notas: notas.present ? notas.value : this.notas,
  );
  Diagnostico copyWithCompanion(DiagnosticosCompanion data) {
    return Diagnostico(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      estadoFenologico: data.estadoFenologico.present
          ? data.estadoFenologico.value
          : this.estadoFenologico,
      notas: data.notas.present ? data.notas.value : this.notas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Diagnostico(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('fecha: $fecha, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('estadoFenologico: $estadoFenologico, ')
          ..write('notas: $notas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    serverUpdatedAt,
    syncStatus,
    syncError,
    loteId,
    fecha,
    fotoPath,
    estadoFenologico,
    notas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Diagnostico &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.loteId == this.loteId &&
          other.fecha == this.fecha &&
          other.fotoPath == this.fotoPath &&
          other.estadoFenologico == this.estadoFenologico &&
          other.notas == this.notas);
}

class DiagnosticosCompanion extends UpdateCompanion<Diagnostico> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> serverUpdatedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<String> loteId;
  final Value<DateTime> fecha;
  final Value<String?> fotoPath;
  final Value<EstadoFenologico> estadoFenologico;
  final Value<String?> notas;
  final Value<int> rowid;
  const DiagnosticosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.loteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.estadoFenologico = const Value.absent(),
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosticosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    required String loteId,
    required DateTime fecha,
    this.fotoPath = const Value.absent(),
    required EstadoFenologico estadoFenologico,
    this.notas = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : loteId = Value(loteId),
       fecha = Value(fecha),
       estadoFenologico = Value(estadoFenologico);
  static Insertable<Diagnostico> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? serverUpdatedAt,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? loteId,
    Expression<DateTime>? fecha,
    Expression<String>? fotoPath,
    Expression<String>? estadoFenologico,
    Expression<String>? notas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (loteId != null) 'lote_id': loteId,
      if (fecha != null) 'fecha': fecha,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (estadoFenologico != null) 'estado_fenologico': estadoFenologico,
      if (notas != null) 'notas': notas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosticosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? serverUpdatedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<String>? loteId,
    Value<DateTime>? fecha,
    Value<String?>? fotoPath,
    Value<EstadoFenologico>? estadoFenologico,
    Value<String?>? notas,
    Value<int>? rowid,
  }) {
    return DiagnosticosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      loteId: loteId ?? this.loteId,
      fecha: fecha ?? this.fecha,
      fotoPath: fotoPath ?? this.fotoPath,
      estadoFenologico: estadoFenologico ?? this.estadoFenologico,
      notas: notas ?? this.notas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $DiagnosticosTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (estadoFenologico.present) {
      map['estado_fenologico'] = Variable<String>(
        $DiagnosticosTable.$converterestadoFenologico.toSql(
          estadoFenologico.value,
        ),
      );
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('loteId: $loteId, ')
          ..write('fecha: $fecha, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('estadoFenologico: $estadoFenologico, ')
          ..write('notas: $notas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SesionTable extends Sesion with TableInfo<$SesionTable, SesionLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authUidMeta = const VerificationMeta(
    'authUid',
  );
  @override
  late final GeneratedColumn<String> authUid = GeneratedColumn<String>(
    'auth_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correoMeta = const VerificationMeta('correo');
  @override
  late final GeneratedColumn<String> correo = GeneratedColumn<String>(
    'correo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correoConfirmadoMeta = const VerificationMeta(
    'correoConfirmado',
  );
  @override
  late final GeneratedColumn<bool> correoConfirmado = GeneratedColumn<bool>(
    'correo_confirmado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correo_confirmado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tokenNubeMeta = const VerificationMeta(
    'tokenNube',
  );
  @override
  late final GeneratedColumn<String> tokenNube = GeneratedColumn<String>(
    'token_nube',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descargaInicialMeta = const VerificationMeta(
    'descargaInicial',
  );
  @override
  late final GeneratedColumn<bool> descargaInicial = GeneratedColumn<bool>(
    'descarga_inicial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("descarga_inicial" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    usuarioId,
    authUid,
    correo,
    correoConfirmado,
    tokenNube,
    descargaInicial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesion';
  @override
  VerificationContext validateIntegrity(
    Insertable<SesionLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('auth_uid')) {
      context.handle(
        _authUidMeta,
        authUid.isAcceptableOrUnknown(data['auth_uid']!, _authUidMeta),
      );
    }
    if (data.containsKey('correo')) {
      context.handle(
        _correoMeta,
        correo.isAcceptableOrUnknown(data['correo']!, _correoMeta),
      );
    }
    if (data.containsKey('correo_confirmado')) {
      context.handle(
        _correoConfirmadoMeta,
        correoConfirmado.isAcceptableOrUnknown(
          data['correo_confirmado']!,
          _correoConfirmadoMeta,
        ),
      );
    }
    if (data.containsKey('token_nube')) {
      context.handle(
        _tokenNubeMeta,
        tokenNube.isAcceptableOrUnknown(data['token_nube']!, _tokenNubeMeta),
      );
    }
    if (data.containsKey('descarga_inicial')) {
      context.handle(
        _descargaInicialMeta,
        descargaInicial.isAcceptableOrUnknown(
          data['descarga_inicial']!,
          _descargaInicialMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SesionLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SesionLocal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      authUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_uid'],
      ),
      correo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correo'],
      ),
      correoConfirmado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correo_confirmado'],
      )!,
      tokenNube: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_nube'],
      ),
      descargaInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}descarga_inicial'],
      )!,
    );
  }

  @override
  $SesionTable createAlias(String alias) {
    return $SesionTable(attachedDatabase, alias);
  }
}

class SesionLocal extends DataClass implements Insertable<SesionLocal> {
  final int id;
  final String usuarioId;
  final String? authUid;

  /// Correo de la cuenta, cuando la sesión anónima ya se vinculó a una.
  final String? correo;

  /// ¿El correo de la cuenta ya fue confirmado en el servidor?
  ///
  /// Con la confirmación activada, vincular el correo **no** lo aplica hasta
  /// que la persona abre el enlace del mensaje. Hasta entonces la cuenta no
  /// sirve para entrar desde otro teléfono, y la app no debe decir que los
  /// datos están respaldados.
  final bool correoConfirmado;

  /// Sesión del servidor (no el token de Google).
  ///
  /// El token de Google dura una hora; esta sesión dura meses. Guardarla es lo
  /// que evita tener que pedir la cuenta en cada arranque de la app.
  final String? tokenNube;

  /// ¿Ya terminó la primera descarga tras entrar con una cuenta existente?
  ///
  /// Arranca en `true` porque una instalación normal no espera nada. Solo
  /// `entrarConCuenta` lo pone en `false`: mientras esté así, la app no puede
  /// ofrecer "crear perfil", o el productor acabaría con un productor
  /// duplicado bajo la misma cuenta.
  final bool descargaInicial;
  const SesionLocal({
    required this.id,
    required this.usuarioId,
    this.authUid,
    this.correo,
    required this.correoConfirmado,
    this.tokenNube,
    required this.descargaInicial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['usuario_id'] = Variable<String>(usuarioId);
    if (!nullToAbsent || authUid != null) {
      map['auth_uid'] = Variable<String>(authUid);
    }
    if (!nullToAbsent || correo != null) {
      map['correo'] = Variable<String>(correo);
    }
    map['correo_confirmado'] = Variable<bool>(correoConfirmado);
    if (!nullToAbsent || tokenNube != null) {
      map['token_nube'] = Variable<String>(tokenNube);
    }
    map['descarga_inicial'] = Variable<bool>(descargaInicial);
    return map;
  }

  SesionCompanion toCompanion(bool nullToAbsent) {
    return SesionCompanion(
      id: Value(id),
      usuarioId: Value(usuarioId),
      authUid: authUid == null && nullToAbsent
          ? const Value.absent()
          : Value(authUid),
      correo: correo == null && nullToAbsent
          ? const Value.absent()
          : Value(correo),
      correoConfirmado: Value(correoConfirmado),
      tokenNube: tokenNube == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenNube),
      descargaInicial: Value(descargaInicial),
    );
  }

  factory SesionLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SesionLocal(
      id: serializer.fromJson<int>(json['id']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      authUid: serializer.fromJson<String?>(json['authUid']),
      correo: serializer.fromJson<String?>(json['correo']),
      correoConfirmado: serializer.fromJson<bool>(json['correoConfirmado']),
      tokenNube: serializer.fromJson<String?>(json['tokenNube']),
      descargaInicial: serializer.fromJson<bool>(json['descargaInicial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'authUid': serializer.toJson<String?>(authUid),
      'correo': serializer.toJson<String?>(correo),
      'correoConfirmado': serializer.toJson<bool>(correoConfirmado),
      'tokenNube': serializer.toJson<String?>(tokenNube),
      'descargaInicial': serializer.toJson<bool>(descargaInicial),
    };
  }

  SesionLocal copyWith({
    int? id,
    String? usuarioId,
    Value<String?> authUid = const Value.absent(),
    Value<String?> correo = const Value.absent(),
    bool? correoConfirmado,
    Value<String?> tokenNube = const Value.absent(),
    bool? descargaInicial,
  }) => SesionLocal(
    id: id ?? this.id,
    usuarioId: usuarioId ?? this.usuarioId,
    authUid: authUid.present ? authUid.value : this.authUid,
    correo: correo.present ? correo.value : this.correo,
    correoConfirmado: correoConfirmado ?? this.correoConfirmado,
    tokenNube: tokenNube.present ? tokenNube.value : this.tokenNube,
    descargaInicial: descargaInicial ?? this.descargaInicial,
  );
  SesionLocal copyWithCompanion(SesionCompanion data) {
    return SesionLocal(
      id: data.id.present ? data.id.value : this.id,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      authUid: data.authUid.present ? data.authUid.value : this.authUid,
      correo: data.correo.present ? data.correo.value : this.correo,
      correoConfirmado: data.correoConfirmado.present
          ? data.correoConfirmado.value
          : this.correoConfirmado,
      tokenNube: data.tokenNube.present ? data.tokenNube.value : this.tokenNube,
      descargaInicial: data.descargaInicial.present
          ? data.descargaInicial.value
          : this.descargaInicial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SesionLocal(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('authUid: $authUid, ')
          ..write('correo: $correo, ')
          ..write('correoConfirmado: $correoConfirmado, ')
          ..write('tokenNube: $tokenNube, ')
          ..write('descargaInicial: $descargaInicial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    usuarioId,
    authUid,
    correo,
    correoConfirmado,
    tokenNube,
    descargaInicial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SesionLocal &&
          other.id == this.id &&
          other.usuarioId == this.usuarioId &&
          other.authUid == this.authUid &&
          other.correo == this.correo &&
          other.correoConfirmado == this.correoConfirmado &&
          other.tokenNube == this.tokenNube &&
          other.descargaInicial == this.descargaInicial);
}

class SesionCompanion extends UpdateCompanion<SesionLocal> {
  final Value<int> id;
  final Value<String> usuarioId;
  final Value<String?> authUid;
  final Value<String?> correo;
  final Value<bool> correoConfirmado;
  final Value<String?> tokenNube;
  final Value<bool> descargaInicial;
  const SesionCompanion({
    this.id = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.authUid = const Value.absent(),
    this.correo = const Value.absent(),
    this.correoConfirmado = const Value.absent(),
    this.tokenNube = const Value.absent(),
    this.descargaInicial = const Value.absent(),
  });
  SesionCompanion.insert({
    this.id = const Value.absent(),
    required String usuarioId,
    this.authUid = const Value.absent(),
    this.correo = const Value.absent(),
    this.correoConfirmado = const Value.absent(),
    this.tokenNube = const Value.absent(),
    this.descargaInicial = const Value.absent(),
  }) : usuarioId = Value(usuarioId);
  static Insertable<SesionLocal> custom({
    Expression<int>? id,
    Expression<String>? usuarioId,
    Expression<String>? authUid,
    Expression<String>? correo,
    Expression<bool>? correoConfirmado,
    Expression<String>? tokenNube,
    Expression<bool>? descargaInicial,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (authUid != null) 'auth_uid': authUid,
      if (correo != null) 'correo': correo,
      if (correoConfirmado != null) 'correo_confirmado': correoConfirmado,
      if (tokenNube != null) 'token_nube': tokenNube,
      if (descargaInicial != null) 'descarga_inicial': descargaInicial,
    });
  }

  SesionCompanion copyWith({
    Value<int>? id,
    Value<String>? usuarioId,
    Value<String?>? authUid,
    Value<String?>? correo,
    Value<bool>? correoConfirmado,
    Value<String?>? tokenNube,
    Value<bool>? descargaInicial,
  }) {
    return SesionCompanion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      authUid: authUid ?? this.authUid,
      correo: correo ?? this.correo,
      correoConfirmado: correoConfirmado ?? this.correoConfirmado,
      tokenNube: tokenNube ?? this.tokenNube,
      descargaInicial: descargaInicial ?? this.descargaInicial,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (authUid.present) {
      map['auth_uid'] = Variable<String>(authUid.value);
    }
    if (correo.present) {
      map['correo'] = Variable<String>(correo.value);
    }
    if (correoConfirmado.present) {
      map['correo_confirmado'] = Variable<bool>(correoConfirmado.value);
    }
    if (tokenNube.present) {
      map['token_nube'] = Variable<String>(tokenNube.value);
    }
    if (descargaInicial.present) {
      map['descarga_inicial'] = Variable<bool>(descargaInicial.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionCompanion(')
          ..write('id: $id, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('authUid: $authUid, ')
          ..write('correo: $correo, ')
          ..write('correoConfirmado: $correoConfirmado, ')
          ..write('tokenNube: $tokenNube, ')
          ..write('descargaInicial: $descargaInicial')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, CursorSync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entidadMeta = const VerificationMeta(
    'entidad',
  );
  @override
  late final GeneratedColumn<String> entidad = GeneratedColumn<String>(
    'entidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncIdMeta = const VerificationMeta(
    'lastSyncId',
  );
  @override
  late final GeneratedColumn<String> lastSyncId = GeneratedColumn<String>(
    'last_sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [entidad, lastSyncAt, lastSyncId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CursorSync> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entidad')) {
      context.handle(
        _entidadMeta,
        entidad.isAcceptableOrUnknown(data['entidad']!, _entidadMeta),
      );
    } else if (isInserting) {
      context.missing(_entidadMeta);
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_id')) {
      context.handle(
        _lastSyncIdMeta,
        lastSyncId.isAcceptableOrUnknown(
          data['last_sync_id']!,
          _lastSyncIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entidad};
  @override
  CursorSync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CursorSync(
      entidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      lastSyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_id'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class CursorSync extends DataClass implements Insertable<CursorSync> {
  final String entidad;
  final DateTime? lastSyncAt;
  final String? lastSyncId;
  const CursorSync({required this.entidad, this.lastSyncAt, this.lastSyncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entidad'] = Variable<String>(entidad);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastSyncId != null) {
      map['last_sync_id'] = Variable<String>(lastSyncId);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      entidad: Value(entidad),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastSyncId: lastSyncId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncId),
    );
  }

  factory CursorSync.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CursorSync(
      entidad: serializer.fromJson<String>(json['entidad']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastSyncId: serializer.fromJson<String?>(json['lastSyncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entidad': serializer.toJson<String>(entidad),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastSyncId': serializer.toJson<String?>(lastSyncId),
    };
  }

  CursorSync copyWith({
    String? entidad,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> lastSyncId = const Value.absent(),
  }) => CursorSync(
    entidad: entidad ?? this.entidad,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    lastSyncId: lastSyncId.present ? lastSyncId.value : this.lastSyncId,
  );
  CursorSync copyWithCompanion(SyncMetaCompanion data) {
    return CursorSync(
      entidad: data.entidad.present ? data.entidad.value : this.entidad,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      lastSyncId: data.lastSyncId.present
          ? data.lastSyncId.value
          : this.lastSyncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CursorSync(')
          ..write('entidad: $entidad, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncId: $lastSyncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entidad, lastSyncAt, lastSyncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CursorSync &&
          other.entidad == this.entidad &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastSyncId == this.lastSyncId);
}

class SyncMetaCompanion extends UpdateCompanion<CursorSync> {
  final Value<String> entidad;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> lastSyncId;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.entidad = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSyncId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String entidad,
    this.lastSyncAt = const Value.absent(),
    this.lastSyncId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entidad = Value(entidad);
  static Insertable<CursorSync> custom({
    Expression<String>? entidad,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? lastSyncId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entidad != null) 'entidad': entidad,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastSyncId != null) 'last_sync_id': lastSyncId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? entidad,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? lastSyncId,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      entidad: entidad ?? this.entidad,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncId: lastSyncId ?? this.lastSyncId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entidad.present) {
      map['entidad'] = Variable<String>(entidad.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastSyncId.present) {
      map['last_sync_id'] = Variable<String>(lastSyncId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('entidad: $entidad, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncId: $lastSyncId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AsociacionesTable asociaciones = $AsociacionesTable(this);
  late final $ProductoresTable productores = $ProductoresTable(this);
  late final $FincasTable fincas = $FincasTable(this);
  late final $LotesTable lotes = $LotesTable(this);
  late final $ActividadesAgricolasTable actividadesAgricolas =
      $ActividadesAgricolasTable(this);
  late final $CosechasTable cosechas = $CosechasTable(this);
  late final $DiagnosticosTable diagnosticos = $DiagnosticosTable(this);
  late final $SesionTable sesion = $SesionTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final ProductoresDao productoresDao = ProductoresDao(
    this as AppDatabase,
  );
  late final FincasDao fincasDao = FincasDao(this as AppDatabase);
  late final LotesDao lotesDao = LotesDao(this as AppDatabase);
  late final RegistrosDao registrosDao = RegistrosDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    asociaciones,
    productores,
    fincas,
    lotes,
    actividadesAgricolas,
    cosechas,
    diagnosticos,
    sesion,
    syncMeta,
  ];
}

typedef $$AsociacionesTableCreateCompanionBuilder =
    AsociacionesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      required String nombre,
      required String municipio,
      required String departamento,
      Value<int> rowid,
    });
typedef $$AsociacionesTableUpdateCompanionBuilder =
    AsociacionesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<String> nombre,
      Value<String> municipio,
      Value<String> departamento,
      Value<int> rowid,
    });

final class $$AsociacionesTableReferences
    extends BaseReferences<_$AppDatabase, $AsociacionesTable, Asociacion> {
  $$AsociacionesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductoresTable, List<Productor>>
  _productoresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productores,
    aliasName: 'asociaciones__id__productores__asociacion_id',
  );

  $$ProductoresTableProcessedTableManager get productoresRefs {
    final manager = $$ProductoresTableTableManager(
      $_db,
      $_db.productores,
    ).filter((f) => f.asociacionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productoresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AsociacionesTableFilterComposer
    extends Composer<_$AppDatabase, $AsociacionesTable> {
  $$AsociacionesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get municipio => $composableBuilder(
    column: $table.municipio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productoresRefs(
    Expression<bool> Function($$ProductoresTableFilterComposer f) f,
  ) {
    final $$ProductoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productores,
      getReferencedColumn: (t) => t.asociacionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductoresTableFilterComposer(
            $db: $db,
            $table: $db.productores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AsociacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $AsociacionesTable> {
  $$AsociacionesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get municipio => $composableBuilder(
    column: $table.municipio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AsociacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AsociacionesTable> {
  $$AsociacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get municipio =>
      $composableBuilder(column: $table.municipio, builder: (column) => column);

  GeneratedColumn<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => column,
  );

  Expression<T> productoresRefs<T extends Object>(
    Expression<T> Function($$ProductoresTableAnnotationComposer a) f,
  ) {
    final $$ProductoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productores,
      getReferencedColumn: (t) => t.asociacionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductoresTableAnnotationComposer(
            $db: $db,
            $table: $db.productores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AsociacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AsociacionesTable,
          Asociacion,
          $$AsociacionesTableFilterComposer,
          $$AsociacionesTableOrderingComposer,
          $$AsociacionesTableAnnotationComposer,
          $$AsociacionesTableCreateCompanionBuilder,
          $$AsociacionesTableUpdateCompanionBuilder,
          (Asociacion, $$AsociacionesTableReferences),
          Asociacion,
          PrefetchHooks Function({bool productoresRefs})
        > {
  $$AsociacionesTableTableManager(_$AppDatabase db, $AsociacionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AsociacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AsociacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AsociacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> municipio = const Value.absent(),
                Value<String> departamento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AsociacionesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                nombre: nombre,
                municipio: municipio,
                departamento: departamento,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String nombre,
                required String municipio,
                required String departamento,
                Value<int> rowid = const Value.absent(),
              }) => AsociacionesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                nombre: nombre,
                municipio: municipio,
                departamento: departamento,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AsociacionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productoresRefs) db.productores],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productoresRefs)
                    await $_getPrefetchedData<
                      Asociacion,
                      $AsociacionesTable,
                      Productor
                    >(
                      currentTable: table,
                      referencedTable: $$AsociacionesTableReferences
                          ._productoresRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AsociacionesTableReferences(
                            db,
                            table,
                            p0,
                          ).productoresRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.asociacionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AsociacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AsociacionesTable,
      Asociacion,
      $$AsociacionesTableFilterComposer,
      $$AsociacionesTableOrderingComposer,
      $$AsociacionesTableAnnotationComposer,
      $$AsociacionesTableCreateCompanionBuilder,
      $$AsociacionesTableUpdateCompanionBuilder,
      (Asociacion, $$AsociacionesTableReferences),
      Asociacion,
      PrefetchHooks Function({bool productoresRefs})
    >;
typedef $$ProductoresTableCreateCompanionBuilder =
    ProductoresCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<String?> usuarioId,
      required String nombreCompleto,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> asociacionId,
      Value<TipoDocumento?> tipoDocumento,
      Value<String?> numeroDocumento,
      Value<int> rowid,
    });
typedef $$ProductoresTableUpdateCompanionBuilder =
    ProductoresCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<String?> usuarioId,
      Value<String> nombreCompleto,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> asociacionId,
      Value<TipoDocumento?> tipoDocumento,
      Value<String?> numeroDocumento,
      Value<int> rowid,
    });

final class $$ProductoresTableReferences
    extends BaseReferences<_$AppDatabase, $ProductoresTable, Productor> {
  $$ProductoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AsociacionesTable _asociacionIdTable(_$AppDatabase db) => db
      .asociaciones
      .createAlias('productores__asociacion_id__asociaciones__id');

  $$AsociacionesTableProcessedTableManager? get asociacionId {
    final $_column = $_itemColumn<String>('asociacion_id');
    if ($_column == null) return null;
    final manager = $$AsociacionesTableTableManager(
      $_db,
      $_db.asociaciones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_asociacionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FincasTable, List<Finca>> _fincasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.fincas,
    aliasName: 'productores__id__fincas__productor_id',
  );

  $$FincasTableProcessedTableManager get fincasRefs {
    final manager = $$FincasTableTableManager(
      $_db,
      $_db.fincas,
    ).filter((f) => f.productorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fincasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductoresTableFilterComposer
    extends Composer<_$AppDatabase, $ProductoresTable> {
  $$ProductoresTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoDocumento?, TipoDocumento, String>
  get tipoDocumento => $composableBuilder(
    column: $table.tipoDocumento,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get numeroDocumento => $composableBuilder(
    column: $table.numeroDocumento,
    builder: (column) => ColumnFilters(column),
  );

  $$AsociacionesTableFilterComposer get asociacionId {
    final $$AsociacionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asociacionId,
      referencedTable: $db.asociaciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AsociacionesTableFilterComposer(
            $db: $db,
            $table: $db.asociaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fincasRefs(
    Expression<bool> Function($$FincasTableFilterComposer f) f,
  ) {
    final $$FincasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fincas,
      getReferencedColumn: (t) => t.productorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FincasTableFilterComposer(
            $db: $db,
            $table: $db.fincas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductoresTable> {
  $$ProductoresTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoDocumento => $composableBuilder(
    column: $table.tipoDocumento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroDocumento => $composableBuilder(
    column: $table.numeroDocumento,
    builder: (column) => ColumnOrderings(column),
  );

  $$AsociacionesTableOrderingComposer get asociacionId {
    final $$AsociacionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asociacionId,
      referencedTable: $db.asociaciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AsociacionesTableOrderingComposer(
            $db: $db,
            $table: $db.asociaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductoresTable> {
  $$ProductoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoDocumento?, String> get tipoDocumento =>
      $composableBuilder(
        column: $table.tipoDocumento,
        builder: (column) => column,
      );

  GeneratedColumn<String> get numeroDocumento => $composableBuilder(
    column: $table.numeroDocumento,
    builder: (column) => column,
  );

  $$AsociacionesTableAnnotationComposer get asociacionId {
    final $$AsociacionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asociacionId,
      referencedTable: $db.asociaciones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AsociacionesTableAnnotationComposer(
            $db: $db,
            $table: $db.asociaciones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fincasRefs<T extends Object>(
    Expression<T> Function($$FincasTableAnnotationComposer a) f,
  ) {
    final $$FincasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fincas,
      getReferencedColumn: (t) => t.productorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FincasTableAnnotationComposer(
            $db: $db,
            $table: $db.fincas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductoresTable,
          Productor,
          $$ProductoresTableFilterComposer,
          $$ProductoresTableOrderingComposer,
          $$ProductoresTableAnnotationComposer,
          $$ProductoresTableCreateCompanionBuilder,
          $$ProductoresTableUpdateCompanionBuilder,
          (Productor, $$ProductoresTableReferences),
          Productor,
          PrefetchHooks Function({bool asociacionId, bool fincasRefs})
        > {
  $$ProductoresTableTableManager(_$AppDatabase db, $ProductoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String?> usuarioId = const Value.absent(),
                Value<String> nombreCompleto = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> asociacionId = const Value.absent(),
                Value<TipoDocumento?> tipoDocumento = const Value.absent(),
                Value<String?> numeroDocumento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductoresCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                usuarioId: usuarioId,
                nombreCompleto: nombreCompleto,
                telefono: telefono,
                email: email,
                asociacionId: asociacionId,
                tipoDocumento: tipoDocumento,
                numeroDocumento: numeroDocumento,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String?> usuarioId = const Value.absent(),
                required String nombreCompleto,
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> asociacionId = const Value.absent(),
                Value<TipoDocumento?> tipoDocumento = const Value.absent(),
                Value<String?> numeroDocumento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductoresCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                usuarioId: usuarioId,
                nombreCompleto: nombreCompleto,
                telefono: telefono,
                email: email,
                asociacionId: asociacionId,
                tipoDocumento: tipoDocumento,
                numeroDocumento: numeroDocumento,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({asociacionId = false, fincasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fincasRefs) db.fincas],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (asociacionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.asociacionId,
                        referencedTable: $$ProductoresTableReferences
                            ._asociacionIdTable(db),
                        referencedColumn: $$ProductoresTableReferences
                            ._asociacionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fincasRefs)
                    await $_getPrefetchedData<
                      Productor,
                      $ProductoresTable,
                      Finca
                    >(
                      currentTable: table,
                      referencedTable: $$ProductoresTableReferences
                          ._fincasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProductoresTableReferences(
                            db,
                            table,
                            p0,
                          ).fincasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.productorId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProductoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductoresTable,
      Productor,
      $$ProductoresTableFilterComposer,
      $$ProductoresTableOrderingComposer,
      $$ProductoresTableAnnotationComposer,
      $$ProductoresTableCreateCompanionBuilder,
      $$ProductoresTableUpdateCompanionBuilder,
      (Productor, $$ProductoresTableReferences),
      Productor,
      PrefetchHooks Function({bool asociacionId, bool fincasRefs})
    >;
typedef $$FincasTableCreateCompanionBuilder = FincasCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  required String productorId,
  required String nombre,
  Value<double?> latitud,
  Value<double?> longitud,
  required String municipio,
  required String departamento,
  Value<int> rowid,
});
typedef $$FincasTableUpdateCompanionBuilder = FincasCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  Value<String> productorId,
  Value<String> nombre,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<String> municipio,
  Value<String> departamento,
  Value<int> rowid,
});

final class $$FincasTableReferences
    extends BaseReferences<_$AppDatabase, $FincasTable, Finca> {
  $$FincasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductoresTable _productorIdTable(_$AppDatabase db) =>
      db.productores.createAlias('fincas__productor_id__productores__id');

  $$ProductoresTableProcessedTableManager get productorId {
    final $_column = $_itemColumn<String>('productor_id')!;

    final manager = $$ProductoresTableTableManager(
      $_db,
      $_db.productores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LotesTable, List<Lote>> _lotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.lotes,
    aliasName: 'fincas__id__lotes__finca_id',
  );

  $$LotesTableProcessedTableManager get lotesRefs {
    final manager = $$LotesTableTableManager(
      $_db,
      $_db.lotes,
    ).filter((f) => f.fincaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FincasTableFilterComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get municipio => $composableBuilder(
    column: $table.municipio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductoresTableFilterComposer get productorId {
    final $$ProductoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productorId,
      referencedTable: $db.productores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductoresTableFilterComposer(
            $db: $db,
            $table: $db.productores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lotesRefs(
    Expression<bool> Function($$LotesTableFilterComposer f) f,
  ) {
    final $$LotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.fincaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableFilterComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FincasTableOrderingComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get municipio => $composableBuilder(
    column: $table.municipio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductoresTableOrderingComposer get productorId {
    final $$ProductoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productorId,
      referencedTable: $db.productores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductoresTableOrderingComposer(
            $db: $db,
            $table: $db.productores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FincasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FincasTable> {
  $$FincasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<String> get municipio =>
      $composableBuilder(column: $table.municipio, builder: (column) => column);

  GeneratedColumn<String> get departamento => $composableBuilder(
    column: $table.departamento,
    builder: (column) => column,
  );

  $$ProductoresTableAnnotationComposer get productorId {
    final $$ProductoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productorId,
      referencedTable: $db.productores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductoresTableAnnotationComposer(
            $db: $db,
            $table: $db.productores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lotesRefs<T extends Object>(
    Expression<T> Function($$LotesTableAnnotationComposer a) f,
  ) {
    final $$LotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.fincaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableAnnotationComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FincasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FincasTable,
          Finca,
          $$FincasTableFilterComposer,
          $$FincasTableOrderingComposer,
          $$FincasTableAnnotationComposer,
          $$FincasTableCreateCompanionBuilder,
          $$FincasTableUpdateCompanionBuilder,
          (Finca, $$FincasTableReferences),
          Finca,
          PrefetchHooks Function({bool productorId, bool lotesRefs})
        > {
  $$FincasTableTableManager(_$AppDatabase db, $FincasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FincasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FincasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FincasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> productorId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<String> municipio = const Value.absent(),
                Value<String> departamento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FincasCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                productorId: productorId,
                nombre: nombre,
                latitud: latitud,
                longitud: longitud,
                municipio: municipio,
                departamento: departamento,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String productorId,
                required String nombre,
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                required String municipio,
                required String departamento,
                Value<int> rowid = const Value.absent(),
              }) => FincasCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                productorId: productorId,
                nombre: nombre,
                latitud: latitud,
                longitud: longitud,
                municipio: municipio,
                departamento: departamento,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FincasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({productorId = false, lotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lotesRefs) db.lotes],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productorId,
                        referencedTable: $$FincasTableReferences
                            ._productorIdTable(db),
                        referencedColumn: $$FincasTableReferences
                            ._productorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lotesRefs)
                    await $_getPrefetchedData<Finca, $FincasTable, Lote>(
                      currentTable: table,
                      referencedTable: $$FincasTableReferences._lotesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$FincasTableReferences(db, table, p0).lotesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.fincaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FincasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FincasTable,
      Finca,
      $$FincasTableFilterComposer,
      $$FincasTableOrderingComposer,
      $$FincasTableAnnotationComposer,
      $$FincasTableCreateCompanionBuilder,
      $$FincasTableUpdateCompanionBuilder,
      (Finca, $$FincasTableReferences),
      Finca,
      PrefetchHooks Function({bool productorId, bool lotesRefs})
    >;
typedef $$LotesTableCreateCompanionBuilder = LotesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  required String fincaId,
  required String nombre,
  required double areaSembradaHa,
  Value<String> codigo,
  required String variedadCacao,
  required DateTime fechaSiembra,
  Value<int> rowid,
});
typedef $$LotesTableUpdateCompanionBuilder = LotesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  Value<String> fincaId,
  Value<String> nombre,
  Value<double> areaSembradaHa,
  Value<String> codigo,
  Value<String> variedadCacao,
  Value<DateTime> fechaSiembra,
  Value<int> rowid,
});

final class $$LotesTableReferences
    extends BaseReferences<_$AppDatabase, $LotesTable, Lote> {
  $$LotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FincasTable _fincaIdTable(_$AppDatabase db) =>
      db.fincas.createAlias('lotes__finca_id__fincas__id');

  $$FincasTableProcessedTableManager get fincaId {
    final $_column = $_itemColumn<String>('finca_id')!;

    final manager = $$FincasTableTableManager(
      $_db,
      $_db.fincas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fincaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ActividadesAgricolasTable,
    List<ActividadAgricola>
  >
  _actividadesAgricolasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.actividadesAgricolas,
        aliasName: 'lotes__id__actividades_agricolas__lote_id',
      );

  $$ActividadesAgricolasTableProcessedTableManager
  get actividadesAgricolasRefs {
    final manager = $$ActividadesAgricolasTableTableManager(
      $_db,
      $_db.actividadesAgricolas,
    ).filter((f) => f.loteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _actividadesAgricolasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CosechasTable, List<Cosecha>> _cosechasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cosechas,
    aliasName: 'lotes__id__cosechas__lote_id',
  );

  $$CosechasTableProcessedTableManager get cosechasRefs {
    final manager = $$CosechasTableTableManager(
      $_db,
      $_db.cosechas,
    ).filter((f) => f.loteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cosechasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DiagnosticosTable, List<Diagnostico>>
  _diagnosticosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diagnosticos,
    aliasName: 'lotes__id__diagnosticos__lote_id',
  );

  $$DiagnosticosTableProcessedTableManager get diagnosticosRefs {
    final manager = $$DiagnosticosTableTableManager(
      $_db,
      $_db.diagnosticos,
    ).filter((f) => f.loteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosticosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LotesTableFilterComposer extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaSembradaHa => $composableBuilder(
    column: $table.areaSembradaHa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variedadCacao => $composableBuilder(
    column: $table.variedadCacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaSiembra => $composableBuilder(
    column: $table.fechaSiembra,
    builder: (column) => ColumnFilters(column),
  );

  $$FincasTableFilterComposer get fincaId {
    final $$FincasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fincaId,
      referencedTable: $db.fincas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FincasTableFilterComposer(
            $db: $db,
            $table: $db.fincas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> actividadesAgricolasRefs(
    Expression<bool> Function($$ActividadesAgricolasTableFilterComposer f) f,
  ) {
    final $$ActividadesAgricolasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actividadesAgricolas,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActividadesAgricolasTableFilterComposer(
            $db: $db,
            $table: $db.actividadesAgricolas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cosechasRefs(
    Expression<bool> Function($$CosechasTableFilterComposer f) f,
  ) {
    final $$CosechasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cosechas,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CosechasTableFilterComposer(
            $db: $db,
            $table: $db.cosechas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> diagnosticosRefs(
    Expression<bool> Function($$DiagnosticosTableFilterComposer f) f,
  ) {
    final $$DiagnosticosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnosticos,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosticosTableFilterComposer(
            $db: $db,
            $table: $db.diagnosticos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaSembradaHa => $composableBuilder(
    column: $table.areaSembradaHa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variedadCacao => $composableBuilder(
    column: $table.variedadCacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaSiembra => $composableBuilder(
    column: $table.fechaSiembra,
    builder: (column) => ColumnOrderings(column),
  );

  $$FincasTableOrderingComposer get fincaId {
    final $$FincasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fincaId,
      referencedTable: $db.fincas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FincasTableOrderingComposer(
            $db: $db,
            $table: $db.fincas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get areaSembradaHa => $composableBuilder(
    column: $table.areaSembradaHa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get variedadCacao => $composableBuilder(
    column: $table.variedadCacao,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaSiembra => $composableBuilder(
    column: $table.fechaSiembra,
    builder: (column) => column,
  );

  $$FincasTableAnnotationComposer get fincaId {
    final $$FincasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fincaId,
      referencedTable: $db.fincas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FincasTableAnnotationComposer(
            $db: $db,
            $table: $db.fincas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> actividadesAgricolasRefs<T extends Object>(
    Expression<T> Function($$ActividadesAgricolasTableAnnotationComposer a) f,
  ) {
    final $$ActividadesAgricolasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.actividadesAgricolas,
          getReferencedColumn: (t) => t.loteId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActividadesAgricolasTableAnnotationComposer(
                $db: $db,
                $table: $db.actividadesAgricolas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cosechasRefs<T extends Object>(
    Expression<T> Function($$CosechasTableAnnotationComposer a) f,
  ) {
    final $$CosechasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cosechas,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CosechasTableAnnotationComposer(
            $db: $db,
            $table: $db.cosechas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> diagnosticosRefs<T extends Object>(
    Expression<T> Function($$DiagnosticosTableAnnotationComposer a) f,
  ) {
    final $$DiagnosticosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diagnosticos,
      getReferencedColumn: (t) => t.loteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiagnosticosTableAnnotationComposer(
            $db: $db,
            $table: $db.diagnosticos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesTable,
          Lote,
          $$LotesTableFilterComposer,
          $$LotesTableOrderingComposer,
          $$LotesTableAnnotationComposer,
          $$LotesTableCreateCompanionBuilder,
          $$LotesTableUpdateCompanionBuilder,
          (Lote, $$LotesTableReferences),
          Lote,
          PrefetchHooks Function({
            bool fincaId,
            bool actividadesAgricolasRefs,
            bool cosechasRefs,
            bool diagnosticosRefs,
          })
        > {
  $$LotesTableTableManager(_$AppDatabase db, $LotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> fincaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> areaSembradaHa = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String> variedadCacao = const Value.absent(),
                Value<DateTime> fechaSiembra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                fincaId: fincaId,
                nombre: nombre,
                areaSembradaHa: areaSembradaHa,
                codigo: codigo,
                variedadCacao: variedadCacao,
                fechaSiembra: fechaSiembra,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String fincaId,
                required String nombre,
                required double areaSembradaHa,
                Value<String> codigo = const Value.absent(),
                required String variedadCacao,
                required DateTime fechaSiembra,
                Value<int> rowid = const Value.absent(),
              }) => LotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                fincaId: fincaId,
                nombre: nombre,
                areaSembradaHa: areaSembradaHa,
                codigo: codigo,
                variedadCacao: variedadCacao,
                fechaSiembra: fechaSiembra,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fincaId = false,
                actividadesAgricolasRefs = false,
                cosechasRefs = false,
                diagnosticosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (actividadesAgricolasRefs) db.actividadesAgricolas,
                    if (cosechasRefs) db.cosechas,
                    if (diagnosticosRefs) db.diagnosticos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fincaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fincaId,
                            referencedTable: $$LotesTableReferences
                                ._fincaIdTable(db),
                            referencedColumn: $$LotesTableReferences
                                ._fincaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (actividadesAgricolasRefs)
                        await $_getPrefetchedData<
                          Lote,
                          $LotesTable,
                          ActividadAgricola
                        >(
                          currentTable: table,
                          referencedTable: $$LotesTableReferences
                              ._actividadesAgricolasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotesTableReferences(
                                db,
                                table,
                                p0,
                              ).actividadesAgricolasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.loteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cosechasRefs)
                        await $_getPrefetchedData<Lote, $LotesTable, Cosecha>(
                          currentTable: table,
                          referencedTable: $$LotesTableReferences
                              ._cosechasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotesTableReferences(
                                db,
                                table,
                                p0,
                              ).cosechasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.loteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (diagnosticosRefs)
                        await $_getPrefetchedData<
                          Lote,
                          $LotesTable,
                          Diagnostico
                        >(
                          currentTable: table,
                          referencedTable: $$LotesTableReferences
                              ._diagnosticosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotesTableReferences(
                                db,
                                table,
                                p0,
                              ).diagnosticosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.loteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesTable,
      Lote,
      $$LotesTableFilterComposer,
      $$LotesTableOrderingComposer,
      $$LotesTableAnnotationComposer,
      $$LotesTableCreateCompanionBuilder,
      $$LotesTableUpdateCompanionBuilder,
      (Lote, $$LotesTableReferences),
      Lote,
      PrefetchHooks Function({
        bool fincaId,
        bool actividadesAgricolasRefs,
        bool cosechasRefs,
        bool diagnosticosRefs,
      })
    >;
typedef $$ActividadesAgricolasTableCreateCompanionBuilder =
    ActividadesAgricolasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      required String loteId,
      required TipoActividad tipoActividad,
      required DateTime fecha,
      Value<String?> observaciones,
      Value<String?> responsable,
      Value<double?> costo,
      Value<String?> fotoPath,
      Value<String?> subtipoLabor,
      Value<String?> producto,
      Value<String?> cantidadAplicada,
      Value<String?> incidencia,
      Value<int?> arbolesAfectados,
      Value<int?> edadCultivoAnios,
      Value<int?> arbolesSembrados,
      Value<int?> edadPlantulaMeses,
      Value<String?> insumos,
      Value<String?> resultadoEsperado,
      Value<int> rowid,
    });
typedef $$ActividadesAgricolasTableUpdateCompanionBuilder =
    ActividadesAgricolasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<String> loteId,
      Value<TipoActividad> tipoActividad,
      Value<DateTime> fecha,
      Value<String?> observaciones,
      Value<String?> responsable,
      Value<double?> costo,
      Value<String?> fotoPath,
      Value<String?> subtipoLabor,
      Value<String?> producto,
      Value<String?> cantidadAplicada,
      Value<String?> incidencia,
      Value<int?> arbolesAfectados,
      Value<int?> edadCultivoAnios,
      Value<int?> arbolesSembrados,
      Value<int?> edadPlantulaMeses,
      Value<String?> insumos,
      Value<String?> resultadoEsperado,
      Value<int> rowid,
    });

final class $$ActividadesAgricolasTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActividadesAgricolasTable,
          ActividadAgricola
        > {
  $$ActividadesAgricolasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LotesTable _loteIdTable(_$AppDatabase db) =>
      db.lotes.createAlias('actividades_agricolas__lote_id__lotes__id');

  $$LotesTableProcessedTableManager get loteId {
    final $_column = $_itemColumn<String>('lote_id')!;

    final manager = $$LotesTableTableManager(
      $_db,
      $_db.lotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActividadesAgricolasTableFilterComposer
    extends Composer<_$AppDatabase, $ActividadesAgricolasTable> {
  $$ActividadesAgricolasTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoActividad, TipoActividad, String>
  get tipoActividad => $composableBuilder(
    column: $table.tipoActividad,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtipoLabor => $composableBuilder(
    column: $table.subtipoLabor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cantidadAplicada => $composableBuilder(
    column: $table.cantidadAplicada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incidencia => $composableBuilder(
    column: $table.incidencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arbolesAfectados => $composableBuilder(
    column: $table.arbolesAfectados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edadCultivoAnios => $composableBuilder(
    column: $table.edadCultivoAnios,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arbolesSembrados => $composableBuilder(
    column: $table.arbolesSembrados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edadPlantulaMeses => $composableBuilder(
    column: $table.edadPlantulaMeses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insumos => $composableBuilder(
    column: $table.insumos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultadoEsperado => $composableBuilder(
    column: $table.resultadoEsperado,
    builder: (column) => ColumnFilters(column),
  );

  $$LotesTableFilterComposer get loteId {
    final $$LotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableFilterComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActividadesAgricolasTableOrderingComposer
    extends Composer<_$AppDatabase, $ActividadesAgricolasTable> {
  $$ActividadesAgricolasTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoActividad => $composableBuilder(
    column: $table.tipoActividad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costo => $composableBuilder(
    column: $table.costo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtipoLabor => $composableBuilder(
    column: $table.subtipoLabor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cantidadAplicada => $composableBuilder(
    column: $table.cantidadAplicada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incidencia => $composableBuilder(
    column: $table.incidencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arbolesAfectados => $composableBuilder(
    column: $table.arbolesAfectados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edadCultivoAnios => $composableBuilder(
    column: $table.edadCultivoAnios,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arbolesSembrados => $composableBuilder(
    column: $table.arbolesSembrados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edadPlantulaMeses => $composableBuilder(
    column: $table.edadPlantulaMeses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insumos => $composableBuilder(
    column: $table.insumos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultadoEsperado => $composableBuilder(
    column: $table.resultadoEsperado,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotesTableOrderingComposer get loteId {
    final $$LotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableOrderingComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActividadesAgricolasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActividadesAgricolasTable> {
  $$ActividadesAgricolasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoActividad, String> get tipoActividad =>
      $composableBuilder(
        column: $table.tipoActividad,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responsable => $composableBuilder(
    column: $table.responsable,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<String> get subtipoLabor => $composableBuilder(
    column: $table.subtipoLabor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumn<String> get cantidadAplicada => $composableBuilder(
    column: $table.cantidadAplicada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incidencia => $composableBuilder(
    column: $table.incidencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arbolesAfectados => $composableBuilder(
    column: $table.arbolesAfectados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get edadCultivoAnios => $composableBuilder(
    column: $table.edadCultivoAnios,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arbolesSembrados => $composableBuilder(
    column: $table.arbolesSembrados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get edadPlantulaMeses => $composableBuilder(
    column: $table.edadPlantulaMeses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insumos =>
      $composableBuilder(column: $table.insumos, builder: (column) => column);

  GeneratedColumn<String> get resultadoEsperado => $composableBuilder(
    column: $table.resultadoEsperado,
    builder: (column) => column,
  );

  $$LotesTableAnnotationComposer get loteId {
    final $$LotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableAnnotationComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActividadesAgricolasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActividadesAgricolasTable,
          ActividadAgricola,
          $$ActividadesAgricolasTableFilterComposer,
          $$ActividadesAgricolasTableOrderingComposer,
          $$ActividadesAgricolasTableAnnotationComposer,
          $$ActividadesAgricolasTableCreateCompanionBuilder,
          $$ActividadesAgricolasTableUpdateCompanionBuilder,
          (ActividadAgricola, $$ActividadesAgricolasTableReferences),
          ActividadAgricola,
          PrefetchHooks Function({bool loteId})
        > {
  $$ActividadesAgricolasTableTableManager(
    _$AppDatabase db,
    $ActividadesAgricolasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActividadesAgricolasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActividadesAgricolasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActividadesAgricolasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<TipoActividad> tipoActividad = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String?> responsable = const Value.absent(),
                Value<double?> costo = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String?> subtipoLabor = const Value.absent(),
                Value<String?> producto = const Value.absent(),
                Value<String?> cantidadAplicada = const Value.absent(),
                Value<String?> incidencia = const Value.absent(),
                Value<int?> arbolesAfectados = const Value.absent(),
                Value<int?> edadCultivoAnios = const Value.absent(),
                Value<int?> arbolesSembrados = const Value.absent(),
                Value<int?> edadPlantulaMeses = const Value.absent(),
                Value<String?> insumos = const Value.absent(),
                Value<String?> resultadoEsperado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActividadesAgricolasCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                tipoActividad: tipoActividad,
                fecha: fecha,
                observaciones: observaciones,
                responsable: responsable,
                costo: costo,
                fotoPath: fotoPath,
                subtipoLabor: subtipoLabor,
                producto: producto,
                cantidadAplicada: cantidadAplicada,
                incidencia: incidencia,
                arbolesAfectados: arbolesAfectados,
                edadCultivoAnios: edadCultivoAnios,
                arbolesSembrados: arbolesSembrados,
                edadPlantulaMeses: edadPlantulaMeses,
                insumos: insumos,
                resultadoEsperado: resultadoEsperado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String loteId,
                required TipoActividad tipoActividad,
                required DateTime fecha,
                Value<String?> observaciones = const Value.absent(),
                Value<String?> responsable = const Value.absent(),
                Value<double?> costo = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String?> subtipoLabor = const Value.absent(),
                Value<String?> producto = const Value.absent(),
                Value<String?> cantidadAplicada = const Value.absent(),
                Value<String?> incidencia = const Value.absent(),
                Value<int?> arbolesAfectados = const Value.absent(),
                Value<int?> edadCultivoAnios = const Value.absent(),
                Value<int?> arbolesSembrados = const Value.absent(),
                Value<int?> edadPlantulaMeses = const Value.absent(),
                Value<String?> insumos = const Value.absent(),
                Value<String?> resultadoEsperado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActividadesAgricolasCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                tipoActividad: tipoActividad,
                fecha: fecha,
                observaciones: observaciones,
                responsable: responsable,
                costo: costo,
                fotoPath: fotoPath,
                subtipoLabor: subtipoLabor,
                producto: producto,
                cantidadAplicada: cantidadAplicada,
                incidencia: incidencia,
                arbolesAfectados: arbolesAfectados,
                edadCultivoAnios: edadCultivoAnios,
                arbolesSembrados: arbolesSembrados,
                edadPlantulaMeses: edadPlantulaMeses,
                insumos: insumos,
                resultadoEsperado: resultadoEsperado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActividadesAgricolasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (loteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.loteId,
                        referencedTable: $$ActividadesAgricolasTableReferences
                            ._loteIdTable(db),
                        referencedColumn: $$ActividadesAgricolasTableReferences
                            ._loteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActividadesAgricolasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActividadesAgricolasTable,
      ActividadAgricola,
      $$ActividadesAgricolasTableFilterComposer,
      $$ActividadesAgricolasTableOrderingComposer,
      $$ActividadesAgricolasTableAnnotationComposer,
      $$ActividadesAgricolasTableCreateCompanionBuilder,
      $$ActividadesAgricolasTableUpdateCompanionBuilder,
      (ActividadAgricola, $$ActividadesAgricolasTableReferences),
      ActividadAgricola,
      PrefetchHooks Function({bool loteId})
    >;
typedef $$CosechasTableCreateCompanionBuilder = CosechasCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  required String loteId,
  required DateTime fecha,
  required double cantidadKg,
  Value<String?> observaciones,
  Value<String?> tipoProducto,
  Value<String?> fotoPath,
  Value<int> rowid,
});
typedef $$CosechasTableUpdateCompanionBuilder = CosechasCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> serverUpdatedAt,
  Value<SyncStatus> syncStatus,
  Value<String?> syncError,
  Value<String> loteId,
  Value<DateTime> fecha,
  Value<double> cantidadKg,
  Value<String?> observaciones,
  Value<String?> tipoProducto,
  Value<String?> fotoPath,
  Value<int> rowid,
});

final class $$CosechasTableReferences
    extends BaseReferences<_$AppDatabase, $CosechasTable, Cosecha> {
  $$CosechasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotesTable _loteIdTable(_$AppDatabase db) =>
      db.lotes.createAlias('cosechas__lote_id__lotes__id');

  $$LotesTableProcessedTableManager get loteId {
    final $_column = $_itemColumn<String>('lote_id')!;

    final manager = $$LotesTableTableManager(
      $_db,
      $_db.lotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CosechasTableFilterComposer
    extends Composer<_$AppDatabase, $CosechasTable> {
  $$CosechasTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidadKg => $composableBuilder(
    column: $table.cantidadKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  $$LotesTableFilterComposer get loteId {
    final $$LotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableFilterComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CosechasTableOrderingComposer
    extends Composer<_$AppDatabase, $CosechasTable> {
  $$CosechasTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidadKg => $composableBuilder(
    column: $table.cantidadKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotesTableOrderingComposer get loteId {
    final $$LotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableOrderingComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CosechasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CosechasTable> {
  $$CosechasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get cantidadKg => $composableBuilder(
    column: $table.cantidadKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoProducto => $composableBuilder(
    column: $table.tipoProducto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  $$LotesTableAnnotationComposer get loteId {
    final $$LotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableAnnotationComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CosechasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CosechasTable,
          Cosecha,
          $$CosechasTableFilterComposer,
          $$CosechasTableOrderingComposer,
          $$CosechasTableAnnotationComposer,
          $$CosechasTableCreateCompanionBuilder,
          $$CosechasTableUpdateCompanionBuilder,
          (Cosecha, $$CosechasTableReferences),
          Cosecha,
          PrefetchHooks Function({bool loteId})
        > {
  $$CosechasTableTableManager(_$AppDatabase db, $CosechasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CosechasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CosechasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CosechasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> cantidadKg = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String?> tipoProducto = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CosechasCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                fecha: fecha,
                cantidadKg: cantidadKg,
                observaciones: observaciones,
                tipoProducto: tipoProducto,
                fotoPath: fotoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String loteId,
                required DateTime fecha,
                required double cantidadKg,
                Value<String?> observaciones = const Value.absent(),
                Value<String?> tipoProducto = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CosechasCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                fecha: fecha,
                cantidadKg: cantidadKg,
                observaciones: observaciones,
                tipoProducto: tipoProducto,
                fotoPath: fotoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CosechasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (loteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.loteId,
                        referencedTable: $$CosechasTableReferences._loteIdTable(
                          db,
                        ),
                        referencedColumn: $$CosechasTableReferences
                            ._loteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CosechasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CosechasTable,
      Cosecha,
      $$CosechasTableFilterComposer,
      $$CosechasTableOrderingComposer,
      $$CosechasTableAnnotationComposer,
      $$CosechasTableCreateCompanionBuilder,
      $$CosechasTableUpdateCompanionBuilder,
      (Cosecha, $$CosechasTableReferences),
      Cosecha,
      PrefetchHooks Function({bool loteId})
    >;
typedef $$DiagnosticosTableCreateCompanionBuilder =
    DiagnosticosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      required String loteId,
      required DateTime fecha,
      Value<String?> fotoPath,
      required EstadoFenologico estadoFenologico,
      Value<String?> notas,
      Value<int> rowid,
    });
typedef $$DiagnosticosTableUpdateCompanionBuilder =
    DiagnosticosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> serverUpdatedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<String> loteId,
      Value<DateTime> fecha,
      Value<String?> fotoPath,
      Value<EstadoFenologico> estadoFenologico,
      Value<String?> notas,
      Value<int> rowid,
    });

final class $$DiagnosticosTableReferences
    extends BaseReferences<_$AppDatabase, $DiagnosticosTable, Diagnostico> {
  $$DiagnosticosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotesTable _loteIdTable(_$AppDatabase db) =>
      db.lotes.createAlias('diagnosticos__lote_id__lotes__id');

  $$LotesTableProcessedTableManager get loteId {
    final $_column = $_itemColumn<String>('lote_id')!;

    final manager = $$LotesTableTableManager(
      $_db,
      $_db.lotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiagnosticosTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosticosTable> {
  $$DiagnosticosTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoFenologico, EstadoFenologico, String>
  get estadoFenologico => $composableBuilder(
    column: $table.estadoFenologico,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  $$LotesTableFilterComposer get loteId {
    final $$LotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableFilterComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosticosTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosticosTable> {
  $$DiagnosticosTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoFenologico => $composableBuilder(
    column: $table.estadoFenologico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotesTableOrderingComposer get loteId {
    final $$LotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableOrderingComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosticosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosticosTable> {
  $$DiagnosticosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstadoFenologico, String>
  get estadoFenologico => $composableBuilder(
    column: $table.estadoFenologico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  $$LotesTableAnnotationComposer get loteId {
    final $$LotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loteId,
      referencedTable: $db.lotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotesTableAnnotationComposer(
            $db: $db,
            $table: $db.lotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiagnosticosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiagnosticosTable,
          Diagnostico,
          $$DiagnosticosTableFilterComposer,
          $$DiagnosticosTableOrderingComposer,
          $$DiagnosticosTableAnnotationComposer,
          $$DiagnosticosTableCreateCompanionBuilder,
          $$DiagnosticosTableUpdateCompanionBuilder,
          (Diagnostico, $$DiagnosticosTableReferences),
          Diagnostico,
          PrefetchHooks Function({bool loteId})
        > {
  $$DiagnosticosTableTableManager(_$AppDatabase db, $DiagnosticosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<String> loteId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<EstadoFenologico> estadoFenologico = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                fecha: fecha,
                fotoPath: fotoPath,
                estadoFenologico: estadoFenologico,
                notas: notas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> serverUpdatedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                required String loteId,
                required DateTime fecha,
                Value<String?> fotoPath = const Value.absent(),
                required EstadoFenologico estadoFenologico,
                Value<String?> notas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverUpdatedAt: serverUpdatedAt,
                syncStatus: syncStatus,
                syncError: syncError,
                loteId: loteId,
                fecha: fecha,
                fotoPath: fotoPath,
                estadoFenologico: estadoFenologico,
                notas: notas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DiagnosticosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (loteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.loteId,
                        referencedTable: $$DiagnosticosTableReferences
                            ._loteIdTable(db),
                        referencedColumn: $$DiagnosticosTableReferences
                            ._loteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiagnosticosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiagnosticosTable,
      Diagnostico,
      $$DiagnosticosTableFilterComposer,
      $$DiagnosticosTableOrderingComposer,
      $$DiagnosticosTableAnnotationComposer,
      $$DiagnosticosTableCreateCompanionBuilder,
      $$DiagnosticosTableUpdateCompanionBuilder,
      (Diagnostico, $$DiagnosticosTableReferences),
      Diagnostico,
      PrefetchHooks Function({bool loteId})
    >;
typedef $$SesionTableCreateCompanionBuilder = SesionCompanion Function({
  Value<int> id,
  required String usuarioId,
  Value<String?> authUid,
  Value<String?> correo,
  Value<bool> correoConfirmado,
  Value<String?> tokenNube,
  Value<bool> descargaInicial,
});
typedef $$SesionTableUpdateCompanionBuilder = SesionCompanion Function({
  Value<int> id,
  Value<String> usuarioId,
  Value<String?> authUid,
  Value<String?> correo,
  Value<bool> correoConfirmado,
  Value<String?> tokenNube,
  Value<bool> descargaInicial,
});

class $$SesionTableFilterComposer
    extends Composer<_$AppDatabase, $SesionTable> {
  $$SesionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authUid => $composableBuilder(
    column: $table.authUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correo => $composableBuilder(
    column: $table.correo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correoConfirmado => $composableBuilder(
    column: $table.correoConfirmado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenNube => $composableBuilder(
    column: $table.tokenNube,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get descargaInicial => $composableBuilder(
    column: $table.descargaInicial,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SesionTableOrderingComposer
    extends Composer<_$AppDatabase, $SesionTable> {
  $$SesionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authUid => $composableBuilder(
    column: $table.authUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correo => $composableBuilder(
    column: $table.correo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correoConfirmado => $composableBuilder(
    column: $table.correoConfirmado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenNube => $composableBuilder(
    column: $table.tokenNube,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get descargaInicial => $composableBuilder(
    column: $table.descargaInicial,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SesionTableAnnotationComposer
    extends Composer<_$AppDatabase, $SesionTable> {
  $$SesionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get authUid =>
      $composableBuilder(column: $table.authUid, builder: (column) => column);

  GeneratedColumn<String> get correo =>
      $composableBuilder(column: $table.correo, builder: (column) => column);

  GeneratedColumn<bool> get correoConfirmado => $composableBuilder(
    column: $table.correoConfirmado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tokenNube =>
      $composableBuilder(column: $table.tokenNube, builder: (column) => column);

  GeneratedColumn<bool> get descargaInicial => $composableBuilder(
    column: $table.descargaInicial,
    builder: (column) => column,
  );
}

class $$SesionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SesionTable,
          SesionLocal,
          $$SesionTableFilterComposer,
          $$SesionTableOrderingComposer,
          $$SesionTableAnnotationComposer,
          $$SesionTableCreateCompanionBuilder,
          $$SesionTableUpdateCompanionBuilder,
          (
            SesionLocal,
            BaseReferences<_$AppDatabase, $SesionTable, SesionLocal>,
          ),
          SesionLocal,
          PrefetchHooks Function()
        > {
  $$SesionTableTableManager(_$AppDatabase db, $SesionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String?> authUid = const Value.absent(),
                Value<String?> correo = const Value.absent(),
                Value<bool> correoConfirmado = const Value.absent(),
                Value<String?> tokenNube = const Value.absent(),
                Value<bool> descargaInicial = const Value.absent(),
              }) => SesionCompanion(
                id: id,
                usuarioId: usuarioId,
                authUid: authUid,
                correo: correo,
                correoConfirmado: correoConfirmado,
                tokenNube: tokenNube,
                descargaInicial: descargaInicial,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String usuarioId,
                Value<String?> authUid = const Value.absent(),
                Value<String?> correo = const Value.absent(),
                Value<bool> correoConfirmado = const Value.absent(),
                Value<String?> tokenNube = const Value.absent(),
                Value<bool> descargaInicial = const Value.absent(),
              }) => SesionCompanion.insert(
                id: id,
                usuarioId: usuarioId,
                authUid: authUid,
                correo: correo,
                correoConfirmado: correoConfirmado,
                tokenNube: tokenNube,
                descargaInicial: descargaInicial,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SesionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SesionTable,
      SesionLocal,
      $$SesionTableFilterComposer,
      $$SesionTableOrderingComposer,
      $$SesionTableAnnotationComposer,
      $$SesionTableCreateCompanionBuilder,
      $$SesionTableUpdateCompanionBuilder,
      (SesionLocal, BaseReferences<_$AppDatabase, $SesionTable, SesionLocal>),
      SesionLocal,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String entidad,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastSyncId,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> entidad,
  Value<DateTime?> lastSyncAt,
  Value<String?> lastSyncId,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncId => $composableBuilder(
    column: $table.lastSyncId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncId => $composableBuilder(
    column: $table.lastSyncId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entidad =>
      $composableBuilder(column: $table.entidad, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncId => $composableBuilder(
    column: $table.lastSyncId,
    builder: (column) => column,
  );
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          CursorSync,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            CursorSync,
            BaseReferences<_$AppDatabase, $SyncMetaTable, CursorSync>,
          ),
          CursorSync,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entidad = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastSyncId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(
                entidad: entidad,
                lastSyncAt: lastSyncAt,
                lastSyncId: lastSyncId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entidad,
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastSyncId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                entidad: entidad,
                lastSyncAt: lastSyncAt,
                lastSyncId: lastSyncId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      CursorSync,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (CursorSync, BaseReferences<_$AppDatabase, $SyncMetaTable, CursorSync>),
      CursorSync,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AsociacionesTableTableManager get asociaciones =>
      $$AsociacionesTableTableManager(_db, _db.asociaciones);
  $$ProductoresTableTableManager get productores =>
      $$ProductoresTableTableManager(_db, _db.productores);
  $$FincasTableTableManager get fincas =>
      $$FincasTableTableManager(_db, _db.fincas);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db, _db.lotes);
  $$ActividadesAgricolasTableTableManager get actividadesAgricolas =>
      $$ActividadesAgricolasTableTableManager(_db, _db.actividadesAgricolas);
  $$CosechasTableTableManager get cosechas =>
      $$CosechasTableTableManager(_db, _db.cosechas);
  $$DiagnosticosTableTableManager get diagnosticos =>
      $$DiagnosticosTableTableManager(_db, _db.diagnosticos);
  $$SesionTableTableManager get sesion =>
      $$SesionTableTableManager(_db, _db.sesion);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
