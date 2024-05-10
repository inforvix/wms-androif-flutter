import 'package:flutter/foundation.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/http/repository/poduto_http_repository.dart';

class HttpControllerProduos extends ChangeNotifier {
  final ValueNotifier<int> pagina = ValueNotifier<int>(0);

  Future<void> getProducts({String marca = '', pedido = ''}) async {
    try {
      List<Map<String, dynamic>> data = [];
      if (gTipoServiddor != 'INFORVIX') {
        pagina.value += 1;
      }
      do {
        final dados = await ProdutoHttpRepository().apiGetProdutos(
            pagina.value.toString(),
            marca: marca,
            pedido: pedido);
        if (dados == null) {
          data.clear();
        } else {
          data.clear();
          for (var pro in dados) {
            data.add(pro.toMap());
          }
          if (data.isNotEmpty) {
            await Dbutil.batcInsert('produtos', data);
          }
        }
        pagina.value += 1;
        notifyListeners();
      } while (data.isNotEmpty);
      pagina.value = 0;

      //await Dbutil.execute('DELETE FROM produtos_ Where rowid < (Select max(rowid) From produtos_ tt Where proCodigo = tt.proCodigo);');

      //await Dbutil.execute('INSERT INTO produtos SELECT * FROM produtos_;');

      //await Dbutil.execute('DELETE FROM produtos_ ');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
