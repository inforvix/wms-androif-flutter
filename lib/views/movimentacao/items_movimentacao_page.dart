// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/common/components.dart';
import 'package:wms_android/model/item_transferencia_model.dart';
import 'package:wms_android/views/movimentacao/confirmar_transferencia_page.dart';

class MovimentacaoItemPage extends StatefulWidget {
  const MovimentacaoItemPage({Key? key}) : super(key: key);

  @override
  State<MovimentacaoItemPage> createState() => _MovimentacaoItemPageState();
}

class _MovimentacaoItemPageState extends State<MovimentacaoItemPage> {
  TextEditingController controllerEndereco = TextEditingController();
  TextEditingController controllerCaixaOrigem = TextEditingController();
  TextEditingController controllerCaixaDestino = TextEditingController();
  TextEditingController controllerProduto = TextEditingController();

  List<ItemTransferenciaModel> itensTransferido = [];
  final FocusNode _produtoFocusNode = FocusNode();

  void inserirItemTransferencia(
      {String? caixaOrigem, caixaDestino, enderecoDestino, codigoProduto}) {
    setState(() {
      bool itemExistente =
          itensTransferido.any((item) => item.codigoBarras == codigoProduto);

      if (!itemExistente) {
        itensTransferido.add(
          ItemTransferenciaModel(
            caixaAntiga: caixaOrigem,
            caixaDestino: caixaDestino,
            enderecoDestino: enderecoDestino,
            codigoBarras: codigoProduto,
          ),
        );
        beepSucesso();
      } else {
        beepErro();
      }
    });
  }

  @override
  void dispose() {
    _produtoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informar Itens para transferencia',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      resizeToAvoidBottomInset:
          true, // Permite que o conteúdo do Scaffold seja redimensionado para evitar a sobreposição do teclado
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  controller: controllerCaixaOrigem,
                  decoration: InputDecoration(
                    labelText: 'Caixa de Origem',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    beepSucesso();
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: controllerCaixaDestino,
                  decoration: InputDecoration(
                    labelText: 'Caixa de Destino',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    beepSucesso();
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: controllerEndereco,
                  decoration: InputDecoration(
                    labelText: 'Endereço de Destino',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    beepSucesso();
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: controllerProduto,
                  focusNode: _produtoFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Codigo de Barras Produto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    inserirItemTransferencia(
                      caixaOrigem: controllerCaixaOrigem.text,
                      caixaDestino: controllerCaixaDestino.text,
                      enderecoDestino: controllerEndereco.text,
                      codigoProduto: controllerProduto.text,
                    );
                    controllerProduto.clear();
                    _produtoFocusNode.requestFocus();
                  },
                ),
              ),
              SizedBox(height: 30),
              InforvixButton(
                onClick: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Aviso"),
                        content: Text(
                          'Deseja transferir ou manter os itens reservados?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              onTap: () async {
                                DadosGlobaisMovimentacao
                                    .transferiItemReservados = true;
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return ConfirmarTransferenciaPage(
                                      itensTransferidos: itensTransferido,
                                    );
                                  },
                                ));
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Transferir',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                DadosGlobaisMovimentacao
                                    .transferiItemReservados = false;
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return ConfirmarTransferenciaPage(
                                      itensTransferidos: itensTransferido,
                                    );
                                  },
                                ));
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Manter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: 'Conferir transferencia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
