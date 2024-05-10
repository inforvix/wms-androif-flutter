import 'package:flutter/material.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/http/repository/recebimento_http_repository.dart';
import 'package:wms_android/model/recebimento.dart';

class RecebimentoController extends ChangeNotifier {
  Future<int> inserir(Recebimento rec) async {
    int ret = await Dbutil.insert('recebimento', rec.toMap());
    notifyListeners();
    return ret;
  }

  // Future<List<Recebimento>> getAll() async {
  //   final rectList = await Dbutil.getData('recebimento');
  //   return rectList.map((rec) => Recebimento.fromMap(rec)).toList();
  // }

  void apagaTudo() async {
    await Dbutil.deleteAll("recebimento");
  }

  Future<int?> apagaPedidoById(String pedido) async {
    final qtd = await Dbutil.delete('recebimento', 'recPedido', pedido);

    return qtd;
  }

  Future<List<Recebimento>> getPedidoById(String pedido) async {
    final recList = await Dbutil.getFilterRowsOr('recebimento', ['recPedido'], [pedido], 'proCodigo');
    return recList.map((exp) => Recebimento.fromMap(exp)).toList();
  }

  Future<int?> getQtdPedidoById(String pedido) async {
    final qtd = await Dbutil.rowCountFilter('recebimento', 'recPedido', pedido);

    return qtd;
  }

  Future<String> exportaPedidoById(String pedido) async {
    String str;
    final expList = await Dbutil.getFilterRowsOr('recebimento', ['recPedido'], [pedido], 'proCodigo');

    try {
      //if (gTipoServiddor != 'INFORVIX') {
      // List<ContagemPedido> contagem = expList
      //     .map((exp) => ContagemPedido(
      //         ean: exp['PRO_CODIGO'],
      //         caixaEndereco: exp['EXP_ENDERECO'],
      //         caixaNumero: exp['EXP_CAIXA'],
      //         quantidade: exp['EXP_QUANTIDADE_SEPARADA'] == null
      //             ? 0
      //             : double.parse(exp['EXP_QUANTIDADE_SEPARADA'].toString())))
      //     .toList();

      // PedidoSincronismo ped = PedidoSincronismo(
      //     usuario: usuLogin!,
      //     volumes: int.parse(volume),
      //     listaEnderecos: contagem);
      // str = await ExpedicaoHttpRepository().apiPutExpedicao(ped, pedido);
      //} else {
      List<Recebimento> contagem = expList.map((exp) => Recebimento.fromMap(exp)).toList();

      str = await RecebimentoHttpRepository().apiPostRecebimento(contagem);
      //}
    } catch (e) {
      str = 'Erro';
    }

    return str;
  }
}
