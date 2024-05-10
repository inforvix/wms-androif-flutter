import 'package:flutter/cupertino.dart';
import 'package:wms_android/model/parametro.dart';

import '../do/db_util.dart';

class ParametroControler with ChangeNotifier {
  void salvarParametro(Parametro par) {
    Dbutil.deleteAll('parametro');
    Dbutil.insert('parametro', par.toMap());
    notifyListeners();
  }

  Future<Parametro> getParametro() async {
    Parametro par = Parametro(
        par_chave_aut: '',
        par_tipo_serviddor: '',
        par_ip: '',
        par_usa_endereco: '',
        par_recebimento_cego: '',
        par_expedicao_online: '');
    await Dbutil.getOneRowOr('parametro', [], [], '').then((value) {
      if (value != null) {
        par = Parametro.fromMap(value);
      } else {
        par.par_chave_aut = 'Inforvix.123';
        par.par_ip = 'http://192.168.0:9000';
        par.par_recebimento_cego = 'N';
        par.par_tipo_serviddor = 'INFORVIX';
        par.par_usa_endereco = 'S';
        par.par_expedicao_online = 'N';
        Dbutil.insert('parametro', par.toMap());
      }
    });
    return par;
  }
}
