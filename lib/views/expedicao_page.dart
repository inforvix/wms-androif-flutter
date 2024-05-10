// ignore_for_file: prefer_const_constructors
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:wms_android/controller/expedicao_controller.dart';
import 'package:wms_android/http/http_expedicao_controller.dart';
import 'package:wms_android/http/http_produto_controller.dart';
import 'package:wms_android/http/repository/expedicao_http_repository.dart';
import 'package:wms_android/model/impressora.dart';
import 'package:wms_android/views/conferencia_page.dart';
import 'package:wms_android/views/separacao_page.dart';

import 'dart:convert';
import '../common/comm.dart';

class ExpedicaoPage extends StatefulWidget {
  const ExpedicaoPage({Key? key}) : super(key: key);

  @override
  State<ExpedicaoPage> createState() => _ExpedicaoPageState();
}

class _ExpedicaoPageState extends State<ExpedicaoPage> {
  bool pedidoValidado = false;
  final HttpControllerProduos controllerProdutos = HttpControllerProduos();
  @override
  void initState() {
    super.initState();
    pedidoValidado = false;
    if (impressoras.isEmpty && gTipoServiddor != 'INFORVIX') {
      ExpedicaoHttpRepository().apiGetimpressoras().then((value) => {
            impressoras
                .add(Impressora(id: 0, impressora: "Selecione uma impressora")),
            impressoras.addAll(value),
            dropdownValue = impressoras.first.impressora
          });
    }
  }

  List<Impressora> impressoras = [];
  String? dropdownValue;
  final ButtonStyle style = ElevatedButton.styleFrom(
    fixedSize: const Size(240, 50),
    textStyle: const TextStyle(fontSize: 20),
  );
  String? pedido;
  String? pedidoDigtado;
  String? volume;
  final fieldTextPedido = TextEditingController();
  FocusNode pedidoFNode = FocusNode();
  var _isLoading = false;

