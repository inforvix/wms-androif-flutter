import 'package:flutter/foundation.dart';
import 'package:wms_android/controller/recebimento_controller.dart';
import 'package:wms_android/http/repository/recebimento_http_repository.dart';

class HttpControllerRecebimento extends ChangeNotifier {
  Future<int?> getRecebimento(String pedido) async {
    var str = '';
    try {
      final dadosDb = await RecebimentoController().getQtdPedidoById(pedido);
      if (dadosDb == 0) {
        final dados = await RecebimentoHttpRepository().apiGetRecebimento(pedido);
        if (dados.isEmpty) {
          str = 'Pedido sem informações ou inexistente!';
          throw Exception(str);
        }

        for (var rec in dados) {
          if (rec.proCodigo.isNotEmpty) {
            rec.recPedido = pedido;
            RecebimentoController().inserir(rec);
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

  Future<void> postContagens(String pedido) async {
    try {
      final dados = await RecebimentoController().getPedidoById(pedido);
      if (dados.isNotEmpty) {
        RecebimentoHttpRepository().apiPostRecebimento(dados);
      }
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
