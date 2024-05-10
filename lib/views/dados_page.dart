// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wms_android/controller/inventario_controller.dart';
import 'package:wms_android/http/http_inventario_controller.dart';
import 'package:wms_android/http/http_produto_controller.dart';
import 'package:wms_android/http/repository/poduto_http_repository.dart';
import 'package:wms_android/model/marca.dart';
import '../common/comm.dart';
import '../controller/produto_controller.dart';

class DadosPage extends StatefulWidget {
  const DadosPage({Key? key}) : super(key: key);

  @override
  State<DadosPage> createState() => _DadosPageState();
}

class _DadosPageState extends State<DadosPage> {
  final HttpControllerProduos controller = HttpControllerProduos();
  TextEditingController pedidoController = TextEditingController();
  List<Marca> marcas = [];
  String? dropdownValue;
  bool _isLoading = false;
  String totProdutos = '';
  String totContado = '';
  String totInventario = '';
  @override
  void initState() {
    super.initState();
    totalItens();
    if (marcas.isEmpty && gTipoServiddor != 'INFORVIX') {
      ProdutoHttpRepository().apiGetMarcas().then((value) => {
            marcas.add(Marca(nomeMarca: "Selecione uma marca para atualizar")),
            marcas.addAll(value),
            setState(() {
              dropdownValue = marcas.first.nomeMarca;
            })
          });
    }
  }

  final ButtonStyle style = ElevatedButton.styleFrom(
    fixedSize: const Size(240, 50),
    textStyle: const TextStyle(
      fontSize: 20,
    ),
    backgroundColor: Colors.blue,
  );

  final ButtonStyle styleApagar = ElevatedButton.styleFrom(
    fixedSize: const Size(240, 50),
    textStyle: const TextStyle(
      fontSize: 20,
    ),
    backgroundColor: Colors.red,
  );
  void totalItens() {
    PodutoControler().getQtdProduto().then((value) => {
          setState(() {
            totProdutos = 'Produtos $value';
          })
        });
    var retorno2 = InventarioController().getTotaisInv();
    {
      retorno2.then((value) => {
            setState(() {
              totContado = 'Total Contado ${value!.toString()}';
            }),
          });
    }
  }

  Future<void> fetchDataProdutos() async {
    try {
      // Obter dados de uma fonte externa

      setState(() {
        _isLoading = true;
      });
      Wakelock.enable();
      if (gTipoServiddor != 'INFORVIX') {
        if (dropdownValue == 'Selecione uma marca para atualizar') {
          showMensagem(context, 'Selecione uma Marca para baixar produtos',
              'Atenção', 'Ok');
          return;
        } else {
          await controller.getProducts(marca: dropdownValue!);
        }
      } else {
        await controller.getProducts();
      }
      //.then((value) =>
    } catch (e) {
      // Exibir uma mensagem de erro personalizada para o usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Ocorreu um erro: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      //alertDialog(context, "Produtos importados");
      totalItens();
      Wakelock.disable();
    }
  }

  Future<void> fetchDataProdutosPorPedido() async {
    try {
      setState(() {
        _isLoading = true;
      });
      Wakelock.enable();
      if (gTipoServiddor != 'INFORVIX') {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("ATENÇÃO"),
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      "Informe o numero do Pedido",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: TextFormField(
                        autofocus: false,
                        controller: pedidoController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                          labelText: "Pedido",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () async {
                      if (pedidoController.text == '') {
                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            'Não foi digitado nenhum pedido',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        await controller.getProducts(
                          pedido: pedidoController.text,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'BUSCAR PRODUTOS',
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
                  padding: const EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'CANCELAR',
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
        await controller.getProducts();
      }
      //.then((value) =>
    } catch (e) {
      // Exibir uma mensagem de erro personalizada para o usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Ocorreu um erro: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      //alertDialog(context, "Produtos importados");
      totalItens();
      Wakelock.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados')),
      body: _isLoading
          ? Container(
              padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
              color: Colors.white,
              child: ListView(children: <Widget>[
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.asset('assets/images/aguarde.png'),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(
                  height: 50,
                ),
                ValueListenableBuilder<int>(
                  valueListenable: controller.pagina,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text(
                        '${controller.pagina.value * 1000} Produtos Importados ',
                        textAlign: TextAlign.center);
                  },
                ),
              ]),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Form(
                  child: ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  gTipoServiddor != 'INFORVIX'
                      ? Column(
                          //flex: 2,
                          //child:
                          children: [
                              DropdownButton<String>(
                                //isExpanded: true,
                                value: dropdownValue,
                                icon: const Icon(
                                    Icons.wifi_protected_setup_rounded),
                                elevation: 15,
                                style: const TextStyle(color: Colors.black),
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
                                items: marcas.map<DropdownMenuItem<String>>(
                                    (Marca marcas) {
                                  return DropdownMenuItem<String>(
                                    value: marcas.nomeMarca,
                                    child: Text(marcas.nomeMarca!),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 15)
                            ])
                      : SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: style,
                          onPressed: fetchDataProdutos,
                          child: Text(
                            'Busca Produtos',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: style,
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            HttpControllerInventario()
                                .postContagens()
                                .then((value) => {
                                      if (value)
                                        {
                                          alertDialog(context,
                                              "Enviado com sucesso! Agora você pode apagar a contagem"),
                                        }
                                      else
                                        {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Container(
                                                    padding: EdgeInsets.all(15),
                                                    width: larguraDisponivel,
                                                    height: alturaDisponivel,
                                                    color: Colors.yellow[800],
                                                    child: Text(
                                                      'Error ao enviar contagem',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'Releway',
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ))
                                        }
                                    });
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: Text(
                            'Envia Inventário',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        totProdutos,
                        textAlign: TextAlign.center,
                      )),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(totContado, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: style,
                          onPressed: fetchDataProdutosPorPedido,
                          child: Text(
                            'Busca Produtos por Pedido',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: styleApagar,
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            PodutoControler()
                                .apagaProduto()
                                .then((value) => setState(() {
                                      _isLoading = false;
                                      alertDialog(context, "Produtos apagados");
                                      totalItens();
                                    }));
                          },
                          child: Text(
                            'Apaga Produtos',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: styleApagar,
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            InventarioController().apagaTudo();
                            setState(() {
                              _isLoading = false;
                              alertDialog(context, "Inventário apagado");
                              totalItens();
                            });
                          },
                          child: Text(
                            'Apaga Inventário',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: styleApagar,
                          onPressed: null,
                          child: Text(
                            'Apaga Expedição',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: styleApagar,
                          onPressed: null,
                          child: Text(
                            'Apaga Recebimento',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            ),
    );
  }
}
