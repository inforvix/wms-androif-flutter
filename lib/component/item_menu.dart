import 'package:flutter/material.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/views/dados_page.dart';
import 'package:wms_android/views/e_commerce_page.dart';
import 'package:wms_android/views/expedicao_page.dart';
import 'package:wms_android/views/movimentacao/movimentacao_page.dart';
import 'package:wms_android/views/parametro_page.dart';
import 'package:wms_android/views/inventario_page.dart';
import 'package:wms_android/views/recebimento_page.dart';
import 'package:wms_android/views/verificacao_page.dart';

class ItemMenu extends StatelessWidget {
  final String texto;

  const ItemMenu(this.texto, {Key? key}) : super(key: key);

  void _selecionbatTela(BuildContext context, String tela) {
    if (tela == 'Expedição') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const ExpedicaoPage();
          },
        ),
      );
    } else if (tela == 'Configuração') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const ParametroPage();
          },
        ),
      );
    } else if (tela == 'Dados') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const DadosPage();
          },
        ),
      );
    } else if (tela == 'Inventário') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const InventarioPage();
          },
        ),
      );
    } else if (tela == 'Recebimento') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const RecebimentoPage();
          },
        ),
      );
    } else if (tela == 'e-Commerce') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const EcommercePage();
          },
        ),
      );
    } else if (tela == 'Verificação') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const VerificacaoPage();
          },
        ),
      );
    } else if (tela == 'Movimentação') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return const MovimentacaoPage();
          },
        ),
      );
    } else {
      alertDialog(context, 'Sem menu configurado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selecionbatTela(context, texto),
      splashColor: Colors.blue[900],
      child: Card(
        borderOnForeground: true,
        elevation: 10,
        color: Colors.blue[500],
        shadowColor: Colors.blue[200],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Releway',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
