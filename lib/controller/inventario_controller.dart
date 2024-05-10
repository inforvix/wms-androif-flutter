import 'package:flutter/material.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/model/inventario.dart';

class InventarioController extends ChangeNotifier {
  Future<int> inserir(Inventario inv) async {
    int ret = await Dbutil.insert('inventario', inv.toMap());
    notifyListeners();
    return ret;
  }

  Future<List<Inventario>> getInventario(String endereco, String caixa) async {
    var where = caixa == ''
        ? '(invEndereco = "${endereco.toUpperCase()}")'
        : '(invEndereco = "${endereco.toUpperCase()}" and invCaixa = "${caixa.toUpperCase()}")';
    final invList = await Dbutil.queryDynamic("""
        SELECT
          inventario.*,
          produtos.proDescricao
        FROM inventario
        join produtos on produtos.proCodigo = inventario.proCodigo 
        where $where 
        order by id desc
        """);

    return invList.map((inv) => Inventario.fromMapGrid(inv)).toList();
  }

  Future<List<Inventario>> getAll() async {
    final invList = await Dbutil.queryDynamic("""
        SELECT
        proCodigo,
        invCaixa,
        invEndereco,
        usuCodigo,
        sum(invQuantidade) as invQuantidade
        FROM inventario 
        group by  
        proCodigo,
        invCaixa,
        invEndereco,
        usuCodigo 
        """);

    return invList.map((inv) => Inventario.fromMap(inv)).toList();
  }

  // Future<List<Inventario>> getAll() async {
  //   final invList = await Dbutil.getData('inventario');

  //   return invList.map((inv) => Inventario.fromMap(inv)).toList();
  // }

  Future<int?> getTotaisInv({String endereco = "", String caixa = ""}) async {
    String where = "";
    if (endereco != "" && caixa != "") {
      where = "where invEndereco = '${endereco.toUpperCase()}' and invCaixa = '${caixa.toUpperCase()}' ";
    } else if (endereco != "") {
      where = "where invEndereco = '${endereco.toUpperCase()}'";
    }
    final count = await Dbutil.countOneField("""
        SELECT
          sum(invQuantidade) as Total
        FROM inventario $where
        
        """);
    return count ?? 0;
  }

  void apagaId(int id) async {
    await Dbutil.delete("inventario", "id", id.toString());
  }

  void apagaTudo() async {
    await Dbutil.deleteAll(
      "inventario",
    );
  }

  void apagaCaixa(String caixa) async {
    await Dbutil.delete("inventario", "invCaixa", caixa.toUpperCase());
  }

  void apagaEndereco(String endereco) async {
    await Dbutil.delete("inventario", "invEndereco", endereco.toUpperCase());
  }

  void alteraId(int id, double qtd) async {
    await Dbutil.updateQuery("update inventario set invQuantidade = ? where id = ?", [qtd, id]);
  }
}
