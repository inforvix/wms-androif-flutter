import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wms_android/controller/parametro_controller.dart';

import 'package:wms_android/views/home_page.dart';
import 'package:wms_android/views/parametro_page.dart';
import '../common/comm.dart';
import '../controller/usuario_controller.dart';
import '../http/http_usuario_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _isLoading = false;
  var login = '';
  var senha = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late AndroidDeviceInfo androidInfo;
  bool senhaObscura = true;

  @override
  initState() {
    super.initState();
    ParametroControler().getParametro().then((value) => {
          gChaveAut = value.par_chave_aut,
          gIp = value.par_ip,
          gTipoServiddor = value.par_tipo_serviddor,
          gFlEndereco = value.par_usa_endereco,
          expedicaoOnline = value.par_expedicao_online == 'S',
        });
    Permission.phone.request();
    Permission.phone.status.then((value) => {
          if (value.isGranted)
            {
              deviceInfo.androidInfo
                  .then((value2) => {gImei = value2.serialNumber})
            }
        });
  }

  handlePressed(String buttonName) {
    {
      if (buttonName == 'botaoSync') {
        setState(() {
          _isLoading = true;
        });
        HttpControllerUsuario().getUsers().then((value) {
          setState(() {
            _isLoading = false;
          });

          final snackBar = SnackBar(
            content: Text(
              'Sincronizado com sucesso!',
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
            action: SnackBarAction(
              textColor: Theme.of(context).colorScheme.surface,
              label: 'Aviso',
              onPressed: () {},
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }).onError((error, stackTrace) {
          setState(() {
            _isLoading = false;
          });
          alertDialog(context, "Atenção! $error".replaceAll(" Exception", ""));
        });
      } else if (buttonName == 'botaoLogin') {
        try {
          if (login.isEmpty) {
            alertDialog(context, "Por favor preencha o login");
          } else if (senha.isEmpty) {
            alertDialog(context, "Por favor preencha a senha");
          } else {
            setState(() {
              _isLoading = true;
            });
            UsuarioControler()
                .login(login.trim(), senha.trim())
                .then((value) => {
                      setState(() {
                        _isLoading = false;
                      }),
                      if (value != null)
                        {
                          usuLogin = value.usu_login,
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => MyHomePage(usu: value)),
                              (Route<dynamic> route) => false),
                        }
                      else
                        {alertDialog(context, "Login e/ou Senha inválidos")}
                    })
                .onError((error, stackTrace) => {
                      alertDialog(context,
                          "Atenção! $error".replaceAll(" Exception", "")),
                      setState(() {
                        _isLoading = false;
                      })
                    });
          }
        } finally {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 40),
        child: AppBar(
          title: const Text('Login'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.settings),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text('Configuração'),
                )
              ],
              onSelected: (int selectedValue) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return const ParametroPage();
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
      body: _isLoading
          ? Container(
              padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
              color: Colors.white,
              child: ListView(children: <Widget>[
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(
                  height: 100,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                )
              ]),
            )
          : Container(
              padding: const EdgeInsets.only(left: 40, right: 40),
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  const Center(child: Text("Versão 0.8")),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Login",
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        login = value;
                      });
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  TextFormField(
                    // autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    obscureText: senhaObscura,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      suffix: IconButton(
                        color: Colors.grey,
                        icon: Icon(senhaObscura
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => {
                          setState(() {
                            senhaObscura = !senhaObscura;
                          })
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        senha = value;
                      });
                    },
                    onFieldSubmitted: (value) {
                      handlePressed("botaoLogin");
                    },
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 1],
                        colors: [
                          Color.fromARGB(255, 109, 190, 206),
                          Color.fromARGB(255, 37, 183, 211),
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: SizedBox.expand(
                      child: TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 48,
                              width: 48,
                              child: Image.asset("assets/images/key.png"),
                            )
                          ],
                        ),
                        onPressed: () => handlePressed("botaoLogin"),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 1],
                        colors: [
                          Color.fromARGB(255, 109, 190, 206),
                          Color.fromARGB(255, 37, 183, 211),
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: SizedBox.expand(
                      child: TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              "Sincronizar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: 48,
                              width: 48,
                              child: Image.asset("assets/images/sync.png"),
                            )
                          ],
                        ),
                        onPressed: () => handlePressed("botaoSync"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
