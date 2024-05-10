// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wms_android/controller/inventario_controller.dart';
import 'package:wms_android/controller/produto_controller.dart';
import 'package:wms_android/model/inventario.dart';
import 'package:wms_android/model/produto.dart';
import '../common/comm.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({Key? key}) : super(key: key);

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(fixedSize: const Size(240, 50), textStyle: const TextStyle(fontSize: 20));
  final DataGridController _dataGridController = DataGridController();
  List<Inventario> listContagem = [];
  // double ler = 0.0;
  // double conf = 0.0;

  String enderecoLido = '';
  String caixaLido = '';
  String qtdLida = '';
  String tot = '';
  bool automatico = true;

  final fieldTextProduto = TextEditingController();
  final fieldTextCaixa = TextEditingController();
  final fieldTextEndereco = TextEditingController();
  final fieldTextQtd = TextEditingController();
  FocusNode produtoFNode = FocusNode();
  FocusNode enderecoFNode = FocusNode();
  FocusNode caixaFNode = FocusNode();
  FocusNode qtdFNode = FocusNode();

  late InventarioDataSource inventarioDataSource = InventarioDataSource(inventarioData: listContagem);

  void clearTextProduto() {
    fieldTextProduto.clear();
  }

  void focusTextProduto() {
    produtoFNode.requestFocus();
  }

  void clearTextQtd() {
    fieldTextQtd.clear();
    qtdLida = '';
  }

  void clearTextCaixa() {
    fieldTextCaixa.clear();
    focusTextCaixa();
  }

  void clearTextEndereco() {
    fieldTextEndereco.clear();
    focusTextEndereco();
  }

  void focusTextQtd() {
    qtdFNode.requestFocus();
  }

  void focusTextEndereco() {
    enderecoFNode.requestFocus();
  }

  void focusTextCaixa() {
    caixaFNode.requestFocus();
  }

  void escolheFocus() {
    if (enderecoLido.isEmpty && gFlEndereco == 'S') {
      focusTextEndereco();
    } else if (caixaLido.isEmpty && gFlEndereco == 'S') {
      focusTextCaixa();
    } else if (automatico) {
      focusTextProduto();
    } else if (qtdLida.isEmpty && !automatico) {
      focusTextQtd();
    }
  }

  @override
  void initState() {
    qtdLida = '1';
    super.initState();
  }

  void atualizaLista() {
    if (enderecoLido == "") {
      listContagem.clear();
      inventarioDataSource = InventarioDataSource(inventarioData: listContagem);
      return;
    }
    var retorno = InventarioController().getInventario(enderecoLido, caixaLido);
    {
      retorno.then((value) => {
            listContagem = value,
            //filter.sort((a, b) => a.id!.compareTo(b.id!)),
            setState(() {
              inventarioDataSource = InventarioDataSource(inventarioData: listContagem);
            }),
          });
    }
    var retorno2 = InventarioController().getTotaisInv(endereco: enderecoLido, caixa: caixaLido);
    {
      retorno2.then((value) => {
            setState(() {
              tot = 'Total ${value!.toString()}';
            }),
          });
    }
  }

  void atualizaTotal() {
    var retorno2 = InventarioController().getTotaisInv(endereco: enderecoLido, caixa: caixaLido);
    {
      retorno2.then((value) => {
            setState(() {
              tot = 'Total ${value!.toString()}';
            }),
          });
    }
  }

  void alteraQtd(int id, String qtd) {
    if (qtd == '0') {
      InventarioController().apagaId(id);
      alertDialog(context, "Apagado com sucesso");
    } else {
      double qtdCurr = double.parse(qtd);
      InventarioController().alteraId(id, qtdCurr);
      alertDialog(context, "Alterado com sucesso");
    }
    setState(() {
      atualizaLista();
    });

    Navigator.pop(context);
  }

  void apagaCaixa() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Excluir todos os produtos da caixa'),
              content: Text('Tem certeza?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('Não')),
                TextButton(
                    onPressed: () => {
                          Navigator.of(ctx).pop(true),
                        },
                    child: Text('Sim')),
              ],
            )).then((value) {
      if (value ?? false) {
        InventarioController().apagaCaixa(fieldTextCaixa.text);
        fieldTextCaixa.text = '';
        caixaLido = '';
        atualizaLista();
        atualizaTotal();
      }
    });
  }

  void apagaEndereco() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Excluir todos os produtos do endereço'),
              content: Text('Tem certeza?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('Não')),
                TextButton(
                    onPressed: () => {
                          Navigator.of(ctx).pop(true),
                        },
                    child: Text('Sim')),
              ],
            )).then((value) {
      if (value ?? false) {
        InventarioController().apagaEndereco(fieldTextEndereco.text);
        fieldTextEndereco.text = '';
        enderecoLido = '';
        atualizaLista();
        atualizaTotal();
      }
    });
  }

  void filtrar(int tipo) {
    if (tipo == 8) {
      //apaga caixa
      if (fieldTextCaixa.text.isEmpty) {
        alertDialog(context, 'Você precisa informar a caixa primeiro');
        caixaFNode.requestFocus();
      } else {
        apagaCaixa();
      }
    } else if (tipo == 9) {
      //apaga endereço
      if (fieldTextEndereco.text.isEmpty) {
        alertDialog(context, 'Você precisa informar o endereço primeiro');
        enderecoFNode.requestFocus();
      } else {
        apagaEndereco();
      }
    } else if (tipo == 2) {
      setState(() {
        automatico = !automatico;
      });
      if (automatico) {
        qtdLida = '1';
        fieldTextQtd.text = '1';
      }
    } else if (tipo == 7) {
      clearTextCaixa();
      caixaLido = '';
      focusTextCaixa();
    } else if (tipo == 1) {
      clearTextCaixa();
      clearTextEndereco();
      clearTextProduto();
      clearTextQtd();
      qtdLida = '';
      enderecoLido = '';
      caixaLido = '';
      if (gFlEndereco == 'S') {
        focusTextEndereco();
      } else {
        focusTextProduto();
      }
    } else if (tipo == 3) {
      if (gTipoServiddor != 'INFORVIX' && fieldTextEndereco.text != '') {
        if (fieldTextEndereco.text[0] != '0' && fieldTextEndereco.text[0] != '1' && fieldTextEndereco.text[0] != '2') {
          alertDialog(context, 'Endereço inválido');
          enderecoLido = '';
          fieldTextEndereco.text = '';
          enderecoFNode.requestFocus();
        }
      }
      if (gTipoServiddor != 'INFORVIX' && fieldTextCaixa.text != '') {
        RegExp regex = RegExp(r'[a-zA-Z]');
        if (!regex.hasMatch(fieldTextCaixa.text[0])) {
          alertDialog(context, 'Caixa inválida');
          caixaLido = '';
          fieldTextCaixa.text = '';
          caixaFNode.requestFocus();
        }
      }
      setState(() {
        atualizaLista();
      });
    } else {
      atualizaTotal();
      setState(() {
        inventarioDataSource = InventarioDataSource(inventarioData: listContagem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    lerProduto(String produto) async {
      fieldTextProduto.clear();
      if (produto.isEmpty) {
        alertDialog(context, 'Produto Vazio!');
        beepErro();
      }
      if (qtdLida.length > 9) {
        beepErro();
        showMensagem(context, "Quantidade muito grande", "Atenção", "OK");
        return;
      } else {
        Produto? pro = await PodutoControler().buscaProduto(produto);

        if (pro == null) {
          //alertDialog(context, "Produto não localizado!");
          if (context.mounted) {
            beepErro();
            showMensagem(context, "Produto não localizado $produto", "Atenção", "OK");
          }
          fieldTextProduto.clear();
          escolheFocus();
        } else if (qtdLida == '') {
          if (context.mounted) {
            alertDialog(context, "Informe a quantidade");
          }
          focusTextQtd();
        } else {
          beepSucesso();
          var inv = Inventario(
              proCodigo: pro.proCodigo,
              invCaixa: caixaLido,
              invEndereco: enderecoLido,
              invQuantidade: double.parse(qtdLida),
              usuCodigo: usuLogin!,
              proDescricao: pro.proDescricao);
          int id = await InventarioController().inserir(inv);
          inv.id = id;
          listContagem.insert(0, inv);
          if (automatico == false) {
            qtdLida = '';
            fieldTextQtd.clear();
          }
          escolheFocus();
          filtrar(0);
        }
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0, 40),
        child: AppBar(
          title: Text(tot),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.settings),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Limpar campos'),
                ),
                PopupMenuItem(
                  value: 7,
                  child: Text('Limpar caixa'),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(automatico ? 'Semi automático' : 'Automático'),
                ),
                if (gFlEndereco == 'S')
                  PopupMenuItem(
                    value: 8,
                    child: Text('Apagar caixa'),
                  ),
                if (gFlEndereco == 'S')
                  PopupMenuItem(
                    value: 9,
                    child: Text('Apagar endereço'),
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
            gFlEndereco == 'S'
                ? Row(children: [
                    SizedBox(
                      width: larguraDisponivel * 0.48,
                      child: TextFormField(
                          autofocus: true,
                          focusNode: enderecoFNode,
                          decoration: InputDecoration(
                            labelText: 'Endereço:',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          controller: fieldTextEndereco,
                          onChanged: (value) {
                            enderecoLido = value;
                          },
                          onFieldSubmitted: (value) => filtrar(3)),
                    ),
                    SizedBox(
                      width: larguraDisponivel * 0.48,
                      child: TextFormField(
                          autofocus: true,
                          focusNode: caixaFNode,
                          decoration: InputDecoration(
                            labelText: 'Caixa:',
                          ),
                          keyboardType: TextInputType.text,
                          controller: fieldTextCaixa,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            caixaLido = value;
                          },
                          onFieldSubmitted: (value) => filtrar(3)),
                    )
                  ])
                : SizedBox(
                    width: larguraDisponivel * 0.01,
                  ),
            Row(children: [
              automatico
                  ? SizedBox(
                      width: larguraDisponivel * 0.01,
                    )
                  : SizedBox(
                      width: larguraDisponivel * 0.48,
                      child: TextFormField(
                        autofocus: true,
                        focusNode: qtdFNode,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: fieldTextQtd,
                        onChanged: (value) {
                          qtdLida = value;
                        },
                        // onFieldSubmitted: (value) => filtrar(0)
                      ),
                    ),
              SizedBox(
                width: automatico ? larguraDisponivel * 0.95 : larguraDisponivel * 0.48,
                child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Produto',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.send,
                    controller: fieldTextProduto,
                    focusNode: produtoFNode,
                    onFieldSubmitted: (value) => lerProduto(value)),
              )
            ]),
            SizedBox(height: 10),
            SizedBox(
              height: alturaDisponivel - 120 + (gFlEndereco == 'S' ? 0 : 50),
              child: Scrollbar(
                child: SfDataGrid(
                    source: inventarioDataSource,
                    columnWidthMode: ColumnWidthMode.fill,
                    isScrollbarAlwaysShown: false,
                    shrinkWrapRows: false,
                    headerRowHeight: 28,
                    headerGridLinesVisibility: GridLinesVisibility.vertical,
                    gridLinesVisibility: GridLinesVisibility.vertical,
                    rowHeight: 30,
                    onCellLongPress: (details) {
                      var row = _dataGridController.selectedRow;
                      if (row != null) {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => Container(
                                  padding: EdgeInsets.all(15),
                                  width: larguraDisponivel,
                                  height: alturaDisponivel,
                                  color: Color.fromARGB(255, 233, 231, 116),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Alterar ou Apagar",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Releway",
                                            color: Color.fromARGB(255, 245, 20, 4),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Barra: ${row.getCells()[1].value}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Releway",
                                            color: Color.fromARGB(255, 245, 20, 4),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        row.getCells()[2].value,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Releway",
                                            color: Color.fromARGB(255, 245, 20, 4),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Quantidade: ${row.getCells()[3].value.toString()}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Releway",
                                            color: Color.fromARGB(255, 245, 20, 4),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            labelText: 'Nova Quantidade',
                                          ),
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.send,
                                          //controller: fieldTextProduto,
                                          //focusNode: produtoFNode,
                                          onFieldSubmitted: (value) => alteraQtd(row.getCells()[0].value, value)),
                                    ],
                                  ),
                                ));

                        focusTextProduto();
                      }
                    },
                    controller: _dataGridController,
                    columns: <GridColumn>[
                      GridColumn(
                          width: larguraDisponivel * 0.01,
                          columnName: 'id',
                          visible: false,
                          label: Container(
                              //padding: EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              child: Text(
                                'id',
                              ))),
                      GridColumn(
                          width: larguraDisponivel * 0.3,
                          columnName: 'proCodigo',
                          label: Container(
                              //padding: EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              child: Text(
                                'Produto',
                              ))),
                      GridColumn(
                          width: larguraDisponivel * 0.39,
                          columnName: 'proDescricao',
                          label: Container(
                              //padding: EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              child: Text(
                                'Descrição',
                              ))),
                      GridColumn(
                          width: larguraDisponivel * 0.14,
                          columnName: 'invQuantidade',
                          label: Container(
                              // padding: EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              child: Text('Quant.'))),
                      GridColumn(
                          width: larguraDisponivel * 0.14,
                          columnName: 'invCaixa',
                          label: Container(
                              //padding: EdgeInsets.all(5.0),
                              alignment: Alignment.center,
                              child: Text('Caixa'))),
                    ],
                    selectionMode: SelectionMode.single,
                    navigationMode: GridNavigationMode.row),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventarioDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  InventarioDataSource({required List<Inventario> inventarioData}) {
    _inventarioData = inventarioData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'proCodigo', value: e.proCodigo),
              DataGridCell<String>(columnName: 'proDescricao', value: e.proDescricao),
              DataGridCell<double>(columnName: 'invQuantidade', value: e.invQuantidade),
              DataGridCell<String>(columnName: 'invCaixa', value: e.invCaixa),
            ]))
        .toList();
  }

  List<DataGridRow> _inventarioData = [];

  @override
  List<DataGridRow> get rows => _inventarioData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      return Colors.orange[50]!;
    }

    TextStyle? getTextStyle() {
      return TextStyle(color: Colors.black, fontSize: 12);
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
