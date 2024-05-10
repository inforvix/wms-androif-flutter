import 'package:wms_android/controller/ecommerce_controller.dart';
import 'package:wms_android/http/repository/ecommerce_http_repository.dart';

class HttpControllerEcommerce {
  Future<int?> getEcommerce(String pedido) async {
    var str = '';
    try {
      final dadosDb = await EcommerceControler().getQtdPedidoById(pedido);
      if (dadosDb == 0) {
        final dados = await EcommerceHttpRepository().apiGetEcommerce(pedido);
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
            EcommerceControler().inserirExp(exp);
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
