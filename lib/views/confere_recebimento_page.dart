// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, sort_child_properties_last, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wms_android/controller/recebimento_controller.dart';
import 'package:wms_android/model/recebimento.dart';
import '../common/comm.dart';

class ConfereRecebimentoPage extends StatefulWidget {
  final String? Pedido;
  ConfereRecebimentoPage({super.key, required this.Pedido});

  @override
  State<ConfereRecebimentoPage> createState() => _ConfereRecebimentoPageState();
}

class _ConfereRecebimentoPageState extends State<ConfereRecebimentoPage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(fixedSize: const Size(240, 50), textStyle: const TextStyle(fontSize: 20));

  List<Recebimento> listConf = [];
  List<Recebimento> filter = [];
  double ler = 0.0;
  double conf = 0.0;

  late RecebimentoDataSource recebimentoDataSource = RecebimentoDataSource(recebimentoData: listConf);

  final fieldTextProduto = TextEditingController();
  FocusNode produtoFNode = FocusNode();

  void clearTextProduto() {
    fieldTextProduto.clear();
  }

  void focusTextProduto() {
    produtoFNode.requestFocus();
  }

  void escolheFocus() {
    focusTextProduto();
  }

  @override
  void initState() {
    atualizaLista();
    super.initState();
  }

  void atualizaLista() {
    var retorno = RecebimentoController().getPedidoById(widget.Pedido!);
    {
      retorno.then((value) => {
            listConf = value,
            filter.addAll(listConf),
            //filter.sort((a, b) => a.id!.compareTo(b.id!)),
            setState(() {
              recebimentoDataSource = RecebimentoDataSource(recebimentoData: listConf);
            }),
          });
    }
  }

  void filtrar(int tipo) {
    filter = [];
    filter.addAll(listConf);
    if (tipo == 1) {
      clearTextProduto();
    }

    // filter.sort((a, b) {
    //   var cmp = (a.exp_quantidade_conferida ?? 0.0).compareTo(a.exp_quantidade_separar);
    //   if (cmp == 0) {
    //     return 1;
    //   } else if ((a.exp_quantidade_conferida ?? 0.0) > 0) {
    //     return -1;
    //   } else {
    //     return 0;
    //   }
    // });

    setState(() {
      recebimentoDataSource = RecebimentoDataSource(recebimentoData: filter);
    });

    // ler = 0;
    // conf = 0;
    // for (var element in listConf) {
    //   ler = ler + element.exp_quantidade_separar;
    //   conf = conf + (element.exp_quantidade_conferida ?? 0.0);
    // }

    setState(() {
      ler = ler;
      conf = conf;
    });
  }

  @override
  Widget build(BuildContext context) {
    void lerProduto(String produto) {
      if (produto.isEmpty) {
        alertDialog(context, 'Produto Vazio!');
        beepErro();
      } else {
        filter = [];
        filter.addAll(listConf);
        // filter.retainWhere((filtrado) {
        //   return filtrado.pro_codigo.contains(produto.toUpperCase());
        // });
        if (filter.isEmpty) {
          alertDialog(context, 'Produto não localizado!');
          clearTextProduto();
          escolheFocus();
          beepErro();
        } else {
          // Conferencia conf = filter[0];
          // double ler = conf.exp_quantidade_separar;
          // double lido = (conf.exp_quantidade_conferida ?? 0.0);
          // if (ler > lido) {
          //   conf.exp_quantidade_conferida = (conf.exp_quantidade_conferida ?? 0.0) + 1;

          //   filtrar(0);
          //   clearTextProduto();
          //   escolheFocus();
          //   beepSucesso();
          // } else {
          //   alertDialog(context, 'Total do produto já alcançado!');
          //   clearTextProduto();
          //   escolheFocus();
          //   beepErro();
          // }
        }
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0, 40),
        child: AppBar(
          title: Text('$conf lidos '),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.settings),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Limpar campos'),
                  value: 1,
                  // ),
                  // PopupMenuItem(
                  //   child: Text('Mostrar finalizados'),
                  //   value: 2,
                ),
              ],
              onSelected: (int selectedValue) {
                filtrar(selectedValue);
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          shrinkWrap: false,
          children: [
            TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Produto',
                  // suffix: IconButton(
                  //   color: Colors.red[400],
                  //   icon: Icon(Icons.cleaning_services_outlined),
                  //   onPressed: () => {clearTextProduto()},
                  // ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.send,
                controller: fieldTextProduto,
                focusNode: produtoFNode,
                onFieldSubmitted: (value) => lerProduto(value)),
            SizedBox(height: 10),
            SizedBox(
              height: alturaDisponivel - 70,
              child: Scrollbar(
                child: SfDataGrid(
                  source: recebimentoDataSource,
                  columnWidthMode: ColumnWidthMode.fill,
                  isScrollbarAlwaysShown: false,
                  shrinkWrapRows: false,
                  headerRowHeight: 28,
                  headerGridLinesVisibility: GridLinesVisibility.vertical,
                  gridLinesVisibility: GridLinesVisibility.vertical,
                  rowHeight: 30,
                  columns: <GridColumn>[
                    GridColumn(
                        width: larguraDisponivel * 0.4,
                        columnName: 'proCodigo',
                        label: Container(
                            //padding: EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            child: Text(
                              'Produto',
                            ))),
                    GridColumn(
                        width: larguraDisponivel * 0.3,
                        columnName: 'recQuantidade',
                        label: Container(
                            // padding: EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            child: Text('Esperado'))),
                    GridColumn(
                        width: larguraDisponivel * 0.3,
                        columnName: 'recQuantLida',
                        label: Container(
                            //padding: EdgeInsets.all(5.0),
                            alignment: Alignment.center,
                            child: Text('Conferido'))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecebimentoDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  RecebimentoDataSource({required List<Recebimento> recebimentoData}) {
    _recebimentoData = recebimentoData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'proCodigo', value: e.proCodigo),
              DataGridCell<double>(columnName: 'recQuantidade', value: e.recQuantidade),
              DataGridCell<double>(columnName: 'recQuantLida', value: e.recQuantLida),
            ]))
        .toList();
  }

  List<DataGridRow> _recebimentoData = [];

  @override
  List<DataGridRow> get rows => _recebimentoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final double ler = row.getCells()[1].value;
      final double lido = row.getCells()[2].value ?? 0;
      if (ler == lido) {
        return Colors.green[100]!;
      } else if (lido > 0) {
        return Colors.blue[100]!;
      } else {
        return Colors.orange[50]!;
      }
    }

    TextStyle? getTextStyle() {
      final double ler = row.getCells()[1].value;
      final double lido = row.getCells()[2].value ?? 0;
      if (ler == lido) {
        return TextStyle(color: Colors.black, fontSize: 12);
      } else if (lido > 0) {
        return TextStyle(color: Colors.black, fontSize: 12);
      } else {
        return TextStyle(color: Colors.green[900], fontSize: 12);
      }
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((dataGridCell) {
          return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(2.0),
              // padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(),
              ));
        }).toList());
  }
}
