import 'package:wms_android/do/db_util.dart';
import 'package:wms_android/model/usuario.dart';

import '../controller/usuario_controller.dart';
import 'repository/usuario_http_repository.dart';

class HttpControllerUsuario {
  Future<void> getUsers() async {
    try {
      UsuarioControler().inserirUsu(Usuario(
          usu_nome: 'Henrique',
          usu_login: 'H',
          usu_senha: 'H',
          usu_ativo: 'A'));

      final dados = await UsuarioHttpRepository().apiGetAllUsers();
      print(dados);
      List<Map<String, dynamic>> data = [];

      for (var usu in dados) {
        if (usu.usu_login.isNotEmpty) {
          //UsuarioControler().inserirUsu(usu);
          data.add(usu.toMap());
        }
      }
      Dbutil.batcInsert('USUARIO', data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
