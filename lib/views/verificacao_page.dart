// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:wms_android/http/repository/verificacao_http_repository.dart';
import 'package:wms_android/model/verificacao.dart';

class VerificacaoPage extends StatefulWidget {
  const VerificacaoPage({super.key});

  @override
  State<VerificacaoPage> createState() => _VerificacaoPageState();
}

class _VerificacaoPageState extends State<VerificacaoPage> {
  TextEditingController caixaController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  List<VerificacaoModel> dados = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação'),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  autofocus: true,
                  controller: caixaController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black),
                    ),
                    labelText: "Caixa",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  autofocus: false,
                  controller: enderecoController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: Colors.black),
                    ),
                    labelText: "Endereço",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () async {
                    if (caixaController.text != '' &&
                        enderecoController.text != '') {
                      setState(() {
                        isLoading = true;
                      });
                      dados = await VerificacaoHttpRepository()
                          .apiGetEnderecoCaixa(caixaController.text);
                      if (dados[0].caixaEndereco != enderecoController.text) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Aviso"),
                              content: Text(
                                'Esta Caixa esta no endereço: ${dados[0].caixaEndereco}\nDeseja alterar para o endereço: ${enderecoController.text}',
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
                                      await VerificacaoHttpRepository()
                                          .apiPutAlterarEnderecoCaixa(
                                        enderecoController.text,
                                        dados[0].caixaNumero,
                                        dados[0].caixaCodigoBarras,
                                      );
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Sucesso"),
                                            content: Text(
                                              "A Caixa Foi Alterada para o Endereço: ${enderecoController.text}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            actions: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    enderecoController.clear();
                                                    caixaController.clear();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'OK',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Alterar',
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
                                      Navigator.of(context).pop();
                                      enderecoController.clear();
                                      caixaController.clear();
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
                      } else {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Verificação"),
                              content: const Text(
                                "A Caixa Esta no Endereço Correto",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      enderecoController.clear();
                                      caixaController.clear();
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'OK',
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
                      }
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Não foi digitado nenhum pedido',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Verificar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
