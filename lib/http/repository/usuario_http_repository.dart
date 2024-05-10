import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';
import '../../model/usuario.dart';

class UsuarioHttpRepository {
  Future<List<Usuario>> apiGetAllUsers() async {
    if (gTipoServiddor == 'INFORVIX') {
      var baseUrl = '$gIp/usuario';
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('inforvix:$gChaveAut'))}';
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'authorization': basicAuth});

      if (response.statusCode == 200) {
        final List<dynamic> responseMap = jsonDecode(response.body);
        return responseMap
            .map<Usuario>((resp) => Usuario.fromMap(resp))
            .toList();
      } else {
        throw Exception(response.body);
      }
    } else {
      String baseUrl = '$urlBaseCliente/usuarios';

      final response = await http.get(Uri.parse(baseUrl), headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
        //"Host": "api.omnisige.com.br",
      });

      print(response.body.toString());

      final List<dynamic> responseMap = jsonDecode(response.body);
      return responseMap.map<Usuario>((resp) => Usuario.fromMap(resp)).toList();
    }
  }
}
