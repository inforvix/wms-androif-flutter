import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';
import '../../model/inventario.dart';

class InventarioHttpRepository {
  Future<int> apiPostInventario(List<Inventario> contagem) async {
    try {
      String baseUrl = '$gIp/enviaContagem';

      String jsonString = '[';
      for (var element in contagem) {
        jsonString = '$jsonString${element.toJson()},';
      }
      jsonString = jsonString.substring(0, jsonString.length - 1);
      jsonString = '$jsonString]';
      jsonString = jsonString.toUpperCase();
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'authorization': basicAuth,
          "Content-Type": "application/json"
        },
        body: jsonString,
      );

      return response.statusCode;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
