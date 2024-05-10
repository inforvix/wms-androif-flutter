// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:wms_android/controller/recebimento_controller.dart';
import 'package:wms_android/http/http_produto_controller.dart';
import 'package:wms_android/http/http_recebimento_controller.dart';
import 'package:wms_android/views/confere_recebimento_page.dart';
// import 'package:wms_android/http/repository/recebimento_http_repository.dart';

import 'dart:convert';
import '../common/comm.dart';

class RecebimentoPage extends StatefulWidget {
  const RecebimentoPage({Key? key}) : super(key: key);

  @override
  State<RecebimentoPage> createState() => _RecebimentoPageState();
}

class _RecebimentoPageState extends State<RecebimentoPage> {
  bool pedidoValidado = false;
  final HttpControllerProduos controllerProdutos = HttpControllerProduos();
  @override
  void initState() {
    super.initState();
    pedidoValidado = false;
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
      fixedSize: const Size(240, 50), textStyle: const TextStyle(fontSize: 20));
  String? pedido;
  String? pedidoDigtado;
  final fieldTextPedido = TextEditingController();
  FocusNode pedidoFNode = FocusNode();
  var _isLoading = false;

  void conferenciaPress() {
    try {
      setState(() {
        _isLoading = true;
      });
      if (pedido != "" && pedido != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return ConfereRecebimentoPage(Pedido: pedido);
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
    }

    apagarPedido() {
      setState(() {
        _isLoading = true;
      });
      if (pedido != "" && pedido != null) {
        RecebimentoController().apagaPedidoById(pedido!).then((value) => {
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

    void validaRetorno(String retJson, BuildContext ctx) {
      setState(() {
        _isLoading = false;
      });
      if (gTipoServiddor != 'INFORVIX') {
        var parsedJson = json.decode(retJson);
        if (parsedJson['NumeroErros'] == 0) {
          beepSucesso();
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
      try {
        setState(() {
          _isLoading = true;
        });
        if (pedido != "" && pedido != null) {
          RecebimentoController()
              .exportaPedidoById(pedido!)
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
      appBar: AppBar(title: const Text('Recebimento')),
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
                    HttpControllerRecebimento()
                        .getRecebimento(value)
                        .then((value) {
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
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: style,
                        onPressed: pedidoValidado ? conferenciaPress : null,
                        child: const Text('Conferir'),
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
