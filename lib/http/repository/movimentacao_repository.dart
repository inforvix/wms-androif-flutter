// ignore_for_file: unnecessary_brace_in_string_interps
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/model/item_transferencia_model.dart';

class MovimentacaoHttpRepository {
  Future<void> apiPostMovimentacao(
      String importadora,
      segmentoOrigem,
      segmentoDestino,
      codigoMarca,
      bool usarReserva,
      List<ItemTransferenciaModel> itensTransferidos) async {
    Uri url = Uri.parse('$urlBaseCliente/caixa');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        },
        body: jsonEncode(<String, dynamic>{
          "Operacao": "2",
          "Importadora": importadora,
          "SegmentoOrigem": segmentoOrigem,
          "SegmentoDestino": segmentoDestino,
          "CodigoMarca": codigoMarca,
          "UsarReserva": usarReserva,
          "Itens": itensTransferidos.map((item) => item.toJson()).toList(),
        }),
      );
      print(response.body);
    } catch (e) {
      print('Exceção na solicitação POST: $e');
    }
  }
}
