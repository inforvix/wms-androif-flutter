import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/http/repository/expedicao_http_repository.dart';
import 'package:wms_android/model/conferencia.dart';
import 'package:wms_android/model/contagem_pedido.dart';
import 'package:wms_android/model/expedicao.dart';
import 'package:wms_android/model/pedido.dart';

class ExpedicaoControler with ChangeNotifier {
  // void inserirExp(Expedicao exp) {

  // }

  void inserirExp(Expedicao exp) async {
    if (expedicaoOnline) {
      String expJson = jsonEncode(exp.toMap());
      try {
        http.Response response = await http.post(
          Uri.parse(urlExpedicaoOnline),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: expJson,
        );
        if (response.statusCode == 200) {
          print('Objeto Expedicao inserido com sucesso na API.');
        } else {
          print(
              'Falha ao inserir objeto Expedicao na API. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao enviar a solicitação para a API: $e');
      }
    } else {
      Dbutil.insert('EXPEDICAO', exp.toMap());
      notifyListeners();
    }
  }

  Future<List<Expedicao>> getByPedido(String pedido) async {
    if (expedicaoOnline) {
      List<Expedicao> expedicoes = [];

      try {
        // Envia a solicitação GET para a API para buscar as expedicoes com base no pedido
        http.Response response =
            await http.get(Uri.parse('$urlExpedicaoOnline/$pedido'));

        // Verifica se a solicitação foi bem sucedida (código de status 200)
        if (response.statusCode == 200) {
          // Decodifica o JSON retornado pela API
          List<dynamic> jsonExpedicoes = jsonDecode(response.body);

          // Converte os dados JSON em objetos Expedicao e os adiciona à lista expedicoes
          expedicoes = jsonExpedicoes
              .map((expJson) => Expedicao(
                    exp_pedido: expJson['expPedido'],
                    pro_codigo: expJson['proCodigo'],
                    exp_endereco: expJson['expEndereco'],
                    exp_caixa: expJson['expCaixa'],
                    exp_quantidade_separar:
                        expJson['expQuantidadeSeparar'].toDouble(),
                    exp_quantidade_separada:
                        expJson['expQuantidadeSeparada'].toDouble(),
                    usu_login: expJson['usuLogin'],
                    exp_ignorado: expJson['expIgnorado'],
                    exp_volumes: expJson['expVolumes'],
                    id: expJson['id'],
                    exp_quantidade_conferida:
                        expJson['expQuantidadeConferida'].toDouble(),
                  ))
              .toList();
        } else {
          print(
              'Falha ao buscar expedicoes. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao buscar expedicoes: $e');
      }

      return expedicoes;
    } else {
      final expList = await Dbutil.getFilterRowsOr(
          'EXPEDICAO', ['EXP_PEDIDO'], [pedido], 'id');

      return expList
          .map(
            (exp) => Expedicao(
                exp_pedido: exp['EXP_PEDIDO'],
                pro_codigo: exp['PRO_CODIGO'],
                exp_endereco: exp['EXP_ENDERECO'],
                exp_caixa: exp['EXP_CAIXA'],
                exp_quantidade_separar:
                    double.parse(exp['EXP_QUANTIDADE_SEPARAR'].toString()),
                exp_quantidade_separada: exp['EXP_QUANTIDADE_SEPARADA'] == null
                    ? 0
                    : double.parse(exp['EXP_QUANTIDADE_SEPARADA'].toString()),
                usu_login: exp['USU_LOGIN'],
                exp_ignorado: exp['EXP_IGNORADO'],
                exp_volumes: exp['EXP_VOLUMES'],
                id: exp['ID'],
                exp_quantidade_conferida: exp['EXP_QUANTIDADE_CONFERIDA'] ==
                        null
                    ? 0
                    : double.parse(exp['EXP_QUANTIDADE_CONFERIDA'].toString())),
          )
          .toList();
    }
  }

  Future<List<Conferencia>> getByPedidoConferencia(String pedido) async {
    List<Conferencia> confListRet = [];
    if (expedicaoOnline) {
      try {
        // Envia a solicitação GET para a API para buscar as expedicoes com base no pedido
        http.Response response = await http
            .get(Uri.parse('$urlExpedicaoOnline/conferencia/$pedido'));

        // Verifica se a solicitação foi bem sucedida (código de status 200)
        if (response.statusCode == 200) {
          // Decodifica o JSON retornado pela API
          List<dynamic> jsonExpedicoes = jsonDecode(response.body);

          // Converte os dados JSON em objetos Expedicao e os adiciona à lista expedicoes
          confListRet = jsonExpedicoes
              .map((expJson) => Conferencia(
                    pro_codigo: expJson['proCodigo'],
                    exp_quantidade_separar:
                        expJson['expQuantidadeSeparar'].toDouble(),
                    exp_quantidade_conferida:
                        expJson['expQuantidadeConferida'].toDouble(),
                  ))
              .toList();
        } else {
          print(
              'Falha ao buscar expedicoes. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Erro ao buscar expedicoes: $e');
      }

      return confListRet;
    } else {
      final confList = await Dbutil.queryObject(' select  '
          ' PRO_CODIGO, '
          ' cast(sum(EXP_QUANTIDADE_SEPARAR) as numeric) as EXP_QUANTIDADE_SEPARAR,'
          ' cast(sum(EXP_QUANTIDADE_CONFERIDA) as numeric) as  EXP_QUANTIDADE_CONFERIDA '
          ' from EXPEDICAO'
          ' where EXP_PEDIDO = "$pedido" group by PRO_CODIGO');

      for (var element in confList) {
        confListRet.add(Conferencia.fromMap(element));
      }
      return confListRet;
    }
  }

  Future<int?> getQtdPedidoById(String pedido) async {
    final qtd = await Dbutil.rowCountFilter('EXPEDICAO', 'EXP_PEDIDO', pedido);

    return qtd;
  }

  Future<int?> apagaPedidoById(String pedido) async {
    final qtd = await Dbutil.delete('EXPEDICAO', 'EXP_PEDIDO', pedido);

    return qtd;
  }

  Future<String> exportaPedidoById(String pedido, String volume) async {
    String str;
    List<Map<String, dynamic>> expList = [];

    if (expedicaoOnline) {
      http.Response response =
          await http.get(Uri.parse('$urlExpedicaoOnline/$pedido'));
      expList = jsonDecode(response.body);
    } else {
      expList = await Dbutil.getFilterRowsOr(
          'EXPEDICAO', ['EXP_PEDIDO'], [pedido], 'id');
    }

    try {
      if (gTipoServiddor != 'INFORVIX') {
        List<ContagemPedido> contagem = expList
            .map((exp) => ContagemPedido(
                ean: exp['proCodigo'],
                caixaEndereco: exp['expEndereco'],
                caixaNumero: exp['expCaixa'],
                quantidade: exp['expQuantidadeSeparada'] ?? 0))
            .toList();

        PedidoSincronismo ped = PedidoSincronismo(
            usuario: usuLogin!,
            volumes: int.parse(volume),
            listaEnderecos: contagem);

        str = await ExpedicaoHttpRepository().apiPutExpedicao(ped, pedido);
      } else {
        List<Expedicao> contagem =
            expList.map((exp) => Expedicao.Db(exp)).toList();

        str =
            await ExpedicaoHttpRepository().apiPostExpedicao(contagem, pedido);
      }
    } catch (e) {
      str = 'Erro';
    }

    return str;
  }
}
