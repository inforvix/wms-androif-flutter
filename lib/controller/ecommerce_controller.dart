import 'package:flutter/cupertino.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/http/repository/ecommerce_http_repository.dart';
//import 'package:wms_android/http/repository/expedicao_http_repository.dart';
//import 'package:wms_android/model/conferencia.dart';
import 'package:wms_android/model/contagem_pedido.dart';
import 'package:wms_android/model/e_commerce.dart';
import 'package:wms_android/model/pedido.dart';

class EcommerceControler with ChangeNotifier {
  void inserirExp(Ecommerce exp) {
    Dbutil.insert('ECOMMERCE', exp.toMap());
    notifyListeners();
  }

  Future<List<Ecommerce>> getByPedido(String pedido) async {
    final expList = await Dbutil.getFilterRowsOr(
        'ECOMMERCE', ['EXP_PEDIDO'], [pedido], 'id');

    return expList
        .map(
          (exp) => Ecommerce(
              exp_pedido: exp['EXP_PEDIDO'],
              pro_codigo: exp['PRO_CODIGO'],
              exp_endereco: exp['EXP_ENDERECO'],
              exp_caixa: exp['EXP_CAIXA'],
              exp_quantidade_separar:
                  double.parse(exp['EXP_QUANTIDADE_SEPARAR'].toString()),
              exp_quantidade_separada: exp['EXP_QUANTIDADE_SEPARADA'] == null
                  ? 0
                  : double.parse(exp['EXP_QUANTIDADE_SEPARADA'].toString()),
              usu_login: exp['USU_LOGIN'],
              exp_ignorado: exp['EXP_IGNORADO'],
              exp_volumes: exp['EXP_VOLUMES'],
              id: exp['ID'],
              exp_quantidade_conferida: exp['EXP_QUANTIDADE_CONFERIDA'] == null
                  ? 0
                  : double.parse(exp['EXP_QUANTIDADE_CONFERIDA'].toString())),
        )
        .toList();
  }

  // Future<List<Conferencia>> getByPedidoConferencia(String pedido) async {
  //   List<Conferencia> confListRet = [];
  //   final confList = await Dbutil.queryObject(' select  '
  //       ' PRO_CODIGO, '
  //       ' cast(sum(EXP_QUANTIDADE_SEPARAR) as numeric) as EXP_QUANTIDADE_SEPARAR,'
  //       ' cast(sum(EXP_QUANTIDADE_CONFERIDA) as numeric) as  EXP_QUANTIDADE_CONFERIDA '
  //       ' from EXPEDICAO'
  //       ' where EXP_PEDIDO = "$pedido" group by PRO_CODIGO');

  //   for (var element in confList) {
  //     confListRet.add(Conferencia.fromMap(element));
  //   }
  //   return confListRet;
  // }

  Future<int?> getQtdPedidoById(String pedido) async {
    final qtd = await Dbutil.rowCountFilter('ECOMMERCE', 'EXP_PEDIDO', pedido);

    return qtd;
  }

  Future<int?> apagaPedidoById(String pedido) async {
    final qtd = await Dbutil.delete('ECOMMERCE', 'EXP_PEDIDO', pedido);

    return qtd;
  }

  Future<String> exportaPedidoById(String pedido, String volume) async {
    String str;
    final expList = await Dbutil.getFilterRowsOr(
        'ECOMMERCE', ['EXP_PEDIDO'], [pedido], 'id');

    try {
      //if (gTipoServiddor != 'INFORVIX') {
      List<ContagemPedido> contagem = expList
          .map((exp) => ContagemPedido(
              ean: exp['PRO_CODIGO'],
              caixaEndereco: exp['EXP_ENDERECO'],
              caixaNumero: exp['EXP_CAIXA'],
              quantidade: exp['EXP_QUANTIDADE_SEPARADA'] ?? 0))
          .toList();

      PedidoSincronismo ped = PedidoSincronismo(
          usuario: usuLogin!,
          volumes: int.parse(volume),
          listaEnderecos: contagem);
      str = await EcommerceHttpRepository().apiPutEcommerce(ped, pedido);
      //} else {
      // List<Ecommerce> contagem =
      //     expList.map((exp) => Ecommerce.Db(exp)).toList();

      // str = await EcommerceHttpRepository().apiPostExpedicao(contagem, pedido);
      //  }
    } catch (e) {
      str = 'Erro';
    }

    return str;
  }
}
