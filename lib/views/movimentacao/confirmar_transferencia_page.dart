// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/common/components.dart';
import 'package:wms_android/http/repository/movimentacao_repository.dart';
import 'package:wms_android/model/item_transferencia_model.dart';
import 'package:wms_android/model/movimentacao.dart';

class ConfirmarTransferenciaPage extends StatefulWidget {
  const ConfirmarTransferenciaPage({
    super.key,
    required this.itensTransferidos,
  });
  final List<ItemTransferenciaModel> itensTransferidos;

  @override
  State<ConfirmarTransferenciaPage> createState() =>
      _ConfirmarTransferenciaPageState();
}

class _ConfirmarTransferenciaPageState
    extends State<ConfirmarTransferenciaPage> {
  late ItensTransferidoDataSource itensTransferidoDataSourceGrid;
  @override
  void initState() {
    super.initState();
    itensTransferidoDataSourceGrid =
        ItensTransferidoDataSource(itemTransferido: widget.itensTransferidos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Transferencia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: SfDataGrid(
                source: itensTransferidoDataSourceGrid,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'produto',
                    label: Container(
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text(
                          'Produto',
                        )),
                  ),
                  GridColumn(
                    columnName: 'cx_origem',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Cx Origem')),
                  ),
                  GridColumn(
                    columnName: 'cx_destino',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text(
                          'Cx Destino',
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  GridColumn(
                    columnName: 'endereco',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Endereço')),
                  ),
                ],
              ),
            ),
            InforvixButton(
              title: 'Validar',
              onClick: () async {
                //Enviar a movimentacao
                await MovimentacaoHttpRepository().apiPostMovimentacao(
                    DadosGlobaisMovimentacao.importdora,
                    DadosGlobaisMovimentacao.segmentoEstoqueOrigem,
                    DadosGlobaisMovimentacao.segmentoEstoqueDestino,
                    DadosGlobaisMovimentacao.marca,
                    DadosGlobaisMovimentacao.transferiItemReservados,
                    widget.itensTransferidos);

                if (DadosGlobaisMovimentacao.status == '1 - VALIDA') {
                  await MovimentacaoHttpRepository()
                      .apiPostMovimentacaoProcessar(
                          DadosGlobaisMovimentacao.transferenciaLogisticaId);
                  await MovimentacaoHttpRepository().apiGetMovimentacaConsultar(
                      DadosGlobaisMovimentacao.transferenciaLogisticaId);

                  if (DadosGlobaisMovimentacao.statusConsulta ==
                      '2 - FINALIZADO') {
                    print('Transferencia realizada com sucesso');
                  }
                } else {}

                //Verificar o status, em caso de sucesso processar a validação e consultar para verificar se esta tudo certo e retornar o status de movimentcação realizada com sucesso
              },
            )
          ],
        ),
      ),
    );
  }
}

class ItensTransferidoDataSource extends DataGridSource {
  ItensTransferidoDataSource(
      {required List<ItemTransferenciaModel> itemTransferido}) {
    __dataItemTransferido = itemTransferido
        .map<DataGridRow>((item) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'produto', value: item.codigoBarras),
              DataGridCell<String>(
                  columnName: 'cx_origem', value: item.caixaAntiga),
              DataGridCell<String>(
                  columnName: 'cx_destino', value: item.caixaDestino),
              DataGridCell<String>(
                  columnName: 'endereco', value: item.enderecoDestino),
            ]))
        .toList();
  }

  List<DataGridRow> __dataItemTransferido = [];

  @override
  List<DataGridRow> get rows => __dataItemTransferido;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        color: Colors.orange[100]!,
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}
