import 'package:wms_android/controller/expedicao_controller.dart';
import 'package:wms_android/http/repository/expedicao_http_repository.dart';

class HttpControllerExpedicao {
  Future<int?> getExpedicao(String pedido) async {
    var str = '';
    try {
      final dadosDb = await ExpedicaoControler().getQtdPedidoById(pedido);
      if (dadosDb == 0) {
        final dados = await ExpedicaoHttpRepository().apiGetExpedicao(pedido);
        if (dados.isEmpty) {
          str = 'Pedido sem informações ou inexistente!';
          throw Exception(str);
        }
        int i = 1;
        for (var exp in dados) {
          if (exp.pro_codigo.isNotEmpty) {
            exp.exp_pedido = pedido;
            exp.id = i;
            i++;
            ExpedicaoControler().inserirExp(exp);
          }
        }
        return dados.length;
      } else {
        return dadosDb;
      }
    } catch (e) {
      throw Exception(str == '' ? 'Sem conexão Wi-Fi! $e' : str);
    }
  }
}
