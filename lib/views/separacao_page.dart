// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, sort_child_properties_last, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:wms_android/controller/expedicao_controller.dart';
import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/model/expedicao.dart';
import '../common/comm.dart';
import 'package:http/http.dart' as http;

class SeparacaoPage extends StatefulWidget {
  final String? Pedido;
  SeparacaoPage({super.key, required this.Pedido});

  @override
  State<SeparacaoPage> createState() => _SeparacaoPage1State();
}

class _SeparacaoPage1State extends State<SeparacaoPage> {
  final ButtonStyle style = ElevatedButton.styleFrom(
      fixedSize: const Size(240, 50), textStyle: const TextStyle(fontSize: 20));
  final DataGridController _dataGridController = DataGridController();

  List<Expedicao> listExp = [];
  List<Expedicao> filter = [];
  late ExpedicaoDataSource expedicaoDataSource;
  String? endereco;
  String? caixa;

  String enderecoLido = '';
  String caixaLido = '';
  String qtdLida = '';
  bool automatico = true;

  final fieldTextProduto = TextEditingController();
  final fieldTextCaixa = TextEditingController();
  final fieldTextEndereco = TextEditingController();
  final fieldTextQtd = TextEditingController();
  FocusNode produtoFNode = FocusNode();
  FocusNode enderecoFNode = FocusNode();
  FocusNode caixaFNode = FocusNode();
  FocusNode qtdFNode = FocusNode();

