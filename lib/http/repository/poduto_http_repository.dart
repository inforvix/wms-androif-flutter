import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/model/marca.dart';
import 'package:wms_android/model/produto.dart';
import '../../common/comm.dart';

class ProdutoHttpRepository {
  Future<List<Produto>?> apiGetProdutos(String pagina,
      {String marca = "", pedido = ""}) async {
    if (gTipoServiddor == 'INFORVIX') {
      var baseUrl = '$gIp/produtos/$pagina';
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        final List<dynamic> responseMap = jsonDecode(response.body);
        return responseMap
            .map<Produto>((resp) => Produto.fromMap(resp))
            .toList();
      } else if (response.statusCode == 204) {
        return null;
      } else {
        throw Exception(response.body);
      }
    } else {
      String baseUrl =
          '$urlBaseCliente/produtos/?marca=${Uri.encodeComponent(marca)}&pPagina=$pagina&pPedido=$pedido';

      final http.Response response;
      try {
        response = await http.get(Uri.parse(baseUrl), headers: {
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
          //"Host": "api.omnisige.com.br",
        });

        final Map<String, dynamic> responseAux = jsonDecode(response.body);
        if (responseAux['paginasTotais'] < responseAux['paginaAtual']) {
          return null;
        } else {
          final List<dynamic> responseMap = responseAux['produtos'];
          return responseMap
              .map<Produto>((resp) => Produto.fromMapAste(resp))
              .toList();
        }
      } catch (err) {
        throw Exception(err);
      }
    }
  }

  Future<List<Marca>> apiGetMarcas() async {
    String baseUrl = '$urlBaseCliente/marcas';
    final http.Response response;
    try {
      response = await http.get(Uri.parse(baseUrl), headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        //"Host": "api.omnisige.com.br",
      });

      final List<dynamic> responseMap = jsonDecode(response.body);
      return responseMap.map<Marca>((resp) => Marca.fromMap(resp)).toList();
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<String> apiGetMarcas2() async {
    Uri url = Uri.parse('$urlBaseCliente/marcas');
    try {
      final response = await http.get(url, headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
      });

      if (response.statusCode == 200) {
        print(response.body);
        return response.body;
      } else {
        throw Exception('Erro ao trazer informações: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção na solicitação GET: $e');
      rethrow;
    }
  }
}
