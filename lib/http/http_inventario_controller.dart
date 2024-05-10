import 'package:flutter/foundation.dart';
import 'package:wms_android/controller/inventario_controller.dart';
import 'package:wms_android/http/repository/inventario_http_repository.dart';

class HttpControllerInventario extends ChangeNotifier {
  Future<bool> postContagens() async {
    try {
      final dados = await InventarioController().getAll();
      int ret = 0;
      if (dados.isNotEmpty) {
        ret = await InventarioHttpRepository().apiPostInventario(dados);
      }
      notifyListeners();
      return ret == 200;
    } catch (e) {
      return false;
    }
  }
}
