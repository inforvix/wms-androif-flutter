// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:wms_android/model/parametro.dart';
import '../common/comm.dart';
import '../controller/parametro_controller.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class ParametroPage extends StatefulWidget {
  const ParametroPage({Key? key}) : super(key: key);

  @override
  State<ParametroPage> createState() => _ParametroPageState();
}

final fieldTextServidor = TextEditingController();
FocusNode servidorFNode = FocusNode();
final fieldTextChave = TextEditingController();
FocusNode chaveFNode = FocusNode();
final fieldTextIp = TextEditingController();
FocusNode ipFNode = FocusNode();

class _ParametroPageState extends State<ParametroPage> {
  bool _switchValue = false;
  bool _switchCego = false;
  bool _switchExpedicaoOnline = false;
  // SharedPreferences _prefs;
  @override
  void initState() {
    super.initState();
    ParametroControler().getParametro().then((value) => {
          tipo = fieldTextServidor.text = value.par_tipo_serviddor,
          chave = fieldTextChave.text = value.par_chave_aut,
          ip = fieldTextIp.text = value.par_ip,
          flEndereco = value.par_usa_endereco,
          flCego = value.par_recebimento_cego,
          flExpedicaoOnline = value.par_expedicao_online,
          setState(() {
            _switchValue = flEndereco == 'S';
            _switchCego = flCego == 'S';
            _switchExpedicaoOnline = flExpedicaoOnline == 'S';
          })
        });
  }

  String chave = '';
  String tipo = '';
  String ip = '';
  String flEndereco = '';
  String flCego = '';
  String flExpedicaoOnline = '';
  final ButtonStyle style = ElevatedButton.styleFrom(
      fixedSize: const Size(240, 50), textStyle: const TextStyle(fontSize: 20));

  void _handleSwitch(bool value) {
    setState(() {
      _switchValue = value;
      value == true ? flEndereco = 'S' : flEndereco = 'N';
    });
  }

  void _handleSwitchCego(bool value) {
    setState(() {
      _switchCego = value;
      value == true ? flCego = 'S' : flCego = 'N';
    });
  }

  void _handleSwitchExpedicaoOnline(bool value) {
    setState(() {
      _switchExpedicaoOnline = value;
      value == true ? flExpedicaoOnline = 'S' : flExpedicaoOnline = 'N';
    });
  }

  @override
  Widget build(BuildContext context) {
    salvar() {
      Parametro p = Parametro(
          par_chave_aut: chave,
          par_tipo_serviddor: tipo,
          par_ip: ip,
          par_usa_endereco: flEndereco,
          par_recebimento_cego: flCego,
          par_expedicao_online: flExpedicaoOnline);
      ParametroControler().salvarParametro(p);
      gTipoServiddor = tipo;
      gChaveAut = chave;
      gIp = ip;
      gFlEndereco = flEndereco;
      alertDialog(context, 'Salvo com sucesso!');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Parâmetro')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Form(
            child: ListView(
          children: [
            TextFormField(
              autofocus: true,
              controller: fieldTextChave,
              focusNode: chaveFNode,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Chave de Autenticação',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                chave = value;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              //controller: fieldTextPedido,
            ),
            TextFormField(
              autofocus: true,
              controller: fieldTextServidor,
              focusNode: servidorFNode,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'Tipo Servidor',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                tipo = value;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              //controller: fieldTextPedido,
            ),
            TextFormField(
              autofocus: true,
              controller: fieldTextIp,
              focusNode: ipFNode,
              style: TextStyle(color: Colors.black, fontSize: 15),
              decoration: const InputDecoration(
                labelText: 'IP',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                ip = value;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              //controller: fieldTextPedido,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Usar Endereçamento",
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                Switch(
                  value: _switchValue,
                  onChanged: _handleSwitch,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Recebimento Cego",
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                Switch(
                  value: _switchCego,
                  onChanged: _handleSwitchCego,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text("Expedição online",
                    style: TextStyle(color: Colors.black, fontSize: 15)),
                Switch(
                  value: _switchExpedicaoOnline,
                  onChanged: _handleSwitchExpedicaoOnline,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // const SizedBox(
                //   height: 25,
                // ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: style,
                  onPressed: salvar,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