  void clearTextProduto() {
    fieldTextProduto.clear();
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

  void focusTextProduto() {
    produtoFNode.requestFocus();
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
    super.initState();
    atualizaLista();
  }

  void atualizaLista() {
    var retorno = ExpedicaoControler().getByPedido(widget.Pedido!);
    {
      retorno.then((value) => {
            listExp = value,
            filter.addAll(listExp),
            //filter.sort((a, b) => a.id!.compareTo(b.id!)),
            expedicaoDataSource = ExpedicaoDataSource(expedicaoData: listExp),
            setState(() {
              endereco = listExp.first.exp_endereco;
              caixa = listExp.first.exp_caixa;
            }),
            filtrar(0),
          });
    }
  }

  void filtrar(int tipo) {
    if (tipo == 2) {
      setState(() {
        automatico = !automatico;
      });
      if (automatico) {
        qtdLida = '1';
        fieldTextQtd.text = '1';
      }
    } else {
      if (tipo == 1) {
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
      }

      filter = [];
      filter.addAll(listExp);
      if (tipo == 0) {
        filter.removeWhere((item) =>
            item.exp_quantidade_separada! == item.exp_quantidade_separar);
      }
      filter.sort((a, b) {
        // double cmp = (a.exp_quantidade_separada! - a.exp_quantidade_separar);

        // if (cmp == 0) {
        //   return a.id!;
        // }

        //if (a.exp_quantidade_separada != 0 &&
        //  a.exp_quantidade_separada != a.exp_quantidade_separar) {
        //return -1;
        // }

        return a.id!.compareTo(b.id!);
      });

      if (enderecoLido.isNotEmpty && caixaLido.isNotEmpty) {
        filter.retainWhere((filtrado) {
          return filtrado.exp_endereco.contains(enderecoLido.toUpperCase()) &&
              filtrado.exp_caixa.contains(caixaLido.toUpperCase());
        });
      } else if (enderecoLido.isNotEmpty) {
        filter.retainWhere((filtrado) {
          return filtrado.exp_endereco.contains(enderecoLido.toUpperCase());
        });
      } else if (caixaLido.isNotEmpty) {
        filter.retainWhere((filtrado) {
          return filtrado.exp_caixa.contains(caixaLido.toUpperCase());
        });
      }

      //verificar se todos foram lidos caixa e endereço
      var temItemLista = false;
      for (var element in filter) {
        if (element.exp_quantidade_separada != element.exp_quantidade_separar) {
          temItemLista = true;
          break;
        }
      }
      if (!temItemLista) {
        if (caixaLido.isNotEmpty) {
          caixaLido = '';
          clearTextCaixa();
          beepErro();
          //alertDialog(context, 'Não existe item na lista com essa informação');
          filtrar(0);
        } else if (enderecoLido.isNotEmpty) {
          enderecoLido = '';
          clearTextEndereco();
          beepErro();
          //alertDialog(context, 'Não existe item na lista com essa informação');
          filtrar(0);
        } else if (caixaLido.isEmpty && enderecoLido.isEmpty) {
          beepSucesso();
          alertDialog(context, 'Finalizada Separação');
        }
      }
      setState(() {
        expedicaoDataSource = ExpedicaoDataSource(expedicaoData: filter);
        if (filter.isNotEmpty) {
          endereco = filter.first.exp_endereco;
          caixa = filter.first.exp_caixa;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void lerProduto(String produto) async {
      if (produto.isEmpty) {
        beepErro();
        alertDialog(context, 'Produto Vazio!');
        clearTextProduto();
        escolheFocus();
      } else {
        filter = [];
        filter.addAll(listExp);
        filter.retainWhere((filtrado) {
          return filtrado.exp_endereco.contains(enderecoLido.toUpperCase()) &&
              filtrado.exp_caixa.contains(caixaLido.toUpperCase()) &&
              filtrado.pro_codigo.contains(produto.toUpperCase());
        });
        if (filter.isEmpty) {
          alertDialog(context, 'Produto não localizado!');
          clearTextProduto();
          focusTextProduto();
          beepErro();
        } else {
          Expedicao exp = filter[0];
          double ler = exp.exp_quantidade_separar;
          double lido = (exp.exp_quantidade_separada ?? 0.0);
          if (qtdLida == '0' || qtdLida == '') {
            qtdLida = '1';
          }
          if (ler >= (lido + double.parse(qtdLida))) {
            exp.usu_login = usuLogin;
            if (expedicaoOnline) {
              String expJson =
                  '{"exp_pedido": ${exp.exp_pedido}, "pro_codigo": ${exp.pro_codigo}, "id": ${exp.id},"exp_quantidade_separada": ${qtdLida}}';
              try {
                http.Response response = await http.put(
                  Uri.parse('$urlExpedicaoOnline/separacao-item'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: expJson,
                );
                if (response.statusCode == 200) {
                  print('Objeto Expedicao inserido com sucesso na API.');
                  atualizaLista();
                } else {
                  print(
                      'Falha ao inserir objeto Expedicao na API. Status code: ${response.statusCode}');
                }
              } catch (e) {
                print('Erro ao enviar a solicitação para a API: $e');
              }
            } else {
              Dbutil.insert('expedicao', exp.toMap());
            }

            filtrar(0);
            clearTextProduto();
            clearTextQtd();
            escolheFocus();
            beepSucesso();
          } else if (ler == lido) {
            alertDialog(context, 'Total do produto já alcançado!');
            clearTextProduto();
            escolheFocus();
            beepErro();
          } else {
            alertDialog(
                context, 'Quantidade do produto maior do que o necessário!');
            clearTextProduto();
            escolheFocus();
            beepErro();
          }
        }
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0, 40),
        child: AppBar(
          title: Text('Ped: ${widget.Pedido}'),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.settings),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Limpar campos'),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text(automatico ? 'Semi automático' : 'Automático'),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('Exibir concluídos'),
                  value: 3,
                ),
              ],
              onSelected: (int selectedValue) {
                filtrar(selectedValue);
              },
            )
          ],
        ),
      ),
      body: (endereco == null)
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                                  labelText: 'Endereço: $endereco',
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                controller: fieldTextEndereco,
                                onChanged: (value) {
                                  enderecoLido = value;
                                },
                                onFieldSubmitted: (value) => filtrar(0)),
                          ),
                          SizedBox(
                            width: larguraDisponivel * 0.48,
                            child: TextFormField(
                                autofocus: true,
                                focusNode: caixaFNode,
                                decoration: InputDecoration(
                                  labelText: 'Caixa: $caixa',
                                ),
                                keyboardType: TextInputType.text,
                                controller: fieldTextCaixa,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) {
                                  caixaLido = value;
                                },
                                onFieldSubmitted: (value) => filtrar(0)),
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
                      width: automatico
                          ? larguraDisponivel * 0.95
                          : larguraDisponivel * 0.48,
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
                    height: alturaDisponivel - 190,
                    child: Scrollbar(
                      child: SfDataGrid(
                        source: expedicaoDataSource,
                        columnWidthMode: ColumnWidthMode.fill,
                        isScrollbarAlwaysShown: false,
                        shrinkWrapRows: false,
                        headerRowHeight: 28,
                        selectionMode: SelectionMode.single,
                        navigationMode: GridNavigationMode.row,
                        onCellLongPress: (details) {
                          var row = _dataGridController.selectedRow;
                          if (row != null) {
                            fieldTextCaixa.text = row.getCells()[2].value;
                            fieldTextEndereco.text = row.getCells()[1].value;
                            fieldTextProduto.text = row.getCells()[0].value;
                            fieldTextQtd.text =
                                row.getCells()[3].value.toString();
                            enderecoLido = row.getCells()[1].value;
                            qtdLida = row.getCells()[3].value.toString();
                            caixaLido = row.getCells()[2].value;
                            focusTextProduto();
                          }
                        },
                        controller: _dataGridController,
                        headerGridLinesVisibility: GridLinesVisibility.vertical,
                        gridLinesVisibility: GridLinesVisibility.vertical,
                        rowHeight: 30,
                        columns: <GridColumn>[
                          GridColumn(
                              width: larguraDisponivel *
                                  (gFlEndereco == 'S' ? 0.32 : 0.54),
                              columnName: 'pro_codigo',
                              label: Container(
                                  //padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Produto',
                                  ))),
                          GridColumn(
                              width: larguraDisponivel * 0.16,
                              visible: gFlEndereco == 'S',
                              columnName: 'exp_endereco',
                              label: Container(
                                  // padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  child: Text('Endere.'))),
                          GridColumn(
                              width: larguraDisponivel * 0.22,
                              columnName: 'exp_caixa',
                              visible: gFlEndereco == 'S',
                              label: Container(
                                  //padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Caixa',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                          GridColumn(
                              width: larguraDisponivel *
                                  (gFlEndereco == 'S' ? 0.14 : 0.22),
                              columnName: 'exp_quantidade_separar',
                              label: Container(
                                  // padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  child: Text('Qtd'))),
                          GridColumn(
                              width: larguraDisponivel *
                                  (gFlEndereco == 'S' ? 0.14 : 0.22),
                              columnName: 'exp_quantidade_separada',
                              label: Container(
                                  //padding: EdgeInsets.all(5.0),
                                  alignment: Alignment.center,
                                  child: Text('Lido'))),
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

class ExpedicaoDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ExpedicaoDataSource({required List<Expedicao> expedicaoData}) {
    _expediaoData = expedicaoData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'pro_codigo', value: e.pro_codigo),
              DataGridCell<String>(
                  columnName: 'exp_endereco', value: e.exp_endereco),
              DataGridCell<String>(columnName: 'exp_caixa', value: e.exp_caixa),
              DataGridCell<double>(
                  columnName: 'exp_quantidade_separar',
                  value: e.exp_quantidade_separar),
              DataGridCell<double>(
                  columnName: 'exp_quantidade_separada',
                  value: e.exp_quantidade_separada),
            ]))
        .toList();
  }

  List<DataGridRow> _expediaoData = [];

  @override
  List<DataGridRow> get rows => _expediaoData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final double ler = row.getCells()[3].value;
      final double lido = row.getCells()[4].value;
      if (ler == lido) {
        return Colors.green[100]!;
      } else if (lido > 0) {
        return Colors.blue[100]!;
      } else {
        return Colors.orange[50]!;
      }
    }

    TextStyle? getTextStyle() {
      final double ler = row.getCells()[3].value;
      final double lido = row.getCells()[4].value;
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
