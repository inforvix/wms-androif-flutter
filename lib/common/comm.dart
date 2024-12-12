import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:wms_android/model/usuario.dart';

String? usuLogin;
double alturaDisponivel = 0.0;
double larguraDisponivel = 0.0;
String gChaveAut = '';
String gTipoServiddor = '';
String tenant = 'Teste';
Usuario? usuarioGlobal;

class DadosGlobaisMovimentacao {
  static String importdora = '';
  static String segmentoEstoqueOrigem = '';
  static String segmentoEstoqueDestino = '';
  static String marca = '';
  static bool transferiItemReservados = false;
  static int transferenciaLogisticaId = 0;
  static String status = '';
  static String statusConsulta = '';
  static String observacao = '';
  static int statusCodeProcessar = 0;
}

String urlExpedicaoOnline = 'http://192.168.1.86:9897/v1/expedicao';
String urlBaseCliente =
    'https://app-aste-logistica-stage.azurewebsites.net/logistica/coletor';
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
      'https://app-aste-logistica-stage.azurewebsites.net/logistica/coletor';

  static String bodyEnviado = '';
  static String bodyRetornado = '';
}
