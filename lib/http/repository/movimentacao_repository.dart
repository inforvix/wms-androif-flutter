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
    Uri url = Uri.parse('$urlBaseCliente/transferencias/validar');
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
      final responseData = jsonDecode(response.body);

      DadosGlobaisMovimentacao.transferenciaLogisticaId =
          responseData['transferenciaLogisticaId'];
      DadosGlobaisMovimentacao.status = responseData['status'];
      DadosGlobaisMovimentacao.observacao = responseData['observacao'];
    } catch (e) {
      DadosGlobaisMovimentacao.observacao = e.toString();
    }
  }

  Future<void> apiPostMovimentacaoProcessar(int idTransferencia) async {
    Uri url =
        Uri.parse('$urlBaseCliente/transferencias/processar/$idTransferencia');
    try {
      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        },
      );
    } catch (e) {
      print('Exceção na solicitação POST: $e');
    }
  }

  Future<void> apiGetMovimentacaConsultar(int idTransferencia) async {
    Uri url = Uri.parse('$urlBaseCliente/transferencias/$idTransferencia');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Tenant": "$tenant",
          "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        },
      );
      final responseData = jsonDecode(response.body);

      DadosGlobaisMovimentacao.statusConsulta = responseData['status'];
      DadosGlobaisMovimentacao.observacao = responseData['observacao'];
    } catch (e) {
      print('Exceção na solicitação GET: $e');
    }
  }
}
