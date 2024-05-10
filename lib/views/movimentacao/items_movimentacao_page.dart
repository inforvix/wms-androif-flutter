// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
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
      itensTransferido.add(
        ItemTransferenciaModel(
          caixaAntiga: caixaOrigem,
          caixaDestino: caixaDestino,
          enderecoDestino: enderecoDestino,
          codigoBarras: codigoProduto,
        ),
      );
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return ConfirmarTransferenciaPage(
                        itensTransferidos: itensTransferido,
                      );
                    },
                  ));
                },
                title: 'Confirmar transferencia',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
