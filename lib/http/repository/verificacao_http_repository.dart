// ignore_for_file: unnecessary_brace_in_string_interps
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/model/verificacao.dart';

class VerificacaoHttpRepository {
  Future<List<VerificacaoModel>> apiGetEnderecoCaixa(String caixa) async {
    if (gTipoServiddor == 'INFORVIX') {
      throw Exception('Método não implementao para o nosso servidor');
    } else {
      var baseUrl = '$urlBaseCliente/caixa/$caixa';

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
          //"Host": "api.omnisige.com.br",
        },
      );

      if (response.statusCode >= 200 || response.statusCode <= 299) {
        List<dynamic> jsonData = json.decode(response.body);
        List<VerificacaoModel> data =
            jsonData.map((item) => VerificacaoModel.fromJson(item)).toList();
        return data;
      } else {
        return throw Exception('Erro');
      }
    }
  }

  Future<void> apiPutAlterarEnderecoCaixa(
      String caixaEndereco, caixaNumero, caixaCodigoBarras) async {
    Uri url = Uri.parse('$urlBaseCliente/caixa');
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        },
        body: jsonEncode(<String, dynamic>{
          "caixaEndereco": caixaEndereco,
          "caixaNumero": caixaNumero,
          "caixaCodigoBarras": caixaCodigoBarras,
        }),
      );
      print(response.body);
    } catch (e) {
      print('Exceção na solicitação POST: $e');
    }
  }
}
