import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';
import '../../model/recebimento.dart';

class RecebimentoHttpRepository {
  Future<List<Recebimento>> apiGetRecebimento(String pedido) async {
    if (gTipoServiddor == 'INFORVIX') {
      var baseUrl = '$gIp/recebimento/$pedido';
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        final List<dynamic> responseMap = jsonDecode(response.body);
        return responseMap
            .map<Recebimento>((resp) => Recebimento.fromMap(resp))
            .toList();
      } else {
        throw Exception(response.body);
      }
    } else {
      String baseUrl = '$urlBaseCliente/pedidos/$pedido';
      final http.Response response;
      try {
        response = await http.get(Uri.parse(baseUrl), headers: {
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
          //"Host": "api.omnisige.com.br",
        });

        final List<dynamic> responseMap = jsonDecode(response.body);
        return responseMap
            .map<Recebimento>((resp) => Recebimento.fromMap(resp))
            .toList();
      } catch (err) {
        throw Exception(err);
      }
    }
  }

  Future<String> apiPostRecebimento(List<Recebimento> rec) async {
    try {
      String baseUrl = '$gIp/enviaRecebimento';

      String jsonString = '[';
      for (var element in rec) {
        jsonString = '$jsonString${element.toJson()},';
      }
      jsonString = jsonString.substring(0, jsonString.length - 1);
      jsonString = '$jsonString]';
      jsonString = jsonString.toUpperCase();
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';

      final response = await http.post(Uri.parse(baseUrl),
          headers: {
            'authorization': basicAuth,
            "Content-Type": "application/json"
          },
          body: jsonString);
      //  jsonEncode(contagem.toString()));

      return response.body;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
