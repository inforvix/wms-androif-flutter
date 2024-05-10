import 'package:http/http.dart' as http;
import 'package:wms_android/common/comm.dart';

class ImportadoraApi {
  Future<String> buscarImportadoras() async {
    Uri url = Uri.parse('$urlBaseCliente/importadoras');
    try {
      final response = await http.get(url, headers: {
        "Tenant": "$tenant",
        "Api-Key": "eaHdZp9b14wGPZQUm0p4B3Owq7JMqES5",
      });

      if (response.statusCode == 200) {
        print(response.body);
        return response.body;
      } else {
        throw Exception('Erro ao trazer informações: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção na solicitação GET: $e');
      rethrow;
    }
  }
}
