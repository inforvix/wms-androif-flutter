import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/model/expedicao.dart';
import 'package:wms_android/model/impressora.dart';
import 'package:wms_android/model/pedido.dart';

import '../../common/comm.dart';

class ExpedicaoHttpRepository {
  Future<List<Expedicao>> apiGetExpedicao(String pedido) async {
    if (gTipoServiddor == 'INFORVIX') {
      var baseUrl = '$gIp/expedicao/$pedido';
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        final List<dynamic> responseMap = jsonDecode(response.body);
        return responseMap
            .map<Expedicao>((resp) => Expedicao.fromMap(resp))
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
            .map<Expedicao>((resp) => Expedicao.fromMap(resp))
            .toList();
      } catch (err) {
        throw Exception(err);
      }
    }
  }

  Future<String> apiPutExpedicao(
      PedidoSincronismo contagem, String pedido) async {
    String baseUrl = '$urlBaseCliente/pedidos/$pedido';

    final response = await http.put(Uri.parse(baseUrl),
        headers: {
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
          "Host": "api.omnisige.com.br",
          "Content-Type": "application/json"
        },
        body: contagem.toJson());

    return response.body;
  }

  //inforvix
  Future<String> apiPostExpedicao(
      List<Expedicao> contagem, String pedido) async {
    try {
      String baseUrl = '$gIp/enviaexpedicao';

      String jsonString = '[';
      for (var element in contagem) {
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

  Future<List<Impressora>> apiGetimpressoras() async {
    //String baseUrl = '$urlBaseCliente/impressoras';
    String baseUrl =
        'https://api.omnisige.com.br/logistica/coletor/impressoras';

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        "Host": "api.omnisige.com.br",
      },
    );

    final List<dynamic> responseMap = jsonDecode(response.body);
    return responseMap
        .map<Impressora>((resp) => Impressora.fromMap(resp))
        .toList();
  }

  Future<String> apiPutImpressao(String pedido, String impressora) async {
    String baseUrl =
        '$urlBaseCliente/impressoras/$pedido/impressora/$impressora';

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        // "Host": "api.omnisige.com.br"
      },
    );

    return response.body;
  }
}
