// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:wms_android/model/usuario.dart';

class Dbutil {
  static const int databaseVersion = 4;

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'wms.db'),
      version: databaseVersion,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute(' CREATE TABLE parametro ('
        ' par_chave_aut varchar(50),'
        ' par_tipo_serviddor varchar(50),'
        ' par_ip varchar(50), '
        ' par_usa_endereco varchar(1) );');

    await db.execute(' insert into parametro ('
        ' par_chave_aut, par_tipo_serviddor, par_ip, par_usa_endereco)values( '
        ' "Inforvix.123" ,"ASTE", "http://192.168.2.253/apirest/InforvixApiRest.dll", "S" );');

    await db.execute(' CREATE TABLE recebimento ('
        ' recPedido      varchar(15) NOT NULL,'
        ' proCodigo      varchar(20) NOT NULL,'
        ' recCaixa       varchar(10),'
        ' recQuantidade  float,'
        ' recQuantLida   float,'
        ' usuLogin       varchar(20),'
        ' PRIMARY KEY (recPedido,proCodigo) );');

    await db.execute(' CREATE TABLE inventario ('
        ' id              integer PRIMARY KEY AUTOINCREMENT NOT NULL,'
        ' proCodigo      varchar(50) NOT NULL,'
        ' invCaixa       varchar(20),'
        ' invEndereco    varchar(20),'
        ' invQuantidade  numeric(12,3) NOT NULL,'
        ' usuCodigo      varchar(20));');

    await db.execute(
        ' CREATE TABLE USUARIO (USU_LOGIN varchar(30) PRIMARY KEY NOT NULL UNIQUE, '
        ' USU_NOME varchar(80), USU_SENHA varchar(30), USU_ATIVO varchar(1)); ');

    await db.execute(' CREATE TABLE EXPEDICAO ('
        ' EXP_PEDIDO               varchar(15) NOT NULL,'
        ' PRO_CODIGO               varchar(20) NOT NULL,'
        ' EXP_ENDERECO             varchar(10) NOT NULL,'
        ' EXP_CAIXA                varchar(10) NOT NULL,'
        ' EXP_QUANTIDADE_SEPARAR   numeric,'
        ' EXP_QUANTIDADE_SEPARADA  numeric,'
        ' USU_LOGIN                varchar(20),'
        ' EXP_IGNORADO             varchar(1),'
        ' EXP_VOLUMES              varchar(5),'
        ' ID                       integer,'
        ' EXP_QUANTIDADE_CONFERIDA  numeric,'
        ' PRIMARY KEY (EXP_PEDIDO, PRO_CODIGO, EXP_ENDERECO, EXP_CAIXA));');

    await db.execute(' CREATE TABLE produtos ( '
        ' proCodigo             varchar(50) PRIMARY KEY NOT NULL, '
        ' proDescricao          varchar(100), '
        ' proCusto              float, '
        ' proEstoqueCongelado   float, '
        ' proCodigoInterno      varchar(50)); ');

    await db.execute(' CREATE INDEX idx_produtos_pro_codigo_interno'
        ' ON produtos'
        ' (proCodigoInterno);');

    await db.execute(
        "ALTER TABLE parametro ADD COLUMN par_recebimento_cego varchar(1);");

    await db.execute(
        "ALTER TABLE parametro ADD COLUMN par_expedicao_online varchar(1);");

    await db.execute(' CREATE TABLE ECOMMERCE ('
        ' EXP_PEDIDO               varchar(15) NOT NULL,'
        ' PRO_CODIGO               varchar(20) NOT NULL,'
        ' EXP_ENDERECO             varchar(10) NOT NULL,'
        ' EXP_CAIXA                varchar(10) NOT NULL,'
        ' EXP_QUANTIDADE_SEPARAR   numeric,'
        ' EXP_QUANTIDADE_SEPARADA  numeric,'
        ' USU_LOGIN                varchar(20),'
        ' EXP_IGNORADO             varchar(1),'
        ' EXP_VOLUMES              varchar(5),'
        ' ID                       integer,'
        ' EXP_QUANTIDADE_CONFERIDA  numeric,'
        ' PRIMARY KEY (EXP_PEDIDO, PRO_CODIGO, EXP_ENDERECO, EXP_CAIXA));');

    db.setVersion(1);
  }

  static Future<void> _upgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 2 && newVersion == 3) {
      try {
        await db.execute(' CREATE TABLE IF NOT EXISTS parametro ('
            ' par_chave_aut varchar(50),'
            ' par_tipo_serviddor varchar(50),'
            ' par_ip varchar(50), '
            ' par_usa_endereco varchar(1) );');

        await db.execute(' CREATE TABLE recebimento ('
            ' recPedido      varchar(15) NOT NULL,'
            ' proCodigo      varchar(20) NOT NULL,'
            ' recCaixa       varchar(10),'
            ' recQuantidade  float,'
            ' recQuantLida   float,'
            ' usuLogin       varchar(20),'
            ' PRIMARY KEY (recPedido,proCodigo) );');

        await db.execute(' CREATE TABLE IF NOT EXISTS inventario ('
            ' id              integer PRIMARY KEY AUTOINCREMENT NOT NULL,'
            ' proCodigo      varchar(50) NOT NULL,'
            ' invCaixa       varchar(20),'
            ' invEndereco    varchar(20),'
            ' invQuantidade  numeric(12,3) NOT NULL,'
            ' usuCodigo      varchar(20));');

        await db.execute(' CREATE TABLE IF NOT EXISTS produtos ( '
            ' proCodigo             varchar(50) PRIMARY KEY NOT NULL, '
            ' proDescricao          varchar(100), '
            ' proCusto              float, '
            ' proEstoqueCongelado   float, '
            ' proCodigoInterno      varchar(50)); ');

        await db.execute(
            ' CREATE INDEX IF NOT EXISTS idx_produtos_pro_codigo_interno'
            ' ON produtos'
            ' (proCodigoInterno);');

        await db.execute(
            "ALTER TABLE parametro ADD COLUMN par_recebimento_cego varchar(1);");

        await db.execute(
            "ALTER TABLE parametro ADD COLUMN par_expedicao_online varchar(1);");
      } catch (e) {
        Exception('Não foi possivél criar novas tabelas');
      }
    }
    if (oldVersion == 3 && newVersion == 4) {
      try {
        await db.execute(' CREATE TABLE ECOMMERCE ('
            ' EXP_PEDIDO               varchar(15) NOT NULL,'
            ' PRO_CODIGO               varchar(20) NOT NULL,'
            ' EXP_ENDERECO             varchar(10) NOT NULL,'
            ' EXP_CAIXA                varchar(10) NOT NULL,'
            ' EXP_QUANTIDADE_SEPARAR   numeric,'
            ' EXP_QUANTIDADE_SEPARADA  numeric,'
            ' USU_LOGIN                varchar(20),'
            ' EXP_IGNORADO             varchar(1),'
            ' EXP_VOLUMES              varchar(5),'
            ' ID                       integer,'
            ' EXP_QUANTIDADE_CONFERIDA  numeric,'
            ' PRIMARY KEY (EXP_PEDIDO, PRO_CODIGO, EXP_ENDERECO, EXP_CAIXA));');
      } catch (e) {
        Exception('Não foi possivél criar novas tabelas');
      }
    }
    db.setVersion(databaseVersion);
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database();
    return await db.transaction((txn) async {
      return await txn.insert(table, data,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    });
  }

  static Future batcInsert(
      String table, List<Map<String, dynamic>> data) async {
    final db = await database();
    final batch = db.batch();

    for (var i = 0; i < data.length; i++) {
      batch.insert(table, data[i],
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<int> update(String table, Map<String, dynamic> data,
      List<String> campo, List<String> valor) async {
    final db = await Dbutil.database();
    String campos = '';

    if (campo.isNotEmpty) {
      for (var i = 0; i < campo.length; i++) {
        campos = '$campos$campo = ? ';
      }
    }
    return await db.transaction((txn) async {
      return await txn.update(table, data, where: campos, whereArgs: valor);
    });
  }

  static Future<int> updateId(
      String table, Map<String, dynamic> data, String columnId) async {
    final db = await Dbutil.database();
    String id = data[columnId];
    return await db.transaction((txn) async {
      return txn.update(table, data, where: '$columnId = ?', whereArgs: [id]);
    });
  }

  static Future<List<Map<String, dynamic>>> getFilterRowsAnd(String table,
      List<String> campo, List<String> valor, String campoOrdem) async {
    final db = await Dbutil.database();
    String ordem = '';
    String where = '';
    if (campoOrdem.isNotEmpty) {
      ordem = ' order by $campoOrdem';
    }
    if (campo.isNotEmpty) {
      where = 'where 1=1 ';
      for (var i = 0; i < campo.length; i++) {
        var _campo = campo[i];
        var _valor = valor[i];
        where = " $where and $_campo = '$_valor' ";
      }
    }
    return await db.rawQuery("select * from $table $where $ordem");
  }

  static Future<void> rawDelete(String sql) async {
    final db = await Dbutil.database();
    await db.rawDelete(sql);
  }

  static Future<void> execute(String sql) async {
    final db = await Dbutil.database();
    await db.execute(sql);
  }

  static Future<List<Map<String, dynamic>>> getFilterRowsOr(String table,
      List<String> campo, List<String> valor, String campoOrdem) async {
    final db = await Dbutil.database();
    String ordem = '';
    String where = '';
    if (campoOrdem.isNotEmpty) {
      ordem = ' order by $campoOrdem';
    }
    if (campo.isNotEmpty) {
      where = 'where 1=2 ';
      for (var i = 0; i < campo.length; i++) {
        var _campo = campo[i];
        var _valor = valor[i];
        where = " $where or $_campo = '$_valor' ";
      }
    }
    return await db.rawQuery("select * from $table $where $ordem");
  }

  static Future<Map<String, dynamic>?> getOneRowAnd(String table,
      List<String> campo, List<String> valor, String campoOrdem) async {
    final db = await Dbutil.database();
    String ordem = '';
    String where = '';
    if (campoOrdem.isNotEmpty) {
      ordem = ' order by $campoOrdem';
    }
    if (campo.isNotEmpty) {
      where = 'where 1=1 ';
      for (var i = 0; i < campo.length; i++) {
        var _campo = campo[i];
        var _valor = valor[i];
        where = " $where and $_campo = '$_valor' ";
      }
    }
    var ret = await db.rawQuery("select * from $table $where $ordem LIMIT 1");
    if (ret.isNotEmpty) {
      return ret[0];
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOneRowOr(String table,
      List<String> campo, List<String> valor, String campoOrdem) async {
    final db = await Dbutil.database();
    String ordem = '';
    String where = '';
    if (campoOrdem.isNotEmpty) {
      ordem = ' order by $campoOrdem';
    }
    if (campo.isNotEmpty) {
      where = 'where 1=2 ';
      for (var i = 0; i < campo.length; i++) {
        var _campo = campo[i];
        var _valor = valor[i];
        where = " $where or $_campo = '$_valor' ";
      }
    }
    var ret = await db.rawQuery("select * from $table $where $ordem LIMIT 1");
    if (ret.isNotEmpty) {
      return ret[0];
    } else {
      return null;
    }
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  static Future<int?> rowCount(String table) async {
    final db = await Dbutil.database();
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  static Future<int?> countOneField(String sql) async {
    final db = await Dbutil.database();
    return Sqflite.firstIntValue(await db.rawQuery(sql));
  }

  static Future<int?> rowCountFilter(
      String table, String campo, String valor) async {
    final db = await Dbutil.database();
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table where $campo = $valor'));
  }

  static Future<List<Map<String, Object?>>> queryObject(String sql) async {
    final db = await Dbutil.database();
    return await db.rawQuery(sql);
  }

  static Future<List<Map<String, dynamic>>> queryDynamic(String sql) async {
    final db = await Dbutil.database();
    return await db.rawQuery(sql);
  }

  static Future<int> updateQuery(String sql, List<Object> valor) async {
    final db = await Dbutil.database();
    return await db.rawUpdate(sql, valor);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  static Future<int> delete(String table, String columnId, String id) async {
    final db = await Dbutil.database();
    return await db.transaction((txn) {
      return txn.delete(table, where: "$columnId = ?", whereArgs: [id]);
    });
  }

  static Future<int> deleteAll(String table) async {
    final db = await Dbutil.database();
    return await db.transaction((txn) {
      return txn.delete(table);
    });
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await Dbutil.database();
    return db.query(table);
  }

  static Future<List<Map<String, dynamic>>> getDataLimit(
      String table, int limite) async {
    final db = await Dbutil.database();
    return db.query(table, limit: limite);
  }

  static Future<Usuario?> login(String usuario, String senha) async {
    final db = await Dbutil.database();
    //final db2 = await Dbutil.database();
    var res = await db
        .rawQuery("SELECT * FROM USUARIO WHERE USU_LOGIN = '$usuario' ");

    if (res.isNotEmpty) {
      var usu = Usuario.fromMapDb(res.first);
      if (usu.usu_senha != senha) {
        throw Exception('Senha invalida');
      } else if (usu.usu_ativo == 'I') {
        throw Exception('Usuário inativo');
      } else {
        return usu;
      }
    } else {
      var res = await db.rawQuery("SELECT count(*) as qtd FROM USUARIO ");
      if (res.first['qtd'] == 0) {
        throw Exception(
            'Não existe usuário no banco, sincronize antes de logar');
      }
      return null;
    }
  }
}


/*
https://github.com/tekartik/sqflite/blob/master/sqflite/README.md

// Get a location using getDatabasesPath
var databasesPath = await getDatabasesPath();
String path = join(databasesPath, 'demo.db');

// Delete the database
await deleteDatabase(path);

// open the database
Database database = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
  // When creating the db, create the table
  await db.execute(
      'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
});

// Insert some records in a transaction
await database.transaction((txn) async {
  int id1 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
  print('inserted1: $id1');
  int id2 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
      ['another name', 12345678, 3.1416]);
  print('inserted2: $id2');
});

// Update some record
int count = await database.rawUpdate(
    'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    ['updated name', '9876', 'some name']);
print('updated: $count');

// Get the records
List<Map> list = await database.rawQuery('SELECT * FROM Test');
List<Map> expectedList = [
  {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
  {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
];
print(list);
print(expectedList);
assert(const DeepCollectionEquality().equals(list, expectedList));

// Count the records
count = Sqflite
    .firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
assert(count == 2);

// Delete a record
count = await database
    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
assert(count == 1);

// Close the database
await database.close();*/