  void separacaoPress() {
    try {
      setState(() {
        _isLoading = true;
      });
      if (pedido != "" && pedido != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return SeparacaoPage(Pedido: pedido);
            },
          ),
        );
      } else {
        alertDialog(context, "Atenção! Está faltando o Pedido correto");
        beepErro();
        pedidoFNode.requestFocus();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void conferenciaPress() {
    try {
      setState(() {
        _isLoading = true;
      });
      if (pedido != "" && pedido != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return ConferenciaPage(Pedido: pedido);
            },
          ),
        );
      } else {
        alertDialog(context, "Atenção! Está faltando o Pedido correto");
        beepErro();
        pedidoFNode.requestFocus();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void clearTextPedido() {
      fieldTextPedido.clear();
      pedido = '';
      pedidoDigtado = '';
      pedidoValidado = false;
      pedidoFNode.requestFocus();
      setState(() {
        dropdownValue = 'Selecione uma impressora';
        _isLoading = false;
      });
    }

    apagarPedido() {
      setState(() {
        _isLoading = true;
      });
      if (pedido != "" && pedido != null) {
        ExpedicaoControler().apagaPedidoById(pedido!).then((value) => {
              alertDialog(context, 'Foram apagadas $value linhas do pedido'),
              setState(clearTextPedido),
              beepSucesso(),
              setState(() {
                _isLoading = false;
              })
            });
      } else {
        alertDialog(context, "Atenção! Está faltando o Pedido correto");
        beepErro();
      }
    }

    imprimir(String impressora) {
      if (impressora.isEmpty) {
      } else {
        ExpedicaoHttpRepository()
            .apiPutImpressao(pedido!, impressora)
            .then((value) => {
                  if (value == "true")
                    {
                      alertDialog(context, 'Impresão enviada'),
                      setState(clearTextPedido)
                    }
                  else
                    {
                      alertDialog(
                          context, 'Não foi possivel enviar a impressão')
                    }
                });
      }
    }

    void validaRetorno(String retJson, BuildContext ctx) {
      setState(() {
        _isLoading = false;
      });
      if (gTipoServiddor != 'INFORVIX') {
        var parsedJson = json.decode(retJson);
        if (parsedJson['NumeroErros'] == 0) {
          beepSucesso();
          imprimir(dropdownValue!);
        } else {
          showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                    padding: EdgeInsets.all(15),
                    width: larguraDisponivel,
                    height: alturaDisponivel,
                    color: Colors.yellow[800],
                    child: Text(
                      parsedJson['Mensagens'],
                      style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Releway',
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ));
        }
      } else {
        if (retJson == 'Sucesso') {
          beepSucesso();
        } else {
          beepErro();
          alertDialog(context, 'Não foi possível enviar a expedição');
        }
      }
    }

    exportaPedido() {
      if (gTipoServiddor != 'INFORVIX') {
        if (dropdownValue == 'Selecione uma impressora') {
          alertDialog(context, dropdownValue = 'Selecione uma impressora');
          return;
        }
        if (volume == null || volume == '') {
          alertDialog(context, 'Informe um volume');
          return;
        }
      } else {
        volume = '1';
      }
      try {
        setState(() {
          _isLoading = true;
        });
        if (pedido != "" && pedido != null) {
          ExpedicaoControler()
              .exportaPedidoById(pedido!, volume!)
              .then((value) => {validaRetorno(value, context)});
        } else {
          alertDialog(context, "Atenção! Está faltando o Pedido correto");
          beepErro();
        }
      } catch (e) {
        throw Exception(e.toString());
      }
    }

    void limparPress() {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Excluir pedido'),
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
          apagarPedido();
        }
      });
    }

    void exportaPress() {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Exportar pedido'),
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
          exportaPedido();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expedição')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Form(
            child: ListView(
          children: [
            TextFormField(
                autofocus: true,
                focusNode: pedidoFNode,
                style: TextStyle(color: Colors.black, fontSize: 30),
                decoration: const InputDecoration(
                  labelText: 'Pedido',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.send,
                controller: fieldTextPedido,
                onChanged: (value) {
                  pedidoDigtado = value;
                  pedido = '';
                  setState(() {
                    pedidoValidado = false;
                    dropdownValue = 'Selecione uma impressora';
                  });
                },
                onFieldSubmitted: (value) async {
                  if (value.isEmpty) {
                    alertDialog(context, 'Preencha o pedido');
                    beepErro();
                    clearTextPedido();
                  } else {
                    pedido = value;
                    pedidoDigtado = value;
                    setState(() {
                      _isLoading = true;
                    });
                    await controllerProdutos.getProducts(pedido: value);
                    HttpControllerExpedicao().getExpedicao(value).then((value) {
                      pedido = pedidoDigtado;
                      setState(() {
                        pedidoValidado = true;
                        _isLoading = false;
                      });
                      final snackBar = SnackBar(
                        content: Text(
                          'Expedição sincronizada com $value itens!',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                        action: SnackBarAction(
                          textColor: Theme.of(context).colorScheme.surface,
                          label: 'Aviso',
                          onPressed: () {},
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }).onError((error, stackTrace) {
                      pedido = '';
                      alertDialog(context,
                          "Atenção! $error".replaceAll(" Exception", ""));
                      beepErro();
                      clearTextPedido();
                    });
                  }
                }),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const SizedBox(
                        height: 25,
                      ),
                      ElevatedButton(
                        style: style,
                        onPressed: pedidoValidado ? separacaoPress : null,
                        child: Text(
                          'Separar',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: style,
                        onPressed: pedidoValidado ? conferenciaPress : null,
                        child: const Text('Conferir'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      gTipoServiddor != 'INFORVIX'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                        //style:TextStyle(color: Colors.black, fontSize: 30),
                                        decoration: const InputDecoration(
                                          hintText: 'Volume',
                                          // labelText: '',
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          volume = value;
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: dropdownValue,
                                      icon: const Icon(Icons.print_outlined),
                                      elevation: 15,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      underline: Container(
                                        height: 0,
                                        color: Colors.blue,
                                      ),
                                      onChanged: (String? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          dropdownValue = value!;
                                        });
                                      },
                                      items: impressoras
                                          .map<DropdownMenuItem<String>>(
                                              (Impressora imperssoras) {
                                        return DropdownMenuItem<String>(
                                          value: imperssoras.impressora,
                                          child: Text(imperssoras.impressora),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ])
                          : const SizedBox(
                              height: 20,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: style,
                        onPressed: pedidoValidado ? exportaPress : null,
                        child: const Text('Exportar'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: style,
                        onPressed: pedidoValidado ? limparPress : null,
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
          ],
        )),
      ),
    );
  }
}
