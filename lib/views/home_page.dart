import 'package:flutter/material.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/component/item_menu.dart';
import 'package:wms_android/model/usuario.dart';

class MyHomePage extends StatefulWidget {
  final Usuario usu;
  const MyHomePage({Key? key, required this.usu}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  get login => widget.usu.usu_nome;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: Text('Bem vindo $login'));
    alturaDisponivel = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    larguraDisponivel = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left +
        MediaQuery.of(context).padding.right;
    return Scaffold(
        appBar: appBar,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/fundo.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GridView(
              padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: const <Widget>[
                ItemMenu('Expedição'),
                ItemMenu('Recebimento'),
                ItemMenu('Inventário'),
                ItemMenu('Movimentação'),
                ItemMenu('e-Commerce'),
                //ItemMenu('Vendas'),
                ItemMenu('Dados'),
                ItemMenu('Configuração'),
                ItemMenu('Verificação')
              ],
            ),
          ],
        ));
  }
}
