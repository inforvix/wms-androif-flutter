import 'package:flutter/cupertino.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/model/produto.dart';

class PodutoControler extends ChangeNotifier {
  void inserirPro(Produto pro) {
    Dbutil.insert('produto', pro.toMap());
    notifyListeners();
  }

  // Future<List<Produto>> getByPedido(String pedido) async {
  //   final expList =
  //       await Dbutil.getFilterRows('EXPEDICAO', ['EXP_PEDIDO'], [pedido], 'id');

  //   return expList
  //       .map(
  //         (exp) => Produto(
  //             exp_pedido: exp['EXP_PEDIDO'],
  //             pro_codigo: exp['PRO_CODIGO'],
  //             exp_endereco: exp['EXP_ENDERECO'],
  //             exp_caixa: exp['EXP_CAIXA'],
  //             exp_quantidade_separar:
  //                 double.parse(exp['EXP_QUANTIDADE_SEPARAR'].toString()),
  //             exp_quantidade_separada: exp['EXP_QUANTIDADE_SEPARADA'] == null
  //                 ? 0
  //                 : double.parse(exp['EXP_QUANTIDADE_SEPARADA'].toString()),
  //             usu_login: exp['USU_LOGIN'],
  //             exp_ignorado: exp['EXP_IGNORADO'],
  //             exp_volumes: exp['EXP_VOLUMES'],
  //             id: exp['ID'],
  //             exp_quantidade_conferida: exp['EXP_QUANTIDADE_CONFERIDA'] == null
  //                 ? 0
  //                 : double.parse(exp['EXP_QUANTIDADE_CONFERIDA'].toString())),
  //       )
  //       .toList();
  // }

  // Future<List<Conferencia>> getByPedidoConferencia(String pedido) async {
  //   List<Conferencia> confListRet = [];
  //   final confList = await Dbutil.query(' select  '
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

  Future<int?> getQtdProduto() async {
    final qtd = await Dbutil.rowCount('produtos');

    return qtd;
  }

  Future<void> apagaProduto() async {
    Dbutil.deleteAll('produtos');
  }

  Future<Produto?> getProdutoById(String codigo) async {
    Produto? pro;
    Dbutil.getOneRowOr('produtos', ['proCodigo'], [codigo], '')
        .then((value) => {
              if (value != null) {pro = Produto.fromMap(value)}
            });

    return pro;
  }

  Future<Produto?> buscaProduto(String codigo) async {
    Produto? pro;
    var ret = await Dbutil.getOneRowOr(
        'produtos', ['proCodigo', 'ProCodigoInterno'], [codigo, codigo], '');
    if (ret != null) {
      pro = Produto.fromMap(ret);
    }
    return pro;
  }

  // Future<String> exportaPedidoById(String pedido, String volume) async {
  //   String str;
  //   final expList =
  //       await Dbutil.getFilterRows('EXPEDICAO', ['EXP_PEDIDO'], [pedido], 'id');

  //   try {
  //     if (gTipoServiddor != 'INFORVIX') {
  //       List<ContagemPedido> contagem = expList
  //           .map((exp) => ContagemPedido(
  //               ean: exp['PRO_CODIGO'],
  //               caixaEndereco: exp['EXP_ENDERECO'],
  //               caixaNumero: exp['EXP_CAIXA'],
  //               quantidade: exp['EXP_QUANTIDADE_SEPARADA'] == null
  //                   ? 0
  //                   : double.parse(exp['EXP_QUANTIDADE_SEPARADA'].toString())))
  //           .toList();

  //       PedidoSincronismo ped = PedidoSincronismo(
  //           usuario: usuLogin!,
  //           volumes: int.parse(volume),
  //           listaEnderecos: contagem);
  //       str = await ExpedicaoHttpRepository().apiPutExpedicao(ped, pedido);
  //     } else {
  //       List<Expedicao> contagem =
  //           expList.map((exp) => Expedicao.Db(exp)).toList();

  //       str =
  //           await ExpedicaoHttpRepository().apiPostExpedicao(contagem, pedido);
  //     }
  //   } catch (e) {
  //     str = 'Erro';
  //   }

  //   return str;
  // }
}
