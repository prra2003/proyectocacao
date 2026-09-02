// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$ProductoresDaoMixin on DatabaseAccessor<AppDatabase> {
  $AsociacionesTable get asociaciones => attachedDatabase.asociaciones;
  $ProductoresTable get productores => attachedDatabase.productores;
  ProductoresDaoManager get managers => ProductoresDaoManager(this);
}

class ProductoresDaoManager {
  final _$ProductoresDaoMixin _db;
  ProductoresDaoManager(this._db);
  $$AsociacionesTableTableManager get asociaciones =>
      $$AsociacionesTableTableManager(_db.attachedDatabase, _db.asociaciones);
  $$ProductoresTableTableManager get productores =>
      $$ProductoresTableTableManager(_db.attachedDatabase, _db.productores);
}

mixin _$FincasDaoMixin on DatabaseAccessor<AppDatabase> {
  $AsociacionesTable get asociaciones => attachedDatabase.asociaciones;
  $ProductoresTable get productores => attachedDatabase.productores;
  $FincasTable get fincas => attachedDatabase.fincas;
  $LotesTable get lotes => attachedDatabase.lotes;
  FincasDaoManager get managers => FincasDaoManager(this);
}

class FincasDaoManager {
  final _$FincasDaoMixin _db;
  FincasDaoManager(this._db);
  $$AsociacionesTableTableManager get asociaciones =>
      $$AsociacionesTableTableManager(_db.attachedDatabase, _db.asociaciones);
  $$ProductoresTableTableManager get productores =>
      $$ProductoresTableTableManager(_db.attachedDatabase, _db.productores);
  $$FincasTableTableManager get fincas =>
      $$FincasTableTableManager(_db.attachedDatabase, _db.fincas);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db.attachedDatabase, _db.lotes);
}

mixin _$LotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $AsociacionesTable get asociaciones => attachedDatabase.asociaciones;
  $ProductoresTable get productores => attachedDatabase.productores;
  $FincasTable get fincas => attachedDatabase.fincas;
  $LotesTable get lotes => attachedDatabase.lotes;
  LotesDaoManager get managers => LotesDaoManager(this);
}

class LotesDaoManager {
  final _$LotesDaoMixin _db;
  LotesDaoManager(this._db);
  $$AsociacionesTableTableManager get asociaciones =>
      $$AsociacionesTableTableManager(_db.attachedDatabase, _db.asociaciones);
  $$ProductoresTableTableManager get productores =>
      $$ProductoresTableTableManager(_db.attachedDatabase, _db.productores);
  $$FincasTableTableManager get fincas =>
      $$FincasTableTableManager(_db.attachedDatabase, _db.fincas);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db.attachedDatabase, _db.lotes);
}

mixin _$RegistrosDaoMixin on DatabaseAccessor<AppDatabase> {
  $AsociacionesTable get asociaciones => attachedDatabase.asociaciones;
  $ProductoresTable get productores => attachedDatabase.productores;
  $FincasTable get fincas => attachedDatabase.fincas;
  $LotesTable get lotes => attachedDatabase.lotes;
  $ActividadesAgricolasTable get actividadesAgricolas =>
      attachedDatabase.actividadesAgricolas;
  $CosechasTable get cosechas => attachedDatabase.cosechas;
  $DiagnosticosTable get diagnosticos => attachedDatabase.diagnosticos;
  RegistrosDaoManager get managers => RegistrosDaoManager(this);
}

class RegistrosDaoManager {
  final _$RegistrosDaoMixin _db;
  RegistrosDaoManager(this._db);
  $$AsociacionesTableTableManager get asociaciones =>
      $$AsociacionesTableTableManager(_db.attachedDatabase, _db.asociaciones);
  $$ProductoresTableTableManager get productores =>
      $$ProductoresTableTableManager(_db.attachedDatabase, _db.productores);
  $$FincasTableTableManager get fincas =>
      $$FincasTableTableManager(_db.attachedDatabase, _db.fincas);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db.attachedDatabase, _db.lotes);
  $$ActividadesAgricolasTableTableManager get actividadesAgricolas =>
      $$ActividadesAgricolasTableTableManager(
        _db.attachedDatabase,
        _db.actividadesAgricolas,
      );
  $$CosechasTableTableManager get cosechas =>
      $$CosechasTableTableManager(_db.attachedDatabase, _db.cosechas);
  $$DiagnosticosTableTableManager get diagnosticos =>
      $$DiagnosticosTableTableManager(_db.attachedDatabase, _db.diagnosticos);
}

mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $SesionTable get sesion => attachedDatabase.sesion;
  $SyncMetaTable get syncMeta => attachedDatabase.syncMeta;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$SesionTableTableManager get sesion =>
      $$SesionTableTableManager(_db.attachedDatabase, _db.sesion);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db.attachedDatabase, _db.syncMeta);
}
