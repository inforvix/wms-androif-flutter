import 'package:flutter/cupertino.dart';
import 'package:wms_android/do/db_util.dart';
import '../model/usuario.dart';

class UsuarioControler with ChangeNotifier {
  void inserirUsu(Usuario usu) {
    Dbutil.insert('usuario', {
      'USU_NOME': usu.usu_nome,
      'USU_LOGIN': usu.usu_login,
      'USU_SENHA': usu.usu_senha,
      'USU_ATIVO': usu.usu_ativo
    });
    notifyListeners();
  }

  Future<List<Usuario>> loadUsu() async {
    final usuList = await Dbutil.getData('usuario');
    return usuList
        .map(
          (usu) => Usuario(
              usu_nome: usu['USU_NOME'],
              usu_login: usu['USU_LOGIN'],
              usu_senha: usu['USU_SENHA'],
              usu_ativo: usu['USU_ATIVO']),
        )
        .toList();
  }

  Future<Usuario?> login(String usuario, String senha) async {
    final usu = await Dbutil.login(usuario, senha);
    return usu;
  }
}
