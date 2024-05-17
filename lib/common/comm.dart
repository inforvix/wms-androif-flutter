import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_beep/flutter_beep.dart';

String? usuLogin;
double alturaDisponivel = 0.0;
double larguraDisponivel = 0.0;
String gChaveAut = '';
String gTipoServiddor = '';
String tenant = 'Teste';

class DadosGlobaisMovimentacao {
  static String importdora = 'ASTE';
  static String segmentoEstoqueOrigem = '1';
  static String segmentoEstoqueDestino = '1';
  static String marca = '00003';
}

String urlExpedicaoOnline = 'http://192.168.1.86:9897/v1/expedicao';
String urlBaseCliente =
    'https://app-aste-logistica-prod-pre.azurewebsites.net/logistica/coletor';
String gIp = '';
String gImei = '';
String gFlEndereco = '';
bool expedicaoOnline = false;

alertDialog(BuildContext context, String msg) {
  if (context.mounted) {
    ToastContext().init(context);
    Toast.show(msg, duration: Toast.lengthLong, gravity: Toast.top);
  }
}

showMensagem(BuildContext context, String msg, caption, buttonText) {
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(caption),
        content: Text(msg),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

beepErro() {
  FlutterBeep.beep(false);
  Future.delayed(const Duration(milliseconds: 400))
      .then((value) => {FlutterBeep.beep(false)});
}

beepSucesso() {
  FlutterBeep.beep();
}

class DadosGlobais {
  static const urlApiCliente =
      'https://app-aste-logistica-prod-pre.azurewebsites.net/logistica/coletor';
}
